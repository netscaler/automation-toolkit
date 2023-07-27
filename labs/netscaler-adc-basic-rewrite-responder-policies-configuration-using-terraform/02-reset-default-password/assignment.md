---
slug: reset-default-password
id: bf9j8vxeclbw
type: challenge
title: Reset the NetScaler ADC default password
teaser: Reset the NetScaler ADC default password
notes:
- type: text
  contents: Reset ADC password
tabs:
- title: Code Editor
  type: code
  hostname: cloud-client
  path: /root/reset-default-password
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

## Reset default password

The ADC instance provisioned in the Google Cloud
has a default initial password. Before any configuration can be applied we need to reset this default password. This can be done interactively through the Web GUI or
through the nscli by ssh.

In this challenge, we are going to reset password using the terraform provider.

Terraform configuration
=======================

The configuration has already been written to the directory
`/root/reset-default-password`. You can browse the files in the Code Editor tab.

`provider.tf` - This file contains the provider connection information.
You will notice that we define the endpoint to be
an `https` url. This will ensure that the data exchanged with the target ADC
will be encrypted.
Because the target ADC's default TLS certificate is self signed
we also need to set the option `insecure_skip_verify = true`.This will avoid the http requests failing due to certificate
verification errors.
For production instances it is strongly recommended to replace
the default TLS certificate with a properly signed one.

`resources.tf`- This file contains the resource which will do the actual
reset of the password. For Google Cloud the default password is the instance id.
The new password is defined with the `new_password` attribute.
You can edit this to something else other than the provided one.If you do make sure to take note of it, because you will be needing to change the resource files for the subsequent challenges.

Apply configuration
===================
Go to Bastion Host CLI and perform following operations :
1. Change current directory to the one containing the terraform configuration files

	```bash
	cd /root/reset-default-password
	```

2. Initialize the terraform configuration.
	```bash
	terraform init
	```
	This command will download and install the citrixadc provider
	which is needed to run the configuration.

3. Apply the configuration.
	```bash
	terraform apply
	```
	This command will present you with the configuration changes
	and will prompt you to verify you want to apply them.

	Answer `yes` and press enter.

If all goes well you should see a message saying 1 resource was
created without any errors.

Conclusion
==========

We have now configured the target ADC with a new password.

If you changed the new password to something else than the one
supplied please take note of it since you will be needing it
for the subsequent challenges citrixadc provider configuration.
