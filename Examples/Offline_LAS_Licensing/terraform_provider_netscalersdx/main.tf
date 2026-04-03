resource "netscalersdx_nslaslicense_offline" "license" {
  entitlement_name = var.entitlement_name
  restricted_mode  = var.restricted_mode
  las_secrets_json = var.las_secrets_json
}

output "license_status" {
  description = "Status of the offline LAS license application."
  value       = netscalersdx_nslaslicense_offline.license.status
}

output "license_blob_path" {
  description = "Local path on the Terraform host where the license blob was saved."
  value       = netscalersdx_nslaslicense_offline.license.license_blob_path
}

output "netscalersdx_version" {
  description = "SDX software version detected on the appliance."
  value       = netscalersdx_nslaslicense_offline.license.version
}

output "netscalersdx_build" {
  description = "SDX build number detected on the appliance."
  value       = netscalersdx_nslaslicense_offline.license.build
}

output "lsguid" {
  description = "License Server GUID extracted from the appliance."
  value       = netscalersdx_nslaslicense_offline.license.lsguid
}
