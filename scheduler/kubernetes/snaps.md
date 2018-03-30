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

## Managing snapshots with `kubectl`

### Pre-requisites
This requires that you already have [STORK](/scheduler/kubernetes/stork.html) installed and running on your
Kubernetes cluster

### Taking snapshots

If you have a PVC called mysql-data backed by a Portworx volume, you can create a snapshot for that PVC by
using the following spec:

```
apiVersion: volumesnapshot.external-storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: mysql-snapshot
  namespace: default
spec:
  persistentVolumeClaimName: mysql-data
```

Once you apply the above object you can check the status of the snapshots using `kubectl`:

```
$ kubectl get volumesnapshot,volumesnapshotdatas 
NAME                             AGE
volumesnapshots/mysql-snapshot   2s

NAME                                                                            AGE
volumesnapshotdatas/k8s-volume-snapshot-2bc36c2d-227f-11e8-a3d4-5a34ec89e61c    1s
```

The creation of the volumesnapshotdatas object indicates that the snapshot has
been created. If you describe the volumesnapshotdatas object you can see the
Portworx Volume Snapshot ID and the PVC for which the snapshot was created.

```
$ kubectl describe volumesnapshotdatas 
Name:         k8s-volume-snapshot-2bc36c2d-227f-11e8-a3d4-5a34ec89e61c
Namespace:    
Labels:       <none>
Annotations:  <none>
API Version:  volumesnapshot.external-storage.k8s.io/v1
Kind:         VolumeSnapshotData
Metadata:
  Cluster Name:                   
  Creation Timestamp:             2018-03-08T03:17:02Z
  Deletion Grace Period Seconds:  <nil>
  Deletion Timestamp:             <nil>
  Resource Version:               29989636
  Self Link:                      /apis/volumesnapshot.external-storage.k8s.io/v1/k8s-volume-snapshot-2bc36c2d-227f-11e8-a3d4-5a34ec89e61c
  UID:                            2bc3a203-227f-11e8-98cc-0214683e8447
Spec:
  Persistent Volume Ref:
    Kind:  PersistentVolume
    Name:  pvc-f782bf5c-20e7-11e8-931d-0214683e8447
  Portworx Volume:
    Snapshot Id:  991673881099191762
  Volume Snapshot Ref:
    Kind:  VolumeSnapshot
    Name:  default/mysql-snapshot-2b2150dd-227f-11e8-98cc-0214683e8447
Status:
  Conditions:
    Last Transition Time:  <nil>
    Message:               
    Reason:                
    Status:                
    Type:                  
  Creation Timestamp:      <nil>
Events:                    <none>
```
### Creating PVCs from snapshots 

When you install STORK, it also creates a storage class called stork-snapshot-sc.
This storage class can be used to create PVCs from snapshots.

To create a PVC from a snapshot, you would add the
`snapshot.alpha.kubernetes.io/snapshot` annotation to refer to the snapshot
name.

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

