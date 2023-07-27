---
slug: netscaler-adc-basic-content-switching-cspolicy2
id: 0a90rpuxuxpn
type: challenge
title: Content Switching with Basic Policies part 2
teaser: Configure ADC to route traffic based on HTTP Header value.
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

## Configure a Content Switching policy.

In this challenge we will see how we can create Content Switching Policies to route traffic to your applications based on HTTP Header value.

- If the HTTP request contains a Header `Color: red` we are expecting all traffic to go to the application with the red background
- If the HTTP request contains a Header `Color: green` we are expecting all traffic to go to the application with the green background

Learn more about ADC Content Switching [here](https://docs.citrix.com/en-us/citrix-adc/current-release/content-switching.html).


Terraform configuration
=======================

Click on the `Code Editor` tab to know the configuration files.

In this Challenge we need to change the `rule` of the two content-switching policies.
To achieve this you need to open `example.tfvars` file and change the values of `cspolicy1_rule`  and `cspolicy2_rule` with the values below:
`cspolicy1_rule`'s value to
```bash
"HTTP.REQ.HEADER(\"Color\").CONTAINS(\"red\")"
```
and `cspolicy2_rule`'s value to
```bash
"HTTP.REQ.HEADER(\"Color\").CONTAINS(\"green\")"
```

 **_NOTE:_** After Editing the terraform configuration files please save the files by clicking on the **disk** icon on the top right corner as shown below in the screenshot.


 ![Save-files-ss](https://github.com/citrix/terraform-cloud-scripts/blob/master/assets/instruqt_lab/netscaler-adc-basic-content-switching-using-terraform/Part-2-Save.png?raw=true)


Apply Configuration
===================

Go to Bastion Host CLI and perform following operations:-

In order to apply the configuration we first need to change to
the correct directory.
```bash
cd /root/apply-cs-configuration
```

We need to apply the updated configuration.
```bash
terraform apply -var-file example.tfvars
```
Answer `yes` and hit `enter` to proceed. If all is well you will see a message for the successful
creation of the resources.

Verifying the configuration
===========================

## Verifying using cURL

Lets Verify the Configuration in the  Bastion Host CLI  through CURL command.
Go to Bastion Host CLI  and type the following Curl command.

Note: Update the VIP with the IP address present in the `Citrix ADC data` tab while executing the below command

1. To check the red web server with the header `Color: red`

```bash
curl -X GET http://{VIP} -H 'Content-Type: application/json' -H 'Color: red'
```
![curl-red-server](https://github.com/citrix/terraform-cloud-scripts/blob/master/assets/instruqt_lab/netscaler-adc-basic-content-switching-using-terraform/curl-red-server.png?raw=true)

2. To verify the green web server with the header `Color: green`

```bash
curl -X GET http://{VIP} -H 'Content-Type: application/json' -H 'Color: green'
```
![curl-green-server](https://github.com/citrix/terraform-cloud-scripts/blob/master/assets/instruqt_lab/netscaler-adc-basic-content-switching-using-terraform/curl-green-server.png?raw=true)



## Inspect Configuration through ADC Web GUI
You can also inspect the same information through the
Citrix ADC Web GUI.
Open a browser window with the NSIP. After login head to Traffic Management -> Content Switching -> policies.
You should be able to see the two content-switching policies.
you can view further details.

![NetScaler-GUI](https://github.com/citrix/terraform-cloud-scripts/blob/master/assets/instruqt_lab/netscaler-adc-basic-content-switching-using-terraform/adc-gui-red-green-policy.png?raw=true)

Conclusion
==========

In this challenge we demonstrated how to apply a Content Switching policy to route traffic based on HTTP Header value. In the next challenge we are going to create an additional policy to route traffic based on the HTTP Header presence.

Proceed to the next challenge.