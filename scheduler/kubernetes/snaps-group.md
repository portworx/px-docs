---
layout: page
title: "Create group snapshots"
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

## Creating group snapshots

To take group snapshots, one either specifies annotations that will match PVCs for the group or a Portworx volume group ID.

The group snapshot method supports the following annotations:
* __portworx/snapshot-type__: Indicates the type of snapshot. For group snapshots, the value should be **local**.
* __portworx.selector/\<key\>: \<value\>__: When this annotation is provided, Portworx will select all PVCs with labels `<key>:<value>` and create a group snapshot. Example: `portworx.selector/stack: wordpress`.
* __portworx.selector/group-id__: Group ID of the Portworx volumes if they were created using the `--group` parameter. Portworx will select all volumes that match this group ID and create a group snapshot.

If both annotations and group ID are specified above, all PVCs that match annotations *and* group ID will be snapped.

## Examples

#### Creating snapshots of all PVCs that match certain annotations

In below example, we are taking a group snapshot that will snap all PVCs in the *default* namespace and that have labels *tier: prod* and *type: db*. The prefix *portworx.selector/* before the annotation keys indiciate these are annotations that STORK will process to select PVCs.

Portworx will quiesce I/O on all volumes before triggering their snapshots.

```
apiVersion: volumesnapshot.external-storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: mysql-snapshot
  namespace: default
  annotations:
    portworx/snapshot-type: local
    portworx.selector/tier: prod
    portworx.selector/type: db
spec:
  persistentVolumeClaimName: mysql-data
```

*persistentVolumeClaimName* in the above spec can be name of any single PVC that will get matched using the selector or the group ID.

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
volumesnapshotdatas/k8s-snapshotdata-0b1c5b4a-4b43-11e8-b4d7-5a6317d9d914                    14s
volumesnapshotdatas/k8s-snapshotdata-0af5b7ad-4b43-11e8-b4d7-5a6317d9d914                    14s
volumesnapshotdatas/k8s-snapshotdata-0b15ab9f-4b43-11e8-b4d7-5a6317d9d914                    14s
```

Above we can see that creation of `mysql-snapshot` created 2 more volumesnapshots `mysql-data-1-779368893912016693` and `mysql-data-2-314922951056863611`. Each of these would correspond to the PVCs that matched the annotations/group-id specified in the `mysql-snapshot` volumesnapshot.

The creation of the volumesnapshotdatas object indicates that the snapshot has been created. If you describe the volumesnapshotdatas object you can see the Portworx Snapshot IDs and the PVCs for which the snapshot was created.

```
$ kubectl describe volumesnapshotdatas 
Name:         k8s-snapshotdata-0b1c5b4a-4b43-11e8-b4d7-5a6317d9d914
Namespace:
Labels:       <none>
Annotations:  <none>
API Version:  volumesnapshot.external-storage.k8s.io/v1
Kind:         VolumeSnapshotData
Metadata:
  Cluster Name:
  Creation Timestamp:  2018-04-29T00:19:55Z
  Resource Version:    1501612
  Self Link:           /apis/volumesnapshot.external-storage.k8s.io/v1/k8s-snapshotdata-0b1c5b4a-4b43-11e8-b4d7-5a6317d9d914
  UID:                 0b1c3729-4b43-11e8-8c81-080027ee1df7
Spec:
  Persistent Volume Ref:
    Kind:  PersistentVolume
    Name:  pvc-12a5926f-4a54-11e8-8c81-080027ee1df7
  Portworx Volume:
    Snapshot Data:  k8s-snapshotdata-0af5b7ad-4b43-11e8-b4d7-5a6317d9d914,k8s-snapshotdata-0b15ab9f-4b43-11e8-b4d7-5a6317d9d914
    Snapshot Id:    779368893912016693,314922951056863611
    Snapshot Type:  local
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
Name:         k8s-snapshotdata-0af5b7ad-4b43-11e8-b4d7-5a6317d9d914
Namespace:
Labels:       namespace=default
Annotations:  <none>
API Version:  volumesnapshot.external-storage.k8s.io/v1
Kind:         VolumeSnapshotData
Metadata:
  Cluster Name:
  Creation Timestamp:  2018-04-29T00:19:55Z
  Resource Version:    1501608
  Self Link:           /apis/volumesnapshot.external-storage.k8s.io/v1/k8s-snapshotdata-0af5b7ad-4b43-11e8-b4d7-5a6317d9d914
  UID:                 0af5b72d-4b43-11e8-8c81-080027ee1df7
Spec:
  Persistent Volume Ref:  <nil>
  Portworx Volume:
    Snapshot Id:    779368893912016693
    Snapshot Type:  local
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
Name:         k8s-snapshotdata-0b15ab9f-4b43-11e8-b4d7-5a6317d9d914
Namespace:
Labels:       namespace=default
Annotations:  <none>
API Version:  volumesnapshot.external-storage.k8s.io/v1
Kind:         VolumeSnapshotData
Metadata:
  Cluster Name:
  Creation Timestamp:  2018-04-29T00:19:55Z
  Resource Version:    1501610
  Self Link:           /apis/volumesnapshot.external-storage.k8s.io/v1/k8s-snapshotdata-0b15ab9f-4b43-11e8-b4d7-5a6317d9d914
  UID:                 0b1596ca-4b43-11e8-8c81-080027ee1df7
Spec:
  Persistent Volume Ref:  <nil>
  Portworx Volume:
    Snapshot Id:    314922951056863611
    Snapshot Type:  local
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

#### Creating snapshots of all PVCs in a namespace

Below spec will take snapshots of all PVCs in the dev namespace.

Portworx will quiesce I/O on all volumes before triggering their snapshots.

```
apiVersion: volumesnapshot.external-storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: mysql-snapshot-all-dev
  namespace: dev
  annotations:
    portworx/snapshot-type: local
    portworx.selector/namespace: dev
spec:
  persistentVolumeClaimName: mysql-data
```

## Deleting group snapshots

To delete group snapshots, you need to delete the `VolumeSnapshot` that was used to create the group snapshots. STORK will delete all other volumesnapshots that were created for this group snapshot.