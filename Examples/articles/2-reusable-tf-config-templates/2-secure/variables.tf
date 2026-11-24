variable "nsip" {
  description = "NetScaler Public Management IP"
}

variable "netscaler_private_vip" {
  description = "NetScaler Private VIP"
}

variable "apps_private_ip_addresses" {
  description = "Private IP addresses for the internal Apps"
}

variable "gcp_project" {
  description = "GCP project"
}

variable "region" {
  description = "GCP region"
}