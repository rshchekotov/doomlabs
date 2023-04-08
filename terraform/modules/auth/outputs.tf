locals {
  base_dn = var.environment == "production" ? "dc=${var.host_name},dc=${var.host_tld}" : "dc=ldap,dc=localhost"
}

output "keycloak_host" {
  description = "Hostname for the Keycloak Container"
  value       = docker_service.keycloak.task_spec[0].container_spec[0].hostname
}

output "ldap_host" {
  description = "Hostname for the LDAP Container"
  value       = docker_service.ldap.task_spec[0].container_spec[0].hostname
}

output "ldap_base_dn" {
  description = "Base DN for the LDAP Container"
  value       = local.base_dn
}