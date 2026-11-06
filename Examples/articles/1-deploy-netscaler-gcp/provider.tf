terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}

provider "google" {
  # Configuration options
  project     = var.project
  region = var.region
  credentials = file("~/terraform-sa.json")
}