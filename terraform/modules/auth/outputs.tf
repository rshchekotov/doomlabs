# Output the Docker Volume
output "ldap_host" {
  description = "Hostname for the LDAP Container"
  value       = docker_service.ldap.task_spec[0].container_spec[0].hostname
}