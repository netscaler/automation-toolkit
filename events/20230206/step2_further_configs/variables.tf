variable "primary_netscaler_ip" {
  type        = string
  description = "Primary NetScaler NSIP"
}
variable "snip" {
  type        = string
  description = "NetScaler SNIP"
}
variable "snip_netmask" {
  type        = string
  description = "SNIP NetMask"
}
variable "web_server1_name" {
  type       = string
  description = "Web Server1 Name"
}
variable "web_server1_port" {
  type        = string
  description = "Web Server1 Port"
}
variable "web_server1_ip" {
  type        = string
  description = "Web Server1 IP"
}
variable "web_server1_serivetype" {
  type        = string
  description = "Web Server1 ServiceType"
}
variable "web_server2_name" {
  type        = string
  description = "Web Server2 Name"

}
variable "web_server2_port" {
  type        = string
  description = "Web Server2 PORT"

}
variable "web_server2_ip" {
  type        = string
  description = "Web Server2 IP"

}
variable "web_server2_serivetype" {
  type        = string
  description = "Web Server2 SERVICETYPE"

}
variable "lbvserver_name" {
  type        = string
  description = "LBVserver Name"

}
variable "lbvserver_ip" {
  type        = string
  description = "LBVvserver IP"

}
variable "lbvserver_port" {
  type        = number
  description = "Which Port number LBVserver is serving traffic?"

}
variable "lbvserver_servicetype" {
  type        = string
  description = "Which SERIVCETYPE LBVserver is serving traffic?"
}
