# NetScaler SDX connection
variable "sdx_host" {
  type        = string
  description = "Management IP of the NetScaler SDX appliance."
}

variable "sdx_username" {
  type        = string
  description = "SDX admin username. Must be 'nsroot' for offline LAS licensing."
  default     = "nsroot"
}

variable "sdx_password" {
  type        = string
  description = "Password for the nsroot account."
  sensitive   = true
}

# Offline LAS license parameters
variable "entitlement_name" {
  type        = string
  description = "Entitlement name for the SDX license as listed in LAS customer entitlements (e.g. 'SDX 9195 Premium'). Must start with a valid SDX model prefix: SDX 89, SDX 91, SDX 92, SDX 14, SDX 15, SDX 16, SDX 17, or SDX 26."
}

variable "restricted_mode" {
  type        = bool
  description = "When true, uses JSON-based restricted offline activation instead of file upload. Use in environments where file uploads to the Citrix Cloud LAS API are blocked."
  default     = false
}

variable "las_secrets_json" {
  type        = string
  description = "Absolute or module-relative path to the las_secrets.json credentials file."
  default     = "./las_secrets.json"
}
