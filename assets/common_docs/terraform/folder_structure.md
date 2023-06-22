# Folder Structure

- `main.tf` describes the actual config objects to be created. The attributes of these resources are either hard coded or looked up from input variables in `example.tfvars`
- `variables.tf` describes the input variables to the terraform config. These can have defaults
- `versions.tf` is used to specify the contains version requirements for Terraform and providers.
- `example.tfvars` has the inputs for variables specified in `variables.tf`. For variables not defined in this file, default values will be taken.
- `outputs.tf` contains the outputs from the resources created in `main.tf`