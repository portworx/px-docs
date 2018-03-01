---
layout: page
title: "Pre-provisioned volumes"
keywords: portworx, pre-provisioned volumes, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk, StatefulSets
sidebar: home_sidebar
meta-description: "Looking to use a pre-provisioned volume in your Kubernetes cluster? Follow this step-by-step tutorial on how to use pre-provisioned volumes with k8s."
---
* TOC
{:toc}

This document describes how to use a pre-provisioned volume in your Kubernetes cluster.

## Creating Portworx volume using pxctl

First create a volume using Portworx CLI. On one of the nodes with Portworx installed run the following command:
```
# /opt/pwx/bin/pxctl volume create <vol-name> --size <size>
```
For more details on creating volumes using pxctl, [see here](/control/volume.html).

Alternately, you can also use [Portworx snapshots created before](/control/snap.html).

## Using the Portworx volume

Once you have a portworx volume, you can use it in 2 different ways:

### 1. Using the Portworx volume directly in a pod
You can create a pod that directly uses a Portworx volume as follows:
```yaml
apiVersion: v1
kind: Pod
metadata:
   name: nginx-px
spec:
   containers:
   - image: nginx
     name: nginx-px
     volumeMounts:
     - mountPath: /test-portworx-volume
       name: testvol
   volumes:
   - name: testvol
     # This Portworx volume must already exist.
     portworxVolume:
       volumeID: testvol
```
Above `testvol` is the existing Portworx volume created using pxctl.

### 2. Using the Portworx volume by creating a PersistentVolume & PersistentVolumeClaim

#### Creating PersistentVolume

First create a `PersistentVolume` that references the Portworx volume. Following is an example spec.
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: testvol
  labels:
    name: testvol
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  portworxVolume:
    volumeID: testvol
```
Above `PersistentVolume` references an existing Portworx volume `testvol` (Notice that metadata.name and spec.portworxVolume.volumeID must be volume-name-or-ID)  created using pxctl. Also note that it also has labels. We'll soon see how they can be useful.

#### Creating PersistentVolumeClaim

Now create a `PersistentVolumeClaim` that will claim the above created volume. Following is an example spec.

```yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: testvol-pvc
spec:
  selector:
    matchLabels:
      name: testvol
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```
Notice how we use a label selector to select the right `PersistentVolume` using it's label.

>**Note:**<br/> If you are planning to use the `PersistentVolumeClaim` in a pod in a non-default namespace, the `PersistentVolumeClaim` needs to created in that namespace.

#### Creating a pod using the PersistentVolumeClaim

Now you can create a pod that references the above `PersistentVolumeClaim`. Below is an example.
```yaml
apiVersion: v1
kind: Pod
metadata:
   name: nginx-px
spec:
  containers:
  - image: nginx
    name: nginx-px
    volumeMounts:
    - mountPath: /test-portworx-volume
      name: testvol
  volumes:
  - name: testvol
    persistentVolumeClaim:
      claimName: testvol-pvc
```
