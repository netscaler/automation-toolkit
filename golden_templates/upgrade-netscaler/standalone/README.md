# Upgrade a NetScaler standalone appliance using Ansible-Playbook

## Prerequisites

1. Ansible version should be 4.9.0. 
```bash
pip install ansible==4.9.0
```
2. Ns build Image should be present in both the NetScalers. If in case you don't have the build image available locally please refer [HERE](https://www.citrix.com/downloads/citrix-adc/) to download the Image. After you download the build, upload it to the NetScaler and Update the ansible-playbook yaml file providing the path and the file name of the build Image.
3. Password-less SSH authentication between the controller node (system in which you are running ansiblee playbook) and the NetScalers. For more info on how to do that refer [HERE](https://github.com/citrix/citrix-adc-ansible-modules#usage)
4. Instaling ADC modules and plugins
```bash
ansible-galaxy collection install git+https://github.com/citrix/citrix-adc-ansible-modules.git#/ansible-collections/adc
```

## Usage

1. Edit the inventory file with the NSIP of the NetScalers.
2. Update the yaml file with the build_location and build_file_name, referring to the path and file name of the build image.
2. Run 
```bash
ansible-playbook standalone_upgrade.yaml -i inventory.txt`
```

## Further Reference

* Upgrade a NetScaler standalone appliance [documentation](https://docs.netscaler.com/en-us/citrix-adc/current-release/upgrade-downgrade-citrix-adc-appliance/upgrade-standalone-appliance.html)

## For Password-based SSH authentication: 

Refer [HERE](../../../../assets/common_docs/ansible/ansible_password_based_ssh.md)