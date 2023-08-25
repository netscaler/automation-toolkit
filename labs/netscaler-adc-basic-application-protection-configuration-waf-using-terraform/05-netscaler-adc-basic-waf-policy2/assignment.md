---
slug: netscaler-adc-basic-waf-policy2
id: 0pkjgqxfxicy
type: challenge
title: WAF Policies part 2
teaser: Create a WAF Policy to log all SQL Injection attacks that pass through content
  switching.
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

## Configure a WAF policy to log malicious requests.


In this challenge we will see how we can create WAF Policies to log an malicious request that goes through our content switching server without blocking the request. We are going to create an application firewall profile and policy that will enable `SQL Injection` protection for all types of applications (`HTML, XML, JSON`) and `LOG` malicious traffic. Our WAF will log all malicious requests that will go to both echoserver1 and echoserver2:

- If we send an SQL Injection attack to `{VIP}/echoserver1` or `{VIP}/echoserver2` we are expecting WAF to log the malicious request.
- Additionally in the case `{VIP}/echoserver1`  it should also block the request as we already have a policy in place that protects `{VIP}/echoserver1` in load balancing level.



Learn more about ADC WAF [here](https://docs.netscaler.com/en-us/citrix-adc/current-release/application-firewall/introduction-to-citrix-web-app-firewall.html).


Terraform configuration
=======================
In this Challenge we will create an Application Firewall profile that will not block the incoming request but it will just log the information of the client request that is trying to exploit SQL injection. So, this profile will be linked to Application Firewall profile `tf_appfwpolicy2`, that contains the rule, and if the rule matches with the request then the profile action will be performed.

We will then bind this policy with the content switching virtual server, that was previously created `tf_csvserver`.

So, to achieve this perform the following in operations.

Go to the `code Editor` tab and update the following changes.
Open `main.tf` file.

So, We need to create new AppFW (Application Firewall) Policy, Application Firewall profile and also bind the content switching virtual server `tf_csvserver`  to the Application Firewall policy. So to achieve this add the resource block to the `main.tf` file

```hcl

resource "citrixadc_appfwprofile" "tf_appfwprofile2" {
  name           = var.appfwprofile2_name
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
    "log",
    "stats",
  ]
  jsonsqlinjectiontype = "SQLSplCharANDKeyword"
  jsonxssaction = [
    "block",
    "log",
    "stats",
  ]
  logeverypolicyhit = "OFF"
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
    "log",
    "stats",
  ]
  sqlinjectionchecksqlwildchars     = "OFF"
  sqlinjectionparsecomments         = "checkall"
  sqlinjectiontransformspecialchars = "OFF"
  sqlinjectiontype                  = "SQLSplCharANDKeyword"
  starturlaction = [
    "log",
    "stats",
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
resource "citrixadc_appfwpolicy" "tf_appfwpolicy2" {
  name        = var.appfwpolicy2_name
  profilename = citrixadc_appfwprofile.tf_appfwprofile2.name
  rule        = var.appfwpolicy2_rule
}

resource "citrixadc_csvserver_appfwpolicy_binding" "tf_bind1" {
  name                   = citrixadc_csvserver.tf_csvserver.name
  policyname             = citrixadc_appfwpolicy.tf_appfwpolicy2.name
  priority               = 100
  gotopriorityexpression = "END"
}
```


Then open the `variables.tf` file.
We need to create a variable block for the `cspolicy3_name` and `cspolicy3_rule` variables.

So, add the below code in the `variables.tf` file.
```hcl
variable "appfwpolicy2_name" {
  type        = string
  description = "Appfw Policy2 name"
}
variable "appfwpolicy2_rule" {
  type        = string
  description = "Appfw Policy2 rule"
}
variable "appfwprofile2_name" {
  type        = string
  description = "Appfw Profile2 rule"
}
```

Then, open the `example.tfvars` file.
Here we need to set the values of the variables. So, add the below lines in `example.tfvars` file.
```hcl
appfwpolicy2_name = "tf_appfwpolicy2"
appfwpolicy2_rule = "HTTP.REQ.URL.STARTSWITH(\"/echoserver2\")&&HTTP.REQ.URL.CONTAINS(\"aspx?\")"

appfwprofile2_name = "tf_appfwprofile2"

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

## Verifying using cURL

Lets Verify the Configuration in the Bastion Host CLI  through CURL command.
Go to Bastion Host CLI  and type the following Curl command.

Note: Replace  the VIP in cURL command with the VIP address present in the `NetScaler ADC data` tab while executing the below command


1. To check the WAF configuration for the `echoserver1`, we will verify with the curl command for SQL exploitation, in this case it should block the request, and log the information.
```bash
curl -vi {VIP}/echoserver1/user.aspx?id=1%3B%20DROP%20TABLE%20users
```
![curl-echoserver1](https://github.com/citrix/terraform-cloud-scripts/blob/master/assets/instruqt_lab/netscaler-adc-basic-waf-using-terraform/curl-echoserver1.png?raw=true)

2. To check the same request to the `echoserver2`, in this case it should execute the command and get the response as usual.

```bash
curl -vi {VIP}/echoserver2/user.aspx?id=1%3B%20DROP%20TABLE%20users
```
![curl-echoserver2](https://github.com/citrix/terraform-cloud-scripts/blob/master/assets/instruqt_lab/netscaler-adc-basic-waf-using-terraform/curl-echoserver2.png?raw=true)

3. To check the logs perform the following commands in the Bastion Host CLI tab.
- ssh to the NetScaler using NSIP which is the management IP that you can find on the NetScaler ADC data tab.
```bash
ssh nsroot@<NSIP>
```
provide the password as `verysecret`.
- Get into shell interface by just typing `shell`
- Type the below commands for the logs
```bash
tail -f  /var/log/ns.log
```

As you execute the above curl commands for SQL attach the logs gets stored in the above mentioned `ns.log` file.

![log-echoserver1](https://github.com/citrix/terraform-cloud-scripts/blob/master/assets/instruqt_lab/netscaler-adc-basic-waf-using-terraform/log-echoserver1.png?raw=true)

![log-echoserver2](https://github.com/citrix/terraform-cloud-scripts/blob/master/assets/instruqt_lab/netscaler-adc-basic-waf-using-terraform/log-echoserver2.png?raw=true)


## Inspect Configuration through NetScaler Web GUI

You can also inspect the same information through the
NetScaler ADC Web GUI.
Open a browser window with the NSIP. After login head to **Security** -> **Citrix Web App Firewall**.
You should be able to see the two content-switching policies.
you can view further details.

![NetScaler-GUI](https://github.com/citrix/terraform-cloud-scripts/blob/master/assets/instruqt_lab/netscaler-adc-basic-waf-using-terraform/adc-gui-appfwpolicy2.png?raw=true)

![NetScaler-GUI](https://github.com/citrix/terraform-cloud-scripts/blob/master/assets/instruqt_lab/netscaler-adc-basic-waf-using-terraform/adc-gui-appfwprofile2.png?raw=true)

Conclusion
==========

In this challenge we demonstrated how to apply a basic WAF policy in content switching level to log all SQL Injection attack. Now that we covered both use cases we will see how we can remove all configurations managed through Terraform.

Proceed to the next challenge.