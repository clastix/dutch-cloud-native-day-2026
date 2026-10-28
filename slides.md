---
theme: default
title: Beyond "create machines and YOLO"
info: |
  Dutch Cloud Native Days 2026, Utrecht.
  Workshop: building a truly managed Kubernetes service with Cluster API, Kamaji and Sveltos.
author: Dario Tranchitella
colorSchema: light
aspectRatio: 16/9
canvasWidth: 980
fonts:
  sans: Montserrat
  mono: DM Mono
  provider: none
lineNumbers: false
drawings:
  persist: false
transition: fade
mdc: true
layout: cover
---

<p class="eyebrow">Dutch Cloud Native Days 2026 · Utrecht · Workshop</p>

# Beyond “create machines and YOLO”

Building a truly managed Kubernetes service with Cluster API, Kamaji and Sveltos

<p class="cx-speaker"><strong>Dario Tranchitella</strong> · CLASTIX</p>

<!--
TODO: confirm the final workshop title, it is a working title.
-->

---

<p class="eyebrow">Before we start</p>

# Thank you, Dutch Cloud Native Days

<div class="grid grid-cols-[1fr_auto] gap-12 items-center mt-8">
<div>

<p class="lead">CLASTIX is proud to be a <strong>Platinum Sponsor</strong> of Dutch Cloud Native Days 2026.</p>

Thanks to the organisers, the volunteers, and to all of you for spending 90 minutes of your conference with us.

</div>
<img src="/brand/clastix_vertical_fullcolor.svg" class="w-40" alt="CLASTIX" onerror="this.style.display='none'">
</div>

---

<p class="eyebrow">Who is talking</p>

# Dario Tranchitella

<div class="grid grid-cols-2 gap-8 mt-6">
<div>

- Co-Founder and CTO at CLASTIX
- Kamaji maintainer
- Creator of Project Capsule
- dario@clastix.io

</div>
<div class="card">

### What we do at CLASTIX

We build and support the Open Source foundations of Managed Kubernetes services: **Kamaji**, **Capsule**, and **kMetal**, our product on top of them.

</div>
</div>

<!--
TODO: fill in the bio. Kept as placeholders on purpose.
-->

---

<p class="eyebrow">90 minutes, hands-on</p>

# Agenda

| Time | Block | Steps |
| --- | --- | --- |
| 00:00 | Welcome and setup | |
| 00:05 | What makes Kubernetes *managed* | |
| 00:15 | Why Cluster API, why Kamaji | |
| 00:25 | **Day-0** · the management cluster | 1 → 6 |
| 00:45 | **Day-1** · a cluster as a resource | 7 → 8 |
| 01:00 | **Day-2** · addons that heal themselves | 9 → 10 |
| 01:15 | Bonus · operators all the way down | |
| 01:20 | Reality check, and what comes next | |
| 01:27 | Q&A | |

<!--
Timings are a proposal: adjust to the room.
-->

---

<p class="eyebrow">Prerequisites</p>

# Follow along, or type along

<div class="grid grid-cols-2 gap-8 mt-4">
<div>

### On your laptop

- `kind`, `kubectl`, `helm`, `clusterctl` v1.14.3, `docker`
- Linux with `/dev/kvm` for the full hands-on
- ~10 GB of free memory: two VMs of 3 GiB, plus the management cluster

### Everything is in the repository

```bash
git clone https://github.com/clastix/dutch-cloud-native-day-2026.git
cd dutch-cloud-native-day-2026/workshop && ls
```

</div>
<div class="card">

### No KVM? No problem

KubeVirt can fall back to software emulation (step 3), it is just slower.

On macOS the VM images are `amd64` only: follow the flow, the rationale is what matters.

Every step is a numbered script in `workshop/`: what you see on the slides is what runs.

</div>
</div>

<!--
TODO: repository URL once it is public.
-->

---
layout: section
number: "01"
---

# What makes Kubernetes *managed*?

It is not about spinning up clusters and calling it a day.

---

<p class="eyebrow">Self-managed vs managed</p>

# It is all about the Control Plane

<div class="grid grid-cols-2 gap-8 mt-2">
<div>

<div class="zone">
<span class="zone-label">Your cluster</span>
<div class="grid grid-cols-3 gap-2">
<div class="node cp">control plane</div>
<div class="node cp">control plane</div>
<div class="node cp">control plane</div>
<div class="node">etcd</div>
<div class="node">etcd</div>
<div class="node">etcd</div>
<div class="node">worker</div>
<div class="node">worker</div>
<div class="node">worker</div>
</div>
</div>

<p class="mt-3 text-sm">You patch it, you back up etcd, you rotate certificates, you get paged.</p>

</div>
<div>

<div class="zone platform mb-3">
<span class="zone-label">Provider</span>
<div class="node ghost">Control Plane · an API endpoint</div>
</div>

<div class="zone">
<span class="zone-label">Your cluster</span>
<div class="grid grid-cols-3 gap-2">
<div class="node">worker</div>
<div class="node">worker</div>
<div class="node">worker</div>
</div>
</div>

<p class="mt-3 text-sm">The Control Plane is <strong>externally managed</strong>, and <strong>not visible</strong>: <code>kubectl get nodes</code> shows workers only.</p>

</div>
</div>

---

<p class="eyebrow">Isolation</p>

# User space and platform space

<div class="grid grid-cols-2 gap-6 mt-4">
<div class="card solid">

### Platform space · ours

- API Server, Controller Manager, Scheduler
- Datastore, certificates, upgrades
- The addons the cluster can't live without: kube-proxy, CoreDNS, CNI
- The SLA

</div>
<div class="card bordered">

### User space · theirs

- Workloads, namespaces, RBAC
- Their own addons and operators
- Node pools, through *our* API

</div>
</div>

<p class="quote mt-6">If a customer can break it, and it stays broken, it is not managed.</p>

---

<p class="eyebrow">Hosted Control Plane</p>

# Control Planes are just workloads

<div class="grid grid-cols-[3fr_2fr] gap-6 mt-2">
<div class="zone platform">
<span class="zone-label">Management cluster</span>
<div class="grid grid-cols-2 gap-3">
<div class="zone">
<span class="zone-label">Tenant A</span>
<div class="grid gap-1">
<div class="node cp">kube-apiserver</div>
<div class="node cp">controller-manager</div>
<div class="node cp">scheduler</div>
</div>
</div>
<div class="zone">
<span class="zone-label">Tenant B</span>
<div class="grid gap-1">
<div class="node cp">kube-apiserver</div>
<div class="node cp">controller-manager</div>
<div class="node cp">scheduler</div>
</div>
</div>
</div>
<div class="node mt-3">Datastore · shared or dedicated</div>
</div>
<div class="grid gap-3">
<div class="zone">
<span class="zone-label">Tenant A · workers</span>
<div class="grid grid-cols-2 gap-1"><div class="node">node</div><div class="node">node</div></div>
</div>
<div class="zone">
<span class="zone-label">Tenant B · workers</span>
<div class="grid grid-cols-3 gap-1"><div class="node">node</div><div class="node">node</div><div class="node">node</div></div>
</div>
</div>
</div>

<p class="mt-4">Kamaji takes this pattern and pushes it: the Control Plane is a set of pods, reachable through a <code>LoadBalancer</code>.</p>

---

<p class="eyebrow">Kamaji</p>

# The Hosted Control Plane manager

<div class="grid grid-cols-[1fr_auto] gap-10 items-start mt-4">
<div>

- **Apache 2.0**, backed by **CLASTIX**
- Tenant Control Planes run as pods: `Deployment`, `Service`, `Secret`
- Datastores: etcd, PostgreSQL, MySQL, NATS
- Blue/green Control Plane upgrades
- The foundation of **kMetal**, the CLASTIX product

</div>
<img src="/brand/clastix_kamaji_black.svg" class="w-72" alt="Kamaji">
</div>

---

<p class="eyebrow">Not a lab experiment</p>

# Who runs Kamaji in production

<div class="grid grid-cols-3 gap-4 mt-6">
<div class="card">
<h3>Rackspace</h3>
<p>Rackspace Spot</p>
</div>
<div class="card">
<h3>OVHcloud</h3>
<p>Brand new Managed Kubernetes, <span class="accent">99.99% SLA</span></p>
</div>
<div class="card">
<h3>IONOS</h3>
<p>Managed Kubernetes</p>
</div>
<div class="card">
<h3>kt cloud</h3>
<p>South Korea</p>
</div>
<div class="card">
<h3>Infomaniak</h3>
<p>Switzerland</p>
</div>
<div class="card bordered">
<h3>…and more</h3>
<p>Aruba, TINEXT, KINX, etc.</p>
</div>
</div>

<!--
Names as text on purpose: use customer logos only with their permission.
-->

---
layout: section
number: "02"
---

# Why Cluster API, and why Kamaji

All of them, besides Kamaji, share one more trait.

---

<p class="eyebrow">No Cluster API 101 today</p>

# Why Cluster API is the right tool

<div class="grid grid-cols-3 gap-5 mt-8">
<div class="card">

### Declarative

A cluster is a set of Kubernetes resources: you describe it, you version it, you review it.

</div>
<div class="card">

### Idempotent

Apply it once or a hundred times: controllers converge to the same state.

</div>
<div class="card">

### The glue

One API between your offering and the infrastructure underneath it.

</div>
</div>

<p class="mt-8 lead">Every provider on the previous slide relies on it.</p>

---

<p class="eyebrow">Providers</p>

# Today KubeVirt, tomorrow your infrastructure

<div class="grid grid-cols-[2fr_3fr] gap-8 mt-4">
<div class="card solid">

### In this workshop

**KubeVirt**: VMs as Kubernetes resources, so a laptop is enough to play the cloud.

</div>
<div>

The same Kamaji Control Plane works with many infrastructure providers:

<div class="flex flex-wrap gap-2 mt-3">
<span class="badge">Proxmox</span>
<span class="badge">vSphere</span>
<span class="badge">OpenStack</span>
<span class="badge bordered">Metal³</span>
<span class="badge bordered">Tinkerbell</span>
<span class="badge bordered">Nutanix</span>
<span class="badge bordered">Hetzner</span>
<span class="badge bordered">IONOS Cloud</span>
<span class="badge bordered">AWS</span>
<span class="badge bordered">Azure</span>
</div>

<p class="caption mt-4">Guides: github.com/clastix/cluster-api-control-plane-provider-kamaji/tree/master/docs</p>

</div>
</div>

---

<p class="eyebrow">Three kinds of providers</p>

# Who does what

<div class="grid grid-cols-3 gap-5 mt-6">
<div class="card">
<p class="badge lilac">Infrastructure</p>
<h3 class="mt-3">KubeVirt</h3>
<p>Where do machines run?</p>
</div>
<div class="card">
<p class="badge lilac">Bootstrap</p>
<h3 class="mt-3">kubeadm</h3>
<p>How does a machine become a node?</p>
</div>
<div class="card solid">
<p class="badge magenta">Control Plane</p>
<h3 class="mt-3">Kamaji</h3>
<p>Who runs the Control Plane, and how?</p>
</div>
</div>

<p class="mt-8">Swap any of the three, the <code>Cluster</code> API stays the same.</p>

---

<p class="eyebrow">The gap</p>

# Cluster API leaves Control Plane Day-2 to the providers

<div class="grid grid-cols-2 gap-8 mt-4">
<div>

Control Plane providers think in **Virtual Machines**:

- upgrade = roll VMs
- heal = replace VMs
- scale = boot VMs

The application (Kubernetes) is strongly coupled to the infrastructure (the VM it runs on).

</div>
<div class="card lilac">

### A Control Plane is software

It deserves what every other workload gets on Kubernetes: reconciliation, self-healing, rolling updates, resource requests.

Not a VM lifecycle.

</div>
</div>

---

<p class="eyebrow">Why Kamaji</p>

# Control Planes, reconciled like any workload

<div class="grid grid-cols-3 gap-5 mt-6">
<div class="card">

### Self-healing

Reconciliation is baked in, like any Kubernetes operator: delete something, it comes back.

</div>
<div class="card">

### Same infrastructure

Control Planes run on the management cluster: no three VMs per tenant.

</div>
<div class="card">

### Sharding

Spread Tenant Control Planes across Kubernetes clusters to shrink the blast radius.

</div>
</div>

<p class="caption mt-6">Sharding: <code>KamajiControlPlane.spec.deployment.externalClusterReference</code>, behind the <code>ExternalClusterReference</code> feature gate.</p>

---

<p class="eyebrow">Kamaji and kubeadm</p>

# Not stepping on kubeadm’s toes

<div class="grid grid-cols-2 gap-8 mt-4">
<div class="card solid">

### Control Plane · Kamaji

Kamaji bootstraps the Control Plane **internally**, reusing kubeadm phases: certificates, kubeconfigs, kubelet configuration, bootstrap tokens, addons.

</div>
<div class="card">

### Workers · kubeadm

Worker nodes join with the regular **kubeadm Bootstrap provider** (`KubeadmConfigTemplate`), the one you already know.

</div>
</div>

<p class="mt-6">Kamaji is the Control Plane provider: it replaces the VMs, not kubeadm.</p>

---
layout: section
number: "03"
---

# Day-0: the management cluster

Steps 1 → 6, everything in <code>workshop/</code>

---

<p class="eyebrow">What we are building</p>

# One laptop, a whole Managed Kubernetes service

<div class="zone platform mt-2">
<span class="zone-label">kind · management</span>
<div class="grid grid-cols-4 gap-2">
<div class="node">Calico</div>
<div class="node">MetalLB</div>
<div class="node">KubeVirt</div>
<div class="node">cert-manager</div>
<div class="node cp">Kamaji</div>
<div class="node cp">Cluster API</div>
<div class="node cp">Sveltos</div>
<div class="node">kamaji-etcd</div>
</div>
<div class="grid grid-cols-2 gap-4 mt-4">
<div class="zone">
<span class="zone-label">capi-quickstart · Control Plane</span>
<div class="grid grid-cols-2 gap-2"><div class="node cp">pod</div><div class="node cp">pod</div></div>
</div>
<div class="zone">
<span class="zone-label">capi-quickstart · workers</span>
<div class="grid grid-cols-2 gap-2"><div class="node">KubeVirt VM</div><div class="node">KubeVirt VM</div></div>
</div>
</div>
</div>

<p class="caption mt-3">Validated end-to-end on 2026-10-28 with the versions pinned in each script.</p>

---

<p class="eyebrow"><span class="step-number">1</span>Management cluster</p>

# kind, without a CNI, then Calico

<<< @/workshop/manifests/kind-config.yaml yaml

<<< @/workshop/01-management-cluster.sh bash {all|6|8-10}

<!--
kindnet is disabled: Calico replaces it, as in the Cluster API quickstart.
-->

---

<p class="eyebrow"><span class="step-number">2</span>Load balancing</p>

# MetalLB: Control Planes need an address

<<< @/workshop/02-metallb.sh bash {5-9|11-15|17-32}{maxHeight:'360px'}

<!--
The upstream quickstart one-liner picks every subnet with a gateway:
kind networks are dual-stack, so it concatenates the IPv6 and IPv4 subnets
and MetalLB rejects the pool. We keep the IPv4 one only.
-->

---

<p class="eyebrow"><span class="step-number">3</span>Infrastructure</p>

# KubeVirt: the cloud our workers run on

<<< @/workshop/03-kubevirt.sh bash {all|5-6|8-10|12}

<p class="caption">Measured: ~2 minutes until KubeVirt is <code>Available</code>.</p>

---

<p class="eyebrow"><span class="step-number">4</span>Control Plane manager</p>

# cert-manager and Kamaji

<<< @/workshop/04-kamaji.sh bash {5-10|12-17|19-20}{maxHeight:'330px'}

<p class="caption">Kamaji edge releases are public; version-pinned stable releases come with a CLASTIX subscription.</p>

---

<p class="eyebrow"><span class="step-number">5</span>Cluster API</p>

# One command, three providers

<<< @/workshop/05-cluster-api.sh bash {all|11|12|13|14}

<p class="caption">Every provider version is pinned, so every attendee installs the same stack.</p>

<!--
clusterctl skips cert-manager since we installed it with Helm in step 4.
-->

---

<p class="eyebrow"><span class="step-number">6</span>Addons</p>

# Sveltos, agents in the management cluster

<<< @/workshop/06-sveltos.sh bash {all|10}

<div class="card mt-4">

`agent.managementCluster=true`: Sveltos agents run next to the Control Planes. The tenant cluster only receives the addons, nothing of ours lands in user space.

</div>

---

<p class="eyebrow">Checkpoint</p>

# Day-0, measured

| Step | What | Time |
| --- | --- | --- |
| 1 | kind + Calico | 41 s |
| 2 | MetalLB | 32 s |
| 3 | KubeVirt | 2 min 03 s |
| 4 | cert-manager + Kamaji | 57 s |
| 5 | Cluster API providers | 21 s |
| 6 | Sveltos | 54 s |

<p class="lead mt-6">About <span class="accent">6 minutes</span> from nothing to a management cluster.</p>

<p class="caption">On a 20-core Linux workstation with KVM: your laptop may differ.</p>

---
layout: section
number: "04"
---

# Day-1: a cluster as a resource

Steps 7 → 8

---

<p class="eyebrow"><span class="step-number">7</span>The manifest</p>

# Six resources, three providers

<div class="grid grid-cols-3 gap-4 mt-4">
<div>
<p class="badge">Core</p>

- `Cluster`
- `MachineDeployment`

</div>
<div>
<p class="badge lilac">Infrastructure · KubeVirt</p>

- `KubevirtCluster`
- `KubevirtMachineTemplate`

</div>
<div>
<p class="badge magenta">Control Plane · Kamaji</p>

- `KamajiControlPlane`

<p class="badge bordered mt-4">Bootstrap · kubeadm</p>

- `KubeadmConfigTemplate`

</div>
</div>

<p class="mt-6">Adapted from the Kamaji provider’s KubeVirt guide to the Cluster API <strong>v1beta2</strong> contract.</p>

<p class="caption">workshop/manifests/capi-quickstart/</p>

---

<p class="eyebrow"><span class="step-number">7</span>Core</p>

# The Cluster: networks and references

<<< @/workshop/manifests/capi-quickstart/cluster.yaml yaml {all|7-13|14-17|18-21}{maxHeight:'400px'}

---

<p class="eyebrow"><span class="step-number">7</span>Infrastructure</p>

# KubevirtCluster: hands off the Control Plane

<<< @/workshop/manifests/capi-quickstart/kubevirt-cluster.yaml yaml {4-7}

<div class="card mt-4">

Without the annotation, CAPK creates a `LoadBalancer` Service for Control Plane VMs that will never exist. With it, Kamaji patches the `KubevirtCluster` with its own endpoint.

</div>

---

<p class="eyebrow"><span class="step-number">7</span>Control Plane</p>

# KamajiControlPlane

<<< @/workshop/manifests/capi-quickstart/kamaji-control-plane.yaml yaml {all|7|8-10|11-15|16-22|23-26}{maxHeight:'400px'}

<!--
configurationJSONPatches: Kamaji edge generates the kubelet configuration with newer Kubernetes
defaults. A v1.34 kubelet refuses crashLoopBackOff.maxContainerRestartPeriod and
imagePullCredentialsVerificationPolicy, both behind disabled feature gates.
Nice side effect for the narrative: the platform owns the kubelet configuration of every node.
-->

---

<p class="eyebrow"><span class="step-number">7</span>Workers</p>

# KubevirtMachineTemplate: what a worker is

<<< @/workshop/manifests/capi-quickstart/kubevirt-machine-template.yaml yaml {all|9-10|18-28|30-33}{maxHeight:'380px'}

<!--
The container disk carries the OS and the Kubernetes binaries: the OS artefact is part of the offering.
Sized down from the upstream guide (3 workers, 4 GiB) to 2 workers with 3 GiB, to fit a laptop.
-->

---

<p class="eyebrow"><span class="step-number">7</span>Workers</p>

# Bootstrap and MachineDeployment: how many, and how they join

<div class="grid grid-cols-2 gap-4">
<div>

<<< @/workshop/manifests/capi-quickstart/kubeadm-config-template.yaml yaml

</div>
<div>

<<< @/workshop/manifests/capi-quickstart/machine-deployment.yaml yaml {all|8|13-17|19-22}{maxHeight:'380px'}

</div>
</div>

---

<p class="eyebrow"><span class="step-number">7</span>Apply</p>

# Declare it, then watch it converge

<<< @/workshop/07-create-cluster.sh bash {6|8-10|12-16}

<p class="caption">The Control Plane is ready in <span class="accent">~16 seconds</span>; the whole step, VMs included, took 82 seconds.</p>

---

<p class="eyebrow">Platform space</p>

# What the provider sees

```text
$ kubectl get tenantcontrolplanes
NAME                       VERSION   STATUS   CONTROL-PLANE ENDPOINT   DATASTORE   AGE
capi-quickstart-kubevirt   v1.34.1   Ready    172.19.255.200:6443      default     16s

$ kubectl get pods,svc
NAME                                            READY   STATUS
pod/capi-quickstart-kubevirt-66d9669679-jwcst   3/3     Running   # apiserver, controller-manager, scheduler
pod/capi-quickstart-kubevirt-66d9669679-xd782   3/3     Running   # …the second replica
pod/virt-launcher-capi-quickstart-md-0-…        2/2     Running   # worker VM
pod/virt-launcher-capi-quickstart-md-0-…        2/2     Running   # worker VM

NAME                               TYPE           EXTERNAL-IP      PORT(S)
service/capi-quickstart-kubevirt   LoadBalancer   172.19.255.200   6443:31935/TCP
```

<p class="mt-4">Two replicas of the whole Control Plane, as pods. No <code>capi-quickstart-lb</code> Service: the endpoint belongs to Kamaji.</p>

---

<p class="eyebrow"><span class="step-number">8</span>User space</p>

# What the customer sees

<<< @/workshop/08-kubeconfig.sh bash {6|8-9}

```text
NAME                               STATUS     ROLES    AGE   VERSION
capi-quickstart-md-0-brlzj-9hbgn   NotReady   <none>   27s   v1.34.1
capi-quickstart-md-0-brlzj-smt87   NotReady   <none>   29s   v1.34.1
```

<p class="mt-2">Workers only: no Control Plane nodes in sight. But they are <strong>NotReady</strong>.</p>

---
layout: center
---

<p class="eyebrow">NotReady</p>

# There is no CNI

<p class="lead">kube-proxy runs, CoreDNS is Pending, nodes can’t be Ready.</p>

<p class="lead">This is a managed service: we can’t ask the customer to install it.</p>

---
layout: section
number: "05"
---

# Day-2: addons that heal themselves

Steps 9 → 10

---

<p class="eyebrow">Sveltos</p>

# Addons, declared once for every cluster

<div class="grid grid-cols-3 gap-5 mt-6">
<div class="card">

### Select

A `ClusterProfile` matches clusters by label. Cluster API clusters are discovered automatically.

</div>
<div class="card">

### Deploy

Helm charts, raw YAML, Kustomize, templated with cluster data.

</div>
<div class="card solid">

### Reconcile

`ContinuousWithDriftDetection`: any change in the tenant cluster is reverted.

</div>
</div>

---

<p class="eyebrow"><span class="step-number">9</span>The CNI is ours</p>

# Cilium, for every cluster

<<< @/workshop/manifests/cilium-clusterprofile.yaml yaml {all|6-11|12-14|19-32}{maxHeight:'400px'}

<!--
Gotcha: an empty clusterSelector matches no cluster in Sveltos (libsveltos GetMatchingClusters).
Every Cluster API Cluster carries the cluster.x-k8s.io/cluster-name label: Exists matches all of them.
ipam.mode=kubernetes: pod CIDRs come from the Cluster clusterNetwork (10.243.0.0/16), allocated per node.
-->

---

<p class="eyebrow"><span class="step-number">9</span>Apply</p>

# Ready, without the customer lifting a finger

<<< @/workshop/09-cni.sh bash {6|8-10}

```text
NAME                               STATUS   ROLES    AGE   VERSION
capi-quickstart-md-0-brlzj-9hbgn   Ready    <none>   72s   v1.34.1
capi-quickstart-md-0-brlzj-smt87   Ready    <none>   74s   v1.34.1
```

<p class="caption">Measured: 30 to 45 seconds from <code>kubectl apply</code> to Ready nodes.</p>

---
layout: center
---

<p class="eyebrow">Day-0 ✓ · Day-1 ✓ · Day-2?</p>

# “Customers will break their clusters, and bury us in support tickets.”

<p class="lead">Let’s be that customer.</p>

---

<p class="eyebrow"><span class="step-number">10</span>Break it</p>

# Delete what a cluster can’t live without

<<< @/workshop/10-break-it.sh bash {7|8|9|11}

---

<p class="eyebrow">Myth busted</p>

# Seconds, not tickets

| Deleted by the customer | Reconciled by | Back after |
| --- | --- | --- |
| `daemonset/kube-proxy` | Kamaji | <span class="accent">1 s</span> |
| `deployment/coredns` | Kamaji | <span class="accent">≤ 2 s</span> |
| `daemonset/cilium` | Sveltos, drift detection | <span class="accent">~10 s</span> |

<p class="lead mt-6">Nodes stayed <strong>Ready</strong>. No outage, no ticket.</p>

<p class="caption">Measured twice on this workshop setup, 2026-10-28: time until the object is recreated.</p>

---
layout: section
number: "06"
---

# Bonus: operators all the way down

---

<p class="eyebrow">Cluster API Operator</p>

# Providers as resources, not commands

<div class="grid grid-cols-[3fr_2fr] gap-6">
<div>

```yaml
apiVersion: operator.cluster.x-k8s.io/v1alpha2
kind: ControlPlaneProvider
metadata:
  name: kamaji
  namespace: kamaji-system
spec:
  version: v0.21.0
---
apiVersion: operator.cluster.x-k8s.io/v1alpha2
kind: InfrastructureProvider
metadata:
  name: kubevirt
  namespace: capk-system
spec:
  version: v0.11.2
```

</div>
<div class="card">

`clusterctl init` is imperative. The **cluster-api-operator** turns providers into `CoreProvider`, `BootstrapProvider`, `ControlPlaneProvider` and `InfrastructureProvider` resources.

GitOps your management cluster, upgrades included.

</div>
</div>

<p class="caption">Illustrative: not part of today’s validated flow.</p>

---

<p class="eyebrow">ClusterClass</p>

# One class, many clusters

<div class="grid grid-cols-[3fr_2fr] gap-6">
<div>

```yaml
apiVersion: cluster.x-k8s.io/v1beta2
kind: Cluster
metadata:
  name: tenant-a
spec:
  topology:
    classRef:
      name: kamaji-kubevirt
    version: v1.34.1
    controlPlane:
      replicas: 2
    workers:
      machineDeployments:
      - class: default-worker
        name: md-0
        replicas: 3
```

</div>
<div>

<div class="card">

The `ClusterClass` holds the templates, the customer-facing `Cluster` holds the knobs.

</div>

<div class="card lilac mt-4">

### Handle with care

It requires advanced knowledge, and a clear design of your **service offering**: classes, variables, patches, supported versions.

</div>

</div>
</div>

<p class="caption">A Kamaji + KubeVirt ClusterClass: templates/kubevirt in the Kamaji provider repository. Illustrative.</p>

---
layout: section
number: "07"
---

# Reality check

---

<p class="eyebrow">DRAFT · to be confirmed</p>

# The metrics that matter

<div class="grid grid-cols-3 gap-5 mt-4">
<div class="card">

### Reliability

- API Server availability per tenant
- Datastore health and latency
- Reconciliation errors

</div>
<div class="card">

### Performance

- API request latency, p99 by verb
- Time to Control Plane ready
- Time for a node to join

</div>
<div class="card">

### Tenant isolation

- Control Plane resource usage per tenant
- API Priority and Fairness rejections
- Datastore size per tenant

</div>
</div>

<!--
TODO: the abstract promises metrics for reliability, performance and tenant isolation,
the outline didn't detail them. These are proposals: confirm, replace, or drop.
-->

---

<p class="eyebrow">What we didn’t build today</p>

# A cluster is not a service, yet

<div class="grid grid-cols-3 gap-3 mt-4">
<div class="node">OS artefacts and their lifecycle</div>
<div class="node">Networking, beyond KubeVirt</div>
<div class="node">Storage integration</div>
<div class="node">Quotas</div>
<div class="node">Self-service</div>
<div class="node">A portal</div>
<div class="node">Cloud Controller Manager</div>
<div class="node">Upgrades orchestration</div>
<div class="node">Security posture</div>
<div class="node">Backup and restore</div>
<div class="node">Metering and billing</div>
<div class="node">Observability and SLOs</div>
</div>

<p class="mt-6">…and whatever we forgot.</p>

<!--
TODO: review the list, the last row (backup, metering, observability) is an addition to the original outline.
-->

---
layout: center
---

<p class="eyebrow">This is not a gap</p>

# You can build all of it yourself

<div class="flex justify-center gap-16 mt-8">
<div>
<p class="figure">12</p>
<p>months</p>
</div>
<div>
<p class="figure">6+</p>
<p>engineers</p>
</div>
</div>

<p class="lead mt-8">Or…</p>

---

<p class="eyebrow">Sales pitch · yes, this is one</p>

# kMetal

<div class="grid grid-cols-[1fr_auto] gap-10 items-center mt-2">
<div>

<p class="lead">What we cooked at CLASTIX, on the exact same foundations you just used: <strong>Kamaji</strong>, <strong>Cluster API</strong>, <strong>Sveltos</strong>, <strong>KubeVirt</strong>.</p>

<div class="card solid mt-6">

### Second workshop, right after the lunch break

90 minutes to prove it in real life: from 12 months and 6 engineers to **less than 2 weeks** of validation.

</div>

</div>
<img src="/brand/clastix_kmetal_fullcolor.svg" class="w-72" alt="kMetal">
</div>

<!--
Make it evident: this slide is a commercial pitch, no hidden product placement.
TODO: room and time of the kMetal workshop.
-->

---
layout: end
---

<p class="eyebrow">Thank you · Dank je wel</p>

# Questions?

<p class="lead">Kamaji · kamaji.clastix.io</p>
<p class="lead">Workshop · https://github.com/clastix/dutch-cloud-native-day-2026</p>
<p class="mt-6">CLASTIX is a Platinum Sponsor of Dutch Cloud Native Days 2026.</p>

<!--
TODO: booth location, if any.
-->
