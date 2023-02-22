# Output the Docker Volume
output "certificates" {
  description = "Docker Volume for Certificates"
  value       = docker_volume.certificates.name
}