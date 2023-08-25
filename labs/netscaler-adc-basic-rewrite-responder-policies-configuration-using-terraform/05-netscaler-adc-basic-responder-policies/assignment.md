---
slug: netscaler-adc-basic-responder-policies
id: in7n376gyzkz
type: challenge
title: Basic Responder Policies
teaser: Configure ADC to redirect an incoming request based on certain criteria.
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

## Configure a basic Responder policy.

In this challenge we will see how we can create Responder Policies to alter HTTP Responses based on certain criteria. We are going to create a policy that will change the “host” from root “/” to “/echoserver2”.

- Every request sent to `{VIP}/` should be redicted to `{VIP}/echoserver2`.
- The `X-Forwarded-For` header should now be missing, as we are sending traffic to `echoserver2` and not `echoserver1`.



In this challenge we will create  `citrixadc_responderaction` and  `citrixadc_responderpolicy`  resources (responder action and responder policy), which will configure ADC to perform the responder action to the request under certain conditions.

First, the responder policy expression will be evaluated against the request and then the corresponding action will be performed. According to our configuration:
- all the requests sent to `{VIP}/` should be redirected to `{VIP}/echoserver2`.
- If the requested URL contains  `/echoserver1` then the previously created rewrite action will be performed.

Follow below instruction to configure responder policy on NetScaler.

Learn more about ADC responder policy [here](https://docs.netscaler.com/en-us/citrix-adc/current-release/appexpert/responder.html).

Terraform Configuration
============

Go to the `code Editor` tab and update the following changes.
Open `main.tf` file.

Add the resource block to create new rewrite policy and rewrite action and to bind the rewrite the policy to the content-switching vserver `tf_csvserver` as shown below. So, append the below code (resource block) to the `main.tf` file.

```hcl
resource "citrixadc_responderaction" "tf_responderaction" {
  name   = "tf_responder_action"
  type   = var.responderaction_type
  target = var.responderaction_target
}
resource "citrixadc_responderpolicy" "tf_responder_policy" {
  name   = var.responderpolicy_name
  action = citrixadc_responderaction.tf_responderaction.name
  rule   = var.responderpolicy_rule
}

resource "citrixadc_csvserver_responderpolicy_binding" "tf_bind" {
  name       = citrixadc_csvserver.tf_csvserver.name
  policyname = citrixadc_responderpolicy.tf_responder_policy.name
  priority   = 100
}
```

Then open the `variables.tf` file.
We need to create a variable block for the some of the above referring variable attributes.

So, append the below code in the `variables.tf` file.

```hcl
variable "responderaction_type" {
  type        = string
  description = "Type of responder action"
}
variable "responderaction_target" {
  type        = string
  description = "responder action target"
}

variable "responderpolicy_name" {
  type        = string
  description = "responder policy name"
}
variable "responderpolicy_rule" {
  type        = string
  description = "responder Policy Rule"
}
```

Then, open the `example.tfvars` file.
Here we need to set the values of the variables. So, add the below lines in `example.tfvars` file.

 **_NOTE:_** Please update the `{VIP}` under responderaction_target variable from the value present on NetScaler ADC data tab.

```hcl
responderaction_type       = "redirect"
responderaction_target     = "\"http://{VIP}/echoserver2\""

responderpolicy_name="tf_responder_policy"
responderpolicy_rule="HTTP.REQ.URL.PATH_AND_QUERY.EQ(\"/\")"
```

 **_NOTE:_** After Editing the terraform configuration files please save the files by clicking on the **disk** icon on the top right corner as shown below in the screenshot.

  ![Save-files-ss](https://github.com/citrix/terraform-cloud-scripts/blob/master/assets/instruqt_lab/netscaler-adc-basic-content-switching-using-terraform/Part-3-Save.png?raw=true)

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
- If we visit VIP/echoserver1 we are expecting all traffic to go to the application with the extra HTTP Header as  `X-Forwarded-For` and value as source ip
![echoserver1](https://github.com/citrix/terraform-cloud-scripts/blob/master/assets/instruqt_lab/netscaler-adc-basic-rewrite-responder-policies-using-terraform/echo1-browser.png?raw=true)

- If we visit just VIP we are expecting all traffic to be redirected to echoserver2 with no additional HTTP Header added to the request.
![echoserver2](https://github.com/citrix/terraform-cloud-scripts/blob/master/assets/instruqt_lab/netscaler-adc-basic-rewrite-responder-policies-using-terraform/browser-echoserver2.png?raw=true)

**_NOTE:_** Please update the `VIP` whike verifying the above, from the value present on NetScaler ADC data tab.

## Inspect Configuration through ADC Web GUI

You can also inspect the same information through the
NetScaler ADC Web GUI.
Open a browser window with the NSIP, with username as `nsroot` and password as `verysecret`. After login head to AppExpert -> Responder -> Policies.
You should be able to see the `tf_responder_policy` and by clicking on it
you can view further details.

![adc-responder](https://github.com/citrix/terraform-cloud-scripts/blob/master/assets/instruqt_lab/netscaler-adc-basic-rewrite-responder-policies-using-terraform/adc-gui-responder.png?raw=true)

Conclusion
==========

In this challenge we demostrated how to apply a basic Responder Policy to manipulate to Redirect a request based on certain criteria. Now that we covered both use cases we will see how we can remove all configurations managed through Terraform.

Proceed to the next challenge.