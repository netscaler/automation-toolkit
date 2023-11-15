terraform {
  required_providers {
    citrixadc = {
      source = "citrix/citrixadc"
    }
  }
}

provider "citrixadc" {
  # The endpoint and the username is already configured in Terraform Cloud as Env variables
  # endpoint = "http://..."
  # username = "secret"
  password = var.NS_PASSWORD
}