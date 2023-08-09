terraform {
  required_providers {
    citrixadc = {
      source = "citrix/citrixadc"
    }
  }
}
provider "citrixadc" {
  endpoint             = "https://${var.primary_netscaler_nsip}"
  username             = "<username>" # NS_LOGIN env variable
  password             = "<password>" # NS_PASSWORD env variable
  insecure_skip_verify = true
}
