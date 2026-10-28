#!/usr/bin/env bash
# Step 7: a Kubernetes cluster, declaratively.
set -euo pipefail
cd "$(dirname "$0")"

kubectl apply -f manifests/capi-quickstart/

# The Control Plane is a set of pods, ready in seconds
kubectl wait cluster capi-quickstart --for=condition=ControlPlaneAvailable --timeout=5m
kubectl get tenantcontrolplanes

# Worker nodes are KubeVirt VMs: wait until they joined the cluster
kubectl wait machinedeployment capi-quickstart-md-0 --for=jsonpath='{.status.replicas}'=2 --timeout=5m
kubectl wait machines -l cluster.x-k8s.io/cluster-name=capi-quickstart \
  --for=jsonpath='{.status.phase}'=Running --timeout=15m
clusterctl describe cluster capi-quickstart
