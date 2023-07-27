---
slug: environment-setup
id: nyfc2rdsotbx
type: challenge
title: Provision Citrix ADC VPX
teaser: Environment Setup - Deploy Citrix ADC VPX and a pair of web-apps for you.
notes:
- type: text
  contents: Environment Setup - Deploy Citrix ADC VPX and a pair of web-apps for you.
tabs:
- title: IP Details
  type: service
  hostname: cloud-client
  path: /adc.html
  port: 80
difficulty: basic
timelimit: 300
---
Welcome to "**Deliver Apps with Citrix ADC and Ansible**" lab.

In this lab, we have provisioned -

1. Citrix ADC VPX
   1. `Citrix ADC NSIP (Management login) IP` for management access.
   2. `Citrix ADC VIP (load balancer) Client IP` is the frontend IP for your apps in the backend-servers.
2. Two backend servers for you.

You can check out the **details in the `IP Details` tab.**

**As part of the lab, we will achieve the following** :

1. Change Citrix ADC VPX login password.
2. Configure two services for the above backend servers.
3. Configure a load balancer to deliver the backend servers over internet.

Let us get started. Please click `Next` to proceed.
