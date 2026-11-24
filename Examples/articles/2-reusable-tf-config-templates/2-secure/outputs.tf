# secret manager outputs
output "ns_username_secret_version" {
  value = data.google_secret_manager_secret_version.ns_username.name
}

output "ns_password_secret_version" {
  value = data.google_secret_manager_secret_version.ns_password.name
}

output "Message" {
  value = "Thank you. NetScaler has been configured."
}
