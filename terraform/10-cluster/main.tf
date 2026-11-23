#   cd terraform/10-cluster && terraform init && terraform apply
# Later phases add more helm_release blocks here (monitoring, Istio, Keycloak, Falco).

# helm_release = `helm install/upgrade` as a Terraform resource.
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm" # chart repo (like a package registry)
  chart            = "argo-cd"
  version          = var.argocd_chart_version # ALWAYS pin chart versions
  namespace        = "argocd"
  create_namespace = true

  # Our overrides of the chart's defaults, kept in a YAML file (easier to read than set {} blocks).
  values = [file("${path.module}/values/argocd.yaml")]

  # Wait until all pods are Ready before reporting success (fail the apply otherwise).
  wait    = true
  timeout = 600
}

# Why the Argo CD Applications are NOT created here: they're custom resources (CRDs) that
# only exist after the chart is installed, and Terraform validates them at PLAN time,
# before the chart exists -> the first apply fails. So we `kubectl apply` them afterwards.
