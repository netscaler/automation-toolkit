---
slug: setup-vpx
id: 0zelij1ma9b8
type: challenge
title: Provision NetScaler ADC VPX and Setup Terraform
teaser: Environment Setup - Deploy NetScaler ADC VPX and a pair of web-apps for you
notes:
- type: text
  contents: Setup VPX
tabs:
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

Welcome to the "Deliver Apps with NetScaler ADC and Terraform" lab.

In this lab, we have provisioned -

1. NetScaler ADC VPX
   1. `NetScaler ADC NSIP (Management login) IP` for management access
   2. `NetScaler ADC VIP (load balancer) Client IP` is the frontend IP for your apps in the backend-servers.
2. Two backend servers for you.

As part of the lab, we will achieve the following :
1.	Install Terraform CLI binary and NetScaler ADC provider[(terraform-provider-citrixadc)](https://registry.terraform.io/providers/citrix/citrixadc/latest) in a bastion host with access to the target ADC instance.
2.	Change NetScaler ADC VPX default password using Terraform
3.	Configure NetScaler ADC with two services corresponding to above backend servers and a load balancer to deliver them over internet all using Terraform.

For this challenge we will need to download and setup the terraform CLI binary.
Terraform provides instructions on how to download and install the
terraform binary in this [page](https://www.terraform.io/downloads).
All available terraform binaries are listed [here](https://releases.hashicorp.com/terraform/). Let’s get started with Terraform installation.

Install terraform
=================

For our purposes we will be downloading a specific terraform version known to work
with our current provider version.

1. Download the .zip file with the binary for the linux_amd64 platform

	```bash
	curl https://releases.hashicorp.com/terraform/1.1.4/terraform_1.1.4_linux_amd64.zip --output terraform_1.1.4_linux_amd64.zip
	```

2. Extract the executable in the current directory

	```bash
	unzip terraform_1.1.4_linux_amd64.zip
	```
3. Move the extracted binary to a location defined in the PATH variable

	```bash
	mv ./terraform /usr/local/bin
	```
4. Verify that the terraform binary is executable from the command line

	```bash
	terraform version
	```
	The above command should show you the version information of the terraform binary.
	> Ignore any out of date warning message.

Conclusion
==========

Having installed the terraform binary our next task will be
to apply terraform configurations.

Please proceed to the next challenge.
