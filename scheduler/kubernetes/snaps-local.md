---
layout: page
title: "Create and use local snapshots"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk, snapshots, stork, clones
redirect_from:
  - /scheduler/kubernetes/snaps-in-cluster.html
meta-description: "Learn to take a snapshot of a volume from a Kubernetes persistent volume claim (PVC) and use that snapshot as the volume for a new pod. Try today!"
---

* TOC
{:toc}

This document will show you how to create snapshots of Portworx volumes and how you can clone those snapshots to use them in pods.

>**Note:** The suggested way to manage snapshots on Kuberenetes is to use STORK. If you are looking to create Portworx snapshots using PVC annotations, you will find [instructions here](/scheduler/kubernetes/snaps-annotations.html).

## Pre-requisites

**Installing STORK**

{% include k8s/stork/stork-prereq.md %}

## Creating snapshots

With local snapshots, you can either snapshot individual PVCs one by one or snapshot a group of PVCs by using a selector or a group ID.

* [Taking snapshots of individual PVCs](/scheduler/kubernetes/snaps-single-pvc.html)

* [Taking snapshots of a group of PVCs](/scheduler/kubernetes/snaps-group.html)

<a name="pvc-from-snap"></a>
## Creating PVCs from snapshots

When you install STORK, it also creates a storage class called _stork-snapshot-sc_. This storage class can be used to create PVCs from snapshots.

To create a PVC from a snapshot, you would add the `snapshot.alpha.kubernetes.io/snapshot` annotation to refer to the snapshot
name.

Note that the storageClassName needs to be the Stork StorageClass `stork-snapshot-sc` as in the example below.

For the above snapshot, the spec would like this:
```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-snap-clone
  annotations:
    snapshot.alpha.kubernetes.io/snapshot: mysql-snapshot
spec:
  accessModes:
     - ReadWriteOnce
  storageClassName: stork-snapshot-sc
  resources:
    requests:
      storage: 2Gi
```

Once you apply the above spec you will see a PVC created by STORK. This PVC will be backed by a Portworx volume clone of the snapshot created above.

```
$ kubectl get pvc  
NAMESPACE   NAME                                   STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS                AGE
default     mysql-data                             Bound     pvc-f782bf5c-20e7-11e8-931d-0214683e8447   2Gi        RWO            px-mysql-sc                 2d
default     mysql-snap-clone                       Bound     pvc-05d3ce48-2280-11e8-98cc-0214683e8447   2Gi        RWO            stork-snapshot-sc           2s
```

If you had taken snapshots of a group of PVCs, the process is the same as above. So corresponding to each volumesnapshot, you will create a PVC.
