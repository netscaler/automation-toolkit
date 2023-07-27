---
slug: install-prerequisites
id: vw3sdovybyhb
type: challenge
title: Installing Pre-requisites
teaser: Installing Pre-requisites
notes:
- type: text
  contents: Install Prerequisites
tabs:
- title: Terminal
  type: terminal
  hostname: cloud-client
- title: IP Details
  type: service
  hostname: cloud-client
  path: /adc.html
  port: 80
difficulty: basic
timelimit: 900
---
# Installing Pre-requisites

In this challenge, let us install the prerequisites required to run `ansible-playbooks` to configure the `citrix-adc-vpx` device.

All the pre-requisites can be found in our GitHub link below:
* https://github.com/citrix/citrix-adc-ansible-modules#installation

Pre-rquisites are:
1. Ansible software tool
2. Citrix ADC Python SDK
3. Citrix ADC Ansible modules

---

1. Install `ansible`
======================
To install `ansible`, there are many ways. You can find all the valid ways to install `ansible` in the below link.
* https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html

Here, let us install `ansible` via `pip`.

> TIP: Click on the below `code` to copy it to clipboard.

If not already active, click the `Terminal` tab.

Run the below commands to install `ansible`:

```
python -m pip install --upgrade pip
python -m pip install ansible==5.5.0
```

> The above command will take 3-4 minutes.
> ignore any WARNINGs if you get

After installing, you can verify if the installation is successful by the below command. The output will give you the version of the ansible tool installed.

```
ansible --version
```

---

2. Install `Citrix ADC Python SDK`
====================================
In this, we will install the `Citrix ADC Python SDK` to use `ansible` to configure `citrix adc` devices.

First, clone our `citrix-adc-ansible-modules` github repo

```
git clone https://github.com/citrix/citrix-adc-ansible-modules.git /tmp/citrix-adc-ansible-modules
```


Then, run the below command to install the `Citrix ADC Python SDK`.

```
pip install /tmp/citrix-adc-ansible-modules/deps/nitro-python-1.0_kamet.tar.gz
```

> ignore any WARNINGs if you get

---


3. Install `Citrix ADC Ansible Modules`
==========================================
Next, we will install `citrix-adc` ansible modules from `ansible-galaxy` hub by running the below command.

```
ansible-galaxy collection install git+https://github.com/citrix/citrix-adc-ansible-modules.git#/ansible-collections/adc
```
