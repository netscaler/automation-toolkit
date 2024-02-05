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
  endpoint = format("http://%s", var.netscaler1_nsip)
  # username = "" # NS_LOGIN env variable
  # password = "" # NS_PASSWORD env variable
}

provider "citrixadc" {
  alias    = "netscaler2"
  endpoint = format("http://%s", var.netscaler2_nsip)
  # username = "" # NS_LOGIN env variable
  # password = "" # NS_PASSWORD env variable
}