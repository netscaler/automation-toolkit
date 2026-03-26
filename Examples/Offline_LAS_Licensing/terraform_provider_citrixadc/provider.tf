terraform {
  required_providers {
    citrixadc = {
      source  = "citrix/citrixadc"
      version = ">= 2.1.4"
    }
  }
}

provider "citrixadc" {
  endpoint             = "https://${var.nsip}"
  username             = var.nitro_user
  password             = var.nitro_pass
  insecure_skip_verify = true
}
