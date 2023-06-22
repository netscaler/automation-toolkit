# Simplified Gateway with LDAP and RADIUS

This example shows how to configure a simplified gateway with LDAP and RADIUS authentication.

## NetScaler Community Live Demo

[<img width="300" alt=" Automate Gateway Configurations w/ Golden Terraform templates: LDAP - RADIUS configuration on YouTube" src="https://github.com/netscaler/automation-toolkit/assets/42572246/f8cdf007-66e4-4e7f-bc9f-e533e73ffbdf">](https://www.youtube.com/watch?v=aDUXfdb4u-s)

Video Link: <https://www.youtube.com/watch?v=aDUXfdb4u-s>

## Folder Structure
There are two seperate terraform modules
1. `step1_configure_ha` helps in configuring the NetScalers in HA mode
2. `step2_gateway_ldap_radius` helps in configuring gateway-ldap-radius usecase to the primary NetScaler after the HA mode.

Each of these terraform modules contains the below file structure -

Refer [HERE](../../../assets/common_docs/terraform/folder_structure.md).

## Pre-requisites

1. Two NetScaler ADCs to be provisioned already in the same subnet
2. All the necessary certificates for gateway configuration should be present in `step2_gateway_ldap_radius` folder

## Usage

### Step1: Configure HA

1. `cd step1_configure_ha`
2. Refer [HERE](../../../assets/common_docs/terraform/terraform_usage.md) for steps

### Step2: Further Gateway Configuration

1. `cd step2_gateway_ldap_radius`
2. Refer [HERE](../../../assets/common_docs/terraform/terraform_usage.md) for steps

## Network Architecture
![Network Architecture for Ldap RADIUS](../../../assets/gateway/ldap_radius_architecture_diag.png "Network Architecture for Ldap RADIUS")
