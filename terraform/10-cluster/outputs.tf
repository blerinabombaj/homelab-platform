output "argocd_url" {
  value = "http://argocd.lab.test"
}

output "argocd_admin_password_cmd" {
  description = "Run this to get the initial admin password"
  value       = "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo"
}
