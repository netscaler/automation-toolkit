import requests
import logging
import os
import sys
import time
import json
from ipaddress import IPv4Network, ip_network
import traceback
import copy

from azure.identity import DefaultAzureCredential
from azure.mgmt.compute import ComputeManagementClient
from azure.mgmt.resource import ResourceManagementClient
from azure.keyvault.secrets import SecretClient

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

handler = logging.FileHandler("/var/log/clusterbootstrap.log", mode="a")

handler.setLevel(logging.DEBUG)
formatter = logging.Formatter('%(asctime)s - %(process)d - %(levelname)s - %(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)

def do_request(url, method, data=None, retries=3, headers=None, timeout = (5,60)):
    data_dump = copy.deepcopy(data)
    
    def hide_sensitive_data(data):
        for k, v in data.items():
            if k in ["password", "new_password"]:
                data[k] = "********"
            elif isinstance(v, dict):
                hide_sensitive_data(v)
    if data_dump: 
        hide_sensitive_data(data_dump)

    logger.debug(f"do_request method={method}  url={url}  data={data_dump}  retries={retries}")
    error = ""
    for attempt in range(retries+1):
        if attempt:
            waitfor(seconds=pow(2,attempt), reason="Waiting before retrying http request")
        try:
            response = requests.request(method, url=url, json=data, headers=headers, timeout=timeout)
            logger.debug(f"response status={response.status_code}  text={response.text} attempt={attempt}")
            if response.ok:
                if not response.text:
                    return None
                try:
                    result = json.loads(response.text)
                    return result
                except json.decoder.JSONDecodeError:
                    logger.error(f"do_request method={method}  url={url}  data={data_dump} response={response.text} attempt={attempt} failed. Reason: JSONDecodeError")
                    error = "JSONDecodeError"
                    pass
            else:
                logger.error(f"do_request method={method}  url={url}  data={data_dump} response={response.text} status={response.status_code} attempt={attempt} failed.")
                error = response.text
        except Exception as e:
            logger.error(f"do_request method={method}  url={url}  data={data_dump} attempt={attempt} failed. Reason: {str(e)}")
            error = str(e)
            pass
    raise ValueError(f"request url={url} method={method} failed. Reason: {error}")

def waitfor(seconds=2, reason=None):
    if reason is not None:
        logger.info(f"Waiting for {seconds} seconds. Reason: {reason}")
    else:
        logger.info("Waiting for {seconds} seconds")
    time.sleep(seconds)


class HTTPNitro:
    def __init__(self, nsip, nsuser="nsroot", nspass="nsroot"):
        self.nsip = nsip
        self.nsuser = nsuser
        self.nspass = nspass
        self.timeout = (5, 60)

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
        return do_request(url, method, data, retries, headers, self.timeout)

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

    def check_connection(self, retries=0):
        logger.info(f"Checking connection to {self.nsip}")
        headers = {"Content-Type": "application/json"}
        payload = {"login": {"username": self.nsuser, "password": self.nspass}}
        try:
            self.do_request(resource="login", method="POST", data=payload, headers=headers, retries=retries)
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
                response = do_request(url, 'POST', data=payload, retries=0, headers=headers) 

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
            for ip_dict in result.get("nsip", []):
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
            logger.error(f"Failed to fetch the clsuternodes. Reason: {str(e)}")
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
          {"service": {"name": "azurelbdnsservice0", "ip": nameserver, "servicetype":"DNS", "port":"53", "healthmonitor": "NO"}},
          {"lbvserver": {"name": "azurelbdnsvserver", "servicetype": "DNS"}},
          {"lbvserver_service_binding": {"name": "azurelbdnsvserver", "servicename": "azurelbdnsservice0"}},
          {"dnsnameserver": {"dnsvservername": "azurelbdnsvserver"}}
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
            logger.error(f"Failed to unbind ip from ipset. Reason: {str(e)}")
            
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

def get_node_metadata():
    metadata_url = "http://169.254.169.254/metadata/instance?api-version=2023-07-01"
    return do_request(metadata_url, "GET", retries=8, headers={"Metadata":"true"})
    
def vmss_node_count(subscription_id, resource_group, vmss_name):
    client = ComputeManagementClient(
        credential=DefaultAzureCredential(),
        subscription_id=subscription_id
    )

    while True:
        try:
            response = client.virtual_machine_scale_sets.get(
                resource_group_name=resource_group,
                vm_scale_set_name=vmss_name
            )
            logger.info(f"Vmss node count = {response.sku.capacity}")
            return response.sku.capacity
        except Exception as e:
            logger.error(f"Failed to get virtual_machine_scale_sets. Error: {str(e)}")
            waitfor(seconds=5, reason="Waiting before trying to fetch vmss resource")

def get_vault_url(subscription_id, resource_group):
    client = ResourceManagementClient(credential=DefaultAzureCredential(), subscription_id=subscription_id)
    while True:
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


def main():

    metadata = get_node_metadata()
    try:
        subscription_id = metadata["compute"]["subscriptionId"]
        vmss_name = metadata["compute"]["vmScaleSetName"]
        resource_group = metadata["compute"]["resourceGroupName"]
        nsip = metadata["network"]["interface"][0]["ipv4"]["ipAddress"][0]["privateIpAddress"]
        mgmt_snip = metadata["network"]["interface"][0]["ipv4"]["ipAddress"][1]["privateIpAddress"]
        mgmt_netmask = str(IPv4Network(f'0.0.0.0/{metadata["network"]["interface"][0]["ipv4"]["subnet"][0]["prefix"]}').netmask)
        clip = str(ip_network(f'{metadata["network"]["interface"][0]["ipv4"]["subnet"][0]["address"]}/{metadata["network"]["interface"][0]["ipv4"]["subnet"][0]["prefix"]}')[-3])
        # the secondary interfaces in instance metadata need not be in the right order
        # https://github.com/MicrosoftDocs/azure-docs/issues/7706
        server_if_idx, client_if_idx = 2, 1
        if str(metadata["network"]["interface"][1]["ipv4"]["subnet"][0]["prefix"]) == "27":
            server_if_idx, client_if_idx = 1, 2
        vip = metadata["network"]["interface"][client_if_idx]["ipv4"]["ipAddress"][0]["privateIpAddress"]
        vip_netmask = str(IPv4Network(f'0.0.0.0/{metadata["network"]["interface"][client_if_idx]["ipv4"]["subnet"][0]["prefix"]}').netmask)
        server_snip = metadata["network"]["interface"][server_if_idx]["ipv4"]["ipAddress"][0]["privateIpAddress"]
        server_netmask = str(IPv4Network(f'0.0.0.0/{metadata["network"]["interface"][server_if_idx]["ipv4"]["subnet"][0]["prefix"]}').netmask)
    except Exception as e:
        logger.error("Error fetching required metadata of the node: {str(e)}")
        raise

    adc_password = get_adc_password(subscription_id, resource_group)
    node = CitrixADC(nsip="localhost", nspass=adc_password)
    node.wait_for_reachability(max_time=180)
    cluster_ip = node.get_clip()
    if cluster_ip and cluster_ip == clip:
        logger.info(f"Node is already part of cluster")
        return
    
    cluster = Cluster(clip, adc_password, nameserver="168.63.129.16", vip_netmask=vip_netmask, mgmt_netmask=mgmt_netmask, server_netmask=server_netmask, backplane="0/1")
    if vmss_node_count(subscription_id, resource_group, vmss_name) < 2 or (not cluster.check_connection(retries=5)):
        cluster.add_first_node(nsip, vip, mgmt_snip, server_snip)
    else:
        cluster.add_node(nsip, vip, mgmt_snip, server_snip)

main()
