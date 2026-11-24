data "google_secret_manager_secret_version" "ns_username" {
  secret = "ns-username"
}

data "google_secret_manager_secret_version" "ns_password" {
  secret = "ns-password"
}
