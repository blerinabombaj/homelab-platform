#!/usr/bin/env bash
# k3s runs containers with its own containerd, NOT with Docker. Images built by
# `docker compose build` are invisible to k3s until you import them.
# (Once CI pushes to GHCR in Phase 9, k3s pulls from the registry instead.)
set -euo pipefail
cd "$(dirname "$0")/.."          # run from the repo root, wherever you call it from

docker compose build vote result worker
for svc in vote result worker; do
  echo "importing homelab/${svc}:dev"
  # docker save = image -> tar stream; k3s ctr images import = tar -> containerd
  docker save "homelab/${svc}:dev" | sudo k3s ctr images import -
done
