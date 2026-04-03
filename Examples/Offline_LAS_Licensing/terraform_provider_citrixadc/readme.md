# Offline LAS Licensing for NetScaler ADC — Terraform

This example shows how to use the `citrixadc_nslaslicense_offline` Terraform resource to apply a License Activation Service (LAS) license offline to a NetScaler ADC appliance.

## How It Works

The provider performs the complete offline licensing workflow from the machine running Terraform (the Terraform host):

1. Connects to the NetScaler NITRO API to trigger generation of an offline activation request package.
2. Downloads the package from the appliance via SFTP.
3. Contacts the LAS cloud service to exchange the request package for a license blob.
4. Uploads the license blob back to the appliance via SFTP.
5. Applies the license using the NITRO API and initiates a warm reboot.

**Destroy / Update behaviour:** Deleting or modifying this resource in Terraform is a no-op — the license remains active on the appliance. Any change to `entitlement_name`, `is_fips`, or `restricted_mode` requires destroying and re-creating the resource (`terraform taint` or `-replace`).

## Prerequisites

- Terraform >= 1.0
- `citrix/citrixadc` provider **>= 2.1.4** (the version that includes offline LAS support)
- NetScaler ADC running a compatible build:

  | Version | Minimum Build (non-FIPS) | Minimum Build (FIPS) |
  |---------|--------------------------|----------------------|
  | 14.1    | 51.80                    | 51.80                |
  | 13.1    | 60.29                    | 37.247               |

- Network access from the Terraform host to:
  - The NetScaler management IP (NITRO API on port 80/443 + SFTP on port 22)
  - The LAS cloud endpoints in `las_secrets.json`

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

Store this file securely. It is referenced by the `las_secrets_json` variable and read at `terraform apply` time.

### 2. Configure `example.tfvars`

Edit the file with the details for your appliance:

| Variable | Required | Description |
|----------|----------|-------------|
| `nsip` | Yes | Management IP of the NetScaler ADC |
| `nitro_user` | Yes | Must be `nsroot` |
| `nitro_pass` | Yes | Password for `nsroot` |
| `entitlement_name` | Yes | License entitlement name as listed in LAS customer entitlements (see below) |
| `is_fips` | No | `true` for FIPS-enabled VPX only (default: `false`) |
| `restricted_mode` | No | `true` to use JSON-based restricted activation instead of file upload (default: `false`) — see below |
| `las_secrets_json` | No | Path to `las_secrets.json` (default: `./las_secrets.json`) |

#### `entitlement_name` Values

The `entitlement_name` is the human-readable license entitlement name exactly as it appears in your LAS customer entitlements. The format is `"<platform> <model> <edition>"`.

Valid model prefixes: `VPX`, `MPX 59`, `MPX 89`, `MPX 91`, `MPX 92`, `MPS 14`, `MPS 25`, `MPX 15`, `MPX 16`, `MPX 17`, `MPX 26`, `FIPS MPX 14`, `FIPS MPX 15`, `FIPS MPX 16`, `FIPS MPX 89`, `FIPS MPX 91`, `FIPS MPX 92`.

Examples:

| Platform | Example `entitlement_name` |
|----------|---------------------------|
| VPX | `VPX 10000 Premium` |
| MPX | `MPX 9130 Premium` |
| MPX 15120-50G | `MPX 15120 50G` |
| MPX 26200-100G | `MPX 26200 100G` |
| FIPS MPX | `FIPS MPX 14020 Premium` |

> **Note:** The exact entitlement name must match what is listed for your account in LAS. The provider validates this against your customer entitlements at apply time.

#### Restricted Mode

When `restricted_mode = true`, the provider extracts the `lsid` and `pubkey` fields from the activation request package and sends them via a JSON-based API instead of uploading the full package file to the Citrix Cloud LAS service. Use this when outbound file uploads to Citrix Cloud are blocked in your environment.

#### FIPS Notes

- Set `is_fips = true` **only** for FIPS-enabled VPX appliances.
- FIPS MPX appliances (prefix `FIPS MPX 14xxx`) do **not** require `is_fips = true`.
- FIPS MPX appliances only support the `Premium` edition.

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
| `netscaler_version` | NetScaler software version detected on the appliance |
| `netscaler_build` | NetScaler build number |
| `lsguid` | License Server GUID from the appliance |
