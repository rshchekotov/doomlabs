#region Terraform Providers
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
#endregion

#region Local Variables
locals {
  # Variables
  ldap_port    = var.environment == "production" ? 636 : 389
  ldap_base_dn = var.environment == "production" ? "dc=${var.host_name},dc=${var.host_tld}" : "dc=ldap,dc=localhost"

  # Environments
  ldap_env = yamlencode(merge({
    LDAP_ORGANISATION   = var.ldap_organization,
    LDAP_DOMAIN         = var.environment == "production" ? "ldap.${var.host_name}.${var.host_tld}" : "ldap.localhost",
    LDAP_BASE_DN        = local.ldap_base_dn,
    LDAP_ADMIN_PASSWORD = var.ldap_root_password
    }, var.environment == "production" ? {
    LDAP_TLS_CRT_FILENAME    = "/etc/letsencrypt/live/${var.host_name}.${var.host_tld}/cert.pem",
    LDAP_TLS_KEY_FILENAME    = "/etc/letsencrypt/live/${var.host_name}.${var.host_tld}/privkey.pem",
    LDAP_TLS_CA_CRT_FILENAME = "/etc/letsencrypt/live/${var.host_name}.${var.host_tld}/fullchain.pem"
    } : {
    LDAP_TLS = false
  }))

  # LDIF's
  base_ldif = templatefile("${path.module}/data/base.tpl", {
    base_dn          = local.ldap_base_dn
    gitea_users      = lookup(var.ldap_group_memberships, "gitea_users", [])
    acquaintances    = lookup(var.ldap_group_memberships, "acquaintances", [])
    casual_friends   = lookup(var.ldap_group_memberships, "casual_friends", [])
    close_friends    = lookup(var.ldap_group_memberships, "close_friends", [])
    intimate_friends = lookup(var.ldap_group_memberships, "intimate_friends", [])
  })
  users_ldif = join("\n\n", [for idx, user in var.ldap_users : templatefile("${path.module}/data/user_entry.tpl", {
    base_dn  = local.ldap_base_dn
    ldap_org = var.ldap_organization
    # User Variables
    id         = 8001 + idx
    uid        = user.uid
    first_name = user.first_name
    last_name  = user.last_name
    email      = user.email
    password   = user.password
    state      = user.state
    city       = user.city
    country    = user.country
  })])

  # Mount Points
  mounts = concat([{
    target = "/var/lib/ldap"
    source = docker_volume.ldap_db.name
    type   = "volume"
    }, {
    target = "/etc/ldap/slapd.d"
    source = docker_volume.ldap_config.name
    type   = "volume"
    }], var.environment == "production" ? [{
    target = "/etc/letsencrypt"
    source = var.volume-certificates
    type   = "volume"
  }] : [])

  # Secrets
  secrets = [{
    secret   = docker_secret.ldap_env
    filename = "/container/environment/01-custom/env.startup.yaml"
  }]
}
#endregion

#region Local Files
resource "local_sensitive_file" "base_ldif" {
  content  = local.base_ldif
  filename = "${path.module}/docker/secret/base.ldif"
}

resource "local_sensitive_file" "users_ldif" {
  content  = local.users_ldif
  filename = "${path.module}/docker/secret/users.ldif"
}
#endregion

#region Docker Volumes
resource "docker_volume" "ldap_db" {
  name = "${var.brand-abbrev}-ldap-db"
}

resource "docker_volume" "ldap_config" {
  name = "${var.brand-abbrev}-ldap-config"
}
#endregion

#region Docker Secrets
resource "docker_secret" "ldap_env" {
  name = "${var.brand-abbrev}-ldap-env-${replace(timestamp(), ":", ".")}"
  data = base64encode(local.ldap_env)
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }
}
#endregion

#region Docker Image
resource "docker_image" "ldap" {
  name = "${var.brand-name}/seeded-ldap"

  build {
    context = "${path.module}/docker"
    tag     = ["${var.brand-name}/seeded-ldap-${var.environment}:1.0.0"]
    version = "2"
  }

  depends_on = [
    local_sensitive_file.base_ldif,
    local_sensitive_file.users_ldif
  ]
}
#endregion

#region Docker Service
resource "docker_service" "ldap" {
  name = "${var.brand-abbrev}-ldap-service"
  task_spec {
    container_spec {
      image    = docker_image.ldap.image_id
      hostname = "${var.brand-abbrev}-ldap"

      dynamic "mounts" {
        for_each = local.mounts
        content {
          target = mounts.value.target
          source = mounts.value.source
          type   = mounts.value.type
        }
      }

      dynamic "secrets" {
        for_each = local.secrets
        content {
          secret_id   = secrets.value.secret.id
          secret_name = secrets.value.secret.name
          file_name   = secrets.value.filename
          file_uid    = "911"
          file_gid    = "911"
          file_mode   = 0777
        }
      }
    }

    restart_policy {
      condition    = "on-failure"
      delay        = "5s"
      max_attempts = 5
      window       = "10s"
    }

    networks_advanced {
      name = var.network-name
    }

    runtime = "container"
  }

  #endpoint_spec {
  #  ports {
  #    protocol       = "tcp"
  #    publish_mode   = "ingress"
  #    published_port = local.ldap_port
  #    target_port    = local.ldap_port
  #  }
  #}
}
#endregion