resource "citrixadc_nsvpxparam" "tf_nsvpxparam" {
  cpuyield = "YES"
}

# set HA node -failSafe ON -maxFlips 3 -maxFlipTime 1200 
resource "citrixadc_hanode" "local_node" {
  hanode_id   = 0 //the id of local_node is always 0
  failsafe    = "ON"
  maxflips    = 3
  maxfliptime = 1200
}

############################ 
# Upload SSL certificates 
############################# 
resource "citrixadc_systemfile" "ns_server_cert" {
  filename     = var.servercertfile_name
  filelocation = "/nsconfig/ssl/"
  filecontent  = file("${path.module}/${var.servercertfile_name}")
}
resource "citrixadc_systemfile" "ns_server_key" {
  filename     = var.servekeyfile_name
  filelocation = "/nsconfig/ssl/"
  filecontent  = file("${path.module}/${var.servekeyfile_name}")
}

#Intermediate certificates 
# scp remote_mycoolcompany_com.ca-bundle nsroot@10.0.10.10:/nsconfig/ssl/ 
# scp remote_mycoolcompany_com.ca-bundle_ic1 nsroot@10.0.10.10:/nsconfig/ssl/ 
resource "citrixadc_systemfile" "remote_mycoolcompany_com_ca-bundle" {
  filename     = var.intermediate_certificate1_name
  filelocation = "/nsconfig/ssl/"
  filecontent  = file("${path.module}/${var.intermediate_certificate1_name}")
}
resource "citrixadc_systemfile" "remote_mycoolcompany_com_ca-bundle_ic1" {
  filename     = var.intermediate_certificate2_name
  filelocation = "/nsconfig/ssl/"
  filecontent  = file("${path.module}/${var.intermediate_certificate2_name}")
}

#Gateway certificate and key 
# scp remote_mycoolcompany_com.crt nsroot@10.0.10.10:/nsconfig/ssl/ 
# scp "remote.mycoolcompany.com_key3.txt" nsroot@10.0.10.10:/nsconfig/ssl/ 
resource "citrixadc_systemfile" "remote_mycoolcompany_com_crt" {
  filename     = var.gateway_certfile_name
  filelocation = "/nsconfig/ssl/"
  filecontent  = file("${path.module}/${var.gateway_certfile_name}")
}
resource "citrixadc_systemfile" "remote_mycoolcompany_com_key" {
  filename     = var.gateway_keyfile_name
  filelocation = "/nsconfig/ssl/"
  filecontent  = file("${path.module}/${var.gateway_keyfile_name}")
}

############################# 
# Base configuration 
############################# 

#This command is only for the Primary node 
# set ns ip 10.0.10.10 -vServer DISABLED -gui SECUREONLY -mgmtAccess ENABLED -restrictAccess ENABLED 
#This command is only for the Secondary node 
# set ns ip 10.0.10.11 -vServer DISABLED -gui SECUREONLY -mgmtAccess ENABLED -restrictAccess ENABLED 

resource "citrixadc_nsip" "nsip_qenzcpieio" {
  ipaddress      = var.snip_ip_address
  netmask        = var.snip_netmask
  vserver        = "DISABLED"
  gui            = "SECUREONLY"
  mgmtaccess     = "ENABLED"
  restrictaccess = "ENABLED"
}

# No need as there will be default route associated
# resource "citrixadc_route" "route_zluebtokju" {
#   count   = length(var.route)
#   network = var.route[count.index]["network"]
#   netmask = var.route[count.index]["netmask"]
#   gateway = var.route[count.index]["gateway"]
#   depends_on = [
#     citrixadc_nsip.nsip_qenzcpieio
#   ]
# }


# #Add SSL certificates 
# add ssl certKey Intermediate_SSL_certificate -cert remote_mycoolcompany_com.ca-bundle 
# add ssl certKey Intermediate_SSL_certificate_ic1 -cert remote_mycoolcompany_com.ca-bundle_ic1 
# add ssl certKey remote.mycoolcompany.com -cert remote_mycoolcompany_com.crt -key "remote.mycoolcompany.com_key 3.txt" 

# #Link SSL certificates to intermediate certificates 
# link ssl certKey Intermediate_SSL_certificate Intermediate_SSL_certificate_ic1 
# link ssl certKey remote.mycoolcompany.com Intermediate_SSL_certificate 

# Above configuration is implemeted in below terraform resource block
# Need to check on link ssl certKey Intermediate_SSL_certificate Intermediate_SSL_certificate_ic1  
resource "citrixadc_sslcertkey" "sslcertkey_yactrltynp" { #Issuer certificate mismatch
  certkey = "Intermediate_SSL_certificate"
  cert    = "remote_mycoolcompany_com.ca-bundle"
  linkcertkeyname = citrixadc_sslcertkey.sslcertkey_todfwaybti.certkey
  depends_on = [
    citrixadc_systemfile.remote_mycoolcompany_com_ca-bundle
  ]
}
resource "citrixadc_sslcertkey" "sslcertkey_todfwaybti" {
  certkey = "Intermediate_SSL_certificate_ic1"
  cert    = "remote_mycoolcompany_com.ca-bundle_ic1"
  depends_on = [
    citrixadc_systemfile.remote_mycoolcompany_com_ca-bundle_ic1
  ]
}
# link ssl certKey remote.mycoolcompany.com Intermediate_SSL_certificate 
resource "citrixadc_sslcertkey" "tf_sslcertkey" {
  certkey = "remote.mycoolcompany.com"
  cert    = "remote_mycoolcompany_com.crt"
  key     = "remote.mycoolcompany.com_key3.txt"
  linkcertkeyname = citrixadc_sslcertkey.sslcertkey_yactrltynp.certkey
  depends_on = [
    citrixadc_systemfile.remote_mycoolcompany_com_crt,
    citrixadc_systemfile.remote_mycoolcompany_com_key
  ]
}

resource "citrixadc_nsfeature" "tf_nsfeature" {
  cs        = true
  lb        = true
  ssl       = true
  cmp       = true
  sslvpn    = true
  aaa       = true
  rewrite   = true
  responder = true
  wl        = false
}
resource "citrixadc_nsmode" "tf_nsmode" {
  l3   = false
  edge = false
}
resource "citrixadc_nshttpparam" "tf_nshttpparam" {
  dropinvalreqs   = "ON"
  markhttp09inval = "ON"
}
resource "citrixadc_nsparam" "tf_nsparam" {
  cookieversion = 1
}
resource "citrixadc_systemparameter" "tf_systemparameter" {
  promptstring = var.promptstring
  maxclient    = 40
}

resource "citrixadc_systemuser" "tf_systemuser" {
  username     = "ADM-Service-Account"
  password     = "securepassword"
  externalauth = "DISABLED"
}
# set system user nsroot -externalAuth DISABLED

resource "citrixadc_systemgroup" "tf_systemgroup1" {
  groupname = var.systemgroup1_name
  cmdpolicybinding {
    policyname = "read-only"
    priority   = 100
  }
}
resource "citrixadc_systemgroup" "tf_systemgroup2" {
  groupname = var.systemgroup2_name
  cmdpolicybinding {
    policyname = "operator"
    priority   = 100
  }
}
resource "citrixadc_systemgroup" "tf_systemgroup3" {
  groupname = var.systemgroup3_name
  cmdpolicybinding {
    policyname = "network"
    priority   = 100
  }
}
resource "citrixadc_systemgroup" "tf_systemgroup4" {
  groupname = var.systemgroup4_name
  cmdpolicybinding {
    policyname = "sysadmin"
    priority   = 100
  }
}
resource "citrixadc_systemgroup" "tf_systemgroup5" {
  groupname = var.systemgroup5_name
  cmdpolicybinding {
    policyname = "superuser"
    priority   = 100
  }
}


resource "citrixadc_authenticationldapaction" "tf_authenticationldapaction_Management_LDAP_Server" {
  name               = var.management_authenticationldapaction_name
  servername         = var.management_authenticationldapaction_servername
  serverport         = 636
  ldapbase           = var.management_authenticationldapaction_ldapbase
  ldapbinddn         = var.management_authenticationldapaction_ldapbinddn
  ldapbinddnpassword = var.management_authenticationldapaction_ldapbinddnpassword
  ldaploginname      = "sAMAccountName"
  searchfilter       = var.management_authenticationldapaction_searchfilter
  groupattrname      = "memberOf"
  subattributename   = "cn"
  sectype            = "SSL"
  passwdchange       = "ENABLED"
}
resource "citrixadc_authenticationpolicy" "tf_Management_LDAP_Policy" {
  name   = "Management_LDAP_Policy"
  rule   = "true"
  action = citrixadc_authenticationldapaction.tf_authenticationldapaction_Management_LDAP_Server.name
}
resource "citrixadc_systemglobal_authenticationpolicy_binding" "systemglobal__binding_gwtebwywgn" {
  policyname             = citrixadc_authenticationpolicy.tf_Management_LDAP_Policy.name
  priority               = 100
  gotopriorityexpression = "NEXT"
}
resource "citrixadc_nshostname" "tf_nshostname" {
  hostname = "HA-NetScaler-Pair"
}
resource "citrixadc_sslparameter" "sslparameter_zhfnbtqegq" {
  defaultprofile = "ENABLED"
}
resource "citrixadc_sslcipher" "sslcipher_eogidyupcx" {
  ciphergroupname = "SSL_Labs_Cipher_Group_Q4_2021"
  ciphersuitebinding {
    ciphername     = "TLS1.3-AES256-GCM-SHA384"
    cipherpriority = 1
  }
  ciphersuitebinding {
    ciphername     = "TLS1.3-AES128-GCM-SHA256"
    cipherpriority = 2
  }
  ciphersuitebinding {
    ciphername     = "TLS1.3-CHACHA20-POLY1305-SHA256"
    cipherpriority = 3
  }
  ciphersuitebinding {
    ciphername     = "TLS1.2-ECDHE-ECDSA-AES256-GCM-SHA384"
    cipherpriority = 4
  }
  ciphersuitebinding {
    ciphername     = "TLS1.2-ECDHE-ECDSA-AES128-GCM-SHA256"
    cipherpriority = 5
  }
  ciphersuitebinding {
    ciphername     = "TLS1.2-ECDHE-ECDSA-AES256-SHA384"
    cipherpriority = 6
  }
  ciphersuitebinding {
    ciphername     = "TLS1.2-ECDHE-RSA-AES256-GCM-SHA384"
    cipherpriority = 7
  }
}
resource "citrixadc_sslprofile" "sslprofile_nezvhaeqqj" {
  name             = "SSL_Labs_Profile_Q4_2021"
  tls1             = "DISABLED"
  tls11            = "DISABLED"
  tls12            = "ENABLED"
  tls13            = "ENABLED"
  denysslreneg     = "NONSECURE"
  hsts             = "ENABLED"
  maxage           = 157680000
  ecccurvebindings = ["P_256", "P_384", "P_224", "P_521"]
  depends_on       = [citrixadc_sslparameter.sslparameter_zhfnbtqegq]
}


# Replace the ciphers in the SSL profile 
# unbind ssl profile SSL_Labs_Profile_Q4_2021 -cipherName DEFAULT #not supported
# bind ssl profile SSL_Labs_Profile_Q4_2021 -cipherName SSL_Labs_Cipher_Group_Q4_2021 
resource "citrixadc_sslprofile_sslcipher_binding" "sslprofile__binding_bydrzyttal" {
  name           = citrixadc_sslprofile.sslprofile_nezvhaeqqj.name #"SSL_Labs_Profile_Q4_2021"
  ciphername     = citrixadc_sslcipher.sslcipher_eogidyupcx.ciphergroupname
  cipherpriority = 1
}

resource "citrixadc_snmpcommunity" "snmpcommunity_nasflquehd" {
  communityname = var.snmpcommunity_name
  permissions   = "ALL"
}
resource "citrixadc_snmpmanager" "snmpmanager_kbyotszmda" {
  ipaddress = var.snmpmanager1_ipaddress
  netmask   = "255.255.255.255"
}
resource "citrixadc_snmpmanager" "snmpmanager_znnvjqhxnl" {
  ipaddress = var.snmpmanager2_ipaddress
  netmask   = "255.255.255.255"
}
resource "citrixadc_snmpalarm" "snmpalarm_dhellhzjiq" {
  trapname       = "CPU-USAGE"
  thresholdvalue = 80
  normalvalue    = 35
  severity       = "Informational"
}
resource "citrixadc_snmpalarm" "snmpalarm_qiydzhgjub" {
  trapname = "HA-STATE-CHANGE"
  severity = "Critical"
}
resource "citrixadc_snmpalarm" "snmpalarm_jojguqjrzr" {
  trapname       = "MEMORY"
  thresholdvalue = 80
  normalvalue    = 35
  severity       = "Critical"
}
resource "citrixadc_snmpview" "snmpview_jwytycajii" {
  name    = "all_group_view"
  subtree = 1
  type    = "included"
}
resource "citrixadc_snmpgroup" "snmpgroup_poscxdyegh" {
  name          = "all_group"
  securitylevel = "authPriv"
  readviewname  = "all_group_view"
}
resource "citrixadc_snmpuser" "snmpuser_moivcqwmvb" {
  name       = var.snmpuser_name
  group      = "all_group"
  authtype   = "SHA"
  authpasswd = var.snmpuser_authpasswd
  privtype   = "AES"
  privpasswd = var.snmpuser_privpasswd
}

resource "citrixadc_snmptrap" "snmptrap_bpldwoskfn" {
  trapclass       = "generic"
  trapdestination = var.snmptrap1_trapdestination
  version         = "V3"
}
resource "citrixadc_snmptrap" "snmptrap_mquunqimgl" {
  trapclass       = "generic"
  trapdestination = var.snmptrap2_trapdestination
  version         = "V3"
}
resource "citrixadc_snmptrap_snmpuser_binding" "snmptrap__binding_rkcthyuxwg" {
  trapclass       = citrixadc_snmptrap.snmptrap_bpldwoskfn.trapclass
  trapdestination = citrixadc_snmptrap.snmptrap_bpldwoskfn.trapdestination
  username        = citrixadc_snmpuser.snmpuser_moivcqwmvb.name
  securitylevel   = "authPriv"
}
resource "citrixadc_snmptrap_snmpuser_binding" "snmptrap__binding_cwvuxvrjvn" {
  trapclass       = citrixadc_snmptrap.snmptrap_mquunqimgl.trapclass
  trapdestination = citrixadc_snmptrap.snmptrap_mquunqimgl.trapdestination
  username        = citrixadc_snmpuser.snmpuser_moivcqwmvb.name
  securitylevel   = "authPriv"
}

resource "citrixadc_auditsyslogaction" "auditsyslogaction_mgiickzjzf" {
  name                = var.auditsyslogaction_name
  serverip            = var.auditsyslogaction_serverip
  loglevel            = ["EMERGENCY", "ALERT", "CRITICAL", "ERROR", "WARNING"]
  acl                 = "ENABLED"
  timezone            = "LOCAL_TIME"
  userdefinedauditlog = "YES"
}
resource "citrixadc_auditsyslogpolicy" "auditsyslogpolicy_itefscdolv" {
  name   = "Syslog-Policy-1" #Syslog Policy 1
  rule   = "true"
  action = citrixadc_auditsyslogaction.auditsyslogaction_mgiickzjzf.name
}

# #Globally bind the Syslog Policy 
resource "citrixadc_auditsyslogglobal_auditsyslogpolicy_binding" "auditsyslogglobal__binding_kqxnpyfgzd" {
  policyname = citrixadc_auditsyslogpolicy.auditsyslogpolicy_itefscdolv.name
  priority   = 100
}

############################# 
# Create Load Balancers and configure DNS 
############################# 


resource "citrixadc_server" "server_sqztnaumda" {
  name      = var.dns_server1_ipaddress
  ipaddress = var.dns_server1_ipaddress
}
resource "citrixadc_server" "server_wsadkcqflz" {
  name      = var.dns_server2_ipaddress
  ipaddress = var.dns_server2_ipaddress
}
resource "citrixadc_server" "server_pfutrwnpwf" {
  name      = var.server3_ipaddress
  ipaddress = var.server3_ipaddress
}
resource "citrixadc_server" "server_pxjminslbl" {
  name      = var.storefront_server1_ipaddress
  ipaddress = var.storefront_server1_ipaddress
}
resource "citrixadc_server" "server_zbsxvzdore" {
  name      = var.storefront_server2_ipaddress
  ipaddress = var.storefront_server2_ipaddress
}
resource "citrixadc_server" "server_jynqmiwzru" {
  name      = var.ldap_server1_ipaddress
  ipaddress = var.ldap_server1_ipaddress
}
resource "citrixadc_server" "server_airvursjkh" {
  name      = var.ldap_server2_ipaddress
  ipaddress = var.ldap_server2_ipaddress
}
resource "citrixadc_server" "server_hjbevwqkdv" {
  name      = var.radius_server_ipaddress
  ipaddress = var.radius_server_ipaddress
}
resource "citrixadc_servicegroup" "servicegroup_eumxhmjuac" {
  servicegroupname = "DNS_TCP_SVG"
  servicetype      = "DNS_TCP"
  maxclient        = "0"
  maxreq           = "0"
  cip              = "DISABLED"
  usip             = "NO"
  useproxyport     = "YES"
  clttimeout       = 180
  svrtimeout       = 360
  cka              = "NO"
  tcpb             = "NO"
  cmp              = "NO"
}
resource "citrixadc_servicegroup" "servicegroup_chxikudgsk" {
  servicegroupname = "DNS_UDP_SVG"
  servicetype      = "DNS"
  maxclient        = "0"
  maxreq           = "0"
  cip              = "DISABLED"
  usip             = "NO"
  useproxyport     = "NO"
  clttimeout       = 120
  svrtimeout       = 120
  cka              = "NO"
  tcpb             = "NO"
  cmp              = "NO"
}
resource "citrixadc_servicegroup" "servicegroup_ahpzkekxep" {
  servicegroupname = "StoreFront_SVG"
  servicetype      = "SSL"
  maxclient        = "0"
  maxreq           = "0"
  cip              = "DISABLED"
  usip             = "NO"
  useproxyport     = "YES"
  clttimeout       = 180
  svrtimeout       = 360
  cka              = "NO"
  tcpb             = "NO"
  cmp              = "YES"
}
resource "citrixadc_servicegroup" "servicegroup_vvvkkztink" {
  servicegroupname = "LDAP_SVG"
  servicetype      = "TCP"
  maxclient        = "0"
  maxreq           = "0"
  cip              = "DISABLED"
  usip             = "NO"
  useproxyport     = "YES"
  clttimeout       = 9000
  svrtimeout       = 9000
  cka              = "NO"
  tcpb             = "NO"
  cmp              = "NO"
}
resource "citrixadc_servicegroup" "servicegroup_ndsbbzqxlp" {
  servicegroupname = "LDAP_TLS_Offload_SVG"
  servicetype      = "SSL_TCP"
  maxclient        = "0"
  maxreq           = "0"
  cip              = "DISABLED"
  usip             = "NO"
  useproxyport     = "YES"
  clttimeout       = 9000
  svrtimeout       = 9000
  cka              = "NO"
  tcpb             = "NO"
  cmp              = "NO"
}
resource "citrixadc_servicegroup" "servicegroup_pkmvqajaxw" {
  servicegroupname = "RADIUS_SVG"
  servicetype      = "RADIUS"
  maxclient        = "0"
  maxreq           = "0"
  cip              = "DISABLED"
  usip             = "NO"
  useproxyport     = "NO"
  clttimeout       = 120
  svrtimeout       = 120
  cka              = "NO"
  tcpb             = "NO"
  cmp              = "NO"
}
resource "citrixadc_lbvserver" "dns_tcp_lbvserver" {
  name            = var.dns_tcp_lbvserver_name
  servicetype     = var.dns_tcp_lbvserver_servicetype
  ipv46           = var.dns_tcp_lbvserver_ipv46
  persistencetype = "NONE"
  clttimeout      = 180
}
resource "citrixadc_lbvserver" "dns_udp_lbvserver" {
  name            = var.dns_udp_lbvserver_name
  servicetype     = var.dns_udp_lbvserver_servicetype
  ipv46           = var.dns_udp_lbvserver_ipv46
  persistencetype = "NONE"
  clttimeout      = 120
}

resource "citrixadc_lbvserver" "lbvserver_ymgredddqh" {
  name            = var.storefront_lbvserver_name
  servicetype     = var.storefront_lbvserver_servicetype
  ipv46           = var.storefront_lbvserver_ipv46
  port            = 443
  persistencetype = "COOKIEINSERT"
  clttimeout      = 180
}
resource "citrixadc_lbvserver" "lbvserver_pfxwimkyah" {
  name            = var.ldap_lbvserver_name
  servicetype     = var.ldap_lbvserver_servicetype
  ipv46           = var.ldap_lbvserver_ipv46
  port            = 636
  persistencetype = "SOURCEIP"
  clttimeout      = 9000
}
resource "citrixadc_lbvserver" "lbvserver_aretuuhedg" {
  name            = var.ldap_tls_offload_lbvserver_name
  servicetype     = var.ldap_tls_offload_lbvserver_servicetype
  ipv46           = var.ldap_tls_offload_lbvserver_ipv46
  port            = 637
  persistencetype = "SOURCEIP"
  clttimeout      = 9000
}
resource "citrixadc_lbvserver" "lbvserver_ewlwbfnjnk" {
  name            = var.radius_lbvserver_name
  servicetype     = var.radius_lbvserver_servicetype
  ipv46           = var.radius_lbvserver_ipv46
  port            = 1812
  persistencetype = "RULE"
  lbmethod        = "TOKEN"
  rule            = "CLIENT.UDP.RADIUS.USERNAME"
  clttimeout      = 120
}


resource "citrixadc_lbvserver_servicegroup_binding" "lbvserver__binding_wegcwdmyfm" {
  name             = citrixadc_lbvserver.dns_tcp_lbvserver.name                      # "DNS_TCP_LB"
  servicegroupname = citrixadc_servicegroup.servicegroup_eumxhmjuac.servicegroupname #"DNS_TCP_SVG"
}
resource "citrixadc_lbvserver_servicegroup_binding" "lbvserver__binding_knazcgzimi" {
  name             = citrixadc_lbvserver.dns_udp_lbvserver.name                      #"DNS_UDP_LB"
  servicegroupname = citrixadc_servicegroup.servicegroup_chxikudgsk.servicegroupname #"DNS_UDP_SVG"
}
resource "citrixadc_lbvserver_servicegroup_binding" "lbvserver__binding_nlsolummnp" {
  name             = citrixadc_lbvserver.lbvserver_ymgredddqh.name                   #"StoreFront_LB"
  servicegroupname = citrixadc_servicegroup.servicegroup_ahpzkekxep.servicegroupname #"StoreFront_SVG"
}
resource "citrixadc_lbvserver_servicegroup_binding" "lbvserver__binding_kiccugrtpf" {
  name             = citrixadc_lbvserver.lbvserver_pfxwimkyah.name                   #"LDAP_LB"
  servicegroupname = citrixadc_servicegroup.servicegroup_vvvkkztink.servicegroupname #"LDAP_SVG"
}
resource "citrixadc_lbvserver_servicegroup_binding" "lbvserver__binding_pzxtoylktl" {
  name             = citrixadc_lbvserver.lbvserver_aretuuhedg.name                   #"LDAP_TLS_Offload_LB"
  servicegroupname = citrixadc_servicegroup.servicegroup_ndsbbzqxlp.servicegroupname #"LDAP_TLS_Offload_SVG"
}
resource "citrixadc_lbvserver_servicegroup_binding" "lbvserver__binding_lkhrkfmmmm" {
  name             = citrixadc_lbvserver.lbvserver_ewlwbfnjnk.name                   #"RADIUS_LB"
  servicegroupname = citrixadc_servicegroup.servicegroup_pkmvqajaxw.servicegroupname #"RADIUS_SVG"
}

resource "citrixadc_lbmonitor" "lbmonitor_hcfaaeslbw" {
  monitorname = var.dns_tcp_lbmonitor_name
  type        = var.dns_tcp_lbmonitor_type
  query       = var.dns_tcp_lbmonitor_query
  querytype   = "Address"
  lrtm        = "DISABLED"
  interval    = 6
  resptimeout = 3
  downtime    = 20
  destport    = 53
}
resource "citrixadc_lbmonitor" "lbmonitor_chovwassas" {
  monitorname = var.dns_udp_lbmonitor_name
  type        = var.dns_udp_lbmonitor_type
  query       = var.dns_udp_lbmonitor_query
  querytype   = "Address"
  lrtm        = "DISABLED"
  interval    = 6
  resptimeout = 3
  downtime    = 20
  destport    = 53
}
resource "citrixadc_lbmonitor" "lbmonitor_trnqrgntrg" {
  monitorname    = var.storefront_lbmonitor_name
  type           = var.storefront_lbmonitor_type
  scriptname     = "nssf.pl"
  dispatcherip   = var.storefront_lbmonitor_dispatcherip
  dispatcherport = 3013
  lrtm           = "DISABLED"
  interval       = 30
  resptimeout    = 5
  downtime       = 20
  secure         = "YES"
  storename      = var.storefront_lbmonitor_storename
}
resource "citrixadc_lbmonitor" "lbmonitor_uizgmebaiu" {
  monitorname    = var.ldap_lbmonitor_name
  type           = var.ldap_lbmonitor_type
  scriptname     = "nsldap.pl"
  dispatcherip   = var.ldap_lbmonitor_dispatcherip
  dispatcherport = 3013
  password       = var.ldap_lbmonitor_password
  secure         = "YES"
  basedn         = var.ldap_lbmonitor_basedn
  binddn         = var.ldap_lbmonitor_binddn
  filter         = var.ldap_lbmonitor_filter
}
resource "citrixadc_lbmonitor" "lbmonitor_swzbkbrwrr" {
  monitorname = var.radius_lbmonitor_name
  type        = var.radius_lbmonitor_type
  respcode    = ["3"]
  username    = var.radius_lbmonitor_username
  password    = var.radius_lbmonitor_password
  radkey      = var.radius_lbmonitor_radkey
  lrtm        = "DISABLED"
}


resource "citrixadc_servicegroup_servicegroupmember_binding" "servicegroup__binding_hxwtyofwtm" {
  servicegroupname = citrixadc_servicegroup.servicegroup_eumxhmjuac.servicegroupname #"DNS_TCP_SVG"
  ip               = citrixadc_server.server_sqztnaumda.ipaddress                    #"8.8.8.8"
  port             = 53
  weight           = "10"
}
resource "citrixadc_servicegroup_servicegroupmember_binding" "servicegroup__binding_pzsbmgfxsq" {
  servicegroupname = citrixadc_servicegroup.servicegroup_eumxhmjuac.servicegroupname #"DNS_TCP_SVG"
  ip               = citrixadc_server.server_wsadkcqflz.ipaddress                    #"1.1.1.1"
  port             = 53
  weight           = "10"
}
resource "citrixadc_servicegroup_lbmonitor_binding" "servicegroup__binding_encckgfcuq" {
  servicegroupname = citrixadc_servicegroup.servicegroup_eumxhmjuac.servicegroupname #"DNS_TCP_SVG"
  monitorname      = citrixadc_lbmonitor.lbmonitor_hcfaaeslbw.monitorname            #"DNS_TCP_monitor"
  weight           = "80"
}
resource "citrixadc_servicegroup_servicegroupmember_binding" "servicegroup__binding_dunulodvsu" {
  servicegroupname = citrixadc_servicegroup.servicegroup_chxikudgsk.servicegroupname #"DNS_UDP_SVG"
  ip               = citrixadc_server.server_sqztnaumda.ipaddress                    #"8.8.8.8"
  port             = 53
  weight           = "10"
}
resource "citrixadc_servicegroup_servicegroupmember_binding" "servicegroup__binding_ddikktifmu" {
  servicegroupname = citrixadc_servicegroup.servicegroup_chxikudgsk.servicegroupname #"DNS_UDP_SVG"
  ip               = citrixadc_server.server_wsadkcqflz.ipaddress                    #"1.1.1.1"
  port             = 53
  weight           = "10"
}
resource "citrixadc_servicegroup_lbmonitor_binding" "servicegroup__binding_dbwtlpttjz" {
  servicegroupname = citrixadc_servicegroup.servicegroup_chxikudgsk.servicegroupname #"DNS_UDP_SVG"
  monitorname      = citrixadc_lbmonitor.lbmonitor_chovwassas.monitorname            #"DNS_UDP_monitor"
  weight           = "80"
}
resource "citrixadc_servicegroup_servicegroupmember_binding" "servicegroup__binding_jfgnghruur" {
  servicegroupname = citrixadc_servicegroup.servicegroup_ahpzkekxep.servicegroupname #"StoreFront_SVG"
  ip               = citrixadc_server.server_zbsxvzdore.ipaddress                    #"192.168.3.31"
  port             = 443
}
resource "citrixadc_servicegroup_servicegroupmember_binding" "servicegroup__binding_oejyktuylb" {
  servicegroupname = citrixadc_servicegroup.servicegroup_ahpzkekxep.servicegroupname #"StoreFront_SVG"
  ip               = citrixadc_server.server_pxjminslbl.ipaddress                    #"192.168.3.30"
  port             = 443
}
resource "citrixadc_servicegroup_lbmonitor_binding" "servicegroup__binding_oaemujffdq" {
  servicegroupname = citrixadc_servicegroup.servicegroup_ahpzkekxep.servicegroupname #"StoreFront_SVG"
  monitorname      = citrixadc_lbmonitor.lbmonitor_trnqrgntrg.monitorname            #"StoreFront_monitor"
}
resource "citrixadc_servicegroup_servicegroupmember_binding" "servicegroup__binding_uqjotkmwph" {
  servicegroupname = citrixadc_servicegroup.servicegroup_vvvkkztink.servicegroupname #"LDAP_SVG"
  ip               = citrixadc_server.server_airvursjkh.ipaddress                    #"192.168.3.11"
  port             = 636
}
resource "citrixadc_servicegroup_servicegroupmember_binding" "servicegroup__binding_ebmkappfpg" {
  servicegroupname = citrixadc_servicegroup.servicegroup_vvvkkztink.servicegroupname #"LDAP_SVG"
  ip               = citrixadc_server.server_jynqmiwzru.ipaddress                    #"192.168.3.10"
  port             = 636
}
resource "citrixadc_servicegroup_lbmonitor_binding" "servicegroup__binding_apzkavrvpq" {
  servicegroupname = citrixadc_servicegroup.servicegroup_vvvkkztink.servicegroupname #"LDAP_SVG"
  monitorname      = citrixadc_lbmonitor.lbmonitor_uizgmebaiu.monitorname            #"LDAP_MON"
}

resource "citrixadc_servicegroup_servicegroupmember_binding" "servicegroup__binding_sdfgertyui" {
  servicegroupname = citrixadc_servicegroup.servicegroup_ndsbbzqxlp.servicegroupname #"LDAP_TLS_Offload_SVG"
  ip               = citrixadc_server.server_airvursjkh.ipaddress                    #"192.168.3.11"
  port             = 636
}
resource "citrixadc_servicegroup_servicegroupmember_binding" "servicegroup__binding_sertfergwt" {
  servicegroupname = citrixadc_servicegroup.servicegroup_ndsbbzqxlp.servicegroupname #"LDAP_TLS_Offload_SVG"
  ip               = citrixadc_server.server_jynqmiwzru.ipaddress                    #"192.168.3.10"
  port             = 636
}
resource "citrixadc_servicegroup_lbmonitor_binding" "servicegroup__binding_qlcdvznpfp" {
  servicegroupname = citrixadc_servicegroup.servicegroup_ndsbbzqxlp.servicegroupname #"LDAP_TLS_Offload_SVG"
  monitorname      = citrixadc_lbmonitor.lbmonitor_uizgmebaiu.monitorname            #"LDAP_MON"
}
resource "citrixadc_servicegroup_servicegroupmember_binding" "servicegroup__binding_xiwzfksboa" {
  servicegroupname = citrixadc_servicegroup.servicegroup_pkmvqajaxw.servicegroupname #"RADIUS_SVG"
  ip               = citrixadc_server.server_hjbevwqkdv.ipaddress                    #"192.168.3.20"
  port             = 1812
}
resource "citrixadc_servicegroup_lbmonitor_binding" "servicegroup__binding_kyofxsqqgl" {
  servicegroupname = citrixadc_servicegroup.servicegroup_pkmvqajaxw.servicegroupname #"RADIUS_SVG"
  monitorname      = citrixadc_lbmonitor.lbmonitor_swzbkbrwrr.monitorname            #"RADIUS_MON"
}

resource "citrixadc_sslvserver_sslcertkey_binding" "sslvserver__binding_cavebdpwll" {
  vservername = citrixadc_lbvserver.lbvserver_ymgredddqh.name #"StoreFront_LB"
  certkeyname = citrixadc_sslcertkey.tf_sslcertkey.certkey    #"remote.mycoolcompany.com"
}

resource "citrixadc_dnsnameserver" "dnsnameserver_qxduquwhhh" {
  dnsvservername = citrixadc_lbvserver.dns_udp_lbvserver.name #"DNS_UDP_LB"
}
resource "citrixadc_dnsnameserver" "dnsnameserver_ufzjtabuhu" {
  dnsvservername = citrixadc_lbvserver.dns_tcp_lbvserver.name #"DNS_TCP_LB"
  type           = "TCP"
}

############################# 
# Create the AAA and Gateway vServers 
############################# 

resource "citrixadc_ntpserver" "tf_ntpserver0" {
  servername = "0.pool.ntp.org"
}
resource "citrixadc_ntpserver" "tf_ntpserver1" {
  servername = "1.pool.ntp.org"
}

resource "citrixadc_ntpsync" "tf_ntpsync" {
  state = "ENABLED"
}

resource "citrixadc_authenticationauthnprofile" "authenticationauthnprofile_ktfhymohui" {
  name        = "Gateway_Auth_vServer_Profile"
  authnvsname = citrixadc_authenticationvserver.authenticationvserver_ztlrjkpdpv.name #"Gateway_Auth_vServer"
}
resource "citrixadc_authenticationvserver" "authenticationvserver_ztlrjkpdpv" {
  name        = "Gateway_Auth_vServer"
  servicetype = "SSL"
  ipv46       = "0.0.0.0"
}
resource "citrixadc_sslvserver_sslcertkey_binding" "sslvserver__binding_rzcbmamxes" {
  vservername = citrixadc_authenticationvserver.authenticationvserver_ztlrjkpdpv.name #"Gateway_Auth_vServer"
  certkeyname = citrixadc_sslcertkey.tf_sslcertkey.certkey                            #"remote.mycoolcompany.com"
}

#Apply default AAA vServer policies 
# These are the default bindings that are already present in NetScaler,  So we can't implement it
# resource "citrixadc_authenticationvserver_cachepolicy_binding" "authenticationvserver__binding_rvxuncxaaq" {
#   name                   = citrixadc_authenticationvserver.authenticationvserver_ztlrjkpdpv.name #"Gateway_Auth_vServer"
#   policy                 = "_cacheTCVPNStaticObjects"
#   priority               = "10"
#   gotopriorityexpression = "END"
#   bindpoint              = "REQUEST"
# }
# resource "citrixadc_authenticationvserver_cachepolicy_binding" "authenticationvserver__binding_linqrlpevp" {
#   name                   = citrixadc_authenticationvserver.authenticationvserver_ztlrjkpdpv.name #"Gateway_Auth_vServer"
#   policy                 = "_cacheOCVPNStaticObjects"
#   priority               = "20"
#   gotopriorityexpression = "END"
#   bindpoint              = "REQUEST"
# }
# resource "citrixadc_authenticationvserver_cachepolicy_binding" "authenticationvserver__binding_wgwcqnznie" {
#   name                   = citrixadc_authenticationvserver.authenticationvserver_ztlrjkpdpv.name #"Gateway_Auth_vServer"
#   policy                 = "_cacheVPNStaticObjects"
#   priority               = "30"
#   gotopriorityexpression = "END"
#   bindpoint              = "REQUEST"
# }
# resource "citrixadc_authenticationvserver_cachepolicy_binding" "authenticationvserver__binding_pakbnjojvp" {
#   name                   = citrixadc_authenticationvserver.authenticationvserver_ztlrjkpdpv.name #"Gateway_Auth_vServer"
#   policy                 = "_cacheWFStaticObjects"
#   priority               = "10"
#   gotopriorityexpression = "END"
#   bindpoint              = "RESPONSE"
# }
# resource "citrixadc_authenticationvserver_cachepolicy_binding" "authenticationvserver__binding_asdfghjwer" {
#   name                   = citrixadc_authenticationvserver.authenticationvserver_ztlrjkpdpv.name #"Gateway_Auth_vServer"
#   policy                 = "_mayNoCacheReq"
#   priority               = "40"
#   gotopriorityexpression = "END"
#   bindpoint              = "RESPONSE"
# }
# resource "citrixadc_authenticationvserver_cachepolicy_binding" "authenticationvserver__binding_rtyughjvbn" {
#   name                   = citrixadc_authenticationvserver.authenticationvserver_ztlrjkpdpv.name #"Gateway_Auth_vServer"
#   policy                 = "_noCacheRest"
#   priority               = "20"
#   gotopriorityexpression = "END"
#   bindpoint              = "RESPONSE"
# }


resource "citrixadc_authenticationldapaction" "authenticationldapaction_opktkswlqh" {
  name               = var.gateway_authenticationldapaction_name
  servername         = var.gateway_authenticationldapaction_servername
  serverport         = 637
  ldapbase           = var.gateway_authenticationldapaction_ldapbase
  ldapbinddn         = var.gateway_authenticationldapaction_ldapbinddn
  ldapbinddnpassword = var.gateway_authenticationldapaction_ldapbinddnpassword
  ldaploginname      = "sAMAccountName"
  groupattrname      = "memberOf"
  subattributename   = "cn"
  ssonameattribute   = "UserPrincipalName"
  passwdchange       = "ENABLED"
}
resource "citrixadc_authenticationradiusaction" "authenticationradiusaction_cqxcxdvlum" {
  name       = var.authenticationradiusaction_name
  serverip   = var.authenticationradiusaction_serverip
  serverport = 1812
  radkey     = var.authenticationradiusaction_radkey
}
resource "citrixadc_authenticationpolicy" "authenticationpolicy_bttsismyrq" {
  name   = "Gateway_RADIUS_Policy"
  rule   = "true"
  action = citrixadc_authenticationradiusaction.authenticationradiusaction_cqxcxdvlum.name #"Gateway_RADIUS_Server"
}
resource "citrixadc_authenticationpolicy" "authenticationpolicy_kzfdrxegbm" {
  name   = "Gateway_LDAP_Policy"
  rule   = "true"
  action = citrixadc_authenticationldapaction.authenticationldapaction_opktkswlqh.name #"Gateway_LDAP_Server"
}
resource "citrixadc_authenticationpolicylabel" "authenticationpolicylabel_dedfgsgtiy" {
  labelname   = "Gateway_LDAP_Policy_Label"
  loginschema = citrixadc_authenticationloginschema.authenticationloginschema_uzyekmkszy.name #LSCHEMA_INT_new # created new login schema
}

resource "citrixadc_authenticationvserver_authenticationloginschemapolicy_binding" "authenticationvserver__binding_czgdiinyld" {
  name                   = citrixadc_authenticationvserver.authenticationvserver_ztlrjkpdpv.name                 #"Gateway_Auth_vServer"
  policy                 = citrixadc_authenticationloginschemapolicy.lschema_dual_factor_builtin_new_policy.name #"lschema_dual_factor_builtin_new" # created new login schema
  priority               = "100"
  gotopriorityexpression = "END"
}
resource "citrixadc_authenticationpolicylabel_authenticationpolicy_binding" "authenticationpolicylabel__binding_ikyceqhvtp" {
  labelname              = citrixadc_authenticationpolicylabel.authenticationpolicylabel_dedfgsgtiy.labelname #"Gateway_LDAP_Policy_Label"
  policyname             = citrixadc_authenticationpolicy.authenticationpolicy_kzfdrxegbm.name                #"Gateway_LDAP_Policy"
  priority               = "100"
  gotopriorityexpression = "NEXT"
}
resource "citrixadc_authenticationvserver_authenticationpolicy_binding" "citrixadc_authenticationvserver__binding_fgghhnbvcc" {
  name                   = citrixadc_authenticationvserver.authenticationvserver_ztlrjkpdpv.name #"Gateway_Auth_vServer"
  policy                 = citrixadc_authenticationpolicy.authenticationpolicy_bttsismyrq.name   #"Gateway_RADIUS_Policy"
  priority               = "100"
  gotopriorityexpression = "NEXT"
  nextfactor             = citrixadc_authenticationpolicylabel.authenticationpolicylabel_dedfgsgtiy.labelname #Gateway_LDAP_Policy_Label
}
# set authentication loginSchema LSCHEMA_INT -authenticationSchema noschema -passwdExpression AAA.LOGIN.PASSWORD
resource "citrixadc_authenticationloginschema" "authenticationloginschema_uzyekmkszy" {
  name                 = "LSCHEMA_INT_new"
  authenticationschema = "noschema"
  passwdexpression     = "AAA.LOGIN.PASSWORD"
}

# set authentication loginSchema lschema_dual_factor_builtin -authenticationSchema "LoginSchema/DualAuth.xml" -passwdExpression AAA.LOGIN.PASSWORD2 
resource "citrixadc_authenticationloginschema" "authenticationloginschema_pdnomdjvyw" {
  name                 = "lschema_dual_factor_builtin_new"
  authenticationschema = "LoginSchema/DualAuth.xml"
  passwdexpression     = "AAA.LOGIN.PASSWORD2"
}
resource "citrixadc_authenticationloginschemapolicy" "lschema_dual_factor_builtin_new_policy" {
  name   = "lschema_dual_factor_builtin_new"
  rule   = "true"
  action = citrixadc_authenticationloginschema.authenticationloginschema_pdnomdjvyw.name
}

resource "citrixadc_authenticationoauthidpprofile" "tf_idpprofile" {
  name         = "Citrix-Cloud-OAuth-IDP-Profile"
  clientid     = var.authenticationoauthidpprofile_clientid
  clientsecret = var.authenticationoauthidpprofile_clientsecret
  redirecturl  = var.authenticationoauthidpprofile_redirecturl
  issuer       = var.authenticationoauthidpprofile_issuer
  audience     = var.authenticationoauthidpprofile_audience
  sendpassword = "ON"
}
resource "citrixadc_authenticationoauthidppolicy" "tf_idppolicy" {
  name   = "Citrix-Cloud-Gateway-Policy"
  rule   = "true"
  action = citrixadc_authenticationoauthidpprofile.tf_idpprofile.name
}
resource "citrixadc_authenticationvserver_authenticationoauthidppolicy_binding" "tf_bind" {
  name                   = citrixadc_authenticationvserver.authenticationvserver_ztlrjkpdpv.name
  policy                 = citrixadc_authenticationoauthidppolicy.tf_idppolicy.name
  priority               = 100
  gotopriorityexpression = "NEXT"
}
resource "citrixadc_vpnglobal_sslcertkey_binding" "tf_vpnglobal_slcertkey_binding" {
  certkeyname = citrixadc_sslcertkey.tf_sslcertkey.certkey
}

resource "citrixadc_vpnvserver" "vpnvserver_rwcwpgwfgn" {
  name           = var.gateway_vpnvserver_name
  servicetype    = var.gateway_vpnvserver_servicetype
  ipv46          = var.gateway_vpnvserver_ipv46
  port           = 443
  dtls           = "OFF"
  downstateflush = "DISABLED"
  listenpolicy   = "NONE"
  authnprofile   = citrixadc_authenticationauthnprofile.authenticationauthnprofile_ktfhymohui.name #"Gateway_Auth_vServer_Profile"
  depends_on = [
    citrixadc_sslprofile.sslprofile_nezvhaeqqj
  ]
}

# set ssl vserver Gateway_vServer -sslProfile SSL_Labs_Profile_Q4_2021 
resource "citrixadc_sslvserver" "sslvserver_izprawjoeg" {
  vservername = citrixadc_vpnvserver.vpnvserver_rwcwpgwfgn.name #"Gateway_vServer"
  sslprofile  = citrixadc_sslprofile.sslprofile_nezvhaeqqj.name #"SSL_Labs_Profile_Q4_2021"
}
resource "citrixadc_sslvserver_sslcertkey_binding" "sslvserver__binding_gyfoaqaitg" {
  vservername = citrixadc_sslvserver.sslvserver_izprawjoeg.vservername #"Gateway_vServer"
  certkeyname = citrixadc_sslcertkey.tf_sslcertkey.certkey             #"remote.mycoolcompany.com"
}

resource "citrixadc_vpnsessionaction" "vpnsessionaction_vjgcvhrdrz" {
  name                       = var.vpnsessionaction1_name
  defaultauthorizationaction = "ALLOW"
  sso                        = "ON"
  ssocredential              = "PRIMARY"
  icaproxy                   = "ON"
  wihome                     = var.vpnsessionaction1_wihome
  storefronturl              = var.vpnsessionaction1_storefronturl
}
resource "citrixadc_vpnsessionaction" "vpnsessionaction_pwvhwkswnw" {
  name                       = var.vpnsessionaction2_name
  defaultauthorizationaction = "ALLOW"
  sso                        = "ON"
  ssocredential              = "PRIMARY"
  icaproxy                   = "ON"
  wihome                     = var.vpnsessionaction2_wihome
}
resource "citrixadc_vpnsessionpolicy" "vpnsessionpolicy_scsugkktws" {
  name   = var.vpnsessionpolicy1_name
  rule   = var.vpnsessionpolicy1_rule
  action = citrixadc_vpnsessionaction.vpnsessionaction_vjgcvhrdrz.name #"Native_Profile"
}
resource "citrixadc_vpnsessionpolicy" "vpnsessionpolicy_kssyvgzcxs" {
  name   = var.vpnsessionpolicy2_name
  rule   = var.vpnsessionpolicy2_rule
  action = citrixadc_vpnsessionaction.vpnsessionaction_pwvhwkswnw.name #"Web_Profile"
}
resource "citrixadc_vpnvserver_staserver_binding" "vpnvserver__binding_uxhsocvixy" {
  count     = length(var.vpnvserver_staserver)
  name      = citrixadc_sslvserver.sslvserver_izprawjoeg.vservername #"Gateway_vServer"
  staserver = var.vpnvserver_staserver[count.index]
}

# These are the default bindings that are already present in NetScaler, So we can't implement it
# resource "citrixadc_vpnvserver_cachepolicy_binding" "vpnvserver__binding_bwkemtdbxa" {
#   name                   = citrixadc_sslvserver.sslvserver_izprawjoeg.vservername #"Gateway_vServer"
#   policy                 = "_cacheTCVPNStaticObjects"
#   priority               = "10"
#   gotopriorityexpression = "END"
#   bindpoint              = "REQUEST"
# }
# resource "citrixadc_vpnvserver_cachepolicy_binding" "vpnvserver__binding_ybeqyvijdg" {
#   name                   = citrixadc_sslvserver.sslvserver_izprawjoeg.vservername #"Gateway_vServer"
#   policy                 = "_cacheOCVPNStaticObjects"
#   priority               = "20"
#   gotopriorityexpression = "END"
#   bindpoint              = "REQUEST"
# }
# resource "citrixadc_vpnvserver_cachepolicy_binding" "vpnvserver__binding_xolgcloktl" {
#   name                   = citrixadc_sslvserver.sslvserver_izprawjoeg.vservername #"Gateway_vServer"
#   policy                 = "_cacheVPNStaticObjects"
#   priority               = "30"
#   gotopriorityexpression = "END"
#   bindpoint              = "REQUEST"
# }
# resource "citrixadc_vpnvserver_cachepolicy_binding" "vpnvserver__binding_qvwjfdjbsf" {
#   name                   = citrixadc_sslvserver.sslvserver_izprawjoeg.vservername #"Gateway_vServer"
#   policy                 = "_mayNoCacheReq"
#   priority               = "40"
#   gotopriorityexpression = "END"
#   bindpoint              = "REQUEST"
# }
# resource "citrixadc_vpnvserver_cachepolicy_binding" "vpnvserver__binding_cudcutilur" {
#   name                   = citrixadc_sslvserver.sslvserver_izprawjoeg.vservername #"Gateway_vServer"
#   policy                 = "_cacheWFStaticObjects"
#   priority               = "10"
#   gotopriorityexpression = "END"
#   bindpoint              = "RESPONSE"
# }
# resource "citrixadc_vpnvserver_cachepolicy_binding" "vpnvserver__binding_uanbnbckso" {
#   name                   = citrixadc_sslvserver.sslvserver_izprawjoeg.vservername #"Gateway_vServer"
#   policy                 = "_noCacheRest"
#   priority               = "20"
#   gotopriorityexpression = "END"
#   bindpoint              = "RESPONSE"
# }

resource "citrixadc_vpnvserver_vpnsessionpolicy_binding" "vpnvserver__binding_koafozsiot" {
  name                   = citrixadc_sslvserver.sslvserver_izprawjoeg.vservername      #"Gateway_vServer"
  policy                 = citrixadc_vpnsessionpolicy.vpnsessionpolicy_scsugkktws.name #"Native_Policy"
  priority               = "10"
  gotopriorityexpression = "NEXT"
  bindpoint              = "REQUEST"
}
resource "citrixadc_vpnvserver_vpnsessionpolicy_binding" "vpnvserver__binding_pqoxtwuojy" {
  name                   = citrixadc_sslvserver.sslvserver_izprawjoeg.vservername      #"Gateway_vServer"
  policy                 = citrixadc_vpnsessionpolicy.vpnsessionpolicy_kssyvgzcxs.name #"Web_Policy"
  priority               = "20"
  gotopriorityexpression = "NEXT"
  bindpoint              = "REQUEST"
}
resource "citrixadc_vpnvserver" "vpnvserver_toqdaseefd" {
  name           = var.gateway_dtls_vpnvserver_name
  servicetype    = var.gateway_dtls_vpnvserver_servicetype
  ipv46          = var.gateway_dtls_vpnvserver_ipv46
  port           = 443
  downstateflush = "DISABLED"
}
resource "citrixadc_sslvserver_sslcertkey_binding" "sslvserver__binding_ekimchexvk" {
  vservername = citrixadc_vpnvserver.vpnvserver_toqdaseefd.name #"Gateway_DTLS_vServer"
  certkeyname = citrixadc_sslcertkey.tf_sslcertkey.certkey      #"remote.mycoolcompany.com"
}
