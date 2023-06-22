variable "netscaler1_nsip" {
  type        = string
  description = "NetScaler1 IP Address"
}
variable "netscaler2_nsip" {
  type        = string
  description = "NetScaler2 IP Address"
}
variable "rpc_node_password" {
  type        = string
  sensitive   = true
  description = "The new ADC RPC node password that will replace the default one on both ADC instances. [Learn More about RPCNode](https://docs.citrix.com/en-us/citrix-adc/current-release/getting-started-with-citrix-adc/change-rpc-node-password.html)"
}