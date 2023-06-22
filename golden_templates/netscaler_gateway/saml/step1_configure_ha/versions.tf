# provider
terraform {
  required_providers {
    citrixadc = {
      source  = "citrix/citrixadc"
    }
  }
}

provider "citrixadc" {
  endpoint = format("http://%s", var.netscaler1_nsip)
  username = "<username>"
  password = "<password>"
}

provider "citrixadc" {
  alias    = "netscaler2"
  endpoint = format("http://%s", var.netscaler2_nsip)
  username = "<username>"
  password = "<password>"
}