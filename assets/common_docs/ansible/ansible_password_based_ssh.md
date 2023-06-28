# For Password-based SSH authentication: 

1. Install `sshpass`
2. Run 
```
ansible-playbook <yaml_file> -i <inventory_file> --ask-pass
```