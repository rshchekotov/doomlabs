#region Docker Provider
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

#region Local Files
resource "local_sensitive_file" "cloudflare" {
  content = templatefile("${path.module}/data/cftoken.tpl", {
    cloudflare_token = var.cloudflare_token
  })
  filename = "${path.module}/docker/secret/cloudflare.ini"
}
#endregion

#region Docker Volumes
resource "docker_volume" "certificates" {
  name = "${var.brand-abbrev}-certificates"
}
#endregion

#region Docker Image
resource "docker_image" "certbot" {
  name = "${var.brand-name}/certbot"
  build {
    context = "${path.module}/docker"
    tag     = ["${var.brand-name}/certbot-${var.environment}:1.0.0"]
    version = "2"
  }
}
#endregion

#region Docker Service
resource "docker_service" "certbot" {
  name = "${var.brand-abbrev}-certbot-service"
  task_spec {
    container_spec {
      image = docker_image.certbot.image_id
      mounts {
        target = "/etc/letsencrypt"
        source = docker_volume.certificates.name
        type   = "volume"
      }
      # TODO: Configure Environment & Stuff...
      env = {
        DOMAIN      = var.domain,
        ENVIRONMENT = var.environment
      }
    }
    restart_policy {
      condition    = "on-failure"
      delay        = "5s"
      max_attempts = 3
      window       = "10s"
    }
    runtime = "container"
  }
}
#endregion