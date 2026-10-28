#!/usr/bin/env bash
# Step 4: cert-manager and Kamaji, the Hosted Control Plane manager.
set -euo pipefail

helm repo add jetstack https://charts.jetstack.io
helm upgrade --install cert-manager jetstack/cert-manager \
  --version v1.21.3 \
  --namespace cert-manager --create-namespace \
  --set crds.enabled=true \
  --wait

helm repo add clastix https://clastix.github.io/charts
helm upgrade --install kamaji clastix/kamaji \
  --version 0.0.0+latest \
  --namespace kamaji-system --create-namespace \
  --set image.tag=26.10.5-edge \
  --wait --timeout 10m

# Kamaji ships a multi-tenant etcd as the "default" DataStore
kubectl get datastores
