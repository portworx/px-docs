---
layout: page
title: "Dynamic Provisioning on Google Kubernetes Engine (GKE)"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, pv, persistent disk, gke, gce
sidebar: home_sidebar
meta-description: "This page describes how to setup a production ready Portworx cluster in a Google Kubernetes Engine (GKE)."
---

![k8s porx Logo](/images/k8s-porx.png){:height="188px" width="188px"}

* TOC
{:toc}

The steps below will help you enable dynamic provisioning of Portworx volumes in your Google Kurbenetes Engine (GKE) cluster.

## Prerequisites

{% include px-k8s-prereqs.md %}

**PX Version**

Support for GKE is available only in portworx release version 1.4 and above.

## Create a GKE cluster

Following two points are important when creating your GKE cluster.

1. Portworx is supported on GKE cluster provisioned on [Ubuntu Node Images](https://cloud.google.com/kubernetes-engine/docs/node-images). So it is important to specify the node image as **Ubuntu** when creating clusters.

2. To manage GCP disks, Portworx needs access to the GCP Compute Engine API. For GKE 1.10 and above, Compute Engine API access is disabled by default. This can be enabled in the "Project Access" section when creating the GKE cluster. You can either allow full access to all Cloud APIs or set access for each API. When settting access for each API, make sure to select **Read Write** for the **Compute Engine** dropdown.

3. Portworx reuires a ClusterRoleBinding for your user. Without this `kubectl apply ...` command fails with an error like ```clusterroles.rbac.authorization.k8s.io "portworx-pvc-controller-role" is forbidden```. 

Create a ClusterRoleBinding for your user using the following commands:

 ```
   # get current google identity
   $ gcloud info | grep Account
   Account: [myname@example.org]

   # grant cluster-admin to your current identity
   $ kubectl create clusterrolebinding myname-cluster-admin-binding \
      --clusterrole=cluster-admin --user=myname@example.org
   Clusterrolebinding "myname-cluster-admin-binding" created
   ```

More information about creating GKE clusters can be found [here](https://cloud.google.com/kubernetes-engine/docs/clusters/operations).

## Install

Portworx gets deployed as a [Kubernetes DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/). Following sections describe how to generate the spec files and apply them.

### Disk template

Portworx takes in a disk spec which gets used to provision GCP persistent disks dynamically.

{% include asg/gcp-template.md %}

### Generate the spec

{% include k8s-spec-generate.md  asg-addendum="We will supply the template(s) explained in previous section, when we create the Portworx spec." skip12="true" skip13="true" %}

### Applying the spec

Once you have generated the spec file, deploy Portworx.

```bash
$ kubectl apply -f px-spec.yaml
```

{% include k8s-monitor-install.md %}

## Deploy a sample application

Now that you have Portworx installed, checkout various examples of [applications using Portworx on Kubernetes](/scheduler/kubernetes/k8s-px-app-samples.html).

## Troubleshooting Notes

* GKE instances under certain scenarios do not automatically re-attach the persistent disks used by PX.
   - Under the following scenarios, GKE will spin up a new VM as a replacement for older VMs with the same node name:
      * Halting a VM in GKE cluster
      * Upgrading GKE between different kubernetes version
      * Increasing the size of the node pool
   - However, in these cases the previously attached persistent disks will not be re-attached automatically.
   - Currently you will have to manually re-attach the persistent disk to the new VM and then restart portworx on that node.
