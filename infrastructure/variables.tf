variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "us-central1-a"
}

variable "machine_type" {
  description = "GCP VM machine type"
  type        = string
  default     = "e2-micro"
}

variable "machine_image" {
  description = "GCP VM operating system image"
  type        = string
  default     = "debian-cloud/debian-12"
}

variable "firewall_rules" {
  description = "Firewall rules for the web servers"

  type = list(object({
    protocol = string
    ports    = list(string)
  }))

  default = [
    {
      protocol = "tcp"
      ports    = ["22"]
    },
    {
      protocol = "tcp"
      ports    = ["80"]
    }
  ]
}
