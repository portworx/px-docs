---
layout: page
title: "Take snapshot of a Kubernetes PVC"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk, snapshots, stork, clones
meta-description: "Learn to take a snapshot of a Kubernetes persistent volume claim (PVC)"
---

* TOC
{:toc}

This document will show you how to create snapshot of a PVC backed by a Portworx volume.

If you have a PVC called mysql-data, you can create a snapshot for that PVC by using the following spec:

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
$ kubectl get volumesnapshot
NAME                             AGE
volumesnapshots/mysql-snapshot   2s
```

```
$ kubectl get volumesnapshotdatas
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