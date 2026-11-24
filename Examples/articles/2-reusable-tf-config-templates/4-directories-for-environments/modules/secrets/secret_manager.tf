data "google_secret_manager_secret_version" "ns_username" {
  secret = var.ns_username_secret
}

data "google_secret_manager_secret_version" "ns_password" {
  secret = var.ns_password_secret
}
