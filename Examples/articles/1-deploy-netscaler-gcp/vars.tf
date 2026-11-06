variable "project" {
  type = string
}

variable "basename" {
  type = string
}

variable "region" {
  type = string
}

variable "zone" {
  type = string
}

variable "preemptible" {
  type    = bool
  default = false
}

variable "source_image" {
  type = string
}

variable "vpx_vip_cidr_range" {
  type = string
}

variable "controlling_range1" {
  type = string
}

variable "controlling_range2" {
  type = string
}

variable "machine_type" {
  type = string
}

