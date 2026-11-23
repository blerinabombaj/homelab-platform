# versions.tf: WHICH Terraform and WHICH providers this code needs.
# A "provider" is a plugin that talks to an API (here: the Docker Engine API).

terraform {
  # Refuse to run with a Terraform CLI older than 1.6.
  required_version = ">= 1.6"

  required_providers {
    docker = {
      # kreuzwerker/docker is the community Docker provider (there's no official HashiCorp one).
      source = "kreuzwerker/docker"
      # "~> 3.0" = any 3.x, but never 4.0 (major versions may break things).
      # `terraform init` writes the exact version it picked to .terraform.lock.hcl:
      # commit that file, so everyone gets the same version.
      version = "~> 3.0"
    }
  }
}

# Provider configuration: talk to the local Docker daemon through its Unix socket.
# Your user must be in the "docker" group (same as for `docker ps` without sudo).
provider "docker" {
  host = "unix:///var/run/docker.sock"
}
