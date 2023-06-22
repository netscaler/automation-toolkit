# SSL Certificates
servercertfile_name = "ns-server1.cert"
servekeyfile_name   = "ns-server1.key"

intermediate_certificate1_name = "remote_mycoolcompany_com.ca-bundle"
intermediate_certificate2_name = "remote_mycoolcompany_com.ca-bundle_ic1"

gateway_certfile_name = "remote_mycoolcompany_com.crt"
gateway_keyfile_name  = "remote.mycoolcompany.com_key3.txt"

# Basic Networking
snip_ip_address = "10.0.10.12"
snip_netmask    = "255.255.255.0"


# Centralized authentication for management access
systemgroup1_name = "NetScaler-ReadOnly"
systemgroup2_name = "NetScaler-Operator"
systemgroup3_name = "NetScaler-Network"
systemgroup4_name = "NetScaler-Sysadmin"
systemgroup5_name = "NetScaler-SuperUser"

management_authenticationldapaction_servername         = "10.0.10.13"
management_authenticationldapaction_ldapbase           = "CN=Users,DC=mycoolcompany,DC=local"
management_authenticationldapaction_ldapbinddn         = "NetScaler-Service-Account@mycoolcompany.local"
management_authenticationldapaction_ldapbinddnpassword = "secretpassword"
management_authenticationldapaction_searchfilter       = "memberOf:1.2.840.113556.1.4.1941:=CN=NetScaler-Admins,CN=Users,DC=mycoolcompany,DC=local"

# SNMP
snmpcommunity_name     = "public"
snmpmanager1_ipaddress = "10.50.50.10"
snmpmanager2_ipaddress = "10.50.50.20"

snmpuser_name       = "snmp_monitoring_user"
snmpuser_authpasswd = "secretpassword"
snmpuser_privpasswd = "secretpassword"

snmptrap1_trapdestination = "10.50.50.10"
snmptrap2_trapdestination = "10.50.50.20"

# Syslog
auditsyslogaction_name     = "syslog.mycoolcompany.internal"
auditsyslogaction_serverip = "10.0.10.1"

# DNS
dns_server1_ipaddress   = "8.8.8.8"
dns_server2_ipaddress   = "1.1.1.1"
dns_tcp_lbmonitor_query = "remote.mycoolcompany.com"
dns_udp_lbmonitor_query = "remote.mycoolcompany.com"

server3_ipaddress = "10.0.10.25"


#Load balancing configuration
storefront_lbvserver_ipv46       = "10.0.10.14"
ldap_lbvserver_ipv46             = "10.0.10.13"
ldap_tls_offload_lbvserver_ipv46 = "10.0.10.13"
radius_lbvserver_ipv46           = "10.0.10.13"

# Authentication Configuration
ldap_server1_ipaddress  = "192.168.3.10"
ldap_server2_ipaddress  = "192.168.3.11"
radius_server_ipaddress = "192.168.3.20"


# Store Front configuration
storefront_lbmonitor_storename = "Store"
storefront_server1_ipaddress   = "192.168.3.30"
storefront_server2_ipaddress   = "192.168.3.31"

ldap_lbmonitor_password = "secretpassword"
ldap_lbmonitor_basedn   = "CN=Users,DC=mycoolcompany,DC=local"
ldap_lbmonitor_binddn   = "NetScaler-Service-Account@mycoolcompany.local"
ldap_lbmonitor_filter   = "memberOf:1.2.840.113556.1.4.1941:=CN=NetScaler-Admins,CN=Users,DC=mycoolcompany,DC=local"

radius_lbmonitor_username = "RADIUS-Service-Account"
radius_lbmonitor_password = "secretpassword"
radius_lbmonitor_radkey   = "secretpassword"

gateway_authenticationldapaction_servername         = "10.0.10.13"
gateway_authenticationldapaction_ldapbase           = "CN=Users,DC=mycoolcompany,DC=local"
gateway_authenticationldapaction_ldapbinddn         = "NetScaler-Service-Account@mycoolcompany.local"
gateway_authenticationldapaction_ldapbinddnpassword = "secretpassword" ##

authenticationradiusaction_serverip = "10.0.10.13"
authenticationradiusaction_radkey   = "secretpassword"

gateway_vpnvserver_ipv46 = "10.0.10.15"

vpnsessionaction1_wihome        = "https://10.0.10.14/Citrix/StoreWeb"
vpnsessionaction1_storefronturl = "https://10.0.10.14/"

vpnsessionaction2_wihome = "https://10.0.10.14/Citrix/StoreWeb"


vpnvserver_staserver = ["http://192.168.3.30", "http://192.168.3.31"]

gateway_dtls_vpnvserver_ipv46 = "10.0.10.15"


## These defaults don't need to be modified

# promptstring = "%u@%h-%s"

# management_authenticationldapaction_name = "Management_LDAP_Server"

# dns_tcp_lbvserver_name        = "DNS_TCP_LB"
# dns_tcp_lbvserver_servicetype = "DNS_TCP"
# dns_tcp_lbvserver_ipv46       = "0.0.0.0"

# dns_udp_lbvserver_name        = "DNS_UDP_LB"
# dns_udp_lbvserver_servicetype = "DNS"
# dns_udp_lbvserver_ipv46       = "0.0.0.0"

# storefront_lbvserver_name        = "StoreFront_LB"
# storefront_lbvserver_servicetype = "SSL"

# ldap_lbvserver_name        = "LDAP_LB"
# ldap_lbvserver_servicetype = "TCP"

# ldap_tls_offload_lbvserver_name        = "LDAP_TLS_Offload_LB"
# ldap_tls_offload_lbvserver_servicetype = "TCP"

# radius_lbvserver_name        = "RADIUS_LB"
# radius_lbvserver_servicetype = "RADIUS"

# dns_tcp_lbmonitor_name = "DNS_TCP_monitor"
# dns_tcp_lbmonitor_type = "DNS-TCP"

# dns_udp_lbmonitor_name = "DNS_UDP_monitor"
# dns_udp_lbmonitor_type = "DNS"

# storefront_lbmonitor_name = "StoreFront_monitor"
# storefront_lbmonitor_type = "STOREFRONT"
# storefront_lbmonitor_dispatcherip = "127.0.0.1"

# ldap_lbmonitor_name = "LDAP_MON"
# ldap_lbmonitor_type = "LDAP"
# ldap_lbmonitor_dispatcherip = "127.0.0.1"

# radius_lbmonitor_name = "RADIUS_MON"
# radius_lbmonitor_type = "RADIUS"

# gateway_authenticationldapaction_name = "Gateway_LDAP_Server"

# authenticationradiusaction_name = "Gateway_RADIUS_Server"

# gateway_vpnvserver_name        = "Gateway_vServer"
# gateway_vpnvserver_servicetype = "SSL"

# vpnsessionaction1_name = "Native_Profile"

# vpnsessionaction2_name = "Web_Profile"

# gateway_dtls_vpnvserver_name        = "Gateway_DTLS_vServer"
# gateway_dtls_vpnvserver_servicetype = "DTLS"
