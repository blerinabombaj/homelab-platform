# homelab-platform

A Kubernetes platform built fully as code on a home PC (WSL2 + k3s). The workload is a polyglot microservice app (Python, Node.js, .NET, Redis, Postgres).

## Architecture
_TODO: diagram (vote → redis → worker → postgres → result), then the platform layers around it._

## Stack
| Layer | Tool |
|---|---|
| Local dev | Docker Compose |
| Provisioning | Terraform / OpenTofu |
| Cluster | k3s |
| Ingress | Gateway API |
| GitOps | Argo CD |
| Service mesh / canary | Istio (ambient mode) |
| Observability | OpenTelemetry Collector, Prometheus, Grafana, Loki, Tempo, Alloy |
| SSO | Keycloak |
| Runtime security | Falco |

## How to run (on the PC)
```bash
cp .env.example .env                       # set a real password

# Phase 1: Docker Compose
docker compose up -d --build               # vote :8080, result :8081
docker compose --profile seed run --rm seed

# Phase 2: Terraform (Docker provider)
cd terraform/00-docker && cp example.tfvars terraform.tfvars
terraform init && terraform plan && terraform apply   # vote :9080, result :9081

# Phase 3: k3s
bash scripts/install-k3s.sh
kubectl apply -k k8s/platform/gateway
bash scripts/k3s-import-images.sh
bash scripts/create-db-secret.sh
kubectl apply -k k8s/apps/voting-app/overlays/dev

# Phase 4: Argo CD (GitOps)
cd terraform/10-cluster && terraform init && terraform apply
kubectl apply -f k8s/platform/argocd/httproute.yaml
kubectl apply -f k8s/platform/argocd/apps/
```
Mac `/etc/hosts`: `<pc-tailscale-ip>  vote.lab.test result.lab.test argocd.lab.test petclinic.lab.test`

## What I learned
_TODO: fill in per phase, see ROADMAP.md._

## Credits
App code in `app/` is from [dockersamples/example-voting-app](https://github.com/dockersamples/example-voting-app) (Apache 2.0). Everything else (Dockerfiles, compose, Terraform, Kubernetes, CI) is written from scratch.
