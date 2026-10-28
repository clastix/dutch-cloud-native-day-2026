# Dutch Cloud Native Days 2026 · Workshop

**Beyond “create machines and YOLO”**: building a truly managed Kubernetes service with Cluster API, Kamaji and Sveltos.

Utrecht, 90 minutes, hands-on.

## Slides

The deck is [Slidev](https://sli.dev), with the CLASTIX brand (Montserrat and DM Mono bundled locally, no fonts fetched at runtime).

```bash
npm install
npm run dev      # http://localhost:3030, presenter mode at /presenter
```

| Path | What |
| --- | --- |
| `slides.md` | The deck |
| `layouts/` | `cover`, `section` and `end` layouts in Clastix Blue |
| `global-bottom.vue` | Footer on content slides |
| `styles/` | Brand tokens and helpers (`eyebrow`, `card`, `zone`, `node`, `badge`, …) |
| `public/brand/` | Official logos from [clastix.io/brand](https://clastix.io/brand) |

Code on the slides is imported from `workshop/` (`<<< @/workshop/...`): what is shown is what runs.

## Workshop

Prerequisites: `docker`, `kind`, `kubectl`, `helm`, `clusterctl` v1.14.3. Linux with `/dev/kvm` for the full flow.

| Step | Script | What |
| --- | --- | --- |
| 1 | `01-management-cluster.sh` | kind without a CNI, then Calico |
| 2 | `02-metallb.sh` | MetalLB and an address pool on the kind network |
| 3 | `03-kubevirt.sh` | KubeVirt |
| 4 | `04-kamaji.sh` | cert-manager and Kamaji |
| 5 | `05-cluster-api.sh` | Cluster API: kubeadm bootstrap, Kamaji control plane, KubeVirt infrastructure |
| 6 | `06-sveltos.sh` | Sveltos, agents in the management cluster |
| 7 | `07-create-cluster.sh` | The `capi-quickstart` cluster from `manifests/capi-quickstart/` |
| 8 | `08-kubeconfig.sh` | The customer view: worker nodes only, `NotReady` |
| 9 | `09-cni.sh` | Cilium through a Sveltos `ClusterProfile` |
| 10 | `10-break-it.sh` | Delete kube-proxy, CoreDNS and Cilium, watch them come back |

Validated end-to-end on 2026-10-28 with:

| Component | Version |
| --- | --- |
| Calico | v3.33.0 |
| MetalLB (chart) | 0.16.1 |
| KubeVirt | v1.9.1 |
| cert-manager | v1.21.3 |
| Kamaji | `26.10.5-edge` (chart `0.0.0+latest`) |
| Cluster API / kubeadm bootstrap | v1.14.3 |
| Kamaji Control Plane provider | v0.21.0 |
| Cluster API Provider KubeVirt | v0.11.2 |
| Sveltos (chart) | 1.16.1 |
| Cilium | 1.20.4 |
| Tenant Kubernetes | v1.34.1 |

### Gotchas found while validating

- **MetalLB pool**: the Cluster API quickstart one-liner selects every subnet with a gateway. kind networks are dual-stack, so it concatenates IPv6 and IPv4 and MetalLB rejects the pool. Step 2 keeps the IPv4 subnet only.
- **clusterctl provider overrides**: a `providers:` entry in `$XDG_CONFIG_HOME/cluster-api/clusterctl.yaml` or `~/.cluster-api/clusterctl.yaml` replaces the built-in URL (check with `clusterctl config repositories`). Step 5 pins every provider version, which wins over the version in an overridden URL.
- **Kubelet configuration**: Kamaji `26.10.5-edge` generates the KubeletConfiguration with newer Kubernetes defaults. A v1.34.1 kubelet refuses `crashLoopBackOff.maxContainerRestartPeriod` and `imagePullCredentialsVerificationPolicy` (feature gates disabled), `kubeadm join` times out. The `KamajiControlPlane` removes them with `kubelet.configurationJSONPatches`.
- **v1beta2 `KubeadmConfigTemplate`**: `nodeRegistration` must have at least one field.
- **Sveltos selectors**: an empty `clusterSelector` matches no cluster. Every Cluster API `Cluster` carries `cluster.x-k8s.io/cluster-name`, so `operator: Exists` matches all of them.
