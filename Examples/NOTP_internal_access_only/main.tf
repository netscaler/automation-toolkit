resource "citrixadc_authenticationldapaction" "ldapmgmt" {
  name = "Auth_Act_LDAP_NOTP_Manage_${var.suffix}"
  serverip = var.ldap_server_ip
  serverport = var.ldap_server_port
  sectype = var.ldap_protocol
  ldapbase = var.ldap_base
  ldapbinddn = var.ldap_bind_name
  ldapbinddnpassword = var.ldap_bind_pw
  ldaploginname = var.ldap_login_name
  groupattrname = var.ldap_group_attribute
  subattributename = var.ldap_sub_attribute
  authentication = "DISABLED"
  otpsecret = var.ldap_otp_parameter
}

resource "citrixadc_authenticationldapaction" "ldapauth" {
  name = "Auth_Act_LDAP_NOTP_Authentication_${var.suffix}"
  serverip = var.ldap_server_ip
  serverport = var.ldap_server_port
  sectype = var.ldap_protocol
  ldapbase = var.ldap_base
  ldapbinddn = var.ldap_bind_name
  ldapbinddnpassword = var.ldap_bind_pw
  ldaploginname = var.ldap_login_name
  groupattrname = var.ldap_group_attribute
  subattributename = var.ldap_sub_attribute
  authentication = "ENABLED"
}

resource "citrixadc_authenticationldapaction" "ldapsearch" {
  name = "Auth_Act_LDAP_NOTP_Search_${var.suffix}"
  serverip = var.ldap_server_ip
  serverport = var.ldap_server_port
  sectype = var.ldap_protocol
  ldapbase = var.ldap_base
  ldapbinddn = var.ldap_bind_name
  ldapbinddnpassword = var.ldap_bind_pw
  ldaploginname = var.ldap_login_name
  groupattrname = var.ldap_group_attribute
  subattributename = var.ldap_sub_attribute
  authentication = "DISABLED"
  searchfilter = "${var.ldap_otp_parameter}>=#@"
  otpsecret = var.ldap_otp_parameter
}

resource "citrixadc_authenticationpolicy" "authpolmgmt" {
  name = "Auth_Pol_LDAP_NOTP_Manage_${var.suffix}"
  rule = "TRUE"
  action = citrixadc_authenticationldapaction.ldapmgmt.name
}

resource "citrixadc_authenticationpolicy" "authpolauth" {
  name = "Auth_Pol_LDAP_NOTP_Authenticate_${var.suffix}"
  rule = "TRUE"
  action = citrixadc_authenticationldapaction.ldapauth.name
}

resource "citrixadc_authenticationpolicy" "authpolsearch" {
  name = "Auth_Pol_LDAP_NOTP_Search_${var.suffix}"
  rule = "TRUE"
  action = citrixadc_authenticationldapaction.ldapsearch.name
}

resource "citrixadc_authenticationpolicy" "authpolnoauth" {
  name = "Auth_Pol_NoAuth_${var.suffix}"
  rule = "TRUE"
  action = "NO_AUTHN"
}

resource "citrixadc_authenticationpolicy" "authpolnotpauth" {
  name = "Auth_Pol_NOTP_Auth_${var.suffix}"
  rule = "TRUE"
  action = "NO_AUTHN"
}

resource "citrixadc_authenticationpolicy" "authpolnotpmgmt" {
  name = "Auth_Pol_NOTP_Manage_${var.suffix}"
  rule = "HTTP.REQ.COOKIE.VALUE(\"NSC_TASS\").EQ(\"manageotp\") && CLIENT.IP.SRC.IN_SUBNET(${var.client_subnet})"
  action = "NO_AUTHN"
}

resource "citrixadc_authenticationloginschema" "lschemasingle" {
  name = "LogSchema_Auth_Manage_Single_${var.suffix}"
  authenticationschema = "/nsconfig/loginschema/LoginSchema/SingleAuthManageOTP.xml"
}

resource "citrixadc_authenticationloginschema" "lschemadual" {
  name = "LogSchema_NOTP_Dual_${var.suffix}"
  authenticationschema = "/nsconfig/loginschema/LoginSchema/DualAuth.xml"
  passwordcredentialindex = 1
}

resource "citrixadc_authenticationpolicylabel" "pollabmgmtauth" {
  labelname = "Auth_Lab_Mgmt_Or_Auth_${var.suffix}"
  loginschema = "LSCHEMA_INT"
}

resource "citrixadc_authenticationpolicylabel" "pollabnotpldap" {
  labelname = "Auth_Lab_NOTP_LDAP_${var.suffix}"
  loginschema = citrixadc_authenticationloginschema.lschemasingle.name
}

resource "citrixadc_authenticationpolicylabel" "pollabnotpmgmt" {
  labelname = "Auth_Lab_NOTP_Manage_${var.suffix}"
  loginschema = "LSCHEMA_INT"
}

resource "citrixadc_authenticationpolicylabel" "pollabnotpdual" {
  labelname = "Auth_Lab_NOTP_Auth_Dual_${var.suffix}"
  loginschema = citrixadc_authenticationloginschema.lschemadual.name
}

resource "citrixadc_authenticationpolicylabel" "pollabnotpsearch" {
  labelname = "Auth_Lab_NOTP_Search_${var.suffix}"
  loginschema = "LSCHEMA_INT"
}

resource "citrixadc_authenticationpolicylabel_authenticationpolicy_binding" "bindlabmgmt" {
  labelname = citrixadc_authenticationpolicylabel.pollabmgmtauth.labelname
  policyname = citrixadc_authenticationpolicy.authpolnotpmgmt.name
  priority = 100
  gotopriorityexpression = "NEXT"
  nextfactor = citrixadc_authenticationpolicylabel.pollabnotpldap.labelname
}

resource "citrixadc_authenticationpolicylabel_authenticationpolicy_binding" "bindlabauth" {
  labelname = citrixadc_authenticationpolicylabel.pollabmgmtauth.labelname
  policyname = citrixadc_authenticationpolicy.authpolnotpauth.name
  priority = 110
  gotopriorityexpression = "NEXT"
  nextfactor = citrixadc_authenticationpolicylabel.pollabnotpdual.labelname
}

resource "citrixadc_authenticationpolicylabel_authenticationpolicy_binding" "bindlabldap" {
  labelname = citrixadc_authenticationpolicylabel.pollabnotpldap.labelname
  policyname = citrixadc_authenticationpolicy.authpolauth.name
  priority = 100
  gotopriorityexpression = "NEXT"
  nextfactor = citrixadc_authenticationpolicylabel.pollabnotpmgmt.labelname
}

resource "citrixadc_authenticationpolicylabel_authenticationpolicy_binding" "bindlabnotpmgmt" {
  labelname = citrixadc_authenticationpolicylabel.pollabnotpmgmt.labelname
  policyname = citrixadc_authenticationpolicy.authpolmgmt.name
  priority = 100
  gotopriorityexpression = "END"
}

resource "citrixadc_authenticationpolicylabel_authenticationpolicy_binding" "bindlabnotpdual" {
  labelname = citrixadc_authenticationpolicylabel.pollabnotpdual.labelname
  policyname = citrixadc_authenticationpolicy.authpolauth.name
  priority = 100
  gotopriorityexpression = "NEXT"
  nextfactor = citrixadc_authenticationpolicylabel.pollabnotpsearch.labelname
}

resource "citrixadc_authenticationpolicylabel_authenticationpolicy_binding" "bindlabnotpsearch" {
  labelname = citrixadc_authenticationpolicylabel.pollabnotpsearch.labelname
  policyname = citrixadc_authenticationpolicy.authpolsearch.name
  priority = 100
  gotopriorityexpression = "END"
}

resource "citrixadc_authenticationvserver" "aaavserver" {
  name = "AAAVS_NOTP_${var.suffix}"
  ipv46 = "0.0.0.0"
  port = "0"
  servicetype = "SSL"
  authentication = "ON"
}

resource "citrixadc_authenticationvserver_authenticationpolicy_binding" "aaabind" {
  name = citrixadc_authenticationvserver.aaavserver.name
  policy = citrixadc_authenticationpolicy.authpolnoauth.name
  priority = 100
  nextfactor = citrixadc_authenticationpolicylabel.pollabmgmtauth.labelname
  gotopriorityexpression = "NEXT"
}

resource "citrixadc_aaaotpparameter" "aaaparameter" {
  maxotpdevices = 2
}

resource "citrixadc_vpntrafficaction" "tract" {
  name = "Traff_Prof_NOTP_${var.suffix}"
  qual = "HTTP"
  passwdexpression = "AAA.USER.ATTRIBUTE(1)"
}

resource "citrixadc_vpntrafficpolicy" "vpntrpol" {
  name = "Traff_Pol_NOTP_${var.suffix}"
  rule = "TRUE"
  action = citrixadc_vpntrafficaction.tract.name
}

resource "citrixadc_authenticationauthnprofile" "aaaprofnotp" {
  name = "Auth_Prof_NOTP_${var.suffix}"
  authnvsname = citrixadc_authenticationvserver.aaavserver.name
}

resource "citrixadc_sslvserver_sslcertkey_binding" "certbind" {
  vservername = citrixadc_authenticationvserver.aaavserver.name
  certkeyname = var.cert
}