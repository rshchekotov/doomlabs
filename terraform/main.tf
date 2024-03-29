#region Provider Configuration
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.3.0"
    }
  }
}

provider "docker" {
  host = (var.os == "windows" ? "npipe:////.//pipe//docker_engine" : null)
}
#endregion

#region Local Variables
locals {
  certificate-volume = "${var.brand-abbrev}-certificates"

  internal-network = "${var.brand-abbrev}-internal"
}
#endregion

#region Shared Resources
#region Docker Networks
resource "docker_network" "internal" {
  name   = local.internal-network
  driver = "overlay"
}
#endregion

#region Docker Volumes
resource "docker_volume" "dummy" {
  name = "${var.brand-abbrev}-dummy"
}
#endregion
#endregion

# Certificates Module
module "certificates" {
  source = "./modules/certs"

  count = var.environment == "production" ? 1 : 0

  brand-abbrev     = var.brand-abbrev
  brand-name       = var.brand
  domain           = "${var.host_name}.${var.host_tld}"
  environment      = var.environment
  cloudflare_token = var.cloudflare_token

  providers = {
    docker = docker
    local  = local
  }
}

# LDAP Module
module "auth" {
  source = "./modules/auth"

  brand-name             = var.brand
  brand-abbrev           = var.brand-abbrev
  environment            = var.environment
  host_name              = var.host_name
  host_tld               = var.host_tld
  ldap_group_memberships = var.ldap_group_memberships
  ldap_organization      = var.ldap_organization
  ldap_users             = var.ldap_users
  ldap_root_password     = var.ldap_root_password
  network-name           = local.internal-network
  keycloak_username      = var.keycloak_user
  keycloak_password      = var.keycloak_password

  # If in Production, wait for the Certificates module to initialize
  volume-certificates = var.environment == "production" ? module.certificates[0].certificates : docker_volume.dummy.name

  providers = {
    docker = docker
    local  = local
  }
}
module "git" {
  source = "./modules/git"

  brand-name              = var.brand
  brand-abbrev            = var.brand-abbrev
  environment             = var.environment
  host_name               = var.host_name
  host_tld                = var.host_tld
  network-name            = local.internal-network
  gitea-postgres-user     = var.gitea_postgres_user
  gitea-postgres-password = var.gitea_postgres_password
  gitea-admin-name        = var.gitea_admin_name
  gitea-admin-password    = var.gitea_admin_password
  gitea-admin-email       = var.gitea_admin_email
  ldap-host               = module.auth.ldap_host
  ldap-port               = 389
  ldap-bind-dn            = "cn=admin,${module.auth.ldap_base_dn}"
  ldap-bind-password      = var.ldap_root_password
  ldap-user-base          = var.ldap_user_base
  ldap-user-filter        = "(&${var.ldap_git_user_filter}(uid=%s))"
  ldap-admin-filter       = "(&${var.ldap_admin_filter}(uid=%s))"

  providers = {
    docker = docker
  }
}
module "router" {
  source = "./modules/router"

  brand-name          = var.brand
  brand-abbrev        = var.brand-abbrev
  environment         = var.environment
  host_name           = var.host_name
  host_tld            = var.host_tld
  ldap_host           = module.auth.ldap_host
  git_host            = module.git.git_host
  keycloak_host       = module.auth.keycloak_host
  network-name        = local.internal-network
  volume-certificates = var.environment == "production" ? module.certificates[0].certificates : docker_volume.dummy.name

  providers = {
    docker = docker
  }
}