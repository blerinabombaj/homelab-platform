# outputs.tf: values printed after `terraform apply` (also: `terraform output`).
# Other modules or scripts can read them too: `terraform output -raw vote_url`.

output "vote_url" {
  description = "Vote UI"
  value       = "http://localhost:${var.vote_port}"
}

output "result_url" {
  description = "Result UI"
  value       = "http://localhost:${var.result_port}"
}

output "containers" {
  description = "Names of the containers Terraform manages"
  value = [
    docker_container.vote.name,
    docker_container.result.name,
    docker_container.worker.name,
    docker_container.redis.name,
    docker_container.db.name,
  ]
}
