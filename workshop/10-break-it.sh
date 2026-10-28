#!/usr/bin/env bash
# Step 10: be the customer, break the cluster. Then watch it heal.
set -euo pipefail
cd "$(dirname "$0")"
export KUBECONFIG=capi-quickstart.kubeconfig

kubectl -n kube-system delete daemonset kube-proxy   # managed by Kamaji
kubectl -n kube-system delete deployment coredns     # managed by Kamaji
kubectl -n cilium delete daemonset cilium            # managed by Sveltos

watch kubectl get daemonsets,deployments -A
