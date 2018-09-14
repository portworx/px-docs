---
layout: page
title: "Create and use snapshots"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk, snapshots, stork, clones
sidebar: home_sidebar
redirect_from:
  - /scheduler/kubernetes/mount-snapshot-to-pod.html
meta-description: "Learn to take a snapshot of a volume from a Kubernetes persistent volume claim (PVC) and use that snapshot as the volume for a new pod. Try today!"
---

* TOC
{:toc}

This document will show you how to create snapshots of Portworx volumes and how you can clone those snapshots to use them in pods.

>**Note:** The suggested way to manage snapshots on Kuberenetes is to use STORK. If you are looking to create Portworx snapshots using PVC annotations, you will find [instructions here](/scheduler/kubernetes/snaps-annotations.html).

## Snapshot types

Using STORK, you can take 2 types of snapshots:

1. [Local](/scheduler/kubernetes/snaps-local.html): These are per volume snapshots where the snapshots are stored locally in the current Portworx cluster's storage pools.
2. [Cloud](/scheduler/kubernetes/snaps-cloud.html): These snapshots are uploaded to the configured S3-compliant endpoint (e.g AWS S3).

## 3DSnaps

>**Note:** 3DSnaps are supported in Portworx version 1.4 and above and Stork version 1.2 and above. Contact Portworx for early access to Stork 1.2. 3DSnaps are not supported on Kubernetes on DC/OS.

3DSnaps is the umbrella term that covers PX-Enterprise's capability to provide app-consistent cluster wide snapshots whether they are local or cloud.

For each of the snapshot types, Portworx supports specifying pre and post rules that are run on the application pods using the volumes. This allows users to quiesce the applications before the snapshot is taken and resume I/O after the snapshot is taken. The commands will be run in pods which are using the PVC being snapshotted.

Read [Configuring 3DSnaps](/scheduler/kubernetes/snaps-3d.html) for further details on 3DSnaps.
