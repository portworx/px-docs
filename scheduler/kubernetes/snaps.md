---
layout: page
title: "Portworx snapshots"
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

Using STORK, you can take 3 types of snapshots: 
1. [In-cluster](/scheduler/kubernetes/snaps-in-cluster.html): These are per volume snapshots where the snapshots are stored in the current Portworx cluster's storage pools.
2. [Cloud](/scheduler/kubernetes/snaps-cloud.html): These snapshots are uploaded to the configured S3-compliant endpoint (e.g AWS S3).
3. [Group](/scheduler/kubernetes/snaps-group.html): These allow you to snap multiple volumes at the same consistency point.

3DSnaps is the umbrella term that covers PX-Enterprise's capability to provide app-consistent cluster wide snapshots on any node or cloud. 

## Pre-snap and Post-snap commands

>**Note:** Pre-snap and Post-snap commands are supported in upcoming Portworx version 1.4 and above.

For each of the above types, Portworx supports specifying pre and post snapshot commands that are run on the application pods using the volumes.

This allows users to flush or pause I/O from the applications before the snapshot is taken and resume I/O after the snapshot is taken.

Specify following annotations in the `VolumeSnapshot` spec that you use to create the corresponding snapshot type.

* __px/pre-snap-command__: STORK will run the command which is given in the value of this annotation before taking the snapshot.
* __px/post-snap-command__: STORK will run the command which is given in the value of this annotation after taking the snapshot.

The commands will be run in pods using the PVC being snapshotted.

**Examples**

Follow is an example of a cassandra volume snapshot where we run the `nodetool flush` command before triggering the snapshot.

```
apiVersion: volumesnapshot.external-storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: cassandra-snapshot
  annotations:
    px/pre-snap-command: "nodetool flush"
spec:
  persistentVolumeClaimName: cassandra-data
```
