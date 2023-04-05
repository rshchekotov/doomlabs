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
  domain     = var.environment == "production" ? "${var.host_name}.${var.host_tld}" : "localhost"
  gitea_port = 3000
  web_port   = var.environment == "production" ? 443 : 80
  web_proto  = var.environment == "production" ? "https" : "http"
  ldap_port  = var.environment == "production" ? 636 : 389
}
#endregion

#region Docker Volumes
resource "docker_volume" "nginx_conf" {
  name = "${var.brand-abbrev}-nginx-conf"
}

resource "docker_volume" "nginx_logs" {
  name = "${var.brand-abbrev}-nginx-logs"
}
#endregion

#region Docker Image
resource "docker_image" "tcp_proxy" {
  name = "${var.brand-name}/nginx"
  build {
    context = "${path.module}/docker"
    tag     = ["${var.brand-name}/nginx-${var.environment}:1.0.0"]
    version = "2"
  }
}
#endregion

#region Docker Service
resource "docker_service" "tcp_proxy" {
  name = "${var.brand-abbrev}-tcp-proxy-service"
  task_spec {
    container_spec {
      image = docker_image.tcp_proxy.image_id
      mounts {
        target = "/etc/letsencrypt"
        source = var.volume-certificates
        type   = "volume"
      }
      mounts {
        target = "/etc/nginx/conf.d"
        source = docker_volume.nginx_conf.name
        type   = "volume"
      }
      mounts {
        target = "/var/log/nginx"
        source = docker_volume.nginx_logs.name
        type   = "volume"
      }
      env = {
        DOLLAR      = "$",
        DOMAIN      = local.domain,
        ENVIRONMENT = var.environment,
        LDAP_HOST   = var.ldap_host,
        LDAP_PORT   = local.ldap_port,
        GIT_HOST    = var.git_host,
        GIT_PORT    = local.gitea_port,
        WEB_PORT    = local.web_port,
        WEB_PROTO   = local.web_proto
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

  endpoint_spec {
    ports {
      target_port    = local.web_port
      published_port = local.web_port
      publish_mode   = "host"
    }

    ports {
      target_port    = local.ldap_port
      published_port = local.ldap_port
      publish_mode   = "host"
    }
  }
}
#endregion