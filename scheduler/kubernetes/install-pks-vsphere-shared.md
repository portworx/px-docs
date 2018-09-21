---
layout: page
title: "Portworx install on PKS on vSphere using shared datastores"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk

meta-description: "Find out how to install PX in a PKS Kubernetes cluster and have PX provide highly available volumes to any application deployed via Kubernetes."
---

* TOC
{:toc}

## Pre-requisites

* This page assumes you have a running etcd cluster. If not, return to [Installing etcd on PKS](/scheduler/kubernetes/install-pks.html#install-etcd-pks).

## Architecture

Below diagram gives an overview of the Portworx architecture for PKS on vSphere using shared datastores.
* Portworx runs as a Daemonset hence each Kubernetes minion/worker will have the Portworx daemon running.
* Based on the given spec by the end user, Portworx on each node will create it's disk on the configured shared datastore(s) or datastore cluster(s).
* Portworx will aggregate all of the disks and form a single storage cluster. End users can carve PVCs (Persistent Volume Claims), PVs (Persistent Volumes) and Snapshots from this storage cluster.
* Portworx tracks and manages the disks that it creates. So in a failure event, if a new VM spins up, Portworx on the new VM will be able to attach to the same disk that was previously created by the node on the failed VM.

![Portworx architecture for PKS on vSphere using shared datastores or datastore clusters](/images/pks-vsphere-shared.png){:width="1992px" height="1156px"}

## ESXi datastore preparation

Create one or more shared datastore(s) or datastore cluster(s) which is dedicated for Portworx storage. Use a common prefix for the names of the datastores or datastore cluster(s). We will be giving this prefix during Portworx installation later in this guide.

## Portworx installation

1. Create a secret using [this template](#pks-px-vsphere-secret). Replace values replace values corresponding to your vSphere environment.
2. Deploy the Portworx spec using [this template](#pks-px-spec). Replace values replace values corresponding to your vSphere environment.

{% include k8s-monitor-install.md %}

## Wipe Portworx installation

Below are the steps to wipe your entire Portworx installation on PKS.

1. Run cluster-scoped wipe: ```curl -fsL https://install.portworx.com/px-wipe | bash -s -- -T pks```
2. Go to each virtual machine and delete the additional vmdks Portworx created in the shared datastore.

## References

<a name="pks-px-vsphere-secret"></a>
### Secret for vSphere credentials

Things to replace in the below spec to match your environment:

1. **VSPHERE_USER**: Use output of `echo -n <vcenter-server-user> | base64`
2. **VSPHERE_PASSWORD**: Use output of `echo -n <vcenter-server-password> | base64`

```
apiVersion: v1
kind: Secret
metadata:
  name: px-vsphere-secret
  namespace: kube-system
type: Opaque
data:
  VSPHERE_USER: YWRtaW5pc3RyYXRvckB2c3BoZXJlLmxvY2Fs
  VSPHERE_PASSWORD: cHgxLjMuMEZUVw==
```

<a name="pks-px-spec"></a>
### Portworx spec

* If you are using secured etcd, download [Portworx spec for PKS with secure etcd](/k8s-samples/vsphere/px-pks-vsphere-shared-specs-secure-etcd.yaml).
* If you are using non-secured etcd, download [Portworx spec for PKS with non-secure etcd](/k8s-samples/vsphere/px-pks-vsphere-shared-specs.yaml).

You need to change below things in the spec to match your environment. These are sections in the spec with a *CHANGEME* comment.

1. **PX etcd** endpoint in the -k argument.
2. **Cluster ID** in the -c argument. Choose a unique cluster ID.
3. **VSPHERE_VCENTER**: Hostname of the vCenter server.
4. **VSPHERE_DATASTORE_PREFIX**: Prefix of the ESXi datastore(s) that Portworx will use for storage.
5. **Size of disks**: In the Portworx Daemonset arguments below, change `size=100` to the size of the disks you want each Portworx node in the cluster to create. 
  * For e.g if you have 10 nodes in your cluster and you give size=100, each Portworx node will create a 100GB disk in the shared datastore and the cluster storage capacity will be 1TB.
