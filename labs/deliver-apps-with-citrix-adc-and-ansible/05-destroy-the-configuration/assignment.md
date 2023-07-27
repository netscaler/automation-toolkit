---
slug: destroy-the-configuration
id: hkbbl92q7bvd
type: challenge
title: Destroy/Revert the configuration
teaser: Destroy/Revert the configuration
notes:
- type: text
  contents: Destroy/Revert the configuration
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
- title: Citrix ADC CLI Console
  type: terminal
  hostname: cloud-client
difficulty: basic
timelimit: 900
---
# Destroy/revert the configuration

We can also destroy/delete the Citrix ADC server configuration we did in the last step.
For that follow the procedure.

1. Go to the `Code Editor` tab
2. Click on **citrixadc-setuplb.yaml** file
3. Change the `state: present` to `state: absent` in all the ansible-tasks.
   > **Note:** There should be a __space__ between `state:` and `present` or `absent`
4. Save the file by clicking on the save-icon on filename's tab.
5. Go back to `Terminal` tab
6. Run the citrixadc-server.yaml playbook again.

```
cd /root/citrixadc-ansible-track/
```
```
ansible-playbook -i inventory.txt citrixadc-setuplb.yaml
```

Now backend servers no longer serve the user traffic hitting at VIP.

This completes the lab excercise. Check out our [GitHub repository](https://github.com/citrix/citrix-adc-ansible-modules/) to setup Ansible for Citrix ADC in your environment.

Also checkout our [sample playbooks](https://github.com/citrix/citrix-adc-ansible-modules/tree/master/samples) for Web Firewall, Multi Cluster and other advanced use-cases.

Thank you!
