resource "citrixadc_nsfeature" "tf_nsfeature" {
  lb = true
}
resource "citrixadc_nsip" "snip" {
  ipaddress = "10.11.2.4"
  type      = "SNIP"
  netmask   = "255.255.255.0"
}

resource "citrixadc_lbvserver" "tf_lbvserver" {
  name        = "tf_lbvserver"
  servicetype = "HTTP"
  ipv46       = "10.11.1.4"
  lbmethod    = "ROUNDROBIN"
  port        = 80
}
resource "citrixadc_service" "web-server-red" {
  name        = "web-server-red"
  port        = 80
  ip          = "10.11.2.4"
  servicetype = "HTTP"
}
resource "citrixadc_lbvserver_service_binding" "lb_binding1" {
  name        = citrixadc_lbvserver.tf_lbvserver.name
  servicename = citrixadc_service.web-server-red.name
}

resource "citrixadc_service" "web-server-green" {
  name        = "web-server-green"
  port        = 80
  ip          = "10.11.2.5"
  servicetype = "HTTP"
}
resource "citrixadc_lbvserver_service_binding" "lb_binding2" {
  name        = citrixadc_lbvserver.tf_lbvserver.name
  servicename = citrixadc_service.web-server-green.name
}
