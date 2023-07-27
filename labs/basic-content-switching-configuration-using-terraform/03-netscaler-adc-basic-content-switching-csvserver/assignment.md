---
slug: netscaler-adc-basic-content-switching-csvserver
id: 1mk6ce4cuymd
type: challenge
title: Content Switching with Basic Policies part 1
teaser: Configure NetScaler ADC to route traffic based on URL Path.
notes:
- type: text
  contents: Apply content Switching configuration
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

## Configure a Content Switching virtual server in ADC.

In this challenge we will apply basic content switching configuration. If you were following along, in our previous lab `NetScaler ADC Basic Load Balancing Configuration using Terraform` we demonstrated how you can load balance traffic between 2 back-end servers. In this challenge we are going to introduce a Content Switching virtual server in front of our load balancer that will allow you to route traffic to your applications based on certain criteria.


We will start by creating a Content Switching policy that will route traffic based on the URL path that we are using.

- If we visit VIP/red we are expecting all traffic to go to the application with the red background
- If we visit VIP/green we are expecting all traffic to go to the application with the green background



In this challenge we have one content switching virtual server, two load balancing virtual server and two servers.

We will first create two load balancing virtual servers, `tf_lbvserver1` and `tf_lbvserver2`. Then we create two services `web-server-red`and `web-server-green` that corresponds to the back-end servers.

We create the bindings between each load balancing virtual server and the services i.e., .`tf_lbvserver1` is bound to `web-server-red` and `tf_lbvserver2` is bound to `web-server-green`. These have an implicit dependency to the load balancing virtual server and each service. These dependencies are created because we use references to resource attributes in the block of the binding.

We will then be creating two content switching actions that point to the two previously created load balancing virtual servers.

Two content-switching policies are created `tf_policy_red` and `tf_policy_green`, that have specific rules. If a rule is met then the provided action will be invoked. Then, each on of the policies will point to the previously created content switching actions.

Finally, we are creating a content switching virtual server `tf_csvserver`, that has the VIP attached to it. The two content switching policies are then bound to this content switching virtual server.


Learn more about ADC Content Switching [here](https://docs.citrix.com/en-us/citrix-adc/current-release/content-switching.html).

Terraform configuration
=======================

The configuration has already been written to the directory
`/root/apply-cs-configuration`. You can browse the files in the Code Editor tab.

## Files Structure
* `main.tf` describes the actual NetScaler ADC config objects to be created. The attributes of these resources are either hard coded or looked up from input variables in `example.tfvars`
* `variables.tf` describes the input variables to the Terraform config. These can have default values.
* `versions.tf` is used to specify the username, password and endpoint of the NetScaler ADC.
* `example.tfvars` has the variable inputs specified in `variables.tf`



Apply Configuration
===================

Go to Bastion Host CLI and perform following operations:-

In order to apply the configuration we first need to change to
the correct directory.
```bash
cd /root/apply-cs-configuration
```
Then we need to initilize the configuration in order to
download the Citrix ADC provider.
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


Having applied the configuration you should be able to reach the back-end services through the VIP address, so follow the below steps.

Open the browser
- If we visit VIP/red we are expecting all traffic to go to the application with the red background
![red-server](https://github.com/citrix/terraform-cloud-scripts/blob/master/assets/instruqt_lab/netscaler-adc-basic-content-switching-using-terraform/browser-red-server.png?raw=true)

- If we visit VIP/green we are expecting all traffic to go to the application with the green background
![green-server](https://github.com/citrix/terraform-cloud-scripts/blob/master/assets/instruqt_lab/netscaler-adc-basic-content-switching-using-terraform/browser-green-server.png?raw=true)



## Inspect Configuration through ADC Web GUI

You can also inspect the same information through the
NetScaler ADC Web GUI.
Open a browser window with the NSIP. After login head to Traffic Management -> Content Switching -> Virtual servers.
You should be able to see the `tf_csvserver` and by clicking on it
you can view further details.

![NetScaler-GUI](https://github.com/citrix/terraform-cloud-scripts/blob/master/assets/instruqt_lab/netscaler-adc-basic-content-switching-using-terraform/adc-gui-cs.png?raw=true)

![NetScaler-GUI](https://github.com/citrix/terraform-cloud-scripts/blob/master/assets/instruqt_lab/netscaler-adc-basic-content-switching-using-terraform/csvserver-gui.png?raw=true)

![NetScaler-GUI](https://github.com/citrix/terraform-cloud-scripts/blob/master/assets/instruqt_lab/netscaler-adc-basic-content-switching-using-terraform/cspolicy-bindings-gui.png?raw=true)

Conclusion
==========

In this challenge we demonstrated how to create a Content Switching virtual server using Terraform and then we applied a basic Content Switching Policy to route traffic to our Applications based on URL path. In the following challenge we are going to see how we can route traffic based on HTTP Header value.

Proceed to the next challenge.
