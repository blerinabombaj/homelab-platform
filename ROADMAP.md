# Roadmap

One phase = one or more commits. Write "what I learned" in README after each phase.
RAM budget: 8 GB WSL. Only run the components for the phase you're working on.

## Phase 1: Containers (Docker Compose)
- [ ] Read the app code: what talks to what, on which port, through which env vars
- [ ] Write a Dockerfile per service (vote, result, worker, seed-data): multi-stage, non-root user, small base image
- [ ] `compose.yaml`: 5 services, 2 networks (front/back), healthchecks, named volume for Postgres
- [ ] `.env.example` for config, real `.env` stays out of Git

## Phase 2: Terraform (Docker provider)
- [ ] `terraform/00-docker`: same stack as compose, but as Terraform resources
- [ ] Understand state, plan/apply, variables, outputs

## Phase 3: Kubernetes (k3s)
- [ ] Install k3s on the PC (`scripts/install-k3s.sh`), keep bundled Traefik as the Gateway API implementation
- [ ] `k8s/apps/voting-app/base`: Deployments, Services, ConfigMap, Secret, probes, resource limits
- [ ] Kustomize overlay `dev`
- [ ] Gateway API: a Gateway + HTTPRoutes for vote and result

## Phase 4: GitOps (Argo CD)
- [ ] `terraform/10-cluster`: install Argo CD with the Helm provider
- [ ] Argo CD Application for voting-app (app-of-apps later)
- [ ] Change a manifest in Git → watch Argo sync it

## Phase 5: Observability
- [ ] kube-prometheus-stack (Prometheus + Grafana)
- [ ] Loki + Alloy for logs, Tempo for traces
- [ ] OTel Collector; instrument at least one service
- [ ] One dashboard + one alert that actually fires

## Phase 6: Service mesh (Istio ambient)
- [ ] Install Istio ambient, enrol the namespace
- [ ] Deploy vote v2, split traffic 90/10 → canary → 100

## Phase 7: SSO (Keycloak)
- [ ] Keycloak in-cluster, realm as code (import JSON, no secrets in Git)
- [ ] OIDC login for Grafana and Argo CD

## Phase 8: Runtime security (Falco)
- [ ] Install Falco, trigger a rule (shell in a container), see the alert in Grafana

## Phase 9: CI
- [ ] `.github/workflows/ci.yml`: terraform fmt/validate, hadolint, kubeconform, build images
