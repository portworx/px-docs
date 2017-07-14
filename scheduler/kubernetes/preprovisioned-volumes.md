---
layout: page
title: "Pre-provisioned volumes"
keywords: portworx, pre-provisioned volumes, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk, StatefulSets
sidebar: home_sidebar
meta-description: "Looking to use a pre-provisioned volume in your Kubernetes cluster? Follow this step-by-step tutorial on how to use pre-provisioned volumes with k8s."
---

This document describes how to use a pre-provisioned volume in your Kubernetes cluster.


## Using Pre-provisioned Volumes

Create a Volume using Portworx CLI.
On one of the Kubernetes nodes with Portworx installed run the following command

```
# /opt/pwx/bin/pxctl volume create <vol-id> --size <size> --fs <fs-type>
```

### Running Pods

Create Pod which uses Portworx Volumes

Example:

```yaml
   apiVersion: v1
   kind: Pod
   metadata:
    name: test-portworx-volume-pod
   spec:
     containers:
     - image: gcr.io/google_containers/test-webserver
       name: test-container
       volumeMounts:
       - mountPath: /test-portworx-volume
         name: test-volume
     volumes:
     - name: test-volume
       # This Portworx volume must already exist.
       portworxVolume:
         volumeID: "<vol-id>"
         fsType: "<fs-type>"
```
[Download example](/k8s-samples/portworx-volume-pod.yaml?raw=true)

Make sure to replace "vol-id" and "fs-type" in the above spec with
the ones that you used while creating the volume.

Create the Pod.

```
# kubectl create -f examples/volumes/portworx/portworx-volume-pod.yaml
```
Verify that pod is running:

```
# kubectl.sh get pods
    NAME                       READY     STATUS    RESTARTS   AGE
    test-portworx-volume-pod   1/1       Running   0          16s
```

### Persistent Volumes

#### Step1: Create Persistent Volume.

You can create a persistent volume using the following command:

```
# kubectl create -f examples/volumes/portworx/portworx-volume-pv.yaml
```
Example:

```yaml
      apiVersion: v1
      kind: PersistentVolume
      metadata:
        name: <vol-id>
      spec:
        capacity:
          storage: <size>Gi
        accessModes:
          - ReadWriteOnce
        persistentVolumeReclaimPolicy: Retain
        portworxVolume:
          volumeID: "<vol-id>"
          fsType:   "<fs-type>"
```
Make sure to replace &lt;vol-id&gt;, &lt;size&gt; and &lt;fs-type&gt; in the above spec with
the ones that you used while creating the volume.

[Download example](/k8s-samples/portworx-volume-pv.yaml?raw=true)

Verifying persistent volume is created:

```
# kubectl describe pv pv0001
    Name: 	        pv0001
    Labels:		<none>
    StorageClass:
    Status:		Available
    Claim:
    Reclaim Policy:	Retain
    Access Modes:	RWO
    Capacity:		2Gi
    Message:
    Source:
    Type:	        PortworxVolume (a Portworx Persistent Volume resource)
    VolumeID:	        pv0001
    FSType:             ext4
    No events.
```

#### Step2: Create Persistent Volume Claim.

You can create a persistent volume claim using the following command:

```
# kubectl create -f examples/volumes/portworx/portworx-volume-pvc.yaml
```
Example:

```yaml
      kind: PersistentVolumeClaim
      apiVersion: v1
      metadata:
        name: pvc0001
      spec:
        accessModes:
          - ReadWriteOnce
        resources:
          requests:
            storage: <size>Gi
```
[Download example](/k8s-samples/portworx-volume-pvc.yaml?raw=true)

Verifying persistent volume claim is created:

```
# kubectl describe pvc pvc0001
    Name:		pvc0001
    Namespace:	        default
    Status:		Bound
    Volume:		pv0001
    Labels:		<none>
    Capacity:	        2Gi
    Access Modes:	RWO
    No events.
```

#### Step3: Create Pod which uses Persistent Volume Claim.

You can create a pod which uses the PVC by running the following command:

```
# kubectl create -f examples/volumes/portworx/portworx-volume-pvcpod.yaml
```

Example:

```yaml
      apiVersion: v1
      kind: Pod
      metadata:
        name: pvpod
      spec:
        containers:
        - name: test-container
          image: gcr.io/google_containers/test-webserver
          volumeMounts:
          - name: test-volume
            mountPath: /test-portworx-volume
        volumes:
        - name: test-volume
          persistentVolumeClaim:
            claimName: pvc0001
```
[Download example](/k8s-samples/portworx-volume-pvcpod.yaml?raw=true)

Verifying pod is created:

```
# kubectl get pod pvpod
    NAME      READY     STATUS    RESTARTS   AGE
    pvpod       1/1     Running   0          48m        
```