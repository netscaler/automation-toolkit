# NetScaler connection
nsip       = "10.0.0.10"
nitro_user = "nsroot"
nitro_pass = "<nsroot_password>"

# Offline LAS license parameters
# entitlement_name: License entitlement name as listed in LAS customer entitlements.
# Format: "<platform> <model> <edition>" e.g. "VPX 10000 Premium", "MPX 9130 Premium", "FIPS MPX 14020 Premium"
# Refer Readme for valid model prefixes and edition values.
entitlement_name = "VPX 10000 Premium"

# is_fips: Set to true for FIPS-enabled appliances only.
is_fips = false

# las_secrets_json: Path to the las_secrets.json file on the machine running Terraform.
las_secrets_json = "./las_secrets.json"
