---
slug: netscaler-adc-basic-rewrite-responder-policies-prerequisites
id: ox5jvix0dzja
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

Welcome to the lab.

The lab will provision for you a NetScaler ADC and a simple echo server. Then it will guide you on using Terraform to apply your configuration. Echo server is a simple application that echoes back the request it receives. We will leverage the echo server to showcase how our policies manipulate the information contained in the request or response.

You can visit `NetScaler ADC data ` tab to find more details about the IPs that have been assigned to these.


As part of the lab, we will achieve the following :
1.	Install Terraform CLI binary and NetScaler ADC provider[(terraform-provider-citrixadc)](https://registry.terraform.io/providers/citrix/citrixadc/latest) in a bastion host with access to the target ADC instance.
2.	We will configure ADC to route traffic to our echo server. To learn more on how routing works please check `NetScaler ADC Basic Content Switching Configuration using Terraform ` Lab.
3. We will show how we can manipulate an incoming request by adding an additional HTTP Header in an incoming request based on certain criteria.
4. . We will show how we can redirect a request to another URL using a responder policy.


For this challenge we will need to download and setup the Terraform CLI binary.
Terraform provides instructions on how to download and install the
Terraform binary in this [page](https://www.terraform.io/downloads).
All available Terraform binaries are listed [here](https://releases.hashicorp.com/terraform/). Lets get started with Terraform installation.

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
