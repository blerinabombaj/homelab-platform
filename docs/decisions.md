# Decisions log

Short record of why each tool was chosen. Interviewers ask "why X over Y?".

| # | Decision | Why | Alternatives considered |
|---|---|---|---|
| 1 | k3s over kind | Lighter on 8 GB RAM, closer to a real single-node cluster | kind, minikube |
| 2 | Gateway API over Ingress, implemented by k3s's bundled Traefik | ingress-nginx is retired; Gateway API is the successor standard. Reusing Traefik = no extra controller, less RAM | ingress-nginx, Envoy Gateway, Istio gateway |
| 6 | App config via env vars (12-factor) | Upstream code hardcoded hosts and passwords; env vars let compose, Terraform and k8s inject them | Config files baked into images |
| 7 | Secrets created from .env by script, not in Git | Simple and safe for now | Sealed Secrets, External Secrets (later) |
| 3 | Istio ambient over sidecars | No sidecar per pod, less RAM | Istio sidecar, Linkerd |
| 4 | Alloy over Promtail/Grafana Agent | Both deprecated in favour of Alloy | Fluent Bit |
| 5 | Avoid Bitnami charts/images | Bitnami stopped free images in 2025 | Upstream/official charts |
