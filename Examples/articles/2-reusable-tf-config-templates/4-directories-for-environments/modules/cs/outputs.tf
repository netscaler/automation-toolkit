# cs output
output "csvserver_name" {
  value = citrixadc_csvserver.cs_vserver.name
}

output "CS-Configuration-Message" {
  value = "Thank you. Content Switching has been configured."
}
