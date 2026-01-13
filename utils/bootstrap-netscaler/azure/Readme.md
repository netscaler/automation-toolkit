# NetScaler Azure Automation Toolkit

This directory contains a suite of Python scripts designed to automate the deployment, clustering, and management of **NetScaler (formerly Citrix ADC)** instances and **ADM Agents** within Microsoft Azure.

---

## Component Overview

### 1. ADM Agent Registration 
**File:** `autoregister_agent_azure.py`  
**Target:** ADM Agent

This script handles the initial identity and networking setup for the ADM Agent.
* **Secondary IP Management:** Automatically identifies the required secondary IP from the subnet CIDR and assigns it to the Azure Network Interface.
* **Trust Establishment:** Generates a new RSA keypair and registers the public key with the ADM trust service using a pre-auth token.
* **Secret Management:** Retrieves registration info from Azure Key Vault and updates it with the newly generated instance identity.
* **Configuration:** Generates an encrypted `agent.conf` and local PEM files required for the agent to communicate with the management plane.

### 2. ADC Cluster Bootstrapping
**File:** `azure_cluster.py`  
**Target:** NetScaler ADC

This script automates the formation of a high-availability cluster for NetScaler instances.
* **Dynamic Role Discovery:** Uses Azure Instance Metadata (IMDS) to determine if it is the first node in a Scale Set or a joining member.
* **Automated Clustering:** If a cluster does not exist, it initializes the first node with a Cluster IP (CLIP), VIP, and SNIPs. If a cluster exists, it joins as a new node.
* **Security:** Securely retrieves the `nsroot` password from Azure Key Vault to perform NITRO API configurations.
* **Network Configuration:** Configures system modes (L3, USNIP), features (LB, CS, SSL), and DNS settings automatically.

### 3. Monitoring & Maintenance (Bookkeeping)
**File:** `azure_cluster_bookkeep.py`  
**Target:** ADM Agent

A persistent background process that ensures the ADC cluster remains synchronized with the Azure environment.
* **Cluster Synchronization:** Continuously checks for "stale" nodes—instances that are still in the NetScaler configuration but have been deleted from the Azure Virtual Machine Scale Set (VMSS)—and removes them.
* **ADM Registration:** Ensures the Cluster IP (CLIP) is properly registered within the ADM service for management.
* **Azure Monitor Integration:** Collects performance telemetry (CPU usage and throughput) from the cluster and publishes it as Custom Metrics to Azure Monitor.

---

## Workflow Summary



1.  **Registration:** The ADM Agent runs `autoregister_agent_azure.py` to establish its identity and networking.
2.  **Formation:** ADC instances run `azure_cluster.py` during boot to form or join the cluster based on the VMSS state.
3.  **Maintenance:** The Agent runs `azure_cluster_bookkeep.py` in a loop to sync cluster membership with Azure VMSS changes and report health metrics.

---

## Infrastructure Requirements

* **Managed Identity:** Azure VMs must have a System-Assigned Managed Identity authorized to access the designated Azure Key Vault and read Network/Compute resources.
* **Azure Key Vault:** Must contain secrets for `agent-trust` (for the Agent) and `adc-nsroot-pwd` (for the ADC).
* **Network Connectivity:** Instances must have outbound access to the Azure Instance Metadata Service (`169.254.169.254`) and the ADM service URLs.