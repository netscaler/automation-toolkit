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
  username = "<username>" # NS_LOGIN env variable
  password = "<password>" # NS_PASSWORD env variable
}

provider "citrixadc" {
  alias    = "netscaler2"
  endpoint = format("http://%s", var.netscaler2_nsip)
  username = "<username>" # NS_LOGIN env variable
  password = "<password>" # NS_PASSWORD env variable
}