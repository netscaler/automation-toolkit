terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "8.10.0"
    }
  }
}

provider "google" {
  # Configuration options
  project     = var.project
  region = var.region
  credentials = file("~/terraform-sa.json")
}