---
slug: netscaler-adc-basic-virtual-servers-config
id: hbzy89rfeaqx
type: challenge
title: NetScaler ADC base configuration
teaser: Configure ADC to route traffic to our back-end applications.
notes:
- type: text
  contents: Apply content-switching configuration
tabs:
- title: Code Editor
  type: code
  hostname: cloud-client
  path: /root/apply-rewrite-configuration
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

## Configure Load Balancing and Content Switching in ADC

In this challenge we will apply all basic load balancing and content switching configuration to route traffic to our back-end applications. If you were following along, in our previous lab `NetScaler ADC Basic Content Switching Configuration using Terraform` we demonstrated how you can route traffic between different applications. In this challenge we are going to simply create the basic configuration that is required to start applying Rewrite / Responder policies.


We will start by creating a Content Switching policy that will route traffic based on the URL path that we are using.

- If we visit VIP/echoserver1 we are expecting all traffic to go to the echoserver1
- If we visit VIP/echoserver2 we are expecting all traffic to go to the echoserver2


In this challenge we have one content-switching virtual server, two load balancing virtual server and two servers.
Two servers in the background are echoserver which echos back the request sent.

We will first create two load balancing virtual servers, `tf_lbvserver1` and `tf_lbvserver2`. Then we create two services `web-echoserver1` and `web-echoserver2` that corresponds to the back-end servers.

We create the bindings between each load balancing virtual server and the services i.e., .`tf_lbvserver1` is bound to `web-echoserver1` and `tf_lbvserver2` is bound to `web-echoserver2`. These have an implicit dependency to the load balancing virtual server and each service. These dependencies are created because we use references to resource attributes in the block of the binding.

We will then be creating two content switching actions that point to the two previously created load balancing virtual servers.

Two content switching policies are created `tf_policy_echoserver1` and `tf_policy_echoserver2`, that have specific rules. If a rule is met then the provided action will be invoked. Then, each on of the policies will point to the previously created content switching actions.

Finally, we are creating a content switching virtual server `tf_csvserver`, that has the VIP attached to it. The two content switching policies are then bound to this content switching virtual server.


Learn more about NetScaler ADC Content Switching [here](https://docs.netscaler.com/en-us/citrix-adc/current-release/content-switching.html).

Terraform configuration
=======================

The configuration has already been written to the directory
`/root/apply-rewrite-configuration`. You can browse the files in the Code Editor tab.

## Files Structure
* `main.tf` describes the actual NetScaler ADC config objects to be created. The attributes of these resources are either hard coded or looked up from input variables in `example.tfvars`
* `variables.tf` describes the input variables to the terraform config. These can have defaults
* `versions.tf` is used to specify the username, password and endpoint of the Netscaler ADC.
* `example.tfvars` has the variable inputs specified in `variables.tf`



Apply Configuration
===================

Go to Bastion Host CLI and perform following operations:-

In order to apply the configuration we first need to change to
the correct directory.
```bash
cd /root/apply-rewrite-configuration
```
Then we need to initilize the configuration in order to
download the NetScaler ADC provider[(terraform-provider-citrixadc)](https://registry.terraform.io/providers/citrix/citrixadc/latest).
```bash
terraform init
```
Lastly we need to apply the configuration.
```bash
terraform apply -var-file example.tfvars
```
Answer `yes` and hit `enter` to proceed.If all is well you will see a message for the successful
creation of the resources.

Verifying the configuration
===========================

## Verifying using Browser


Having applied the configuration you should be able to reach the backend services through the VIP address, so follow the below steps.

Open the browser
- If we visit VIP/echoserver1 we are expecting all traffic to go to the echoserver1
![echoserver1](https://github.com/citrix/terraform-cloud-scripts/blob/master/assets/instruqt_lab/netscaler-adc-basic-rewrite-responder-policies-using-terraform/browser-echoserver1.png?raw=true)

- If we visit VIP/echoserver1 we are expecting all traffic to go to the echoserver2
![echoserver2](https://github.com/citrix/terraform-cloud-scripts/blob/master/assets/instruqt_lab/netscaler-adc-basic-rewrite-responder-policies-using-terraform/browser-echoserver2.png?raw=true)


## Inspect Configuration through ADC Web GUI

You can also inspect the same information through the
NetScaler ADC Web GUI.
Open a browser window with the NSIP, username as `nsroot` and password as `verysecret` . After login head to `Traffic Management` -> `Content Switching` -> `Virtual servers`.
You should be able to see the `tf_csvserver` and by clicking on it
you can view further details.

![NetScaler-GUI](https://github.com/citrix/terraform-cloud-scripts/blob/master/assets/instruqt_lab/netscaler-adc-basic-content-switching-using-terraform/adc-gui-cs.png?raw=true)

![NetScaler-GUI](https://github.com/citrix/terraform-cloud-scripts/blob/master/assets/instruqt_lab/netscaler-adc-basic-content-switching-using-terraform/csvserver-gui.png?raw=true)

![NetScaler-GUI](https://github.com/citrix/terraform-cloud-scripts/blob/master/assets/instruqt_lab/netscaler-adc-basic-rewrite-responder-policies-using-terraform/adc-gui-cspolicy.png?raw=true)


Conclusion
==========

In this challenge we demonstrated how to created the basic ADC configuration to route traffic to our back-ends using Terraform. Now that we have our setup in place we are going to see how we can create Rewrite / Responder policies to manipulate the information contained in the HTTP Requests and Responses. In the next challenge we are going to apply a Rewrite policy to add an HTTP Header in an incoming request.

Proceed to the next challenge.
