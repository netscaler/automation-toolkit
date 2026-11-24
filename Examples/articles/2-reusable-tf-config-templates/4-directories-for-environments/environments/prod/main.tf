module "secrets" {
  source = "../../modules/secrets"
  ns_username_secret = var.ns_username_secret
  ns_password_secret = var.ns_password_secret

}
module "lb" {
  source = "../../modules/lb"

  netscaler_private_vip = var.netscaler_private_vip
  lbvserver_name = var.lbvserver_name
  servicegroup_name = var.servicegroup_name
  apps_private_ip_addresses = var.apps_private_ip_addresses
}
