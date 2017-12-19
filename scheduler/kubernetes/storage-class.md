---
layout: page
title: "Using Storage Classes"
keywords: portworx, storage class, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk
sidebar: home_sidebar
---

### Storage Classes
Using [Storage Class](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#class-1) objects an admin can define the different classes of Portworx volumes that are offered in a cluster. Following are the different parameters that can be used to define a Portworx Storage Class:

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
   examples/volumes/portworx/portworx-volume-sc.yaml
```

Example:

```yaml
     kind: StorageClass
     apiVersion: storage.k8s.io/v1beta1
     metadata:
       name: portworx-sc
     provisioner: kubernetes.io/portworx-volume
     parameters:
       repl: "1"
```
[Download example](/k8s-samples/portworx-volume-sc.yaml?raw=true)

Verifying storage class is created:

```
# kubectl describe storageclass portworx-sc
     Name: 	        	portworx-sc
     IsDefaultClass:	        No
     Annotations:		<none>
     Provisioner:		kubernetes.io/portworx-volume
     Parameters:		repl=1
     No events.
```
