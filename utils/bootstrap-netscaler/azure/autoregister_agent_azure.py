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
from ipaddress import ip_network

from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
from azure.mgmt.resource import ResourceManagementClient

from azure.mgmt.network import NetworkManagementClient
from azure.mgmt.network.models import NetworkInterfaceIPConfiguration, IPConfiguration, Subnet
from msrestazure.azure_exceptions import CloudError

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


'''
logger = logging.getLogger()
logger.setLevel(logging.DEBUG)
logging.getLogger("boto3").setLevel(logging.WARNING)
logging.getLogger("botocore").setLevel(logging.WARNING)
handler = logging.StreamHandler(sys.stdout)
handler.setLevel(logging.DEBUG)
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)
'''

def waitfor(seconds=2, reason=None):
    if reason is not None:
        logger.info(f"Waiting for {seconds} seconds. Reason: {reason}")
    else:
        logger.info("Waiting for {seconds} seconds")
    time.sleep(seconds)

def do_request(method, url, data=None, headers=None, response_json=True, trust_info=None, retries=3, timeout=(5,60)):
    error = ""
    logger.debug(f"do_request method={method}  url={url}  data={data}  retries={retries}")
    for attempt in range(retries+1):
        if attempt:
            waitfor(seconds=pow(2,attempt), reason="Waiting before retrying http request")
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

def get_secrets_client(subscription_id, resource_group):
    client = ResourceManagementClient(credential=DefaultAzureCredential(), subscription_id=subscription_id)
    while True:
        try:
            resource_list = client.resources.list_by_resource_group(resource_group)
            for resource in list(resource_list):
                if resource.type == "Microsoft.KeyVault/vaults":
                    logger.info(f"Found vault - {resource.name}")
                    return SecretClient(vault_url=f"https://{resource.name}.vault.azure.net/",
                        credential=DefaultAzureCredential(), subscription_id=subscription_id)
        except Exception as e:
            logger.error(f"Failed to fetch resources in resource group. Error: {str(e)}")
        waitfor(seconds=5, reason="Waiting before listing resources in resource group")

def get_trust_registration_info(secrets_client, secret_name):
    logger.info(f"Getting trust info")
    try:

        retrieved_secret = secrets_client.get_secret(secret_name)
        retrieved_secret_value = retrieved_secret.value
        logger.debug(f"Successfully fetched CC auth trust information {retrieved_secret_value}")
        trust_info = json.loads(retrieved_secret_value)
        _, _, _ = trust_info["preauthtoken"], trust_info["serviceurl"], trust_info["servicename"]
        trust_info["servicename"] = "netappliance"
        return trust_info
    except json.decoder.JSONDecodeError:
        raise ValueError(f"Trust-info isn't a valid json")
    except KeyError as ke:
        raise ValueError(f"Trust-info missing required field {ke.args[0]}")
    except Exception as e:
        raise ValueError(f"Failed to get cc trust info from {secret_name}. Reason: {str(e)}")
  
def generate_new_keypair(trust_info):
    logger.info(f"Generating new key pair")
    try:
        (publickey, privatekey) = ccauth.newkeypair()
        trust_info["publickey"] = publickey
        trust_info["privatekey"] = privatekey
        logger.info(f"Successfully generated new keypair")
    except Exception as e:
        raise ValueError(f"Failed to generate newkeypair. Reason: {str(e)}")

def get_cc_urls(trust_info):
    logger.info(f"Fetching urls")
    try:
        url = "https://" + trust_info["serviceurl"] + "/fetch_urls"
        response = do_request(method="GET", url=url, response_json=False)
        fetched_urls = response.split(';')
        trust_info["trustserviceurl"] = fetched_urls[1]
        trust_info["downloadserviceurl"] = fetched_urls[0]
        logger.info(f"Fetched download-service={trust_info['downloadserviceurl']} trust-service={trust_info['trustserviceurl']}")
    except Exception as e:
        raise ValueError(f"Failed to fetch urls from {trust_info['serviceurl']}. Reason: {str(e)}")

def register_keys(trust_info):
    url = f"https://{trust_info['trustserviceurl']}/root/trust/v1/identity"
    payload = {
        "preauthtoken": trust_info["preauthtoken"],
        "signingkey": trust_info["publickey"]
    }
    logger.info("Attempting registering public key with trust")
    try:
        response = do_request(method="POST", url=url, data=payload, headers={"Content-Type":"application/json"})
    except Exception as e:
        raise ValueError(f"Failed to register public key with cc trust. Reason: {str(e)}")
        
    if "status" not in response or response["status"] != "success":
        raise ValueError(f"Registering public key with trust failed - Invalid preauthtoken {trust_info['preauthtoken']}")
    try:
        trust_info["customerid"] = response["customerid"]
        trust_info["instanceid"] = response["instanceid"]
    except KeyError as ke:
        raise ValueError(f"Response from cc trust missing required field {ke.args[0]}")
    logger.info(f'Successfully registered public key with trust. customerid={trust_info["customerid"]} instanceid={trust_info["instanceid"]}')

def write_trust_info(secrets_client, secret_name, trust_info):
    logger.info(f"Updating secret {secret_name}")
    try:
        secret_string = json.dumps(trust_info)
        secret = secrets_client.set_secret(secret_name, secret_string)
        logger.info(f"Updated CC auth trust information to {secret_name}. Response={secret}")
    except Exception as e:
        raise ValueError(f"Failed to update secret {secret_name} with the latest trust info. Error: {str(e)}")

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
        raise ValueError(f"Failed to generate servicekey header. Reason: {str(e)}")

def get_agent(ipaddress, trust_info):
    logger.info(f"Checking if agent {ipaddress} exists")
    try:
        url =  f"https://{trust_info['serviceurl']}/{trust_info['customerid']}/{trust_info['servicename']}/nitro/v2/config/mps_agent?filter=name:{ipaddress}"
        response = do_request("GET", url, trust_info=trust_info)
        agent = response["mps_agent"][0] if "mps_agent" in response and len(response["mps_agent"]) > 0 else None
        logger.info(f"Fetched agent={agent}")
        return agent
    except Exception as e:
        raise ValueError(f"Failed to fetch mps_agent. Reason: {str(e)}")

def create_agent(ipaddress, trust_info):
    logger.info(f"Creating agent {ipaddress}")
    try:
        mps_agent_obj = {"mps_agent":{"name":ipaddress, "hostname":ipaddress, "version":"", "platform": "Azure", "instance_id": trust_info["instanceid"], "datacenter_id": trust_info["datacenterid"]}}
        url = f"https://{trust_info['serviceurl']}/{trust_info['customerid']}/{trust_info['servicename']}/nitro/v2/config/mps_agent"
        response = do_request("POST", url, trust_info=trust_info, data=mps_agent_obj)
        logger.info(f"Successfully created agent {ipaddress}")
        return response['mps_agent'][0]
    except Exception as e:
        raise ValueError(f"Failed to create mps_agent. Reason: {str(e)}")

def get_encryption_key():
    logger.info("Getting encryption key for agent conf")
    try:
        if os.path.exists(MPS_DB_SERVER_KEY_FILE):
            with open(MPS_DB_SERVER_KEY_FILE, "r+") as db_server_key:
                content = db_server_key.read()
                db_server_key.close()
            DB_SERVER_DICT = xmltodict.parse(content)['dbserverkey']
            key = DB_SERVER_DICT['key']
            logger.info("Successfully retreived encryption key")
            return key
        else:    
            lib = ctypes.cdll.LoadLibrary(CRYPTO_LIB)
            lib.get_key.argtypes = (ctypes.POINTER(ctypes.c_char_p),)
            res = ctypes.c_char_p()
            lib.get_key(ctypes.byref(res))
            key = res.value
            fileContents = '<?xml version="1.0" encoding="UTF-8" standalone="no"?>\n<dbserverkey>\n\t'
            fileContents = fileContents + "<key>" + key.decode() + "</key>\n</dbserverkey>"
            file = open(MPS_DB_SERVER_KEY_FILE, "w+")
            file.write(fileContents)
            file.close()
            logger.info(f"Created new encryption key file: {fileContents}")
            return key
    except Exception as e:
        raise ValueError(f"Failed to retreive encryption key. Reason: {str(e)}")

def encrypt(rawData, key):
    try:
        lib = ctypes.cdll.LoadLibrary(CRYPTO_LIB)
        lib.encrypt_str.argtypes = (ctypes.c_char_p, ctypes.c_char_p, ctypes.POINTER(ctypes.c_char_p),)
        if type(key) != bytes:
            key = key.encode('utf-8')
        if rawData != None and type(rawData) != bytes:
            rawData = rawData.encode('utf-8')
        c_key = ctypes.c_char_p(key)
        c_str = ctypes.c_char_p(rawData)
        res = ctypes.c_char_p()
        lib.encrypt_str(c_key, c_str, ctypes.byref(res))
        return res.value
    except Exception as e:
        raise ValueError(f"Encryption failure: {str(e)}")

def create_agent_conf(mps_agent, trust_info):
    logger.info("Creating agent configuration file")
    try:
        if os.path.exists(AGENT_CONFIG_FILE):
            os.remove(AGENT_CONFIG_FILE)
        key = get_encryption_key()
        encyp_customer_id = encrypt(trust_info["customerid"], key)
        encyp_instance_id = encrypt(trust_info["instanceid"], key)
        encyp_service_name = encrypt(trust_info["servicename"], key)
        file_contents = f"""<?xml version="1.0" encoding="UTF-8" standalone="no"?>
        <mps_agent>
        <uuid>{mps_agent['id']}</uuid>
        <url>{trust_info['serviceurl']}</url>
        <customerid>{encyp_customer_id.decode()}</customerid>
        <instanceid>{encyp_instance_id.decode()}</instanceid>
        <servicename>{encyp_service_name.decode()}</servicename>
        <download_service_url>{trust_info['downloadserviceurl']}</download_service_url>
        <abdp_url>{trust_info['serviceurl']}</abdp_url>
        <msg_router_url>{trust_info['serviceurl']}</msg_router_url>
        <environment_id>{trust_info['environmentid']}</environment_id>
        <ads_service_type>ADM</ads_service_type>
        <intent_tenant_name>{encyp_customer_id.decode()}</intent_tenant_name>
        </mps_agent> 
        """
        file = open(AGENT_CONFIG_FILE, "w+")
        file.write(file_contents)
        file.close()
        logger.info(f"Successfully created agent configuration file with contents: {file_contents}")
    except Exception as e:
        raise ValueError(f"Failed to create the agent configuration file. Reason: {str(e)}")
    
def create_trust_key_files(trust_info):
    logger.info("Creating trust pem files on agent")
    try:
        os.system("rm -rf /mpsconfig/trust/.ssh/")
        os.system("mkdir -p /mpsconfig/trust/.ssh")
        f = open("/mpsconfig/trust/.ssh/private.pem", "w")
        f.write(trust_info["privatekey"])
        f.close()
        f = open("/mpsconfig/trust/.ssh/public.pem", "w")
        f.write(trust_info["publickey"])
        f.close()
        logger.info("Successfully created trust pem files")
    except Exception as e:
        raise ValueError(f"Failed to create local trust pem files. Reason: {str(e)}")

def get_node_metadata():
    metadata_url = "http://169.254.169.254/metadata/instance?api-version=2023-07-01"
    return do_request("GET", metadata_url, retries=8, headers={"Metadata":"true"})
    
def get_agent_secondary_ip(metadata):
    subnet_cidr = metadata["network"]["interface"][0]["ipv4"]["subnet"][0]["address"] + "/" + metadata["network"]["interface"][0]["ipv4"]["subnet"][0]["prefix"]
    secondary_ip = str(ip_network(subnet_cidr)[-2])
    logger.info(f"Agent secondary IP should be {secondary_ip}")
    return secondary_ip


def freensd_assign_secondary_ip(interface, secondary_ip, netmask):
    os.system(f'ifconfig {interface} inet {secondary_ip} netmask {netmask} alias')
    return

def azure_assign_secondary_ip(subscription_id, resource_group, secondary_ip, metadata):

    for ip_address in metadata["network"]["interface"][0]["ipv4"]["ipAddress"]:
        if ip_address["privateIpAddress"] == secondary_ip:
            logger.info("Required secondary IP address already assinged to this device")
            return

    primary_ip = metadata["network"]["interface"][0]["ipv4"]["ipAddress"][0]["privateIpAddress"]
    network_client = NetworkManagementClient(credential=DefaultAzureCredential(), subscription_id=subscription_id)
    nics = network_client.network_interfaces.list(resource_group)

    old_agent_nic_name = None
    for nic in nics:
        for ip_config in nic.ip_configurations:
            if ip_config.private_ip_address == primary_ip:
                agent_nic = nic
                agent_subnet_id = ip_config.subnet.id
                break
            if ip_config.private_ip_address == secondary_ip:
                old_agent_nic_name = nic.name
                break

    if old_agent_nic_name:
        for _ in range(5):
            try:
                old_agent_nic = network_client.network_interfaces.get(resource_group, old_agent_nic_name)
                old_agent_nic.ip_configurations = [ipconfig for ipconfig in old_agent_nic.ip_configurations if ipconfig.name !="agent-sec-ip"]
                network_client.network_interfaces.begin_create_or_update(resource_group, old_agent_nic_name, old_agent_nic)
                break
            except Exception as e:
                logger.error("Deleteing agent-secondary-ip from old agent failed. Error: {str(e)}")
            waitfor(seconds=5, reason="Waiting before retrying delete of ip config")

    secondary_ip_config = NetworkInterfaceIPConfiguration(name="agent-sec-ip", subnet=Subnet(id=agent_subnet_id), private_ip_allocation_method="Static" , private_ip_address = secondary_ip)
    agent_nic.ip_configurations.append(secondary_ip_config)

    for _ in range(5):
        try:
            network_client.network_interfaces.begin_create_or_update(resource_group, agent_nic.name, agent_nic)
            logger.info("Successfully assigned agent secondary ip")
            return
        except Exception as e:
            logger.error(f"Assigning agent-secondary-ip failed. Error: {str(e)}")
        waitfor(seconds=5, reason="Waiting before re-attempting assigning agent ip")

    raise ValueError(f"Failed to assign secondary IP {secondary_ip} to agent")


def main():
    metadata = get_node_metadata()
    try:
        subscription_id = metadata["compute"]["subscriptionId"]
        resource_group = metadata["compute"]["resourceGroupName"]
        agent_secondary_ip = get_agent_secondary_ip(metadata)
        azure_assign_secondary_ip(subscription_id, resource_group, agent_secondary_ip, metadata)
        freensd_assign_secondary_ip("0/1", agent_secondary_ip, "255.255.255.192")
        
        secrets_client = get_secrets_client(subscription_id, resource_group)
        trust_info = get_trust_registration_info(secrets_client, "agent-trust")
        if "instanceid" not in trust_info:
            logger.info(f'Service registration needed with token={trust_info["preauthtoken"]}')
            get_cc_urls(trust_info)
            generate_new_keypair(trust_info)
            register_keys(trust_info)
            write_trust_info(secrets_client, "agent-trust", trust_info)
        agent = get_agent(agent_secondary_ip, trust_info)
        if not agent:
            agent = create_agent(agent_secondary_ip, trust_info)
        create_agent_conf(agent, trust_info)
        create_trust_key_files(trust_info)
        logger.info("Successfully completed the agent registration process on Azure instance")
    except Exception as e:
        logger.error(f"Exception hit: {str(e)}")
        tb = traceback.format_exc()
        logger.error(f"Exception backtrace: {tb}")

main()
