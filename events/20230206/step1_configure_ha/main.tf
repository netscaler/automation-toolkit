# add ha node
resource "citrixadc_hanode" "netscaler1" {
  hanode_id = 1
  ipaddress = var.netscaler2_nsip
}

# add ha node
resource "citrixadc_hanode" "netscaler2" {
  provider  = citrixadc.netscaler2
  hanode_id = 1
  ipaddress = var.netscaler1_nsip

  depends_on = [citrixadc_hanode.netscaler1]
}

resource "citrixadc_systemparameter" "netscaler1_ns_prompt" {
  promptstring = "%u@%s"
}
resource "citrixadc_systemparameter" "netscaler2_ns_prompt" {
  provider     = citrixadc.netscaler2
  promptstring = "%u@%s"
}

# It is best practice to change the RPC node password
resource "citrixadc_nsrpcnode" "netscaler1to1_rpc_node" {
  ipaddress = var.netscaler1_nsip
  password  = var.rpc_node_password
  secure    = "ON"

  depends_on = [citrixadc_hanode.netscaler1]
}

# It is best practice to change the RPC node password
resource "citrixadc_nsrpcnode" "netscaler1to2_rpc_node" {
  ipaddress = var.netscaler2_nsip
  password  = var.rpc_node_password
  secure    = "ON"

  depends_on = [citrixadc_hanode.netscaler1]
}

# It is best practice to change the RPC node password
resource "citrixadc_nsrpcnode" "netscaler2to1_rpc_node" {
    provider = citrixadc.netscaler2
  ipaddress = var.netscaler1_nsip
  password  = var.rpc_node_password
  secure    = "ON"

  depends_on = [citrixadc_hanode.netscaler2]
}

# It is best practice to change the RPC node password
resource "citrixadc_nsrpcnode" "netscaler2to2_rpc_node" {
    provider = citrixadc.netscaler2
  ipaddress = var.netscaler2_nsip
  password  = var.rpc_node_password
  secure    = "ON"

  depends_on = [citrixadc_hanode.netscaler2]
}

