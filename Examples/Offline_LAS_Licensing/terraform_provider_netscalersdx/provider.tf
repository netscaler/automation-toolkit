terraform {
  required_providers {
    netscalersdx = {
      source  = "netscaler/netscalersdx"
      version = ">= 0.7.5"
    }
  }
}

provider "netscalersdx" {
  host       = "https://${var.sdx_host}" # Optionally use NETSCALERSDX_HOST env var
  username   = var.sdx_username          # Optionally use NETSCALERSDX_USERNAME env var
  password   = var.sdx_password          # Optionally use NETSCALERSDX_PASSWORD env var
  ssl_verify = false                     # Optionally use NETSCALERSDX_SSL_VERIFY env var
}
