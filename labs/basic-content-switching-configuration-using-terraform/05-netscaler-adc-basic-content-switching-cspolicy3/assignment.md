---
slug: netscaler-adc-basic-content-switching-cspolicy3
id: ozg8easvzzgx
type: challenge
title: Content Switching with Basic Policies part 3
teaser: Configure ADC to route traffic based on HTTP Header.
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

In this challenge we will see how we can create a Content Switching Policies to route traffic to your applications based on HTTP Header.

- If the HTTP request contains the Header `Color`  without value or any other value that is not covered from the existing policies we are expecting all traffic to go to the application with the green background
- If the HTTP request contains a Header `Color: red` we are expecting all traffic to go to the application with the red background
- If the HTTP request contains a Header `Color: green` we are expecting all traffic to go to the application with the green background

Learn more about ADC Content Switching [here](https://docs.citrix.com/en-us/citrix-adc/current-release/content-switching.html).

Terraform Configuration
============

In this challenge we are creating another `citrixadc_cspolicy`  resource, which will have a rule that will check if the Header `Color` exists in the request.
If the Header exists and if its value is something other than `red` or `green` then we are redirecting the requests to the green server, i.e., we are pointing it to content switching action that redirects the traffic to the load balancing virtual server that is pointing to the green server.

Go to the `code Editor` tab and update the following changes.
Open `main.tf` file.

Add the resource block to create content-switching policy and also we need to create binding between content-switching vserver `tf_csvserver` with the newly created content-switching policy as shown below. So, add the below code (resource block) to the `main.tf` file.

```hcl
resource "citrixadc_cspolicy" "tf_policy_default" {
  policyname = var.cspolicy3_name
  rule       = var.cspolicy3_rule
  action     = citrixadc_csaction.tf_csaction2.name
}

resource "citrixadc_csvserver_cspolicy_binding" "tf_csvscspolbind_default" {
  name                   = citrixadc_csvserver.tf_csvserver.name
  policyname      = citrixadc_cspolicy.tf_policy_default.policyname
  priority               = 120
}
```


Then open the `variables.tf` file.
We need to create a variable block for the `cspolicy3_name` and `cspolicy3_rule` variables.

So, add the below code in the `variables.tf` file.

```hcl
variable "cspolicy3_name" {
  type        = string
  description = "CS policy3 name"
}
variable "cspolicy3_rule" {
  description = "CS Policy3 Rule"
}
```

Then, open the `example.tfvars` file.
Here we need to set the values of the variables. So, add the below lines in `example.tfvars` file.
```hcl
cspolicy3_name = "tf_policy_default"
cspolicy3_rule  = "HTTP.REQ.HEADER(\"Color\").EXISTS"
```

 **_NOTE:_** After Editing the terraform configuration files please save the files by clicking on the **disk** icon on the top right corner as shown below in the screenshot.

  ![Save-files-ss](https://github.com/citrix/terraform-cloud-scripts/blob/master/assets/instruqt_lab/netscaler-adc-basic-content-switching-using-terraform/Part-3-Save.png?raw=true)

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
Answer `yes` and hit `enter` to proceed.If all is well you will see a message for the successful
creation of the resources.

Verifying the configuration
===========================

## Verifying using cURL (depending on use case)

Lets Verify the Configuration in the  Bastion Host CLI  through CURL command.
Go to Bastion Host CLI  and type the following Curl command.

Note: Update the VIP with the IP address present in the `Citrix ADC data` tab while executing the below command

1. If the HTTP request contains the Header `Color`  without value or any other value then we are expecting all traffic to go to the application with the green background
So, type the below command in Bastion Host CLI and verify.

```bash
 curl -X GET http://{VIP} -H 'Content-Type: application/json' -H 'Color:"" '
 ```
 ![curl-default-server](https://github.com/citrix/terraform-cloud-scripts/blob/master/assets/instruqt_lab/netscaler-adc-basic-content-switching-using-terraform/curl-default-server.png?raw=true)


2. To check the red web server with the header `Color: red`

```bash
curl -X GET http://{VIP} -H 'Content-Type: application/json' -H 'Color: red'
```

![curl-red-server](https://github.com/citrix/terraform-cloud-scripts/blob/master/assets/instruqt_lab/netscaler-adc-basic-content-switching-using-terraform/curl-red-server.png?raw=true)

3. To verify the green web server with the header `Color: green`

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

![NetScaler-GUI](https://github.com/citrix/terraform-cloud-scripts/blob/master/assets/instruqt_lab/netscaler-adc-basic-content-switching-using-terraform/adc-gui-default-policy.png?raw=true)


Conclusion
==========

In this challenge we demonstrated how to apply a Content Switching policy to route traffic based on HTTP Header. Now that we covered both use cases we will see how we can remove all configurations managed through Terraform.

Proceed to the next challenge.