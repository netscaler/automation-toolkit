terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "8.10.0"
    }
    citrixadc = {
      source = "citrix/citrixadc"
      version = "3.0.3"
    }
  }
  # State in a GCS bucket. Locking is built in, no extra table needed.
  backend "gcs" {
    bucket = "adc-pm-demo-tfstate"
    prefix = "netscaler/dev"
    credentials = "~/terraform-sa.json" # Relative or absolute path
  }
}

# Credentials come from the service account key file; never commit the key
provider "google" {
  project = var.gcp_project
  region = var.region
  credentials = file("~/terraform-sa.json")
}

# Use https and non default password
provider "citrixadc" {
  endpoint = format("https://%s",var.nsip)
  username = module.secrets.ns_username
  password = module.secrets.ns_password

  # Do not error due to non signed ADC TLS certificate
  # Can skip this if ADC TLS certificate is trusted
  insecure_skip_verify = true
}
