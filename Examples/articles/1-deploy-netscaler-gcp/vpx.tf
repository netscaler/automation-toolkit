data "google_client_config" "current" {}


resource "google_compute_network" "vip_network" {
  name                    = "${var.basename}-vip-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "vip_subnet" {
  name          = "${var.basename}-vip-subnetwork"
  ip_cidr_range = var.vpx_vip_cidr_range
  region        = var.region
  network       = google_compute_network.vip_network.id
}

resource "google_compute_address" "vpx_vip_ip" {
  name = "${var.basename}-vpx-vip-address"
  region = var.region
}


resource "google_compute_firewall" "nsip_firewall" {

  name          = "${var.basename}-nsip-firewall"
  network       = "default"
  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  target_tags = ["http-server", "https-server"]
}

resource "google_compute_firewall" "ssh_nsip_firewall" {

  name          = "${var.basename}-nsip-ssh-firewall"
  network       = "default"
  direction     = "INGRESS"
  source_ranges = [var.controlling_range1, var.controlling_range2]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["http-server", "https-server"]
}


resource "google_compute_firewall" "vip_firewall" {
  depends_on = [
    google_compute_network.vip_network, 
    google_compute_subnetwork.vip_subnet
  ]

  name          = "${var.basename}-vip-firewall"
  network       = google_compute_network.vip_network.name
  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  target_tags = ["http-server", "https-server"]
}


resource "google_compute_instance_template" "vpx" {
  region = var.region

  depends_on = [
    google_compute_network.vip_network, 
    google_compute_subnetwork.vip_subnet,
    google_compute_image.vpx_image
  ]

  name        = "${var.basename}-vpx"
  description = "Deploy a single instance of Citrix VPX"

  instance_description = "${var.basename}-vpx"
  machine_type         = var.machine_type
  can_ip_forward       = true
  tags                 = ["http-server", "https-server"]


  scheduling {
    automatic_restart = false
    preemptible       = var.preemptible
  }

  // Create a new boot disk from an image
  disk {
    auto_delete  = true
    boot         = true
    source_image = "${var.basename}-vpx"
  }

  network_interface {
    network = "default"
    access_config {
    }
  }

  network_interface {
    network = google_compute_network.vip_network.name
    subnetwork = google_compute_subnetwork.vip_subnet.name
    access_config {
    }
  }

}

resource "google_compute_instance_from_template" "vpx-01" {
  name = "${var.basename}-vpx"
  zone = var.zone

  source_instance_template = google_compute_instance_template.vpx.id


  network_interface {
    network = "default"
    access_config {
    }
  }

  network_interface {
    network    = "${var.basename}-vip-network"
    subnetwork = "${var.basename}-vip-subnetwork"
    access_config {
      nat_ip = google_compute_address.vpx_vip_ip.address
    }
  }
  
}

resource "google_compute_image" "vpx_image" {
  name   = "${var.basename}-vpx"
  family = "citrix"


  raw_disk {
    source = var.source_image
  }

  guest_os_features {
    type = "MULTI_IP_SUBNET"
  }
}

output "vpx_public_mgmt_ip_address" {
  value       = "Management access for VPX is http://${google_compute_instance_from_template.vpx-01.network_interface.0.access_config.0.nat_ip}"
  description = "The Public IP address of the VPX instance for mangagement."
}

output "vpx_vip_address" {
  value       = google_compute_instance_from_template.vpx-01.network_interface.1.access_config.0.nat_ip
  description = "The Public IP address of the VPX for Client data."
}