#!/usr/bin/env bash
# Step 8: what the customer gets. A kubeconfig, and no Control Plane nodes in sight.
set -euo pipefail
cd "$(dirname "$0")"

clusterctl get kubeconfig capi-quickstart > capi-quickstart.kubeconfig

kubectl --kubeconfig capi-quickstart.kubeconfig get nodes
kubectl --kubeconfig capi-quickstart.kubeconfig get pods -A
