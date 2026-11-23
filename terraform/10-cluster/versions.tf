# Installs platform components into the k3s cluster with Helm, managed by Terraform.
# Why Terraform for Helm? One `terraform apply` rebuilds the whole platform, with pinned versions.
terraform {
  required_version = ">= 1.6"
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0" # v3 changed the syntax: kubernetes = { ... } is an attribute, not a block
    }
  }
}

# The Helm provider talks to the cluster using the same kubeconfig as kubectl.
provider "helm" {
  kubernetes = {
    config_path = var.kubeconfig
  }
}
