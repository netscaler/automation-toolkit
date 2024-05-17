variable "suffix" {
  type = string
}

# LDAP Server Parameter
variable "ldap_server_ip" {
  type = string
}

variable "ldap_server_port" {
  type = string
}

variable "ldap_protocol" {
  type = string
}

variable "ldap_base" {
  type = string
}

variable "ldap_bind_name" {
  type = string
}

variable "ldap_bind_pw" {
  type = string
}

variable "ldap_login_name" {
  type = string
}

variable "ldap_group_attribute" {
  type = string
}

variable "ldap_sub_attribute" {
  type = string
}

variable "ldap_otp_parameter" {
  type = string
}

# Rollout only from internal subnet
variable "client_subnet" {
  type = string
}

# Pre-Installed Certificate to bind
variable "cert" {
  type = string
}