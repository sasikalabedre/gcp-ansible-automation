output "vpc_name" {
  description = "Name of the VPC"
  value       = google_compute_network.automation_vpc.name
}

output "subnet_name" {
  description = "Name of the subnet"
  value       = google_compute_subnetwork.automation_subnet.name
}

output "web_server_names" {
  description = "Names of the web servers"

  value = [
    for instance in google_compute_instance.web :
    instance.name
  ]
}

output "web_server_external_ips" {
  description = "External IP addresses of the web servers"

  value = [
    for instance in google_compute_instance.web :
    instance.network_interface[0].access_config[0].nat_ip
  ]
}

output "web_server_internal_ips" {
  description = "Internal IP addresses of the web servers"

  value = [
    for instance in google_compute_instance.web :
    instance.network_interface[0].network_ip
  ]
}
