#!/usr/bin/env bash
# Step 6: Sveltos, the addon manager. Agents run in the management cluster,
# nothing of ours lands in the tenant's user space besides the addons themselves.
set -euo pipefail

helm repo add projectsveltos https://projectsveltos.github.io/helm-charts
helm upgrade --install projectsveltos projectsveltos/projectsveltos \
  --version 1.16.1 \
  --namespace projectsveltos --create-namespace \
  --set agent.managementCluster=true \
  --wait
