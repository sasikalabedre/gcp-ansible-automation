terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# --------------------------------
# VPC
# --------------------------------

resource "google_compute_network" "automation_vpc" {
  name                    = "devops-automation-vpc"
  auto_create_subnetworks = false
}

# --------------------------------
# Subnet
# --------------------------------

resource "google_compute_subnetwork" "automation_subnet" {
  name          = "devops-automation-subnet"
  ip_cidr_range = "10.20.0.0/24"
  region        = var.region
  network       = google_compute_network.automation_vpc.id
}

# --------------------------------
# Firewall
# --------------------------------

resource "google_compute_firewall" "automation_firewall" {
  name    = "devops-automation-firewall"
  network = google_compute_network.automation_vpc.name

  dynamic "allow" {
    for_each = var.firewall_rules

    content {
      protocol = allow.value.protocol
      ports    = allow.value.ports
    }
  }

  source_ranges = ["0.0.0.0/0"]

  target_tags = ["automation-web"]
}

# --------------------------------
# Web Servers
# --------------------------------

resource "google_compute_instance" "web" {
  count = 2

  name         = "automation-web-${format("%02d", count.index + 1)}"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.machine_image
      size  = 10
      type  = "pd-standard"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.automation_subnet.id

    # Public IP
    access_config {
    }
  }

  tags = ["automation-web"]
}
