#!/usr/bin/env bash
# Step 3: KubeVirt, the "cloud" our worker nodes run on.
set -euo pipefail

kubectl apply -f https://github.com/kubevirt/kubevirt/releases/download/v1.9.1/kubevirt-operator.yaml
kubectl apply -f https://github.com/kubevirt/kubevirt/releases/download/v1.9.1/kubevirt-cr.yaml

# No /dev/kvm (nested virtualisation disabled)? Fall back to software emulation:
# kubectl -n kubevirt patch kubevirt kubevirt --type=merge \
#   -p '{"spec":{"configuration":{"developerConfiguration":{"useEmulation":true}}}}'

kubectl -n kubevirt wait kubevirt kubevirt --for=condition=Available --timeout=10m
