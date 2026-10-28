# capi-quickstart

A Cluster API cluster with a Kamaji-managed Control Plane and KubeVirt worker nodes,
one file per resource, grouped by provider:

| File | Kind | Provider |
| --- | --- | --- |
| `cluster.yaml` | `Cluster` | core |
| `machine-deployment.yaml` | `MachineDeployment` | core |
| `kubevirt-cluster.yaml` | `KubevirtCluster` | infrastructure (KubeVirt) |
| `kubevirt-machine-template.yaml` | `KubevirtMachineTemplate` | infrastructure (KubeVirt) |
| `kamaji-control-plane.yaml` | `KamajiControlPlane` | control plane (Kamaji) |
| `kubeadm-config-template.yaml` | `KubeadmConfigTemplate` | bootstrap (kubeadm) |

Adapted from the [Kamaji provider KubeVirt guide](https://github.com/clastix/cluster-api-control-plane-provider-kamaji/blob/master/docs/providers-kubevirt.md)
to the Cluster API v1beta2 contract.
