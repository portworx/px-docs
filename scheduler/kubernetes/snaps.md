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

3DSnaps is the umbrella term that covers PX-Enterprise's capability to provide app-consistent cluster wide snapshots whether they are local or cloud. 3DSnaps support for local volumes will be in 1.4 release.

## Pre-snap and Post-snap commands

>**Note:** Pre-snap and Post-snap commands are supported in upcoming Portworx version 1.4 and above.

For each of the above types, Portworx supports specifying pre and post commands that are run on the application pods using the volumes.

This allows users to quiesce the applications before the snapshot is taken and resume I/O after the snapshot is taken. The commands will be run in pods which are using the PVC being snapshotted.

Specify following annotations in the `VolumeSnapshot` spec that you use to create the corresponding snapshot type.

* __portworx/pre-snap-command__: STORK will run the command which is given in the value of this annotation before taking the snapshot.
* __portworx/post-snap-command__: STORK will run the command which is given in the value of this annotation after taking the snapshot.
* __portworx/pre-snap-command-run-once__: If "true", STORK will run the pre-snap command on just the first pod using the parent PVC. The default is "false" and the command will be run on all pods.
* __portworx/post-snap-command-run-once__: If "true", STORK will run the post-snap command on just the first pod using the parent PVC. The default is "false" and the command will be run on all pods.

**Examples**

Follow is an example of a cassandra volume snapshot where we run the `nodetool flush` command before triggering the snapshot.

```
apiVersion: volumesnapshot.external-storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: cassandra-snapshot
  annotations:
    portworx/pre-snap-command: "nodetool flush"
spec:
  persistentVolumeClaimName: cassandra-data
```
