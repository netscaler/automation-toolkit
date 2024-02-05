# provider
terraform {
  required_providers {
    citrixadc = {
      source  = "citrix/citrixadc"
      version = "1.29.0"
    }
  }
}

provider "citrixadc" {
  endpoint = format("http://%s", var.primary_netscaler_ip)
  # username = "" # NS_LOGIN env variable
  # password = "" # NS_PASSWORD env variable
}


