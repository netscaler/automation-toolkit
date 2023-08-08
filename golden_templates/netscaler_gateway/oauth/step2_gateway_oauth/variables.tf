
variable "primary_netscaler_nsip" {
  type        = string
  description = "primary_netscaler_nsip"
}

variable "servercertfile_name" {
  type        = string
  description = "server certificate file name"
}
variable "servekeyfile_name" {
  type        = string
  description = "server key file name"
}

variable "intermediate_certificate1_name" {
  type        = string
  description = "intermediate_certificate1_name"
}

variable "intermediate_certificate2_name" {
  type        = string
  description = "intermediate_certificate2_name"
}

variable "gateway_certfile_name" {
  type        = string
  description = "gateway_certfile_name"
}
variable "gateway_keyfile_name" {
  type        = string
  description = "gateway_keyfile_name"
}



variable "snip_ip_address" {
  type        = string
  description = "SNIP IP Address"
}
variable "snip_netmask" {
  type        = string
  description = "SNIP Netmask"
}

# No need as there will be default route associated
# variable "route" {
#   type        = list(map(string))
#   description = "List of Route resource to configure"
# }

## SSL cert

variable "promptstring" {
  type        = string
  description = "systemparameter promptstring"
  default     = "%u@%h-%s"
}

variable "systemgroup1_name" {
  type        = string
  description = "Systemgroup1 name"
}
variable "systemgroup2_name" {
  type        = string
  description = "Systemgroup2 name"
}
variable "systemgroup3_name" {
  type        = string
  description = "Systemgroup3 name"
}
variable "systemgroup4_name" {
  type        = string
  description = "Systemgroup4 name"
}
variable "systemgroup5_name" {
  type        = string
  description = "Systemgroup5 name"
}

variable "management_authenticationldapaction_name" {
  type        = string
  description = "Management Authenticationldapaction Name"
  default     = "Management_LDAP_Server"
}
variable "management_authenticationldapaction_servername" {
  type        = string
  description = "Management Authenticationldapaction servername"
}
variable "management_authenticationldapaction_ldapbase" {
  type        = string
  description = "Management Authenticationldapaction ldapbase"
}
variable "management_authenticationldapaction_ldapbinddn" {
  type        = string
  description = "Management Authenticationldapaction ldapbinddn"
}
variable "management_authenticationldapaction_ldapbinddnpassword" {
  type        = string
  description = "Management Authenticationldapaction ldapbinddnpassword"
}
variable "management_authenticationldapaction_searchfilter" {
  type        = string
  description = "Management Authenticationldapaction searchfilter"
}


variable "snmpcommunity_name" {
  type        = string
  description = "snmpcommunity_name"
}
variable "snmpmanager1_ipaddress" {
  type        = string
  description = "Snmpmanager1 ipaddress"
}
variable "snmpmanager2_ipaddress" {
  type        = string
  description = "Snmpmanager2 ipaddress"
}

variable "snmpuser_name" {
  type        = string
  description = "Snmpuser name"
}
variable "snmpuser_authpasswd" {
  type        = string
  description = "Snmpuser authpasswd"
}
variable "snmpuser_privpasswd" {
  type        = string
  description = "Snmpuser privpasswd"
}

variable "snmptrap1_trapdestination" {
  type        = string
  description = "snmptrap1 trapdestination"
}
variable "snmptrap2_trapdestination" {
  type        = string
  description = "snmptrap2 trapdestination"
}

variable "auditsyslogaction_name" {
  type        = string
  description = "auditsyslogaction name"
}
variable "auditsyslogaction_serverip" {
  type        = string
  description = "auditsyslogaction serverip"
}

variable "dns_server1_ipaddress" {
  type        = string
  description = "Server1 ipaddress"
}

variable "dns_server2_ipaddress" {
  type        = string
  description = "Server2 ipaddress"
}

variable "server3_ipaddress" {
  type        = string
  description = "Server3 ipaddress"
}

variable "storefront_server1_ipaddress" {
  type        = string
  description = "Server4 ipaddress"
}

variable "storefront_server2_ipaddress" {
  type        = string
  description = "storefront_server2_ipaddress"
}

variable "ldap_server1_ipaddress" {
  type        = string
  description = "ldap server1 ipaddress"
}

variable "ldap_server2_ipaddress" {
  type        = string
  description = "Server7 ipaddress"
}

variable "radius_server_ipaddress" {
  type        = string
  description = "Server8 ipaddress"
}


variable "dns_tcp_lbvserver_name" {
  type        = string
  description = "lbvserver1 name"
  default     = "DNS_TCP_LB"
}
variable "dns_tcp_lbvserver_servicetype" {
  type        = string
  description = "lbvserver1 servicetype"
  default     = "DNS_TCP"
}
variable "dns_tcp_lbvserver_ipv46" {
  type        = string
  description = "lbvserver1 ipv46"
  default     = "0.0.0.0"
}

variable "dns_udp_lbvserver_name" {
  type        = string
  description = "lbvserver2 name"
  default     = "DNS_UDP_LB"
}
variable "dns_udp_lbvserver_servicetype" {
  type        = string
  description = "lbvserver2 servicetype"
  default     = "DNS"
}
variable "dns_udp_lbvserver_ipv46" {
  type        = string
  description = "lbvserver2 ipv46"
  default     = "0.0.0.0"
}

variable "storefront_lbvserver_name" {
  type        = string
  description = "storefront_lbvserver name"
  default     = "StoreFront_LB"
}
variable "storefront_lbvserver_servicetype" {
  type        = string
  description = "storefront_lbvserver servicetype"
  default     = "SSL"
}
variable "storefront_lbvserver_ipv46" {
  type        = string
  description = "storefront_lbvserver ipv46"
}

variable "ldap_lbvserver_name" {
  type        = string
  description = "ldap_lbvserver name"
  default     = "LDAP_LB"
}
variable "ldap_lbvserver_servicetype" {
  type        = string
  description = "ldap_lbvserver servicetype"
  default     = "TCP"
}
variable "ldap_lbvserver_ipv46" {
  type        = string
  description = "ldap_lbvserver ipv46"
}

variable "ldap_tls_offload_lbvserver_name" {
  type        = string
  description = "ldap_tls_offload_lbvserver name"
  default     = "LDAP_TLS_Offload_LB"
}
variable "ldap_tls_offload_lbvserver_servicetype" {
  type        = string
  description = "ldap_tls_offload_lbvserver servicetype"
  default     = "TCP"
}
variable "ldap_tls_offload_lbvserver_ipv46" {
  type        = string
  description = "ldap_tls_offload_lbvserver ipv46"
}

variable "radius_lbvserver_name" {
  type        = string
  description = "radius_lbvserver name"
  default     = "RADIUS_LB"
}
variable "radius_lbvserver_servicetype" {
  type        = string
  description = "radius_lbvserver servicetype"
  default     = "RADIUS"
}
variable "radius_lbvserver_ipv46" {
  type        = string
  description = "radius_lbvserver ipv46"
}

variable "dns_tcp_lbmonitor_name" {
  type        = string
  description = "dns_tcp_lbmonitor name"
  default     = "DNS_TCP_monitor"
}
variable "dns_tcp_lbmonitor_type" {
  type        = string
  description = "dns_tcp_lbmonitor type"
  default     = "DNS-TCP"
}
variable "dns_tcp_lbmonitor_query" {
  type        = string
  description = "dns_tcp_lbmonitor query"
}

variable "dns_udp_lbmonitor_name" {
  type        = string
  description = "dns_udp_lbmonitor name"
  default     = "DNS_UDP_monitor"
}
variable "dns_udp_lbmonitor_type" {
  type        = string
  description = "dns_udp_lbmonitor type"
  default     = "DNS"
}
variable "dns_udp_lbmonitor_query" {
  type        = string
  description = "dns_udp_lbmonitor query"
}

variable "storefront_lbmonitor_name" {
  type        = string
  description = "storefront_lbmonitor name"
  default     = "StoreFront_monitor"
}
variable "storefront_lbmonitor_type" {
  type        = string
  description = "storefront_lbmonitor type"
  default     = "STOREFRONT"
}
variable "storefront_lbmonitor_dispatcherip" {
  type        = string
  description = "storefront_lbmonitor dispatcherip"
  default     = "127.0.0.1"
}
variable "storefront_lbmonitor_storename" {
  type        = string
  description = "storefront_lbmonitor storename"
}


variable "ldap_lbmonitor_name" {
  type        = string
  description = "ldap_lbmonitor name"
  default     = "LDAP_MON"
}
variable "ldap_lbmonitor_type" {
  type        = string
  description = "ldap_lbmonitor type"
  default     = "LDAP"
}
variable "ldap_lbmonitor_dispatcherip" {
  type        = string
  description = "ldap_lbmonitor dispatcherip"
  default     = "127.0.0.1"
}
variable "ldap_lbmonitor_password" {
  type        = string
  description = "ldap_lbmonitor password"
}
variable "ldap_lbmonitor_basedn" {
  type        = string
  description = "ldap_lbmonitor basedn"
}
variable "ldap_lbmonitor_binddn" {
  type        = string
  description = "ldap_lbmonitor binddn"
}
variable "ldap_lbmonitor_filter" {
  type        = string
  description = "ldap_lbmonitor filter"
}

variable "radius_lbmonitor_name" {
  type        = string
  description = "radius_lbmonitor name"
  default     = "RADIUS_MON"
}
variable "radius_lbmonitor_type" {
  type        = string
  description = "radius_lbmonitor type"
  default     = "RADIUS"
}
variable "radius_lbmonitor_username" {
  type        = string
  description = "radius_lbmonitor username"
}
variable "radius_lbmonitor_password" {
  type        = string
  description = "radius_lbmonitor password"
}
variable "radius_lbmonitor_radkey" {
  type        = string
  description = "radius_lbmonitor radkey"
}


variable "gateway_authenticationldapaction_name" {
  type        = string
  description = "Gateway Authenticationldapaction Name"
  default     = "Gateway_LDAP_Server"
}
variable "gateway_authenticationldapaction_servername" {
  type        = string
  description = "Gateway Authenticationldapaction servername"
}
variable "gateway_authenticationldapaction_ldapbase" {
  type        = string
  description = "Gateway Authenticationldapaction ldapbase"
}
variable "gateway_authenticationldapaction_ldapbinddn" {
  type        = string
  description = "Gateway Authenticationldapaction ldapbinddn"
}
variable "gateway_authenticationldapaction_ldapbinddnpassword" {
  type        = string
  description = "Gateway Authenticationldapaction ldapbinddnpassword"
}
# variable "gateway_authenticationldapaction_searchfilter" {
#   type        = string
#   description = "Gateway Authenticationldapaction searchfilter"
# }

variable "authenticationradiusaction_name" {
  type        = string
  description = "Authenticationradiusaction name"
  default     = "Gateway_RADIUS_Server"
}
variable "authenticationradiusaction_serverip" {
  type        = string
  description = "Authenticationradiusaction serverip"
}
variable "authenticationradiusaction_radkey" {
  type        = string
  description = "Authenticationradiusaction radkey"
}


variable "authenticationoauthidpprofile_clientid" {
  type = string
  description = "authenticationoauthidpprofile clientid"
}
variable "authenticationoauthidpprofile_clientsecret" {
  type = string
  description = "authenticationoauthidpprofile clientsecret"
}
variable "authenticationoauthidpprofile_redirecturl" {
  type = string
  description = "authenticationoauthidpprofile redirecturl"
}
variable "authenticationoauthidpprofile_issuer" {
  type = string
  description = "authenticationoauthidpprofile issuer"
}
variable "authenticationoauthidpprofile_audience" {
  type = string
  description = "authenticationoauthidpprofile audience"
}

variable "gateway_vpnvserver_name" {
  type        = string
  description = "gateway_vpnvserver name"
  default     = "Gateway_vServer"
}
variable "gateway_vpnvserver_servicetype" {
  type        = string
  description = "gateway_vpnvserver servicetype"
  default     = "SSL"
}
variable "gateway_vpnvserver_ipv46" {
  type        = string
  description = "gateway_vpnvserver ipv46"
}

variable "vpnsessionaction1_name" {
  type        = string
  description = "Vpn sessionaction1 name"
  default     = "Native_Profile"
}
variable "vpnsessionaction1_wihome" {
  type        = string
  description = "Vpn sessionaction1 wihome"
}
variable "vpnsessionaction1_storefronturl" {
  type        = string
  description = "Vpn sessionaction1 storefronturl"
}

variable "vpnsessionaction2_name" {
  type        = string
  description = "Vpn sessionaction2 name"
  default     = "Web_Profile"
}
variable "vpnsessionaction2_wihome" {
  type        = string
  description = "Vpn sessionaction2 wihome"
}


variable "vpnsessionpolicy1_name" {
  type        = string
  description = "Vpn sessionpolicy1 name"
  default     = "Native_Policy"
}
variable "vpnsessionpolicy1_rule" {
  type        = string
  description = "Vpn sessionpolicy1 rule"
  default     = "HTTP.REQ.HEADER(\"User-Agent\").CONTAINS(\"CitrixReceiver\")"
}

variable "vpnsessionpolicy2_name" {
  type        = string
  description = "Vpn sessionpolicy2 name"
  default     = "Web_Policy"
}
variable "vpnsessionpolicy2_rule" {
  type        = string
  description = "Vpn sessionpolicy2 rule"
  default     = "true"
}

variable "vpnvserver_staserver" {
  type        = list(string)
  description = "vpnvserver_staserver"
}

variable "gateway_dtls_vpnvserver_name" {
  type        = string
  description = "gateway_dtls_vpnvserver name"
  default     = "Gateway_DTLS_vServer"
}
variable "gateway_dtls_vpnvserver_servicetype" {
  type        = string
  description = "gateway_dtls_vpnvserver servicetype"
  default     = "DTLS"
}
variable "gateway_dtls_vpnvserver_ipv46" {
  type        = string
  description = "gateway_dtls_vpnvserver ipv46"
}
