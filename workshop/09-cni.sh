#!/usr/bin/env bash
# Step 9: the platform installs the CNI, not the customer.
set -euo pipefail
cd "$(dirname "$0")"

kubectl apply -f manifests/cilium-clusterprofile.yaml

kubectl --kubeconfig capi-quickstart.kubeconfig wait nodes --all --for=condition=Ready --timeout=10m
kubectl --kubeconfig capi-quickstart.kubeconfig get nodes
kubectl get clustersummaries -A
