variable "netscaler_private_vip" {
  description = "NetScaler Private VIP. Leave unset for a non-addressable lbvserver behind content switching"
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
