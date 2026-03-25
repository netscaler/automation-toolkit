# NetScaler connection
variable "nsip" {
  type        = string
  description = "Management IP of the NetScaler ADC appliance."
}

variable "nitro_user" {
  type        = string
  description = "NetScaler admin username. Must be 'nsroot' for offline LAS licensing."
  default     = "nsroot"
}

variable "nitro_pass" {
  type        = string
  description = "Password for the nsroot account."
  sensitive   = true
}

# Offline LAS license parameters
variable "entitlement_name" {
  type        = string
  description = "Entitlement name for the VPX/MPX license as listed in LAS customer entitlements (e.g. 'VPX 10000 Premium', 'MPX 9130 Premium'). Must start with a valid model prefix: VPX, MPX 59, MPX 89, MPX 91, MPX 92, MPS 14/25, MPX 15/16/17/26, FIPS MPX 14/15/16/89/91/92."
}

variable "is_fips" {
  type        = bool
  description = "Set to true for FIPS-enabled VPX appliances. Not required for MPX 14K devices."
  default     = false
}

variable "las_secrets_json" {
  type        = string
  description = "Absolute or module-relative path to the las_secrets.json credentials file."
  default     = "./las_secrets.json"
}
