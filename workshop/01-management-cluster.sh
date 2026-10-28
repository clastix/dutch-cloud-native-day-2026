#!/usr/bin/env bash
# Step 1: the management cluster, kind without a CNI, then Calico.
set -euo pipefail
cd "$(dirname "$0")"

kind create cluster --name management --config manifests/kind-config.yaml

kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.33.0/manifests/calico.yaml
kubectl -n kube-system rollout status daemonset/calico-node --timeout=5m
kubectl wait nodes --all --for=condition=Ready --timeout=5m
