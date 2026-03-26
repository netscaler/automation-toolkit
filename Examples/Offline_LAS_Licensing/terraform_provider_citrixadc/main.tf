resource "citrixadc_nslaslicense_offline" "license" {
  entitlement_name = var.entitlement_name
  is_fips          = var.is_fips
  restricted_mode  = var.restricted_mode
  las_secrets_json = var.las_secrets_json
}

output "license_status" {
  description = "Status of the offline LAS license application."
  value       = citrixadc_nslaslicense_offline.license.status
}

output "license_blob_path" {
  description = "Local path on the Terraform host where the license blob was saved."
  value       = citrixadc_nslaslicense_offline.license.license_blob_path
}

output "netscaler_version" {
  description = "NetScaler software version detected on the appliance."
  value       = citrixadc_nslaslicense_offline.license.version
}

output "netscaler_build" {
  description = "NetScaler build number detected on the appliance."
  value       = citrixadc_nslaslicense_offline.license.build
}

output "lsguid" {
  description = "License Server GUID extracted from the appliance."
  value       = citrixadc_nslaslicense_offline.license.lsguid
}
