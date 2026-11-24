variable "gcp_project" {
  description = "GCP project holding the Secret Manager secrets"
}

variable "nsip" {
  description = "NetScaler Public Management IP"
}

variable "netscaler_private_vip" {
  description = "NetScaler Private VIP. Leave unset when the common content switching vserver owns the VIP"
  default     = null
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

variable "ns_username_secret" {
  description = "Secret Manager secret name for prod ns username"
}

variable "ns_password_secret" {
  description = "Secret Manager secret name for prod ns password"
}

variable "region" {
  description = "GCP region"
}