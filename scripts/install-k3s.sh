#!/usr/bin/env bash
# Install k3s (single-node Kubernetes) on the PC (WSL2 Ubuntu, systemd enabled).
# Run ON THE PC:  bash scripts/install-k3s.sh
set -euo pipefail   # stop on errors (-e), unset variables (-u) and failures inside pipes

# --write-kubeconfig-mode 644: kubeconfig readable without sudo.
# We keep the bundled Traefik (Gateway API implementation) and local-path storage.
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode 644" sh -

# Copy the kubeconfig to the default place kubectl, helm and Terraform look at.
mkdir -p ~/.kube
cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
chmod 600 ~/.kube/config

# Gateway API CRDs (the Gateway/HTTPRoute object types). Traefik's CRD chart usually
# includes them; install the official standard set only if they're missing.
if ! kubectl get crd gateways.gateway.networking.k8s.io >/dev/null 2>&1; then
  kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.3.0/standard-install.yaml
fi

kubectl get nodes -o wide
