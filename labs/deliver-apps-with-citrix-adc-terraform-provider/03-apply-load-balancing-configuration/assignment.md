---
slug: apply-load-balancing-configuration
id: xzlas7iv5b2e
type: challenge
title: Configure load balancer in ADC
teaser: Apply load balancing configuration
notes:
- type: text
  contents: Apply load balancing configuration
tabs:
- title: Code Editor
  type: code
  hostname: cloud-client
  path: /root/apply-lb-configuration
- title: Bastion Host CLI
  type: terminal
  hostname: cloud-client
- title: Citrix ADC data
  type: service
  hostname: cloud-client
  path: /adc.html
  port: 80
difficulty: basic
timelimit: 900
---

Introduction
============

## Configure Load balancer in ADC

In this challenge we will apply an load balancing configuration. For this we have created a configuration under the `/root/apply-lb-configuration` directory.All resources are in a single `resources.tf` file.

In the file we first create a SNIP `snip` address to communicate
with the backend services. Then we create the two services `tf_service1`and `tf_service2` that correspond to the backend servers.

Notice that we add an explicit dependency, with the `depends_on` keyword, to the SNIP resource. This will ensure that the services are created after the
SNIP address and consequently they will be reachable from the
ADC instance.

After that we create the lb vserver `tf_lbvserver` which also has an
explicit dependency to the SNIP address.

Lastly we create the bindings between the lb vserver and
the services.These have an implicit dependency to the lb vserver and
each service.These dependencies are created because we
use references to resource attributes in the block of the binding.

For example the following reference
```hcl
name = citrixadc_lbvserver.tf_lbvserver.name
```
establishes a depency to the lb vserver resource in the same file.

With these dependencies defined, terraform will execute the configuration
in dependency order.Learn more about ADC services, servicegroup, and loadbalancing [here](https://docs.citrix.com/en-us/citrix-adc/current-release/getting-started-with-citrix-adc/communicate-with-clients-servers.html).

Apply Configuration
===================
Go to Bastion Host CLI and perform following operations:-

In order to apply the configuration we first need to change to
the correct directory.
```bash
cd /root/apply-lb-configuration
```
Then we need to initilize the configuration in order to
download the Citrix ADC provider.
```bash
terraform init
```
Lastly we need to apply the configuration.
```bash
terraform apply
```
Answer `yes` and hit `enter` to proceed.If all is well you will see a message for the successful
creation of the resources.

Verifying the configuration
===========================


## Verifying using Browser

Having applied the configuration you should be able to
reach the backend services through the VIP address.

You can view this address in the `Citrix ADC data` tab.

Opening a new browser window with this ip address should
show you a message from the backend servers.


## Inspecting local terraform state

You can inspect the local terraform state of the configuration
by first changing to the configuration directory
```bash
cd /root/apply-lb-configuration
```
and then running the following command
```bash
terraform show
```
You should see the resources created along with their full attributes list.
The local state will reflect what is configured at the target Citrix ADC as long as the relevant configuration changes made to it are performed through the terraform tool.


## Inspect Configuration through ADC nscli

You can also inspect the remote configuration by connecting
to the target Citrix ADC nscli.

To do this you need to ssh into the NSIP.
```bash
ssh nsroot@<NSIP>
```
replace `<NSIP>` with the `Citrix ADC Management IP` as shown on the `Citrix ADC data` tab.
Having logged in you can run the following command to inspect
the configuration
```
show lb vserver tf_lbvserver
```
You should see the details of the lb vserver along with the backend services statuses.


## Inspect Configuration through ADC Web GUI

You can also inspect the same information through the
Citrix ADC Web GUI.
Open a browser window with the NSIP.After login head to Traffic Management -> Load Balancing -> Virtual servers.
You should be able to see the `tf_lbvserver` and by clicking on it
you can view further details.


Conclusion
==========

In this challenge we demostrated how to apply a load balancing configuration.

Proceed to the next challenge.
