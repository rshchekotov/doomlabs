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
  # Domain
  base_domain = var.environment == "production" ? "${var.host_name}.${var.host_tld}" : "localhost"

  # Variables
  ldap_port    = var.environment == "production" ? 636 : 389
  ldap_base_dn = var.environment == "production" ? "dc=${var.host_name},dc=${var.host_tld}" : "dc=ldap,dc=localhost"

  # Environments
  ldap_env = yamlencode(merge({
    LDAP_ORGANISATION   = var.ldap_organization,
    LDAP_DOMAIN         = var.environment == "production" ? "ldap.${var.host_name}.${var.host_tld}" : "ldap.localhost",
    LDAP_BACKEND        = "mdb",
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
  groups_ldif = join("\n\n", [for name, data in var.ldap_group_memberships : templatefile("${path.module}/data/group_entry.tpl", {
    name        = name
    description = data.description
    users       = data.users
  })])

  users_ldif = join("\n\n", [for idx, user in var.ldap_users : templatefile("${path.module}/data/user_entry.tpl", {
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
resource "local_sensitive_file" "groups_ldif" {
  content  = local.groups_ldif
  filename = "${path.module}/docker/ldap/secret/groups.ldif"
}

resource "local_sensitive_file" "users_ldif" {
  content  = local.users_ldif
  filename = "${path.module}/docker/ldap/secret/users.ldif"
}
#endregion

#region Docker Volumes
resource "docker_volume" "ldap_db" {
  name = "${var.brand-abbrev}-ldap-db"
}

resource "docker_volume" "ldap_config" {
  name = "${var.brand-abbrev}-ldap-config"
}

resource "docker_volume" "keycloak_db" {
  name = "${var.brand-abbrev}-keycloak-db"
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

#region Docker Images
resource "docker_image" "ldap" {
  name = "${var.brand-name}/seeded-ldap"

  build {
    context = "${path.module}/docker/ldap"
    tag     = ["${var.brand-name}/seeded-ldap-${var.environment}:1.0.0"]
    version = "2"
  }

  depends_on = [
    local_sensitive_file.groups_ldif,
    local_sensitive_file.users_ldif
  ]
}

resource "docker_image" "keycloak" {
  name = "${var.brand-name}/keycloak"

  build {
    context = "${path.module}/docker/keycloak"
    tag     = ["${var.brand-name}/keycloak-${var.environment}:1.0.0"]
    version = "2"
  }
}
#endregion

#region Docker Services
resource "docker_service" "keycloak_db" {
  name = "${var.brand-abbrev}-keycloak-db-service"

  task_spec {
    container_spec {
      image    = "postgres:15.2-alpine"
      hostname = "${var.brand-abbrev}-keycloak-db"

      env = {
        POSTGRES_USER     = "${var.keycloak_username}",
        POSTGRES_PASSWORD = "${var.keycloak_password}",
        POSTGRES_DB       = "postgres"
      }

      mounts {
        target = "/var/lib/postgresql/data"
        source = docker_volume.keycloak_db.name
        type   = "volume"
      }
    }

    restart_policy {
      condition    = "on-failure"
      delay        = "5s"
      max_attempts = 3
      window       = "10s"
    }

    networks_advanced {
      name = var.network-name
    }

    runtime = "container"
  }
}

resource "docker_service" "keycloak" {
  name = "${var.brand-abbrev}-keycloak-service"
  task_spec {
    container_spec {
      image    = docker_image.keycloak.image_id
      hostname = "${var.brand-abbrev}-keycloak"

      env = {
        KC_DB          = "postgres",
        KC_DB_URL      = "jdbc:postgresql://${var.brand-abbrev}-keycloak-db:5432/postgres",
        KC_DB_USERNAME = "${var.keycloak_username}",
        KC_DB_PASSWORD = "${var.keycloak_password}",

        KEYCLOAK_ADMIN          = "${var.keycloak_username}",
        KEYCLOAK_ADMIN_PASSWORD = "${var.keycloak_password}",

        KC_HOSTNAME = "sso.${local.base_domain}"
      }
    }

    restart_policy {
      condition    = "on-failure"
      delay        = "5s"
      max_attempts = 3
      window       = "10s"
    }

    networks_advanced {
      name = var.network-name
    }

    runtime = "container"
  }

  depends_on = [
    docker_service.keycloak_db,
    docker_service.ldap
  ]
}

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
}
#endregion