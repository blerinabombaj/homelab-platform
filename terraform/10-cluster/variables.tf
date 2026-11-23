variable "kubeconfig" {
  description = "Path to the kubeconfig of the k3s cluster"
  type        = string
  default     = "~/.kube/config"
}

variable "argocd_chart_version" {
  description = "argo-cd Helm chart version. Check the latest with: helm search repo argo/argo-cd"
  type        = string
  default     = "8.0.0"
}
