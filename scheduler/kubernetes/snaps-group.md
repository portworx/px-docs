---
layout: page
title: "Create and use group snapshots"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk, snapshots, stork, clones
sidebar: home_sidebar
meta-description: "Learn to take a group snapshot of a volume from a Kubernetes persistent volume claim (PVC) and use that snapshot as the volume for a new pod. Try today!"
---

* TOC
{:toc}

This document will show you how to create group snapshots of Portworx volumes and how you can clone those snapshots to use them in pods.

## Pre-requisites

**Installing STORK**

{% include k8s/stork/stork-prereq.md %}

**PX Version**

Group snapshots are supported in upcoming Portworx version 1.4 and above.

## Taking group snapshots

To take group snapshots, one either specifies annotations that will match PVCs for the group or a Portworx volume group ID.

The group snapshot method supports the following annotations:
* __px/snapshot-type__: Indicates the type of snapshot. For group snapshots, the value should be **group**.
* __Annotations to select volumes__: Portworx will select PVCs that match the annotations specified.
* __px/group-id__: Group ID of the Portworx volumes if they were created using the `--group` parameter. Portworx will select all volumes that match this group ID.

**Example**

In below example, we are taking a group snapshot that will snap all PVCs in the *default* namespace and that have labels *tier: prod* and *type: db*.

Portworx will quiesce I/O on all volumes before triggering their snapshots.

```
apiVersion: volumesnapshot.external-storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: mysql-snapshot
  namespace: default
  annotations:
    px/snapshot-type: group
    tier: prod
    type: db
spec:
  persistentVolumeClaimName: mysql-data
```

*persistentVolumeClaimName* in the above spec is not relevant for group snapshots. It needs to be present in the spec since the schema requires that. The actual PVCs are actually selected using the annotations.

Once you apply the above object you can check the status of the snapshots using `kubectl`:

```
$ kubectl get volumesnapshot
NAME                                              AGE
volumesnapshots/mysql-data-1-779368893912016693   14s
volumesnapshots/mysql-data-2-314922951056863611   14s
volumesnapshots/mysql-snapshot                    16s
```

```
$ kubectl get volumesnapshotdatas
NAME                                                                                            AGE
volumesnapshotdatas/k8s-volume-snapshot-0b1c5b4a-4b43-11e8-b4d7-5a6317d9d914                    14s
volumesnapshotdatas/mysql-data-1-779368893912016693-data-0af5b7ad-4b43-11e8-b4d7-5a6317d9d914   14s
volumesnapshotdatas/mysql-data-2-314922951056863611-data-0b15ab9f-4b43-11e8-b4d7-5a6317d9d914   14s
```

Above we can see that creation of `mysql-snapshot` created 2 more volumesnapshots `mysql-data-1-779368893912016693` and `mysql-data-2-314922951056863611`. Each of these would correspond to the PVCs that matched the annotations/group-id specified in the `mysql-snapshot` volumesnapshot.

The creation of the volumesnapshotdatas object indicates that the snapshot has been created. If you describe the volumesnapshotdatas object you can see the Portworx Snapshot IDs and the PVCs for which the snapshot was created.

```
$ kubectl describe volumesnapshotdatas 
Name:         k8s-volume-snapshot-0b1c5b4a-4b43-11e8-b4d7-5a6317d9d914
Namespace:
Labels:       <none>
Annotations:  <none>
API Version:  volumesnapshot.external-storage.k8s.io/v1
Kind:         VolumeSnapshotData
Metadata:
  Cluster Name:
  Creation Timestamp:  2018-04-29T00:19:55Z
  Resource Version:    1501612
  Self Link:           /apis/volumesnapshot.external-storage.k8s.io/v1/k8s-volume-snapshot-0b1c5b4a-4b43-11e8-b4d7-5a6317d9d914
  UID:                 0b1c3729-4b43-11e8-8c81-080027ee1df7
Spec:
  Persistent Volume Ref:
    Kind:  PersistentVolume
    Name:  pvc-12a5926f-4a54-11e8-8c81-080027ee1df7
  Portworx Volume:
    Snapshot Data:  mysql-data-1-779368893912016693-data-0af5b7ad-4b43-11e8-b4d7-5a6317d9d914,mysql-data-2-314922951056863611-data-0b15ab9f-4b43-11e8-b4d7-5a6317d9d914
    Snapshot Id:    779368893912016693,314922951056863611
    Snapshot Type:  group
  Volume Snapshot Ref:
    Kind:  VolumeSnapshot
    Name:  default/mysql-snapshot
Status:
  Conditions:
    Last Transition Time:  <nil>
    Message:               Snapshot created successfully and it is ready
    Reason:
    Status:                True
    Type:                  Ready
  Creation Timestamp:      <nil>
Events:                    <none>
```

```
Name:         mysql-data-1-779368893912016693-data-0af5b7ad-4b43-11e8-b4d7-5a6317d9d914
Namespace:
Labels:       namespace=default
Annotations:  <none>
API Version:  volumesnapshot.external-storage.k8s.io/v1
Kind:         VolumeSnapshotData
Metadata:
  Cluster Name:
  Creation Timestamp:  2018-04-29T00:19:55Z
  Resource Version:    1501608
  Self Link:           /apis/volumesnapshot.external-storage.k8s.io/v1/mysql-data-1-779368893912016693-data-0af5b7ad-4b43-11e8-b4d7-5a6317d9d914
  UID:                 0af5b72d-4b43-11e8-8c81-080027ee1df7
Spec:
  Persistent Volume Ref:  <nil>
  Portworx Volume:
    Snapshot Id:    779368893912016693
    Snapshot Type:  in-cluster
  Volume Snapshot Ref:
    Kind:  VolumeSnapshot
    Name:  default/mysql-data-1-779368893912016693
Status:
  Conditions:
    Last Transition Time:  <nil>
    Message:               Snapshot created successfully and it is ready
    Reason:
    Status:                True
    Type:                  Ready
  Creation Timestamp:      <nil>
Events:                    <none>
```

```
Name:         mysql-data-2-314922951056863611-data-0b15ab9f-4b43-11e8-b4d7-5a6317d9d914
Namespace:
Labels:       namespace=default
Annotations:  <none>
API Version:  volumesnapshot.external-storage.k8s.io/v1
Kind:         VolumeSnapshotData
Metadata:
  Cluster Name:
  Creation Timestamp:  2018-04-29T00:19:55Z
  Resource Version:    1501610
  Self Link:           /apis/volumesnapshot.external-storage.k8s.io/v1/mysql-data-2-314922951056863611-data-0b15ab9f-4b43-11e8-b4d7-5a6317d9d914
  UID:                 0b1596ca-4b43-11e8-8c81-080027ee1df7
Spec:
  Persistent Volume Ref:  <nil>
  Portworx Volume:
    Snapshot Id:    314922951056863611
    Snapshot Type:  in-cluster
  Volume Snapshot Ref:
    Kind:  VolumeSnapshot
    Name:  default/mysql-data-2-314922951056863611
Status:
  Conditions:
    Last Transition Time:  <nil>
    Message:               Snapshot created successfully and it is ready
    Reason:
    Status:                True
    Type:                  Ready
  Creation Timestamp:      <nil>
Events:                    <none>
```

## Creating PVCs from group snapshots

When you install STORK, it also creates a storage class called _stork-snapshot-sc_. This storage class can be used to create PVCs from snapshots.

To create a PVC from a snapshot, you would add the `snapshot.alpha.kubernetes.io/snapshot` annotation to refer to the snapshot
name.

For group snapshots, you can create PVCs from their corresponding VolumeSnapshots.

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-snap-1-clone
  annotations:
    snapshot.alpha.kubernetes.io/snapshot: mysql-data-1-779368893912016693
spec:
  accessModes:
     - ReadWriteOnce
  storageClassName: stork-snapshot-sc
  resources:
    requests:
      storage: 2Gi
```

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-snap-2-clone
  annotations:
    snapshot.alpha.kubernetes.io/snapshot: mysql-data-2-314922951056863611
spec:
  accessModes:
     - ReadWriteOnce
  storageClassName: stork-snapshot-sc
  resources:
    requests:
      storage: 2Gi
```

Once you apply the above spec you will see PVCs created by STORK. This PVCs will be backed by a Portworx volume clone of the snapshot.

```
$ kubectl get pvc  
NAMESPACE   NAME                                   STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS                AGE
default     mysql-data-1                             Bound     pvc-f782bf5c-20e7-11e8-931d-0214683e8447   2Gi        RWO            px-mysql-sc                 2d
default     mysql-data-2                             Bound     pvc-e762bf5c-20e7-11e7-921d-0214683e8417   2Gi        RWO            px-mysql-sc                 2d
default     mysql-snap-1-clone                       Bound     pvc-05d3ce48-2280-11e8-98cd-0214683e84a7   2Gi        RWO            stork-snapshot-sc           2s
default     mysql-snap-2-clone                       Bound     pvc-15d3ce48-1280-21e8-98cc-0214683e8447   2Gi        RWO            stork-snapshot-sc           2s
```