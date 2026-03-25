# NetScaler SDX connection
sdx_host     = "10.0.0.5"
sdx_username = "nsroot"
sdx_password = "<nsroot_password>"

# Offline LAS license parameters
# entitlement_name: SDX license entitlement name as listed in LAS customer entitlements.
# Format: "SDX <model> <edition>" e.g. "SDX 8920 Premium", "SDX 15020 50G", "SDX 26100 100G"
# Refer Readme for valid model prefixes and edition values.
entitlement_name = "SDX 8920 Premium"

# las_secrets_json: Path to the las_secrets.json file on the machine running Terraform.
las_secrets_json = "./las_secrets.json"
