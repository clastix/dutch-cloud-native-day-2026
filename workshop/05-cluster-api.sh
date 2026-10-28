#!/usr/bin/env bash
# Step 5: Cluster API with its three providers.
#   infrastructure: kubevirt  (where machines run)
#   bootstrap:      kubeadm   (how worker nodes join)
#   control-plane:  kamaji    (who runs the control plane, as pods)
set -euo pipefail

export CLUSTER_TOPOLOGY=true

clusterctl init \
  --core cluster-api:v1.14.3 \
  --bootstrap kubeadm:v1.14.3 \
  --control-plane kamaji:v0.21.0 \
  --infrastructure kubevirt:v0.11.2 \
  --wait-providers
