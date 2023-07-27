---
slug: netscaler-adc-basic-content-switching-prerequisites
id: z6pntui8nus4
type: challenge
title: Prerequisites
teaser: Provision the base Infrastructure and Setup Terraform CLI
notes:
- type: text
  contents: Setup VPX
tabs:
- title: Bastion Host CLI
  type: terminal
  hostname: cloud-client
- title: Citrix ADC data
  type: service
  hostname: cloud-client
  path: /adc.html
  port: 80
difficulty: basic
timelimit: 3600
---

Introduction
============

Welcome to the lab.

In this lab, we have provisioned the following:
1. NetScaler ADC VPX
2. Two back-end servers for you.

You can visit `NetScaler ADC data ` tab to find more details about the IPs that have been assigned to these.


As part of the lab, we will achieve the following :
1.	Install Terraform CLI binary and Citrix ADC provider in a bastion host with access to the target ADC instance.
2.	Deploy a Content Switching virtual server to route traffic to your applications.
3.	Configure Content Switching Policies and route traffic based on URL path or header values.

For this challenge we will need to download and setup the Terraform CLI binary.
Terraform provides instructions on how to download and install the
Terraform binary in this [page](https://www.terraform.io/downloads).
All available Terraform binaries are listed [here](https://releases.hashicorp.com/terraform/). Let’s get started with Terraform installation.

Install Terraform
=================

First we will download Terraform:

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
4. Verify that the Terraform binary is executable from the command line

	```bash
	terraform version
	```
	The above command should show you the version information of the Terraform binary.
	> Ignore any out of date warning message.

Conclusion
==========

Having installed the Terraform binary our next task will be
to start using Terraform for configuration management.

Please proceed to the next challenge.
