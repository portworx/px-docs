---
layout: page
title: "Dynamic Provisioning"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk, StatefulSets
sidebar: home_sidebar
meta-description: "Looking to use a dynamically provisioned volume with Kubernetes?  Follow this step-by-step tutorial on how to dynamically provision volumes with k8s."
---

This document describes how to dynamically provision a volume using Kubernetes and Portworx.

## Using Dynamic Provisioning
Using Dynamic Provisioning and Storage Classes you don't need to create Portworx volumes out of band and they will be created automatically.

### Storage Classes
Using Storage Classes objects an admin can define the different classes of Portworx Volumes that are offered in a cluster. Following are the different parameters that can be used to define a Portworx Storage Class

```
- fs: filesystem to be laid out: none|xfs|ext4 (default: `ext4`)
- block_size: block size in Kbytes (default: `32`)
- repl: replication factor [1..3] (default: `1`)
- io_priority: IO Priority: [high|medium|low] (default: `low`)
- snap_interval: snapshot interval in minutes, 0 disables snaps (default: `0`)
- aggregation_level: specifies the number of replication sets the volume can be aggregated from (default: `1`)
- ephemeral: ephemeral storage [true|false] (default `false`)
- parent: a label or name of a volume or snapshot from which this storage class is to be created
- secure: to create an encrypted storage class
```

#### Step1: Create Storage Class.

Create the storageclass:

```
# kubectl create -f \
   examples/volumes/portworx/portworx-volume-sc-high.yaml
```

Example:

```yaml
     kind: StorageClass
     apiVersion: storage.k8s.io/v1beta1
     metadata:
       name: portworx-io-priority-high
     provisioner: kubernetes.io/portworx-volume
     parameters:
       repl: "1"
       snap_interval:   "70"
       io_priority:  "high"
```
[Download example](/k8s-samples/portworx-volume-sc-high.yaml?raw=true)

Verifying storage class is created:

```
# kubectl describe storageclass portworx-io-priority-high
     Name: 	        	portworx-io-priority-high
     IsDefaultClass:	        No
     Annotations:		<none>
     Provisioner:		kubernetes.io/portworx-volume
     Parameters:		io_priority=high,repl=1,snapshot_interval=70
     No events.
```

#### Step2: Create Persistent Volume Claim.

Creating the persistent volume claim:

```
# kubectl create -f examples/volumes/portworx/portworx-volume-pvcsc.yaml
```

Example:

```yaml
     kind: PersistentVolumeClaim
     apiVersion: v1
     metadata:
       name: pvcsc001
       annotations:
         volume.beta.kubernetes.io/storage-class: portworx-io-priority-high
     spec:
       accessModes:
         - ReadWriteOnce
       resources:
         requests:
           storage: 2Gi
```
[Download example](/k8s-samples/portworx-volume-pvcsc.yaml?raw=true)

Verifying persistent volume claim is created:

```
# kubectl describe pvc pvcsc001
    Name:	      	pvcsc001
    Namespace:      	default
    StorageClass:   	portworx-io-priority-high
    Status:	      	Bound
    Volume:         	pvc-e5578707-c626-11e6-baf6-08002729a32b
    Labels:	      	<none>
    Capacity:	        2Gi
    Access Modes:   	RWO
    No Events.
```
Persistent Volume is automatically created and is bounded to this pvc.

Verifying persistent volume claim is created:

```
# kubectl describe pv pvc-e5578707-c626-11e6-baf6-08002729a32b
    Name: 	      	pvc-e5578707-c626-11e6-baf6-08002729a32b
    Labels:        	<none>
    StorageClass:  	portworx-io-priority-high
    Status:	      	Bound
    Claim:	      	default/pvcsc001
    Reclaim Policy: 	Delete
    Access Modes:   	RWO
    Capacity:	        2Gi
    Message:
    Source:
    Type:	      	PortworxVolume (a Portworx Persistent Volume resource)
    VolumeID:   	374093969022973811
    No events.
```

#### Step3: Create Pod which uses Persistent Volume Claim with storage class.

Create the pod:

```
# kubectl create -f examples/volumes/portworx/portworx-volume-pvcscpod.yaml
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
           claimName: pvcsc001
```
[Download example](/k8s-samples/portworx-volume-pvcscpod.yaml?raw=true)

Verifying pod is created:

```
# kubectl get pod pvpod
   NAME      READY     STATUS    RESTARTS   AGE
   pvpod       1/1     Running   0          48m        
```