---
slug: netscaler-adc-basic-waf-policy1
id: hojsv1exgtfs
type: challenge
title: WAF Policies part 1
teaser: Create a WAF Policy to block SQL Injection attacks from reaching our back-ends.
tabs:
- title: Code Editor
  type: code
  hostname: cloud-client
  path: /root/apply-waf-configuration
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

## Configure a WAF policy.

In this challenge we will see how we can create WAF Policies to protect our applications from malicious attacks. We are going to start by creating an application firewall profile and policy that will enable `SQL Injection` protection for all types of applications (`HTML, XML, JSON`) and `BLOCK` traffic. Our WAF will protect only echoserver1:

- If we send an SQL Injection attack to `{VIP}/echoserver1` we are expecting WAF to block the request.
- If we send the same malicious request to `{VIP}/echoserver2`  it should pass through ADC.


Learn more about ADC WAF [here](https://docs.citrix.com/en-us/citrix-adc/current-release/application-firewall/introduction-to-citrix-web-app-firewall.html).

Terraform configuration
=======================

In this challenge we will create a web-application-firewall profile `tf_appfwprofile` , and also create a corresponding web-application-firewall policy `tf_appfwpolicy` . As we want to block the SQL Injection attack only to the echoserver1 so, we will bind this policy to the load balancing virtual server that is in front of the echoserver1 i.e., `tf_lbvserver1`.


With our configuration, we are expecting:
- whenever there is SQL Injection attack on echoserver1 it will be blocked.
- where if there is SQL Injection attack on echoserver2 it will not be blocked and it will remain unprotected.

So, to achieve this perform the following in operations.

Go to the `code Editor` tab and update the following changes.
Open `main.tf` file.

So, We need to create new AppFW (Application Firewall) Policy, appfw profile and also bind the load balancing virtual server `tf_lbvserver1`  to the Application Firewall policy. To achieve this, add the resource block to the `main.tf` file

```hcl
resource "citrixadc_appfwprofile" "tf_appfwprofile1" {
  name           = "tf_appfwprofile1"
  addcookieflags = "none"
  bufferoverflowaction = [
    "block",
    "log",
    "stats",
  ]
  canonicalizehtmlresponse = "ON"
  checkrequestheaders      = "OFF"
  cmdinjectionaction = [
    "block",
    "log",
    "stats",
  ]
  contenttypeaction = [
    "none",
  ]
  cookieconsistencyaction = [
    "none",
  ]
  cookieencryption = "none"
  cookiehijackingaction = [
    "none",
  ]
  cookieproxying   = "none"
  cookietransforms = "OFF"
  creditcard = [
    "none",
  ]
  creditcardaction = [
    "none",
  ]
  creditcardxout = "OFF"
  crosssitescriptingaction = [
    "block",
    "log",
    "stats",
  ]
  crosssitescriptingcheckcompleteurls   = "OFF"
  crosssitescriptingtransformunsafehtml = "OFF"
  csrftagaction = [
    "none",
  ]
  defaultcharset = "iso-8859-1"
  denyurlaction = [
    "block",
    "log",
    "stats",
  ]
  dosecurecreditcardlogging = "ON"
  dynamiclearning = [
    "none",
  ]
  enableformtagging                   = "ON"
  errorurl                            = "/"
  excludefileuploadfromchecks         = "OFF"
  exemptclosureurlsfromsecuritychecks = "ON"
  fieldconsistencyaction = [
    "none",
  ]
  fieldformataction = [
    "block",
    "log",
    "stats",
  ]
  fileuploadtypesaction = [
    "block",
    "log",
    "stats",
  ]
  htmlerrorobject = " "
  infercontenttypexmlpayloadaction = [
    "none",
  ]
  inspectcontenttypes = [
    "application/x-www-form-urlencoded",
    "multipart/form-data",
    "text/x-gwt-rpc",
  ]
  invalidpercenthandling = "secure_mode"
  jsondosaction = [
    "block",
    "log",
    "stats",
  ]
  jsonerrorobject = " "
  jsonsqlinjectionaction = [
    "block",
    "log",
    "stats",
  ]
  jsonsqlinjectiontype = "SQLSplCharANDKeyword"
  jsonxssaction = [
    "block",
    "log",
    "stats",
  ]
  logeverypolicyhit = "ON"
  multipleheaderaction = [
    "block",
    "log",
  ]
  optimizepartialreqs      = "ON"
  percentdecoderecursively = "OFF"
  postbodylimitaction = [
    "block",
    "log",
    "stats",
  ]
  refererheadercheck          = "OFF"
  responsecontenttype         = "application/octet-stream"
  rfcprofile                  = "APPFW_RFC_BLOCK"
  semicolonfieldseparator     = "OFF"
  sessionlessfieldconsistency = "OFF"
  sessionlessurlclosure       = "OFF"
  signatures                  = " "
  sqlinjectionaction = [
    "block",
    "log",
    "stats",
  ]
  sqlinjectionchecksqlwildchars     = "OFF"
  sqlinjectionparsecomments         = "checkall"
  sqlinjectiontransformspecialchars = "OFF"
  sqlinjectiontype                  = "SQLSplCharANDKeyword"
  starturlaction = [
    "log",
  ]
  starturlclosure   = "OFF"
  streaming         = "OFF"
  striphtmlcomments = "none"
  stripxmlcomments  = "none"
  trace             = "OFF"
  type = [
    "HTML",
    "JSON",
    "XML",
  ]
  urldecoderequestcookies = "OFF"
  usehtmlerrorobject      = "OFF"
  verboseloglevel         = "pattern"
  xmlattachmentaction = [
    "block",
    "log",
    "stats",
  ]
  xmldosaction = [
    "block",
    "log",
    "stats",
  ]
  xmlerrorobject = " "
  xmlformataction = [
    "block",
    "log",
    "stats",
  ]
  xmlsoapfaultaction = [
    "block",
    "log",
    "stats",
  ]
  xmlsqlinjectionaction = [
    "block",
    "log",
    "stats",
  ]
  xmlsqlinjectionchecksqlwildchars = "OFF"
  xmlsqlinjectionparsecomments     = "checkall"
  xmlsqlinjectiontype              = "SQLSplCharANDKeyword"
  xmlvalidationaction = [
    "none",
  ]
  xmlwsiaction = [
    "none",
  ]
  xmlxssaction = [
    "none",
  ]
}
resource "citrixadc_appfwpolicy" "tf_appfwpolicy1" {
  name        = var.appfwpolicy1_name
  profilename = citrixadc_appfwprofile.tf_appfwprofile1.name
  rule        = var.appfwpolicy1_rule
}

resource "citrixadc_lbvserver_appfwpolicy_binding" "tf_bind1" {
  name                   = citrixadc_lbvserver.tf_lbvserver1.name
  policyname             = citrixadc_appfwpolicy.tf_appfwpolicy1.name
  priority               = 100
  gotopriorityexpression = "END"
}
```

Then open the `variables.tf` file.
We need to create a variable block for the `cspolicy3_name` and `cspolicy3_rule` variables.

So, add the below code in the `variables.tf` file.
```hcl
variable "appfwpolicy1_name" {
  type        = string
  description = "Appfw Policy1 name"
}
variable "appfwpolicy1_rule" {
  type        = string
  description = "Appfw Policy1 rule"
}
variable "appfwprofile1_name" {
  type        = string
  description = "Appfw Profile1 rule"
}

```



Then, open the `example.tfvars` file.
Here we need to set the values of the variables. So, add the below lines in `example.tfvars` file.
```hcl
appfwpolicy1_name = "tf_appfwpolicy1"
appfwpolicy1_rule = "HTTP.REQ.URL.STARTSWITH(\"/echoserver1\")&&HTTP.REQ.URL.CONTAINS(\"aspx?\")"

appfwprofile1_name = "tf_appfwprofile1"

```


 **_NOTE:_** After Editing the terraform configuration files please save the files by clicking on the **disk** icon on the top right corner as shown below in the screenshot.

  ![Save-files-ss](https://github.com/citrix/terraform-cloud-scripts/blob/master/assets/instruqt_lab/netscaler-adc-basic-content-switching-using-terraform/Part-3-Save.png?raw=true)


Apply Configuration
===================
Go to Bastion Host CLI and perform following operations:-

In order to apply the configuration we first need to change to
the correct directory.
```bash
cd /root/apply-waf-configuration
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

## Verifying using cURL

Lets Verify the Configuration in the  Bastion Host CLI  through CURL command.
Go to Bastion Host CLI  and type the following Curl command.

Note: Replace  the VIP in cURL command with the VIP address present in the `NetScaler ADC data` tab while executing the below command

1. To check the WAF configuration for the `echoserver1`, we will verify with the curl command for SQL exploitation, in this case it should block the request, we don't receive any response as shown in below pic

```bash
curl -vi {VIP}/echoserver1/user.aspx?id=1%3B%20DROP%20TABLE%20users
```
![curl-echoserver1](https://github.com/citrix/terraform-cloud-scripts/blob/master/assets/instruqt_lab/netscaler-adc-basic-waf-using-terraform/curl-echoserver1.png?raw=true)

As you can see from the response, NetScaler returns HTTP/1.0 302 and blocks the request which is not reaching our back-end.

2. To check the same request to the `echoserver2`, in this case it should execute the command and get the response as usual.

```bash
curl -vi {VIP}/echoserver2/user.aspx?id=1%3B%20DROP%20TABLE%20users
```
![curl-echoserver2](https://github.com/citrix/terraform-cloud-scripts/blob/master/assets/instruqt_lab/netscaler-adc-basic-waf-using-terraform/curl-echoserver2.png?raw=true)


## Inspect Configuration through ADC Web GUI

You can also inspect the same information through the
Citrix ADC Web GUI.
Open a browser window with the NSIP. After login head to **Security** -> **Citrix Web App Firewall**.
You should be able to see the Two profiles and two policies.
you can view further details.

![NetScaler-GUI](https://github.com/citrix/terraform-cloud-scripts/blob/master/assets/instruqt_lab/netscaler-adc-basic-waf-using-terraform/adc-gui-appfwpolicy1.png?raw=true)

![NetScaler-GUI](https://github.com/citrix/terraform-cloud-scripts/blob/master/assets/instruqt_lab/netscaler-adc-basic-waf-using-terraform/adc-gui-appfwprofile1.png?raw=true)


Conclusion
==========

In this challenge we demonstrated how to apply a basic WAF policy in load balancing level to protect our Applications from an SQL Injection attack. In the following challenge we are going to see how we can enable a WAF policy to log all SQL Injection attacks in context switching level but allow the request to pass through ADC.

Proceed to the next challenge.