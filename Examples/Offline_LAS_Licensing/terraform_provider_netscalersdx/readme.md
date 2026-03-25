# Offline LAS Licensing for NetScaler SDX — Terraform

This example shows how to use the `netscalersdx_nslaslicense_offline` Terraform resource to apply a License Activation Service (LAS) license offline to a NetScaler SDX appliance.

## How It Works

The provider performs the complete offline licensing workflow from the machine running Terraform (the Terraform host):

1. Connects to the NetScaler SDX API to trigger generation of an offline activation request package.
2. Downloads the package from the appliance via SFTP.
3. Contacts the LAS cloud service to exchange the request package for a license blob.
4. Uploads the license blob back to the appliance via SFTP.
5. Applies the license via the SDX API and initiates a warm reboot.

**Destroy / Update behaviour:** Deleting or modifying this resource in Terraform is a no-op — the license remains active on the appliance. Any change to `entitlement_name` requires destroying and re-creating the resource (`terraform taint` or `-replace`).

## Prerequisites

- Terraform >= 1.0
- `netscaler/netscalersdx` provider **>= 0.7.4** (the version that includes offline LAS support)
- Network access from the Terraform host to:
  - The SDX management IP (API on port 443 + SFTP on port 22)
  - The LAS cloud endpoints listed in `las_secrets.json`

## Setup

### 1. Fill in `las_secrets.json`

Populate the file with your Citrix Cloud / LAS credentials:

```json
{
  "ccid": "<your-citrix-customer-id>",
  "client": "<your-client-id>",
  "password": "<your-client-secret>",
  "las_endpoint": "https://las.cloud.com",
  "cc_endpoint": "https://trust.citrixworkspacesapi.net/root/tokens/clients"
}
```

| Key | Description |
|-----|-------------|
| `ccid` | Citrix Cloud customer ID |
| `client` | client ID for the LAS service |
| `password` | client secret |
| `las_endpoint` | LAS API base URL (provided by Citrix) |
| `cc_endpoint` | OAuth token endpoint URL (provided by Citrix) |

Store this file securely. It is read from the Terraform host at `terraform apply` time.

### 2. Configure `example.tfvars`

Edit the file with the details for your SDX appliance:

| Variable | Required | Description |
|----------|----------|-------------|
| `sdx_host` | Yes | Management IP of the NetScaler SDX |
| `sdx_username` | Yes | Must be `nsroot` |
| `sdx_password` | Yes | Password for `nsroot` |
| `entitlement_name` | Yes | SDX license entitlement name as listed in LAS customer entitlements (see table below) |
| `las_secrets_json` | No | Path to `las_secrets.json` (default: `./las_secrets.json`) |

> **Note:** The `sdx_username` must be `nsroot`. Other accounts are not supported for offline LAS licensing.

Alternatively, the provider connection details can be supplied via environment variables instead of `example.tfvars`:

```bash
export NETSCALERSDX_HOST="https://10.0.0.5"
export NETSCALERSDX_USERNAME="nsroot"
export NETSCALERSDX_PASSWORD="<password>"
```

#### `entitlement_name` Values

The `entitlement_name` is the human-readable license entitlement name exactly as it appears in your LAS customer entitlements. The format is `"SDX <model> <edition>"`.

Valid model prefixes: `SDX 89`, `SDX 91`, `SDX 92`, `SDX 14`, `SDX 15`, `SDX 16`, `SDX 17`, `SDX 26`.

Edition availability depends on the model family:

| Model family | Valid editions | Example `entitlement_name` |
|---|---|---|
| SDX 89xx, 91xx, 92xx, 14xxx, 16xxx, 17xxx | `Premium` | `SDX 9195 Premium` |
| SDX 15xxx | `50G`, `Premium` | `SDX 15020 50G` |
| SDX 26xxx | `50S`, `100G`, `Premium` | `SDX 26100 100G` |

## Usage

```bash
terraform init
terraform plan  -var-file example.tfvars
terraform apply -var-file example.tfvars
```

## Outputs

After a successful apply:

| Output | Description |
|--------|-------------|
| `license_status` | Status returned after license application (e.g. `applied`) |
| `license_blob_path` | Local path on the Terraform host where the blob was saved |
| `netscalersdx_version` | SDX software version detected on the appliance |
| `netscalersdx_build` | SDX build number |
| `lsguid` | License Server GUID from the appliance |
