# lb output
output "LB-Configuration-Message" {
  value = "Thank you. Load Balancing has been configured."
}

output "lbvserver_name" {
  value = citrixadc_lbvserver.terraform_test_lb.name
}
