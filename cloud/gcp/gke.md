---
layout: page
title: "Dynamic Provisioning on Google Kubernetes Engine (GKE)"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, pv, persistent disk, gke, gce
sidebar: home_sidebar
meta-description: "This page describes how to setup a production ready Portworx cluster in a GKE environment"
---

![k8s porx Logo](/images/k8s-porx.png){:height="188px" width="188px"}

* TOC
{:toc}

The steps below will help you enable dynamic provisioning of Portworx volumes in your Google Kurbenetes Engine (GKE) cluster.

## Prerequisites

{% include k8s-prereqs.md %}

## Create a GKE cluster
Portworx is supported on GKE cluster provisioned on [Ubuntu Node Images](https://cloud.google.com/kubernetes-engine/docs/node-images).

You can create a 3 node GKE cluster with the gcloud cli using the following command:
```
$ gcloud container clusters create [CLUSTER_NAME] --image-type=ubuntu --zone=[ZONE_NAME]
```

You can set the default cluster with the following command:
```
$ gcloud container clusters get-credentials [CLUSTER_NAME] --zone=[ZONE_NAME]
Fetching cluster endpoint and auth data.
kubeconfig entry generated for gke-cluster-01.
```

More information about the gcloud command for GKE can be found [here](https://cloud.google.com/kubernetes-engine/docs/clusters/operations).

## Add disks to nodes

After your GKE cluster is up, you will need to add disks to each of the nodes. These disks will be used by Portworx to create a storage pool.

You can do this by using the `gcloud compute disks create` and `gcloud compute instances attach-disk` commands as described here [https://cloud.google.com/compute/docs/disks/add-persistent-disk#create_disk](https://cloud.google.com/compute/docs/disks/add-persistent-disk#create_disk).

For example, after you GKE cluster is up, find the compute instances:
```
$ gcloud compute instances list
NAME                                   ZONE           MACHINE_TYPE   PREEMPTIBLE  INTERNAL_IP  EXTERNAL_IP      STATUS
gke-px-gke-default-pool-6a9f0154-gxfg  us-east1-b     n1-standard-1               10.142.0.4   104.196.156.231  RUNNING
gke-px-gke-default-pool-6a9f0154-tzj4  us-east1-b     n1-standard-1               10.142.0.3   35.196.233.64    RUNNING
gke-px-gke-default-pool-6a9f0154-vqpb  us-east1-b     n1-standard-1               10.142.0.2   35.196.124.54    RUNNING
```

Then for each instance [create a persistent disk](https://cloud.google.com/sdk/gcloud/reference/compute/disks/create):
```
gcloud compute disks create [DISK_NAME] --size [DISK_SIZE] --type [DISK_TYPE]
```

Once the persistent disks have been created, [attach a disk to each instance](https://cloud.google.com/sdk/gcloud/reference/compute/instances/attach-disk):
```
gcloud compute instances attach-disk [INSTANCE_NAME] --disk [DISK_NAME]
```

## Install

Portworx gets deployed as a [Kubernetes DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/). Following sections describe how to generate the spec files and apply them.

### Generate the spec

{% include k8s-spec-generate.md %}

### Applying the spec

Once you have generated the spec file, deploy Portworx.

```bash
$ kubectl apply -f px-spec.yaml
```

{% include k8s-monitor-install.md %}

## Deploy a sample application

Now that you have Portworx installed, checkout various examples of [applications using Portworx on Kubernetes](/scheduler/kubernetes/k8s-px-app-samples.html).

## Troubleshooting Notes

* The `kubectl apply ...` command fails with "forbidden" error:
   - If you encounter an error with the cluster role permission (```clusterroles.rbac.authorization.k8s.io "portworx-pvc-controller-role" is forbidden```), create a ClusterRoleBinding for your user using the following commands:

   ```
   # get current google identity
   $ gcloud info | grep Account
   Account: [myname@example.org]

   # grant cluster-admin to your current identity
   $ kubectl create clusterrolebinding myname-cluster-admin-binding \
      --clusterrole=cluster-admin --user=myname@example.org
   Clusterrolebinding "myname-cluster-admin-binding" created
   ```

* GKE instances under certain scenarios do not automatically re-attach the persistent disks used by PX.
   - Under the following scenarios, GKE will spin up a new VM as a replacement for older VMs with the same node name:
      * Halting a VM in GKE cluster
      * Upgrading GKE between different kubernetes version
      * Increasing the size of the node pool
   - However, in these cases the previously attached persistent disks will not be re-attached automatically.
   - Currently you will have to manually re-attach the persistent disk to the new VM and then restart portworx on that node.