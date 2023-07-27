---
slug: netscaler-adc-basic-rewrite-policies
id: fjn0s7rfiqll
type: challenge
title: Basic Rewrite Policies
teaser: Configure ADC to add an HTTP Header in an incoming request
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

## Configure a basic Rewrite policy.

In this challenge we will see how we can create Rewrite Policies to manipulate an HTTP Request based on certain criteria. We are going to start by creating a policy that will add `X-Forwarder-For` header with the value of the `source IP`. The Rewrite Policy will be applied only when accessing echoserver1:

- If we visit `{VIP}/echoserver1` we are expecting ADC to add the HTTP Header and our back-end `echoserver1` to receive the HTTP Header.
- If we visit `{VIP}/echoserver2`  HTTP Header should not be there.


Learn more about ADC Content Switching [here](https://docs.citrix.com/en-us/citrix-adc/current-release/appexpert/rewrite.html).

Terraform Configuration
============

In this challenge we will create  `citrixadc_rewriteaction` and  `citrixadc_rewritepolicy`  resources (rewrite action and rewrite policy) , which will configure the rewrite action to be be applied on a request under specific conditions.

First, the rewrite policy expression will be evaluated against the request and the corresponding action will be performed. If the requested URL contains `/echoserver1` then the specified rewrite action will be performed, by adding an extra HTTP Header to the  the request.
If the requested URL is `/echoserver2` then no action will be performed, as we have not created any rewrite policy for that URL and it is only being handled by the cs policy as before.


Go to the `code Editor` tab and update the following changes.
Open `main.tf` file.

Add the resource block to create new rewrite policy and rewrite action and to bind the rewrite the policy to the content switching virtual server `tf_csvserver` as shown below. So, add the below code (resource block) to the `main.tf` file.

```hcl
resource "citrixadc_rewriteaction" "tf_rewrite_action" {
  name              = "tf_rewrite_action"
  type              = var.rewriteaction_type
  target            = var.rewriteaction_target
  stringbuilderexpr = var.rewriteaction_stringbuilderexpr
}
resource "citrixadc_rewritepolicy" "tf_rewrite_policy" {
  name   = var.rewritepolicy_name
  action = citrixadc_rewriteaction.tf_rewrite_action.name
  rule   = var.rewritepolicy_rule
}
resource "citrixadc_csvserver_rewritepolicy_binding" "tf_bind1" {
  name       = citrixadc_csvserver.tf_csvserver.name
  policyname = citrixadc_rewritepolicy.tf_rewrite_policy.name
  priority   = 100
  bindpoint  = "REQUEST"
}
```

Then open the `variables.tf` file.
We need to create a variable block for the `cspolicy3_name` and `cspolicy3_rule` variables.

So, add the below code in the `variables.tf` file.

```hcl
variable "rewriteaction_type" {
  type        = string
  description = "Type of rewrite action"
}
variable "rewriteaction_target" {
  type        = string
  description = "rewrite action target"
}
variable "rewriteaction_stringbuilderexpr" {
  type        = string
  description = "rewrite action stringbuilderexpr"
}

variable "rewritepolicy_name" {
  type        = string
  description = "rewrite policy name"
}
variable "rewritepolicy_rule" {
  type        = string
  description = "rewrite Policy Rule"
}
```

Then, open the `example.tfvars` file.
Here we need to set the values of the variables. So, add the below lines in `example.tfvars` file.
```hcl
rewriteaction_type              = "insert_http_header"
rewriteaction_target            = "X-Forwarded-For"
rewriteaction_stringbuilderexpr = "CLIENT.IP.DST"

rewritepolicy_name = "tf_rewrite_policy"
rewritepolicy_rule = "HTTP.REQ.URL.SET_TEXT_MODE(IGNORECASE).STARTSWITH(\"/echoserver1\")"
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

Having applied the configuration you should be able to reach the backend services through the VIP address, so follow the below steps.

Open the browser
- If we visit VIP/echoserver1 we are expecting all traffic to go to the application with the extra HTTP Header as  `X-Forwarded-For` and value as source ip
![echoserver1](https://github.com/citrix/terraform-cloud-scripts/blob/master/assets/instruqt_lab/netscaler-adc-basic-rewrite-responder-policies-using-terraform/echo1-browser.png?raw=true)

- If we visit VIP/echoserver2 we are expecting all traffic to go to the application to echoserver2 with no additional HTTP Header added to the request.
![echoserver2](https://github.com/citrix/terraform-cloud-scripts/blob/master/assets/instruqt_lab/netscaler-adc-basic-rewrite-responder-policies-using-terraform/echo2-browser.png?raw=true)


## Inspect Configuration through ADC Web GUI

You can also inspect the same information through the
Citrix ADC Web GUI.
Open a browser window with the NSIP. After login head to AppExpert -> Rewrite -> Policies.
You should be able to see the `tf_rewrite_policy` and by clicking on it
you can view further details.

![NetScaler-GUI](https://github.com/citrix/terraform-cloud-scripts/blob/master/assets/instruqt_lab/netscaler-adc-basic-rewrite-responder-policies-using-terraform/adc-gui-rewritepolicy.png?raw=true)
Conclusion
==========

In this challenge we demostrated how to apply a basic Rewrite Policy to manipulate an HTTP Request based on certain criteria. In the following challenge we are going to see how we can use a basic Responder Policies to redirect traffic to another URL.

Proceed to the next challenge.