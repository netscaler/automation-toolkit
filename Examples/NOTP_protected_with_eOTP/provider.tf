terraform {
  required_providers {
    citrixadc = {
      source = "citrix/citrixadc"
    }
  }
}
provider "citrixadc" {
  endpoint = "http://192.168.123.150:80"
  username = "nsroot"
  password = "training"
}