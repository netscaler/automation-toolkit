terraform {
  required_providers {
    citrixadc = {
      source = "citrix/citrixadc"
    }
  }
}
provider "citrixadc" {
  endpoint = "http://${var.primary_netscaler_nsip}"
  username = "<username>"
  password = "<password>"
}
