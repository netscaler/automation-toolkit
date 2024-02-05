# primary_netscaler_ip           = "10.10.10.141" # Let us give this IP over CLI

snip         = "10.10.10.172"
snip_netmask = "255.255.255.192"

web_server1_name       = "web-server-red"
web_server1_port       = 80
web_server1_ip         = "10.10.10.181"
web_server1_serivetype = "HTTP"

web_server2_name       = "web-server-green"
web_server2_port       = 80
web_server2_ip         = "10.10.10.166"
web_server2_serivetype = "HTTP"

lbvserver_name        = "demo-lb"
lbvserver_ip          = "10.10.10.150"
lbvserver_port        = 80
lbvserver_servicetype = "HTTP"