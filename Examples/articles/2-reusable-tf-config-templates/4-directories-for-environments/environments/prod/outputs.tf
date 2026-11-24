output "Message" {
  value = "Thank you. Prod NetScaler has been configured."
}

# Read by environments/common through terraform_remote_state
output "lbvserver_name" {
  value = module.lb.lbvserver_name
}
