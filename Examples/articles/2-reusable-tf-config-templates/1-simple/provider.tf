terraform {
  required_providers {
    citrixadc = {
      source = "citrix/citrixadc"
      version = "3.0.3"
    }
  }
}


# Use https and non default password
provider "citrixadc" {
  endpoint = format("https://%s",var.nsip)
  username = var.ns_username
  password = var.ns_password

  # Do not error due to non signed ADC TLS certificate
  # Can skip this if ADC TLS certificate is trusted
  insecure_skip_verify = true
}
