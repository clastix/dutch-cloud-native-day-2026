#!/usr/bin/env bash
# Step 2: MetalLB, so Kamaji can expose Tenant Control Planes as LoadBalancer Services.
set -euo pipefail

helm repo add metallb https://metallb.github.io/metallb
helm upgrade --install metallb metallb/metallb \
  --version 0.16.1 \
  --namespace metallb-system --create-namespace \
  --wait

# Carve the address pool out of the kind docker network
# (IPv4 only: kind networks are dual-stack)
SUBNET=$(docker network inspect -f '{{range .IPAM.Config}}{{.Subnet}} {{end}}' "${KIND_EXPERIMENTAL_DOCKER_NETWORK:-kind}" \
  | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -n1)
PREFIX=$(echo "$SUBNET" | sed -E 's|^([0-9]+\.[0-9]+)\..*$|\1|g')

cat <<YAML | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: capi-ip-pool
  namespace: metallb-system
spec:
  addresses:
  - ${PREFIX}.255.200-${PREFIX}.255.250
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: empty
  namespace: metallb-system
YAML
