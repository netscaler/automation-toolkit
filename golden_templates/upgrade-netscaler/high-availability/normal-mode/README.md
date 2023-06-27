# Normal NetScaler Upgrade support for high availability pair using Ansible-Playbook

## Prerequisites

1. Two NetScalers should be in High-Availability mode.
2. Ns build Image should be present in both the NetScalers. If in case you don't have the build image available locally please refer [here](https://www.citrix.com/downloads/citrix-adc/) to download the Image. After you download the build, upload it to the NetScaler and Update the ansible-playbook yaml file providing the path and the file name of the build Image.
3. Password-less SSH authentication between the controller node (system in which you are running ansiblee playbook) and the NetScalers. For more info on how to do that refer [here](https://github.com/citrix/citrix-adc-ansible-modules#usage)
4. Instaling ADC modules and plugins
```bash
ansible-galaxy collection install git+https://github.com/citrix/citrix-adc-ansible-modules.git#/ansible-collections/adc
```

## Usage with demo video

<a href="https://youtu.be/mqbfWsaX5Xc"><img src="https://www.freepnglogos.com/uploads/youtube-logo-hd-8.png" alt="Upgrade NetScaler High Availability Pair - Normal Mode - Using Ansible-Playbook" width="300"></a>


1. Edit the inventory file with the NSIP of the NetScalers.
2. Update the yaml file with the build_location and build_file_name, referring to the path and file name of the build image.
2. Run 
```bash
ansible-playbook ha_upgrade.yaml -i inventory.txt
```


## Further Reference

* Upgrade a high availability pair [documentation](https://docs.netscaler.com/en-us/citrix-adc/current-release/upgrade-downgrade-citrix-adc-appliance/upgrade-downgrade-ha-pair.html)
* Video Reference on how to run this ansible-playbook [HERE](https://youtu.be/mqbfWsaX5Xc)
