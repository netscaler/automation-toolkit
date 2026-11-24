variable "gcp_project" {
  description = "GCP project holding the Secret Manager secrets"
}

variable "region" {
  description = "GCP region"
}

variable "nsip" {
  description = "NetScaler Public Management IP"
}

variable "netscaler_private_vip" {
  description = "NetScaler Private VIP for the content switching vserver"
}

variable "csvserver_name" {
  description = "Name of the content switching vserver"
}

variable "ns_username_secret" {
  description = "Secret Manager secret name for the ns username"
}

variable "ns_password_secret" {
  description = "Secret Manager secret name for the ns password"
}
