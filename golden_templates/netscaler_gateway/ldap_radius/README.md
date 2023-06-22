# Simplified Gateway with LDAP and RADIUS

This example shows how to configure a simplified gateway with LDAP and RADIUS authentication.

## NetScaler Community Live Demo

<https://community.netscaler.com/s/webinar/a078b000010v51jAAA/automating-gateway-configurations-with-golden-terraform-templates-ldap-radius>


## Folder Structure
There are two seperate terraform modules
1. `step1_configure_ha` helps in configuring the NetScalers in HA mode
2. `step2_gateway_ldap_radius` helps in configuring gateway-ldap-radius usecase to the primary NetScaler after the HA mode.

Each of these terraform modules contains the below file structure -

Refer [HERE](../../../assets/common_docs/terraform/folder_structure.md).

## Usage

### Step1: Configure HA

1. `cd step1_configure_ha`
2. Refer [HERE](../../../assets/common_docs/terraform/terraform_usage.md) for steps

### Step2: Further Configs (Configure 1 LBvserver, 2 servers)

1. `cd step2_gateway_saml`
2. Refer [HERE](../../../assets/common_docs/terraform/terraform_usage.md) for steps

## Network Architecture
![Network Architecture for Ldap RADIUS](../../../assets/gateway/ldap_radius_architecture_diag.png "Network Architecture for Ldap RADIUS")
