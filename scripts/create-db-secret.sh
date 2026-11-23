#!/usr/bin/env bash
# Create the db-credentials Secret from .env, so the password never lands in Git.
# Kubernetes Secrets are only base64-ENCODED, not encrypted: anyone with read access can decode them.
# Later improvement: Sealed Secrets or External Secrets (encrypted in Git / pulled from a vault).
set -euo pipefail
cd "$(dirname "$0")/.."

kubectl create namespace voting-app --dry-run=client -o yaml | kubectl apply -f -
# --from-env-file reads KEY=VALUE lines. "--dry-run | apply" = create OR update (idempotent).
kubectl -n voting-app create secret generic db-credentials \
  --from-env-file=.env --dry-run=client -o yaml | kubectl apply -f -
