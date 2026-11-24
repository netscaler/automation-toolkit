variable "nsip" {
  description = "NetScaler Public Management IP"
}

variable "netscaler_private_vip" {
  description = "NetScaler Private VIP"
}

variable "apps_private_ip_addresses" {
  description = "Private IP addresses for the internal Apps"
}

variable "lbvserver_name" {
  description = "Name of the lbvserver"
}

variable "servicegroup_name" {
  description = "Name of the service group"
}

variable "gcp_project" {
  description = "GCP project holding the Secret Manager secrets"
}

variable "region" {
  description = "GCP region"
}