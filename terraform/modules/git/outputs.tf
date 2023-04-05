output "git_host" {
  description = "Hostname for the Gitea Container"
  value       = docker_service.gitea.task_spec[0].container_spec[0].hostname
}