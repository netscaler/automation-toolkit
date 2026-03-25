# Offline LAS Licensing for NetScaler ADC

This example demonstrates how to use the `netscaler.adc.nslaslicense_offline` Ansible module to apply a License Activation Service (LAS) license offline to a NetScaler ADC appliance.

## How It Works

The module performs the following steps, all orchestrated from the Ansible control node:

1. Connects to the NetScaler NITRO API to trigger generation of an offline activation request package.
2. Downloads the request package from the appliance via SFTP.
3. Contacts the LAS cloud service to exchange the request package for a license blob.
4. Uploads the license blob back to the appliance via SFTP.
5. Applies the license using the NITRO API and initiates a warm reboot.

Because the module uses NITRO and SFTP internally, **all tasks must be delegated to `localhost`** (the Ansible control node). No SSH connection to the NetScaler is required from Ansible's inventory perspective.

## Prerequisites

### Control Node

- Ansible 2.14+
- `netscaler.adc` collection installed:
  ```bash
  ansible-galaxy collection install netscaler.adc
  ```
- `paramiko` Python library (for SFTP):
  ```bash
  pip install paramiko
  ```

### NetScaler ADC

The appliance must be running a build that supports offline LAS licensing:

| Version | Minimum Build (non-FIPS) | Minimum Build (FIPS) |
|---------|--------------------------|----------------------|
| 14.1    | 51.80                    | 51.80                |
| 13.1    | 60.29                    | 37.247               |

## Setup

### 1. Fill in `las_secrets.json`

Populate the file with your Citrix Cloud / NetScaler LAS credentials:

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
| `ccid` | Your Citrix Cloud customer ID |
| `client` | client ID for the LAS service |
| `password` | client secret |
| `las_endpoint` | LAS API base URL (provided by Citrix) |
| `cc_endpoint` | OAuth token endpoint URL (provided by Citrix) |

Store this file securely on the control node. Pass its absolute path as `las_secrets_json` in the inventory.

### 2. Configure `inventory.ini`

Edit the inventory to match your appliances. Each host entry needs:

| Variable | Required | Description |
|----------|----------|-------------|
| `nsip` | Yes | Management IP of the NetScaler |
| `nitro_user` | Yes | Must be `nsroot` |
| `nitro_pass` | Yes | Password for `nsroot` |
| `entitlement_name` | Yes | License entitlement name as listed in LAS customer entitlements (see below) |
| `las_secrets_json` | Yes | Absolute path to `las_secrets.json` on the control node |
| `nitro_protocol` | No | `http` or `https` (default: `https`) |
| `validate_certs` | No | `true` or `false` (default: `false`) |
| `is_fips` | No | `true` for FIPS VPX appliances only (default: `false`) |

#### `entitlement_name` Values

The `entitlement_name` is the human-readable license entitlement name exactly as it appears in your LAS customer entitlements. The format is `"<platform> <model> <edition>"`.

Valid model prefixes: `VPX`, `MPX 59`, `MPX 89`, `MPX 91`, `MPX 92`, `MPS 14`, `MPS 25`, `MPX 15`, `MPX 16`, `MPX 17`, `MPX 26`, `FIPS MPX 14`, `FIPS MPX 15`, `FIPS MPX 16`, `FIPS MPX 89`, `FIPS MPX 91`, `FIPS MPX 92`.

Examples:

| Platform | Example `entitlement_name` |
|----------|---------------------------|
| VPX | `VPX 10000 Premium` |
| MPX | `MPX 8905 Premium` |
| MPX 15120-50G | `MPX 15120 50G` |
| MPX 26200-100G | `MPX 26200 100G` |
| FIPS MPX | `FIPS MPX 14020 Premium` |
| FIPS VPX | `FIPS VPX 5000 Premium` |

> **Note:** The exact entitlement name must match what is listed for your account in LAS. The module validates this against your customer entitlements at runtime.

#### FIPS Notes

- Set `is_fips=true` only for FIPS-enabled VPX appliances.
- FIPS MPX appliances (prefix `FIPS MPX 14xxx`) do **not** need `is_fips=true`.
- FIPS MPX appliances only support the `Premium` edition.

## Usage

```bash
ansible-playbook apply_offline_las_license.yaml -i inventory.ini
```

To target a single appliance:

```bash
ansible-playbook apply_offline_las_license.yaml -i inventory.ini --limit ns_vpx_1
```

## Output

A successful run returns:

```json
{
  "changed": true,
  "output_file": "offline_token_10.0.0.10_activation.blob.tgz",
  "loglines": [
    "INFO: LAS version check passed: ...",
    "INFO: Got request package: ...",
    "INFO: License blob applied successfully"
  ]
}
```

The license blob file (`offline_token_<nsip>_activation.blob.tgz`) is written to the current working directory on the control node. The appliance performs a warm reboot after the license is applied.
