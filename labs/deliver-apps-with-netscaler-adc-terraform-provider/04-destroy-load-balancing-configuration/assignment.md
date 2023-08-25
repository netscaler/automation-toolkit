---
slug: destroy-load-balancing-configuration
id: qjyh2ya2ikg2
type: challenge
title: Destroy load balancing configuration
teaser: Destroy load balancing configuration
notes:
- type: text
  contents: Destroy load balancing configuration
tabs:
- title: Code Editor
  type: code
  hostname: cloud-client
  path: /root/apply-lb-configuration
- title: Bastion Host CLI
  type: terminal
  hostname: cloud-client
- title: NetScaler ADC data
  type: service
  hostname: cloud-client
  path: /adc.html
  port: 80
difficulty: basic
timelimit: 900
---

Introduction
============

Having applied the lb vserver configuration in the previous
step we will now destroy that configuration.

This will remove the configuration from the NetScaler ADC instance.

Destroy configuration
=====================

First change to the configuration directory
```bash
cd /root/apply-lb-configuration
```
Then run the following command
```bash
terraform destroy
```
You will be prompted with the destroy plan
which will detail which resources will be destroyed.

Answer `yes` and hit `enter` to proceed. After the operation is successfully completed
all configuration from the target NetScaler ADC is deleted.

The backend services will not be reachable through the VIP
address.

Conclusion
==========

This concludes the track. You learned how to install the terraform CLI binary,
install the NetScaler ADC provider[(terraform-provider-citrixadc)](https://registry.terraform.io/providers/citrix/citrixadc/latest) and apply and destroy
configurations.

You can find more example configurations and documentaion on the NetScaler ADC [Terraform
provider's](https://registry.terraform.io/providers/citrix/citrixadc/latest/docs).
You can experiment with them and combine them to achieve more complex configurations for advanced usecases such as web application firewall, multicluster etc.

General documentation for the NetScaler ADC can be found
at the [NetScaler ADC documentation site](https://docs.netscaler.com/en-us/citrix-adc/current-release.html).
