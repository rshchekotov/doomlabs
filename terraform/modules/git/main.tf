#region Docker Provider
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.1"
    }
  }
}
#endregion

#region Local Variables
locals {
  domain = var.environment == "production" ? "git.${var.host_name}.${var.host_tld}" : "git.localhost"
  proto  = var.environment == "production" ? "https" : "http"
}

#region Docker Volumes
resource "docker_volume" "gitea_data" {
  name = "${var.brand-abbrev}-gitea-data"
}
resource "docker_volume" "gitea_postgres_data" {
  name = "${var.brand-abbrev}-gitea-postgres-data"
}
#endregion

#region Docker Image
resource "docker_image" "gitea_postgres" {
  name = "${var.brand-name}/gitea-postgres"
  build {
    context = "${path.module}/docker/postgres"
    tag     = ["${var.brand-name}/gitea-postgres-${var.environment}:1.0.0"]
    version = "2"
  }
}
resource "docker_image" "gitea" {
  name = "${var.brand-name}/gitea"
  build {
    context = "${path.module}/docker/gitea"
    tag     = ["${var.brand-name}/gitea-${var.environment}:1.0.0"]
    version = "2"
  }
}
#endregion

#region Docker Service
resource "docker_service" "gitea_postgres" {
  name = "${var.brand-abbrev}-gitea-postgres-service"
  task_spec {
    container_spec {
      image    = docker_image.gitea_postgres.image_id
      hostname = "${var.brand-abbrev}-gitea-postgres"
      mounts {
        type   = "volume"
        source = docker_volume.gitea_postgres_data.name
        target = "/var/lib/postgresql/data"
      }

      env = {
        POSTGRES_USER     = var.gitea-postgres-user
        POSTGRES_PASSWORD = var.gitea-postgres-password
        POSTGRES_DB       = "gitea"
      }
    }

    restart_policy {
      condition    = "on-failure"
      delay        = "5s"
      max_attempts = 3
    }

    networks_advanced {
      name = var.network-name
    }

    runtime = "container"
  }
}

resource "docker_service" "gitea" {
  name = "${var.brand-abbrev}-gitea-service"
  task_spec {
    container_spec {
      image    = docker_image.gitea.image_id
      hostname = "${var.brand-abbrev}-gitea"
      mounts {
        type   = "volume"
        source = docker_volume.gitea_data.name
        target = "/data"
      }

      env = {
        APP_NAME                             = "${var.brand-name} Gitea",
        USER                                 = "git",
        USER_UID                             = "1000",
        USER_GID                             = "1000",
        GITEA_ADMIN_NAME                     = var.gitea-admin-name,
        GITEA_ADMIN_EMAIL                    = var.gitea-admin-email,
        GITEA_ADMIN_PASSWORD                 = var.gitea-admin-password,
        GITEA__database__DB_TYPE             = "postgres",
        GITEA__database__HOST                = "${var.brand-abbrev}-gitea-postgres:5432",
        GITEA__database__NAME                = "gitea",
        GITEA__database__USER                = var.gitea-postgres-user,
        GITEA__database__PASSWD              = var.gitea-postgres-password,
        GITEA__security__INSTALL_LOCK        = "true",
        GITEA__server__ROOT_URL              = "${local.proto}://${local.domain}/",
        GITEA__server__DOMAIN                = local.domain,
        GITEA__service__DISABLE_REGISTRATION = "true",
        GITEA__actions__ENABLED              = "true",
        LDAP_NAME                            = "${var.brand-name} LDAP",
        LDAP_HOST                            = var.ldap-host,
        LDAP_PORT                            = var.ldap-port,
        LDAP_BIND_DN                         = var.ldap-bind-dn,
        LDAP_BIND_PASSWORD                   = var.ldap-bind-password,
        LDAP_USER_FILTER                     = var.ldap-user-filter,
        LDAP_ADMIN_FILTER                    = var.ldap-admin-filter,
        LDAP_USER_BASE                       = var.ldap-user-base,
        LDAP_ATTRIBUTE_USERNAME              = var.ldap-attribute-username,
        LDAP_ATTRIBUTE_EMAIL                 = var.ldap-attribute-email,
        LDAP_ATTRIBUTE_FIRST_NAME            = var.ldap-attribute-first-name,
        LDAP_ATTRIBUTE_LAST_NAME             = var.ldap-attribute-last-name
      }
    }

    restart_policy {
      condition    = "on-failure"
      delay        = "5s"
      max_attempts = 3
    }

    networks_advanced {
      name = var.network-name
    }
  }

  depends_on = [docker_service.gitea_postgres]
}
#endregion