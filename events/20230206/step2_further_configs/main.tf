# add ns ip snip
resource "citrixadc_nsip" "snip" {
  ipaddress = var.snip
  type      = "SNIP"
  netmask   = var.snip_netmask
}


# add a new SNIP to new primary and check if it syncs to secondary
# resource "citrixadc_nsip" "snip_test" {
#   ipaddress = "2.2.2.2"
#   type      = "SNIP"
#   netmask   = var.snip_netmask
# }


# add service1 - RED Web Server
resource "citrixadc_service" "web_server1" {
  name        = var.web_server1_name
  port        = var.web_server1_port
  ip          = var.web_server1_ip
  servicetype = var.web_server1_serivetype

  lbvserver = citrixadc_lbvserver.demo_lbvserver.name # bind web_server1 to lbvserver
}

# add service2 - GREEN Web Server
resource "citrixadc_service" "web_server2" {
  name        = var.web_server2_name
  port        = var.web_server2_port
  ip          = var.web_server2_ip
  servicetype = var.web_server2_serivetype

  lbvserver = citrixadc_lbvserver.demo_lbvserver.name # bind web_server2 to lbvserver
}

# ns enable lb
resource "citrixadc_nsfeature" "enable_lb" {
  lb = true
}

# add lbvserver
resource "citrixadc_lbvserver" "demo_lbvserver" {
  name        = var.lbvserver_name
  ipv46       = var.lbvserver_ip
  lbmethod    = "LEASTCONNECTION"
  port        = var.lbvserver_port
  servicetype = var.lbvserver_servicetype
}
