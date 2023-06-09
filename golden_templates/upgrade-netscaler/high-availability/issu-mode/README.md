# In Service Software Upgrade(ISSU) support for high availability using Ansible-Playbook

## Prerequisites

1. Ansible version should be 4.9.0. 
```bash
pip install ansible==4.9.0
```
2. Two NetScalers should be in High-Availability mode.
3. Ns build Image should be present in both the NetScalers. If in case you don't have the build image available locally please refer [HERE](https://www.citrix.com/downloads/citrix-adc/) to download the Image. After you download the build, upload it to the NetScaler and Update the ansible-playbook yaml file providing the path and the file name of the build Image.
4. Password-less SSH authentication between the controller node (system in which you are running ansiblee playbook) and the NetScalers. For more info on how to do that refer [HERE](https://github.com/citrix/citrix-adc-ansible-modules#usage)
5. Instaling ADC modules and plugins
```bash
ansible-galaxy collection install git+https://github.com/citrix/citrix-adc-ansible-modules.git#/ansible-collections/adc
```

## Usage with demo video

<a href="https://youtu.be/lYuo9s76-PM"><img src="https://www.freepnglogos.com/uploads/youtube-logo-hd-8.png" alt="Upgrade NetScaler High Availability Pair - ISSU Mode - Using Ansible-Playbook" width="300"></a>

1. Edit the inventory file with the NSIP of the NetScalers.
2. Update the yaml file with the build_location and build_file_name, referring to the path and file name of the build image.
2. Run 
```bash
ansible-playbook issu_upgrade.yaml -i inventory.txt
```

## Further Reference

* Upgrade a high availability pair [documentation](https://docs.netscaler.com/en-us/citrix-adc/current-release/upgrade-downgrade-citrix-adc-appliance/issu-high-availability.html)
* Video Reference on how to run this ansible-playbook [HERE](https://youtu.be/lYuo9s76-PM)


## For Password-based SSH authentication: 

Refer [HERE](../../../../assets/common_docs/ansible/ansible_password_based_ssh.md)