---
slug: define-target-adc-configurations-in-ansible-playbook
id: knkwtxcwhukf
type: challenge
title: Define target Citrix ADC configurations in Ansible Playbook
teaser: Define target Citrix ADC configurations in Ansible Playbook
notes:
- type: text
  contents: Define target Citrix ADC configurations in Ansible Playbook
tabs:
- title: Code Editor
  type: code
  hostname: cloud-client
  path: /root/citrixadc-ansible-track/
- title: Terminal
  type: terminal
  hostname: cloud-client
- title: IP Details
  type: service
  hostname: cloud-client
  path: /adc.html
  port: 80
difficulty: basic
timelimit: 600
---
# Define target Citrix ADC configurations in Ansible Playbook

An Ansible® playbook is a blueprint of automation tasks — which are complex IT actions executed with limited or no human involvement. Ansible playbooks are executed on a set, group, or classification of hosts, which together make up an Ansible inventory.

Generally, below is the syntax to run a ansible-playbook

```
ansible-playbook  -i inventory.txt  <playbook.yaml>
```

where -

* `inventory.txt`: is a file where you can specify the IP/login/password of the Citrix ADC. You can also see the IP details of the backend servers.
* `playbook.yaml`: is the actual ansible-playbook config file that contains your target Citrix ADC configurations.

Click on the `Code Editor` tab to know the config files.

1. `inventory.txt` - contains the IP/password and other information for the provisioned Citrix ADC.
2. `citrixadc-first-time-password-reset.yaml` - This ansible-playbook is defined to reset the first-time-login password.
3. `citrixadc-setuplb.yaml` - This ansible-playbook create multiple entities inside Citrix ADC as follows -
    1. `citrix_adc_service` - 2 services inside Citrix ADC that are mapped to your backend servers.
    2. `citrix_adc_lb_vserver` - A load balancing server in Citrix ADC bound to the above 2 services. Any traffic hitting at VIP will be load balanced by this server and routed to either of the services/backend-servers.

[Click here](https://docs.citrix.com/en-us/citrix-adc/current-release/getting-started-with-citrix-adc/communicate-with-clients-servers.html) to learn more about Citrix ADC services, servicegroup and loadbalancing.

> Optionally, if you wish to change the Citrix ADC password, you can replace the text `verystrongpassword` in the `inventory.txt` file with that of your choice and do save the file by clicking on save button in the tab. If you opt to change the password, please remember the password for the rest of the track.

Once the target Citrix ADC configurations are defined in playbooks, we are all set to push these configs on the Citrix ADC. Let’s do that in next section.

Proceed next to run these playbook.