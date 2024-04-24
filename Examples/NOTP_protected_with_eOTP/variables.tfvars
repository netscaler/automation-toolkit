suffix = "Lurchi"

# LDAP Parameter
ldap_server_ip = "192.168.123.100"
ldap_server_port = "636"
ldap_protocol = "SSL" # Possible values = PLAINTEXT, TLS, SSL
ldap_bind_name = "administrator@training.local"
ldap_bind_pw = "Citrix.123"
ldap_base = "DC=training, DC=local"
ldap_login_name = "sAMAccountName"
ldap_group_attribute = "memberOf"
ldap_sub_attribute = "cn"
ldap_sso_attribute = "cn"
ldap_otp_parameter = "userParameters"

# email Parameter
email_sender = "mailsvc@training.local"
email_password = "Citrix.1223"
email_server_port = "25" # Possible values = 25, 587, 465 
email_server_ip_or_name = "mail.training.local"
email_server_protocol = "smtp" # Possible values = smtp, smtps

# Pre-Installed Certificate to Bind
cert = "wildcard_training"