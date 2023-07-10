# Normal NetScaler Upgrade support for high availability pair using Ansible-Playbook

## Prerequisites

1. Ansible version should be 4.9.0. 
```bash
pip install ansible==4.9.0
```
2. Two NetScalers should be in High-Availability mode.
3. Regarding NetScaler build there are two options:

    a. NetScaler build image is present in both primary and secondary NetScalers.    
    * Update the [variables.yaml](./variables.yaml) file with `netscaler_build_location` and `netscaler_build_file_name` attributes to reflect the path and file name of the build image currently present in NetScaler, respectively
    * Set the `want_to_copy_build` attribute's value to `no` in the same [variables.yaml](./variables.yaml) file.

    b. NetScaler build image is not present in both primary and secondary NetScalers
    * Please refer [HERE](https://www.citrix.com/downloads/citrix-adc/) to download the build image. 
    * After downloading the build, replace the values of the attributes `want_to_copy_build` and `local_build_file_full_path_with_name` in the [variables.yaml](./variables.yaml) file with `yes` and the full path with name of the build that is now on the local system, respectively.


4. Passwordless SSH authentication between the NetScalers and the control node(system in which the ansible-playbook is running). For additional information, see [HERE](https://github.com/citrix/citrix-adc-ansible-modules/tree/887afdef75865a0ebd4bccb9c759a4b06689107a#usage).
5. Instaling ADC modules and plugins
```bash
ansible-galaxy collection install git+https://github.com/citrix/citrix-adc-ansible-modules.git#/ansible-collections/adc
```
6. By default, Python is installed in the directory `/var/python/bin/python` in NetScaler, but if it is located elsewhere, alter the `netscaler_python_path` variable value in the [variables.yaml](./variables.yaml) file with the path to the Python.

## Usage with demo video

<a href="https://youtu.be/mqbfWsaX5Xc"><img src="https://www.freepnglogos.com/uploads/youtube-logo-hd-8.png" alt="Upgrade NetScaler High Availability Pair - Normal Mode - Using Ansible-Playbook" width="300"></a>


1. Edit the [inventory.ini](./inventory.ini) file with the NetScaler credentials.
2. Update the [variable.yaml](./variables.yaml) file with the necessary inputs.
2. Run the below command
```bash
ansible-playbook ha_upgrade.yaml -i inventory.ini
```


## For Password-based SSH authentication: 

Refer [HERE](../../../../assets/common_docs/ansible/ansible_password_based_ssh.md)

## Troubleshooting
* `No space left on device` error
    * In order to complete tasks, Ansible will copy temporary files to the NetScaler. Therefore, `/root/` will be the default temporary directory. Ansible will complain if the NetScaler's `/root/` has less memory available. The [ansible.cfg](./ansible.cfg) file allows to modify the temporary directory. The steps are listed below.
    * Temporary directory to use on targets when executing tasks:   
    You need to add the below lines into [ansible.cfg](./ansible.cfg) file under [defaults] block.
    ```
    [defaults]
    remote_tmp = /var/
    ```
    * Refer [HERE](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/sh_shell.html#parameter-remote_tmp) for additional information on `remote_tmp`.



## Further Reference

* Upgrade a high availability pair [NetScaler documentation](https://docs.netscaler.com/en-us/citrix-adc/current-release/upgrade-downgrade-citrix-adc-appliance/upgrade-downgrade-ha-pair.html)
* Video Reference on how to run this ansible-playbook [HERE](https://youtu.be/mqbfWsaX5Xc)

