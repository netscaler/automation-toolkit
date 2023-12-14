# Upgrade a NetScaler standalone appliance using Ansible-Playbook

## Prerequisites

1. Optionally, but recommended to have a seperate Python virtual environment for Ansible. This is to avoid any conflicts with the existing Python packages in the system.

   ```bash
   python3 -m venv ansible-4.9.0
   source ansible-4.9.0/bin/activate
   ```

2. Ansible version should be 4.9.0 and the NetScaler ADC modules should be installed. If not, please follow the below steps to install Ansible and NetScaler ADC modules.

   ```bash
   pip3 install ansible==4.9.0
   ```

3. NetScaler build image should be present either in the NetScaler or locally.

   > If in case you don't have the build image available locally please refer [HERE](https://www.citrix.com/downloads/citrix-adc/) to download the image.

4. Either of the below should be present
   a. Password-less SSH authentication between the controller node (system in which you are running ansible playbook) and the NetScalers.
   b. `sshpass` should be installed in the controller node (system in which you are running ansible playbook).

   > For Linux -- `sudo apt install sshpass`
   > For MacOS -- `brew install hudochenkov/sshpass/sshpass`

5. Instaling ADC modules and plugins

   ```bash
   ansible-galaxy collection install "git+https://github.com/citrix/citrix-adc-ansible-modules.git#/ansible-collections/adc,citrix.adc"
   ```

## Usage

1. Edit the `inventory.ini` file with the NSIP of the NetScalers.
2. Update the `variables.yaml` file with the build_location and build_file_name, referring to the path and file name of the build image.
3. Run

   ```bash
   ansible-playbook standalone_upgrade.yaml -i inventory.ini`
   ```

## Further Reference

- Upgrade a NetScaler standalone appliance [documentation](https://docs.netscaler.com/en-us/citrix-adc/current-release/upgrade-downgrade-citrix-adc-appliance/upgrade-standalone-appliance.html)

## For Password-based SSH authentication

Refer [HERE](../../../../assets/common_docs/ansible/ansible_password_based_ssh.md)
