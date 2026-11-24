# secret manager outputs
output "ns_username" {
  value     = data.google_secret_manager_secret_version.ns_username.secret_data
  sensitive = true
}

output "ns_password" {
  value     = data.google_secret_manager_secret_version.ns_password.secret_data
  sensitive = true
}
