# Simplified Gateway with SAML

This example shows how to configure a simplified gateway with SAML authentication.


## Folder Structure
There are two seperate terraform modules
1. `step1_configure_ha` helps in configuring the NetScalers in HA mode
2. `step2_gateway_saml` helps in configuring gateway-saml usecase to the primary NetScaler after the HA mode.

Each of these terraform modules contains the below file structure -

Refer [HERE](../../../assets/common_docs/terraform/folder_structure.md).

## Pre-requisites

1. Two NetScaler ADCs to be provisioned already in the same subnet
2. All the necessary certificates for gateway configuration should be present in `step2_gateway_saml` folder

## Usage

### Step1: Configure HA

1. `cd step1_configure_ha`
2. Refer [HERE](../../../assets/common_docs/terraform/terraform_usage.md) for steps

### Step2: Further Gateway Configuration

1. `cd step2_gateway_saml`
2. Refer [HERE](../../../assets/common_docs/terraform/terraform_usage.md) for steps

## Network Architecture
To be updated