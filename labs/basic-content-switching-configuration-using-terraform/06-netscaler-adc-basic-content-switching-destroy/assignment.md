---
slug: netscaler-adc-basic-content-switching-destroy
id: bzd6tribreob
type: challenge
title: Destroy Configuration
teaser: Destroy Terraform Managed Configuration
notes:
- type: text
  contents: Destroy Content Switching configuration
tabs:
- title: Code Editor
  type: code
  hostname: cloud-client
  path: /root/apply-cs-configuration
- title: Bastion Host CLI
  type: terminal
  hostname: cloud-client
- title: NetScaler ADC data
  type: service
  hostname: cloud-client
  path: /adc.html
  port: 80
difficulty: basic
timelimit: 3600
---
Introduction
============

As we have already applied all configurations for our use cases in the previous
steps we will now destroy that configuration.

This will remove all configuration from the NetScaler ADC instance that is managed from Terraform.

Destroy configuration
=====================
First change to the configuration directory
```bash
cd /root/apply-cs-configuration
```
Then run the following command
```bash
terraform destroy -var-file example.tfvars
```
You will be prompted with the destroy plan
which will detail which resources will be destroyed.

Answer `yes` and hit `enter` to proceed.After the operation is successfully completed
all configuration from the target NetScaler ADC is deleted.

The back-end services will not be reachable through the VIP
address.


Conclusion
==========
This concludes our track.

In this track we focused on some example configurations that can cover specific use cases. You can find more example configurations of how to configure ADC using Terraform on the NetScaler ADC provider's [Github repository](https://github.com/citrix/terraform-provider-citrixadc/tree/master/examples).

You can experiment with them and combine them to achieve more complex configurations for advanced use cases such as Application Protection, High Availability and Global Server Load Balancing and more.

General documentation for the NetScaler ADC can be found
at the [NetScaler ADC documentation site](https://docs.citrix.com/en-us/citrix-adc/current-release.html).
