#!/usr/local/bin/python

import sys 
import time
import os
import json
import requests
import ccauth
import logging
import logging.handlers
import traceback
import socket
import ctypes
import xmltodict
import threading
from datetime import datetime
from ipaddress import ip_network
from concurrent import futures
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
from azure.mgmt.resource import ResourceManagementClient
from azure.mgmt.compute import ComputeManagementClient
from azure.mgmt.network import NetworkManagementClient

CRYPTO_LIB = '/mps/lib/libmps_crypto.so'
AGENT_CONFIG_FILE = '/mpsconfig/agent.conf'
MPS_DB_SERVER_KEY_FILE = "/mpsconfig/db_key.conf"


log_file_name_local = os.path.basename(__file__)
LOG_FILENAME = '/var/mps/log/' + log_file_name_local + '.log'

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)
logging.getLogger("boto3").setLevel(logging.WARNING)
logging.getLogger("botocore").setLevel(logging.WARNING)

logger_handler = logging.handlers.RotatingFileHandler(LOG_FILENAME, maxBytes=100000, backupCount=20)
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger_handler.setFormatter(formatter)
logger.addHandler(logger_handler)

def waitfor(seconds=2, reason=None):
    if reason is not None:
        logger.info(f"Waiting for {seconds} seconds. Reason: {reason}")
    else:
        logger.info("Waiting for {seconds} seconds")
    time.sleep(seconds)

def load_agent_trust():
    logger.info(f"Getting trust_info to talk to ADM service")
    try:
        key = get_encryption_key()
        with open("/mpsconfig/trust/.ssh/private.pem", "r") as private_pem_file:
            private_pem = private_pem_file.read()
            private_pem_file.close()
        with open(AGENT_CONFIG_FILE, "r") as agent_conf_file:
            agent_file_contents = agent_conf_file.read()
            agent_conf_file.close()
        agent_conf_dict = xmltodict.parse(agent_file_contents)['mps_agent']
        trust_info = {
            "agentid": agent_conf_dict['uuid'],
            "instanceid": decrypt(agent_conf_dict['instanceid'], key).decode(),
            "customerid": decrypt(agent_conf_dict['customerid'], key).decode(),
            "servicename": decrypt(agent_conf_dict['servicename'], key).decode(),
            "serviceurl": agent_conf_dict["msg_router_url"],
            "privatekey": private_pem,
            "environment_id": agent_conf_dict['environment_id']
        }
        logger.info(f"Successfully fetched agent trust info")
        return trust_info
    except Exception as e:
        raise ValueError(f"Failed to retreive trust_info. Reason: {str(e)}")

def get_encryption_key():
    logger.info("Getting encryption key for agent conf")
    try:
        with open(MPS_DB_SERVER_KEY_FILE, "r+") as db_server_key:
            content = db_server_key.read()
            db_server_key.close()
        DB_SERVER_DICT = xmltodict.parse(content)['dbserverkey']
        key = DB_SERVER_DICT['key']
        logger.info("Successfully retreived encryption key")
        return key
    except Exception as e:
        raise ValueError(f"Failed to retreive encryption key. Reason: {str(e)}")
        
def decrypt(rawData, key):
    try:
        lib = ctypes.cdll.LoadLibrary(CRYPTO_LIB)
        lib.decrypt_str.argtypes = (ctypes.c_char_p, ctypes.c_char_p, ctypes.POINTER(ctypes.c_char_p),)
        if type(key) != bytes:
            key = key.encode('utf-8')
        if rawData != None and type(rawData) != bytes:
            rawData = rawData.encode('utf-8')
        c_key = ctypes.c_char_p(key)
        c_str = ctypes.c_char_p(rawData)
        res = ctypes.c_char_p()
        lib.decrypt_str(c_key, c_str, ctypes.byref(res))
        data = res.value
        return data
    except Exception as e:
        raise ValueError(f"Decryption failure: {str(e)}")

def generate_cwc_servicekey_header(url, trust_info):
    logger.info(f"Generating servicekey header for {url}")
    try:
        request_info = ccauth.RequestInfo(method = ccauth.RequestMethod.GET, uri=url)
        
        handle = ccauth.CCAuthHandle(ccauth.ConfigurationOptions(
            service_name=trust_info["servicename"],
            service_instance=trust_info["instanceid"],
            private_key=trust_info["privatekey"],
        ))

        service_key = handle.create_servicekey(request_info, ccauth.SigningAlgorithm.DEFAULT)
        header = {"Authorization": f"CWSAuth service={service_key}"}
        logger.info("Successfully generated CC servicekey header")
        return header
    except ccauth.CCAuthException as ce:
        raise ValueError(f"Hit CCAuthException {str(ce)}")
    except Exception as e:
        raise ValueError(f"Failed to generate servicehey header. Reason: {str(e)}")
    
def do_request(method, url, data=None, headers=None, response_json=True, trust_info=None, retries=3, timeout=(5,60)):
    error = ""
    logger.debug(f"do_request method={method}  url={url}  data={data}  retries={retries}")
    for attempt in range(retries+1):
        if attempt:
            waitfor(seconds=min(40,pow(2,attempt)), reason="Waiting before retrying http request")
        try:
            if trust_info:
                headers = {} if headers is None else headers
                headers.update(generate_cwc_servicekey_header(url, trust_info))
            response = requests.request(method, url=url, json=data, headers=headers, timeout=timeout)
            logger.debug(f"response status={response.status_code}  text={response.text} attempt={attempt}")
            if response.ok:
                if not response.text:
                    return None
                if not response_json:
                    return response.text
                try:
                    result = json.loads(response.text)
                    return result
                except json.decoder.JSONDecodeError:
                    logger.error(f"do_request method={method}  url={url}  data={data} response={response.text} attempt={attempt} failed. Reason: JSONDecodeError")
                    error = "JSONDecodeError"
                    pass
            else:
                logger.error(f"do_request method={method}  url={url}  data={data} response={response.reason},{response.text} status={response.status_code} attempt={attempt} failed.")
                error = response.text
        except Exception as e:
            logger.error(f"do_request method={method}  url={url}  data={data} attempt={attempt} failed. Reason: {str(e)}")
            error = str(e)
            pass
    raise ValueError(f"request url={url} method={method} failed. Reason: {error}")
    
class HTTPNitro:
    def __init__(self, nsip, nsuser="nsroot", nspass="nsroot"):
        self.nsip = nsip
        self.nsuser = nsuser
        self.nspass = nspass
        self.timeout = (5,60)

        self.headers = {}
        self.headers["Content-Type"] = "application/json"
        self.headers["X-NITRO-USER"] = self.nsuser
        self.headers["X-NITRO-PASS"] = self.nspass

    def construct_url(self, resource, id=None, action=None):
        # Construct basic get url
        url = f"http://{self.nsip}/nitro/v1/config/{resource}"

        # Append resource id
        if id is not None:
            url = f"{url}/{id}"

        # Append action
        if action is not None:
            url = f"{url}?action={action}"

        return url

    def hide_sensitive_data(self, data):
        for k, v in data.items():
            if k in ["password", "new_password"]:
                data[k] = "********"
            elif isinstance(v, dict):
                self.hide_sensitive_data(v)

    def do_request(self, resource, method, id=None, action=None, data=None, retries=3, headers=None):
        url = self.construct_url(resource, id, action)
        return do_request(url=url, method=method, data=data, retries=retries, headers=headers, timeout=self.timeout)

    def do_request_stat(self, resource, retries=3):
        url = f"http://{self.nsip}/nitro/v1/stat/{resource}"
        return do_request(url=url, method="GET", data=None, retries=retries, headers=self.headers, timeout=self.timeout)

    def change_default_password(self, new_pass):
        logger.info("Changing the default password")
        headers = {"Content-Type": "application/json"}
        payload = {
            "login": {
                "username": self.nsuser,
                "password": self.nspass,
                "new_password": new_pass
            }
        }
        self.do_request(resource="login", method="POST", data=payload, headers=headers, retries=5)
        self.nspass = new_pass
        self.headers["X-NITRO-PASS"] = self.nspass
        logger.info("Successfully changed default password")

    def check_connection(self):
        logger.info(f"Checking connection to {self.nsip}")
        headers = {"Content-Type": "application/json"}
        payload = {"login": {"username": self.nsuser, "password": self.nspass}}
        try:
            self.do_request(resource="login", method="POST", data=payload, headers=headers, retries=0)
            logger.info(f"Connection to {self.nsip} successful")
            return True
        except Exception as e:
            logger.error(f"Node {self.nsip} is not reachable. Reason:{str(e)}")
            return False
        
    def do_get(self, resource, id=None, action=None):
        return self.do_request(resource=resource, method="GET", id=id, action=action, headers=self.headers)

    def do_post(self, resource, data, id=None, action=None):
        return self.do_request(resource=resource, method="POST", id=id, action=action, data=data, headers=self.headers)

    def do_put(self, resource, data, id=None, action=None):
        return self.do_request(resource=resource, method="PUT", id=id, action=action, data=data, headers=self.headers)

    def do_delete(self, resource, id=None, action=None):
        return self.do_request(resource=resource, method="DELETE", id=id, action=action, headers=self.headers)

    def wait_for_reachability(self, max_time=120):
        logger.info(f"Waiting for {self.nsip} to be reachable. Max wait time = {max_time} seconds")
        wait_till = time.time() + max_time

        url = self.construct_url(resource="login")

        headers = {}
        headers["Content-Type"] = "application/json"
        payload = {"login": {"username": self.nsuser, "password": self.nspass}}
        while time.time() < wait_till:
            try:
                logger.debug(f"request: URL={url}")
                response = do_request(url=url, method='POST', data=payload, retries=0, headers=headers) 

                if (response["severity"] != "ERROR"
                    or "ForcePasswordChange is enabled" in response["message"]):
                    logger.info(f"{self.nsip} is now reachable")
                    return
                waitfor(5, "Waiting to make sure the packet engine is UP")
            except Exception as e:
                logger.info(f"Node {self.nsip} is not yet reachable. Reason:{str(e)}")
                waitfor(5, "Waiting before retrying connection")
        logger.error(f"{self.nsip} is not reachable")
        raise ValueError(f"{self.nsip} is not reachable")

class CitrixADC(HTTPNitro):
    def __init__(self, nsip, nsuser="nsroot", nspass="nsroot"):
        super().__init__(nsip=nsip, nsuser=nsuser, nspass=nspass)

    def get_clip(self):
        logger.info(f"Trying to get the CLIP of the cluster from node {self.nsip}")
        try:
            result = self.do_get(resource="nsip?filter=type:CLIP")
            for ip_dict in result["nsip"]:
                if ip_dict["type"] == "CLIP":
                    logger.info(f"Successfully fetched CLIP {ip_dict['ipaddress']} from {self.nsip}")
                    return ip_dict["ipaddress"]
            logger.error(f"Could not fetch the CLIP of the cluster from node {self.nsip}")
            return False
        except Exception as e:
            logger.error(f"Could not fetch the CLIP of the cluster from node {self.nsip}. Reason: {str(e)}")
            return False

    def get_cluster_nodes(self):
        logger.info(f"Getting the nodes in the cluster")
        try:
            result = self.do_get(resource="clusternode")
            logger.info(f"Fetched cluster nodes: {result['clusternode']}")
            return result["clusternode"]
        except Exception as e:
            logger.error(f"Failed to fetch the clusternodes. Reason: {str(e)}")
            return []
  
    def get_cluster_node_id(self, node_ip=None):
        if not node_ip:
            node_ip = self.nsip
        logger.info(f"Trying to get the cluster node-id of {node_ip}")
        try:
            result = self.do_get(resource="clusternode")
            nodes = result["clusternode"]
            for node in nodes:
                if node["ipaddress"] == node_ip:
                    logger.info(f"Successfully fetched cluster node id {node['nodeid']}")
                    return node["nodeid"]
            logger.error(f"Cloud not fetch the cluster node-id")
            return -1
        except Exception as e:
            logger.error(f"Faied to fetch the cluster node-id. Reason {str(e)}")
            return -1

    def add_cluster_instance(self, instID):
        logger.info(f"Adding cluster instance {instID} on node {self.nsip}")
        data = {
            "clusterinstance": {
                "clid": str(instID),
            }
        }
        self.do_post(resource="clusterinstance", data=data)
        logger.info(f"Successfully added cluster instance {instID} on {self.nsip}")
        
    def enable_cluster_instance(self, instID):
        logger.info(f"Enabling cluster instance {instID} on {self.nsip}")
        data = {
            "clusterinstance": {
                "clid": str(instID),
            }
        }
        self.do_post(resource="clusterinstance", data=data, action="enable")
        logger.info(f"Successfully enabled cluster instance {instID} on {self.nsip}")

    def add_cluster_node(self, nodeID, nodeIP, backplane, tunnelmode, state):
        logger.info(f"Adding cluster node {nodeID}/{nodeIP}")
        data = {
            "clusternode": {
                "nodeid": str(nodeID),
                "ipaddress": nodeIP,
                "state": state,
                "backplane": backplane,
                "tunnelmode": tunnelmode,
            }
        }
        self.do_post(resource="clusternode", data=data)
        logger.info(f"Successfully added cluster node with ID:{nodeID} and nodeIP:{nodeIP}")

    def set_cluster_node(self, nodeID, state):
        logger.info(f"Setting cluster state to {state} on node {nodeID}")
        data = {
            "clusternode": {
                "nodeid": str(nodeID),
                "state": state,
            }
        }
        self.do_put(resource="clusternode", data=data)
        logger.info(f"Successfully set cluster node {nodeID} to state {state}")

    def remove_cluster_node(self, nodeID):
        logger.info(f"Removing cluster node {nodeID}")
        try:
            self.do_delete(resource="clusternode", id=str(nodeID))
            logger.info(f"Successfully removed cluster node {nodeID}")
        except Exception as e:
            logger.error(f"Failed to remove cluster node. Reason: {str(e)}")
   
    def enable_feature(self, features_list):
        logger.info(f"Enabling features {features_list} in {self.nsip}")
        data = {"nsfeature": {"feature": features_list}}
        self.do_post(resource="nsfeature", data=data, action="enable")
        logger.info(f"Successfully enabled features {features_list}")

    def enable_mode(self, modes_list):
        logger.info(f"Enabling modes {modes_list} in {self.nsip}")
        data = {"nsmode": {"mode": modes_list}}
        self.do_post(resource="nsmode", data=data, action="enable")
        logger.info(f"Successfully enabled modes {modes_list}")

    def configure_dns(self, nameserver):
        logger.info(f"Configuring {nameserver} as the DNS server on {self.nsip}")
        configs = [
          {"service": {"name": "awslbdnsservice0", "ip": nameserver, "servicetype":"DNS", "port":"53", "healthmonitor": "NO"}},
          {"lbvserver": {"name": "awslbdnsvserver", "servicetype": "DNS"}},
          {"lbvserver_service_binding": {"name": "awslbdnsvserver", "servicename": "awslbdnsservice0"}},
          {"dnsnameserver": {"dnsvservername": "awslbdnsvserver"}}
        ]

        for config in configs:
            self.do_post(resource=list(config.keys())[0], data=config)
        logger.info(f"Successfully configured {nameserver} as dns server")

    def add_ipset(self):
        logger.info(f"Adding ipset 'ipset1'")
        data = {"ipset": {"name":"ipset1"}}
        self.do_post(resource="ipset", data=data)
        logger.info("Successfully added ipset 'ipset1'")

    def bind_ipset(self, ipaddr):
        logger.info(f"Binding {ipaddr} to ipset1")
        data = {"ipset_nsip_binding": {"name": "ipset1", "ipaddress":ipaddr}}
        self.do_post(resource="ipset_nsip_binding", data=data)
        logger.info(f"Successfully bound IP {ipaddr} to ipset 'ipset1'")


    def unbind_ipset(self, ipaddr):
        logger.info(f"Unbinding {ipaddr} from ipset1")
        data = {"ipset_nsip_binding": {"name": "ipset1", "ipaddress":ipaddr}}
        binding_id="ipset1?args=ipaddress:"+ipaddr
        try:
            self.do_delete(resource="ipset_nsip_binding", id=binding_id)
            logger.info(f"Successfully unbound IP {ipaddr} from ipset 'ipset1'")
        except Exception as e:
            logger.error(f"Failed to unbinf ip from ipset. Reason: {str(e)}")
            
    def get_ipset_bindings(self):
        logger.info(f"Getting IPs bound to ipset 'ipset1")
        try:
            result = self.do_get(resource="ipset_nsip_binding", id="ipset1")
            logger.info(f"Successfully fetched ipset bindings: {result['ipset_nsip_binding']}")
            return result['ipset_nsip_binding']
        except Exception as e:
            logger.error(f"Failed to get ip set bindings. Reason:{str(e)}")
            return []

    def set_ssl_global_params(self):
        logger.info(f"Enabling SSL default profile")
        data = {
            "sslparameter": {
                "defaultProfile": "ENABLED"
            }
        }
        self.do_put(resource="sslparameter", data=data)
        logger.info(f"Successfully enabled default SSL profile")

    def join_cluster(self, clip, password):
        logger.info(f"Joining node {self.nsip} to cluster with CLIP {clip}")
        data = {"cluster": {"clip": clip, "password": password}}
        self.do_post(resource="cluster", data=data, action="join")
        logger.info(f"Successfully joined cluster node {self.nsip}")

    def add_nsip(self, ip, netmask, ip_type, owner_node=-1):
        logger.info(f"Adding nsip {ip}/{netmask} type {ip_type} owner {owner_node}")
        data = {"nsip": {"ipaddress": ip, "netmask": netmask, "type": ip_type}}
        if owner_node != -1:
            data["nsip"]["ownernode"] = owner_node
        self.do_post(resource="nsip", data=data)
        logger.info(f"Successfully added NSIP {ip} with type {ip_type}")

    def del_nsip(self, ip):
        logger.info(f"Deleting ip {ip}")
        try:
            self.do_delete(resource="nsip", id=ip)
            logger.info(f"Successfully deleted IP {ip}")
        except Exception as e:
            logger.error(f"Failed to delete ip. Reason: {str(e)}")

    def save_config(self):
        logger.info(f"Saving the configuration")
        data = {"nsconfig": {}}
        self.do_post(resource="nsconfig", data=data, action="save")
        logger.info("Successfully saved nsconfig of {}".format(self.nsip))

    def reboot(self, warm=True):
        logger.info("Rebooting the netscaler")
        data = {"reboot": {"warm": warm}}
        self.do_post(resource="reboot", data=data)
        logger.info(f"Successfully accepted reboot request - {self.nsip}")
        
class Cluster(CitrixADC):
    def __init__(self, clip, nspass, nameserver="", vip_netmask="", mgmt_netmask="", server_netmask="", backplane="1/2", tunnelmode="GRE"):
        super().__init__(nsip=clip, nsuser="nsroot", nspass=nspass)
        self.clip = clip
        self.backplane = backplane
        self.tunnelmode = tunnelmode
        self.nameserver = nameserver
        self.vip_netmask = vip_netmask
        self.mgmt_netmask = mgmt_netmask
        self.server_netmask = server_netmask

    def get_node_count(self, masterstate=""):
        logger.info(f"Trying to get the number of {masterstate} nodes in the cluster")
        get_filter = "" if masterstate == "" else f"?filter=masterstate:{masterstate}"
        result = self.do_get(resource=f"clusternode{get_filter}")
        node_count = 0 if "clusternode" not in result else len(result["clusternode"])
        logger.info(f"Number of {masterstate} nodes in the cluster is {node_count}")
        return node_count
        
    def get_stats(self, counter_names):
        logger.info(f"Getting stats for counters {counter_names} from {self.nsip}")
        response = self.do_request_stat(f"ns?attrs={','.join(counter_names)}")
        return response["ns"]
   
    def wait_until_node_active(self, node_id):
        self.wait_for_reachability()
        logger.info(f"Waiting for node {node_id} to become ACTIVE")
        for _ in range(20):
            result = self.do_get(resource="clusternode", id=node_id)
            clusternode = result["clusternode"][0]
            if clusternode["masterstate"] == "ACTIVE":
                logger.info(f"Node {node_id} is now ACTIVE")
                return
            waitfor(10, f"Waiting for node id:{node_id} ip:{clusternode['ipaddress']} to become active")
        raise ValueError (f"Node {node_id} did not become ACTIVE")


    def add_first_node(self, nodeip, vip, mgmt_snip, server_snip):
        logger.info(f"Adding first node {nodeip} to cluster")
        nodeID = 0  
        backplane = f"{nodeID}/{self.backplane}"
        state = "ACTIVE"
        clusterInstanceID = 1

        node = CitrixADC(nsip=nodeip, nspass=self.nspass)
        node.wait_for_reachability()
        node.add_cluster_instance(clusterInstanceID)
        node.add_cluster_node(nodeID, nodeip, self.backplane, self.tunnelmode, state)
        node.add_nsip(self.clip, "255.255.255.255", "CLIP")
        node.add_nsip(vip, self.vip_netmask, "VIP")
        node.add_nsip(mgmt_snip, self.mgmt_netmask, "SNIP", owner_node=nodeID)
        node.add_nsip(server_snip, self.server_netmask, "SNIP", owner_node=nodeID)
        node.enable_feature(["APPFW", "BOT", "REP", "LB", "CS", "SSL", "WL", "SP", "CR", "GSLB", "SSLVPN", "AAA", "REWRITE", "RESPONDER", "APPFLOW", "CH", "RDPPROXY"])
        node.configure_dns(self.nameserver)
        node.add_ipset()
        node.bind_ipset(vip)
        node.set_ssl_global_params()
        node.enable_mode(["FR", "L3", "USNIP", "PMTUD", "ULFD"])
        node.enable_cluster_instance(clusterInstanceID)
        node.save_config()
        node.reboot()
        waitfor(30, reason="Waiting for first node to reboot")
        node.wait_for_reachability()
        self.wait_until_node_active(0)
        logger.info(f"Successfully created a 1 node cluster with node-id:{nodeID} ip:{nodeip}")
    
    def get_available_node_id(self):
        logger.info("Getting an available node id")
        self.wait_for_reachability()
        result = self.do_get(resource="clusternode")
        nodes = result["clusternode"]
        ids = set([int(node["nodeid"]) for node in nodes])
        for i in range(32):
            if i not in ids:
                logger.info(f"Fetched available node id {i}")
                return i
        raise ValueError("No available node ID")

    def add_node(self, node_ip, vip, mgmt_snip, server_snip):
        logger.info(f"Adding node {node_ip} to cluster with clip {self.clip}")
        node_id = -1
        for _ in range(30):
            node_id = self.get_available_node_id()
            node_backplane = f"{node_id}/{self.backplane}"
            try:
                self.add_cluster_node(node_id, node_ip, node_backplane, self.tunnelmode, "ACTIVE")
                break
            except Exception as e:
                if "Resource already exists" in str(e):
                    logger.info("Node-id {node_id} taken up by another node. Will try again")
                    waitfor(seconds=1)
                else:
                    raise
        try:
            self.add_nsip(vip, self.vip_netmask, "VIP")
            self.add_nsip(mgmt_snip, self.mgmt_netmask, "SNIP", owner_node=node_id)
            self.add_nsip(server_snip, self.server_netmask, "SNIP", owner_node=node_id)
            self.bind_ipset(vip)
            self.save_config()
            node = CitrixADC(node_ip, nspass=self.nspass)
            node.join_cluster(self.clip, self.nspass)
            node.save_config()
            node.reboot()
            waitfor(20, "Waiting for new node to reboot")
            node.wait_for_reachability()
            self.wait_until_node_active(node_id)
        except Exception as e:
            logger.error(f"Failed to add node ip:{node_ip} to cluster")
            self.remove_node(node_id, vip)
            raise e
        logger.info(f"Successfully added node id:{node_id} ip:{node_ip} to cluster")

    def remove_node(self, node_id, node_vip=None):
        logger.info(f"Removing node id:{node_id} vip:{node_vip} from clip {self.clip}")
        self.wait_for_reachability()
        self.remove_cluster_node(node_id)
        if node_vip:
            self.unbind_ipset(node_vip)
            self.del_nsip(node_vip)
        logger.info(f"Node {node_id} clean up done")
        
    def cleanup_stale_nodes(self, valid_node_ips, valid_node_vips):
        logger.info(f"Cleaning up the cluster of stale nodes. Valid node-ips:{valid_node_ips}  node-vips:{valid_node_vips}")
        self.wait_for_reachability()
        nodes = self.get_cluster_nodes()
        vips = self.get_ipset_bindings()
        for node in nodes:
            if node['ipaddress'] not in valid_node_ips:
                self.remove_node(node['nodeid'])
        for vip in vips:
            if vip['ipaddress'] not in valid_node_vips:
                self.unbind_ipset(vip['ipaddress'])
                self.del_nsip(vip['ipaddress'])

def get_environment_job_status(job_id, trust_info):
    url = f"https://{trust_info['serviceurl']}/{trust_info['customerid']}/{trust_info['servicename']}/" \
          f"adcaas/nitro/v1/config/jobs/{job_id}/status"
    response = do_request("GET", url, trust_info=trust_info)

    job_status = response["status"]
    environmentdeployment_state = job_status["state"]
    error_details = job_status.get("errors", [])
    return environmentdeployment_state, job_status.get("action"), error_details

def wait_for_job_completion(job_id, trust_info):
    SLEEP_TIME = 5  # seconds
    OVERALL_WAIT_TIME = 1800  # seconds
    status = "NOTSTARTED"
    error_details = []
    action = None
    time_taken = 0
    while status not in ["COMPLETED", "ERROR"] and time_taken < OVERALL_WAIT_TIME:
        try:
            status, action, error_details = get_environment_job_status(job_id, trust_info)
            time.sleep(SLEEP_TIME)
            time_taken += SLEEP_TIME
        except Exception:
            raise Exception("Failed to retrieve status of job '%s'" % job_id)

    if time_taken > OVERALL_WAIT_TIME:
        status = "ERROR"
        action = None
        error_details = []
        logger.error("Job on environments timed out")
    return status, action, error_details

def register_clip_in_adm(clip, agent_ip, trust_info):
    logger.info(f"Registering clip: {clip}...")
    try:
        url = f"https://{trust_info['serviceurl']}/{trust_info['customerid']}/{trust_info['servicename']}" \
              f"/adcaas/nitro/v1/config/environments/{trust_info['environment_id']}/register_clip"
        data = {
            "register_clip": {
                "clip": clip,
                "agent_ip": agent_ip
            }
        }
        response = do_request("POST", url, data=data, trust_info=trust_info)
        status, action, error_details = wait_for_job_completion(response["register_clip"]["job_id"], trust_info)
        if status == "ERROR":
            raise Exception("Register clip workflow failed with error")
        logger.info(f"Clip {clip} registered successfully.")
    except Exception as e:
        raise ValueError(f"Failed to register clip. Reason: {str(e)}")

def get_node_metadata():
    metadata_url = "http://169.254.169.254/metadata/instance?api-version=2023-07-01"
    return do_request("GET", metadata_url, retries=8, headers={"Metadata":"true"})

def get_vault_url(subscription_id, resource_group):
    client = ResourceManagementClient(credential=DefaultAzureCredential(), subscription_id=subscription_id)
    for _ in range(10):
        try:
            resource_list = client.resources.list_by_resource_group(resource_group)
            for resource in list(resource_list):
                if resource.type == "Microsoft.KeyVault/vaults":
                    logger.info(f"Found vault - {resource.name}")
                    return f"https://{resource.name}.vault.azure.net/"
        except Exception as e:
            logger.error(f"Failed to fetch resources in resource group. Error: {str(e)}")
        waitfor(seconds=5, reason="Waiting before listing resources in resource group")

def get_adc_password(subscription_id, resource_group):
    client = SecretClient(vault_url=get_vault_url(subscription_id, resource_group), 
        credential=DefaultAzureCredential(), subscription_id=subscription_id)

    retrieved_secret = client.get_secret("adc-nsroot-pwd")
    return retrieved_secret.value
    
def get_adc_vmss(compute_client, resource_group):

    vmss_list = compute_client.virtual_machine_scale_sets.list(resource_group)
    
    for vmss in vmss_list:
        if vmss.name.startswith("vmss-adc-"):
            logger.info(f"Fetched vmss with name = {vmss.name}")
            return vmss
    raise ValueError(f"Unable to fetch adc vmss name : {[vmss.name for vmss in vmss_list]}")

def get_vmss_instances_ips(compute_client, network_client, resource_group, vmss_name):
    mgmt_ips, client_ips = [], []
    vmss_vms = compute_client.virtual_machine_scale_set_vms.list(resource_group, vmss_name)

    for vm in vmss_vms:
        vm_details = compute_client.virtual_machines.get(resource_group, vm.name)
        for interface in vm_details.network_profile.network_interfaces:
            if "mgmt-nic" not in interface.id and "client-nic" not in interface.id:
                continue
            nic = network_client.network_interfaces.get(resource_group, interface.id.split('/')[-1])
            for ip_configuration in nic.ip_configurations:
                if ip_configuration.name == "mgmt-ip":
                    mgmt_ips.append(ip_configuration.private_ip_address)
                elif ip_configuration.name == "client-ip":
                    client_ips.append(ip_configuration.private_ip_address)
    logger.info(f"Fetched mgmt-ips={mgmt_ips}  client-ips={client_ips}")
    return mgmt_ips, client_ips



def get_clip(metadata):
    subnet_cidr = metadata["network"]["interface"][0]["ipv4"]["subnet"][0]["address"] + "/" + metadata["network"]["interface"][0]["ipv4"]["subnet"][0]["prefix"]
    clip = str(ip_network(subnet_cidr)[-3])
    logger.info(f"CLIP is {clip}")
    return clip

def check_and_register_clip(node, clip, agent_secondary_ip, trust_info):
    try:
        logger.info("Checking if CLIP needs to be registered")
        resp = node.do_get(resource="lbvserver")
        if "lbvserver" in resp and "registered_clip" in [lb["name"] for lb in resp["lbvserver"]]:
            logger.info(f"lbvserver registered_clip found on cluster. The device is already registered")
        else:
            logger.info("Will register the CLIP")
            register_clip_in_adm(clip, agent_secondary_ip, trust_info)
            node.do_post(resource="lbvserver", data={"lbvserver":{"name": "registered_clip", "servicetype": "HTTP"}})
    except Exception as e:
        logger.error(f"Error in checking and registering CLIP: {type(e)} {str(e)}")

def check_and_cleanup_stale_nodes(cluster, compute_client, network_client, resource_group):
    try:
        logger.info("Checking if there are any stale nodes that need to be cleaned up")
        if cluster.get_node_count(masterstate="ACTIVE") == cluster.get_node_count():
            logger.info("All nodes are active. No cleanup needed")
            return
        logger.info("Will cleanup nodes that are not part of the vmss")
        vmss = get_adc_vmss(compute_client, resource_group)
        mgmt_ips, client_ips = get_vmss_instances_ips(compute_client, network_client, resource_group, vmss.name)
        cluster.cleanup_stale_nodes(mgmt_ips, client_ips)
        logger.info("Cleaned up stale nodes in the cluster")
    except Exception as e:
        logger.error(f"Error in checking and cleaning up stale nodes: {type(e)} {str(e)}")
    return
    
def collect_stats_from_cluster(cluster):
    counters_obj = cluster.get_stats(['totrxmbits', 'rescpuusage', 'cpuusage'])
    node_count = cluster.get_node_count(masterstate="ACTIVE")
    stats_counters = { }
    if "rescpuusage" in counters_obj and int(counters_obj["rescpuusage"]) != 0xffffffff:
        stats_counters["cpuusage"] = counters_obj["rescpuusage"]
    elif "cpuusage" in counters_obj and int(counters_obj["cpuusage"]) != 0xffffffff:
        stats_counters["cpuusage"] = counters_obj["cpuusage"]
    if "rxmbitsrate" in counters_obj and node_count > 0:
        stats_counters["rxmbitsrate"] = counters_obj["rxmbitsrate"]/node_count
    logger.info(f"Gathered stats - {stats_counters}")
    return stats_counters

def send_custom_metrics(location, resource_group, vmss_id, stats_counters):

    azure_monitor_endpoint = f"https://{location}.monitoring.azure.com{vmss_id}/metrics"

    credential = DefaultAzureCredential()

    access_token = credential.get_token('https://monitoring.azure.com/.default')
    logger.info(f"Access token = {access_token}")
    
    headers = {
        "Authorization": "Bearer " + access_token.token,
        "Content-Type": "application/json"
    }

    for metric_name,metric_value in stats_counters.items():
        data = { 
            "time": datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%S"), 
            "data": { 
                "baseData": { 
                    "metric": metric_name, 
                    "namespace": "NetScaler", 
                    "series": [ 
                        {                       
                            "min": metric_value,
                            "max": metric_value,
                            "sum": metric_value,
                            "count": 1
                        }
                    ]
                }
            }
        }
        response = requests.post(azure_monitor_endpoint, headers=headers, json=data)
        logger.info(f"response status={response.status_code}  text={response.text}")

    return

def publish_custom_metrics(cluster, compute_client, location, resource_group):
    try:
        logger.info("Publishing cluster stats to Azure monitor")
        stats = collect_stats_from_cluster(cluster)
        if len(stats) > 0:
            vmss = get_adc_vmss(compute_client, resource_group)
            send_custom_metrics(location, resource_group, vmss.id, stats)
            logger.info(f"Published {stats} to Azure monitor")
        else:
            logger.info("No stats found to publish to Azure monitor")
    except Exception as e:
        logger.error(f"Error in publishing custom metrics to Azure: {type(e)} {str(e)}")

def main():
    while True:
        try:
            trust_info = load_agent_trust()
            metadata = get_node_metadata()
            subscription_id = metadata["compute"]["subscriptionId"]
            resource_group = metadata["compute"]["resourceGroupName"]
            location = metadata["compute"]["location"]
            agent_secondary_ip = metadata["network"]["interface"][0]["ipv4"]["ipAddress"][1]["privateIpAddress"]
            clip = get_clip(metadata)
            adc_password = get_adc_password(subscription_id, resource_group)
            break
        except Exception as e:
            logger.error(f"Error initializing bookkeeping: {str(e)}")
        waitfor(seconds=2, reason="Waiting before retrying initialization")

    node = Cluster(clip=clip, nspass=adc_password)
    
    while True:
        try:
            check_and_register_clip(node, clip, agent_secondary_ip, trust_info)
            compute_client = ComputeManagementClient(credential=DefaultAzureCredential(), subscription_id=subscription_id)
            network_client = NetworkManagementClient(credential=DefaultAzureCredential(), subscription_id=subscription_id)
            check_and_cleanup_stale_nodes(node, compute_client, network_client, resource_group)
            publish_custom_metrics(node, compute_client, location, resource_group)
        except Exception as e:
            logger.error(f"Error while book keeping: {str(e)}")
        waitfor(seconds=60, reason="Waiting before performing book-keeping operations again.")

main()
