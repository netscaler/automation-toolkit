variable "csvserver_name" {
  description = "Name of the content switching vserver"
}

variable "netscaler_private_vip" {
  description = "NetScaler Private VIP for the content switching vserver"
}

variable "routes" {
  description = "Map of route name to the URL path prefix, target lbvserver and policy priority"
  type = map(object({
    path           = string
    lbvserver_name = string
    priority       = number
  }))
}

variable "default_lbvserver_name" {
  description = "lbvserver for requests that match no route. Leave unset for no fallback"
  default     = null
}

variable "strip_path_prefix" {
  description = "Remove the route path prefix before forwarding, e.g. /dev/x -> /x"
  type        = bool
  default     = true
}
