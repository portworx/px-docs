---
layout: page
title: "Defining Kubernetes storage class"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, flexvol, pv, pv claim, persistent disk
sidebar: home_sidebar
---
There is a wide variety of storage resources available today.  SSDs. Spinning disk.  iOPS optimized. The list goes on. Using Kubernetes Storage classes, an admin can define the different classes of volumes offered in a cluster.  To take a simple example, this means you can offer fast storage for some pods, and slow storage for others. 

The following are the different parameters that can be used to define a Portworx Storage Class.  Once your Storage Class is created, you can reference it in PVs and PV Claims.

```
- fs: filesystem to be laid out: none|xfs|ext4 (default: `ext4`)
- block_size: block size in Kbytes (default: `32`)
- repl: replication factor [1..3] (default: `1`)
- io_priority: IO Priority: [high|medium|low] (default: `low`)
- snap_interval: snapshot interval in minutes, 0 disables snaps (default: `0`)
- aggregation_level: specifies the number of replication sets the volume can be aggregated from (default: `1`)
- ephemeral: ephemeral storage [true|false] (default `false`)
```

#### Create Storage Class

Create the storageclass:

```
# kubectl create -f
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
[Download example](k8s-samples/portworx-volume-sc-high.yaml?raw=true)

Verifying storage class is created:

```
# kubectl describe storageclass portworx-io-priority-high
     Name:            portworx-io-priority-high
     IsDefaultClass:          No
     Annotations:   <none>
     Provisioner:   kubernetes.io/portworx-volume
     Parameters:    io_priority=high,repl=1,snapshot_interval=70
     No events.
```

Read on for detailed instructions on running stateful services on Kubernetes.

* [Install PX into an Kubernetes 1.6 cluster]()
* [Force Kubernetes to schedule pods on hosts with your data](/kubernetes-convergence.html)
* [Create Kubernetes Storage Class](/kubernetes-define-storage-class.html)
* [Using pre-provisioned volumes with Kubernetes](/kubernetes-preprovisioned-volumes.html)
* [Dynamically provision volumes with Kubernetes](/kubernetes-dynamically-provisioned-volumes.html)
* [Using Stateful sets](/kubernetes-stateful-sets.html)
* [Running a pod from a snapshot](/kubernetes-running-a-pod-from-snapshot.html)
* [Failover a database using Kubernetes](kubernetes-database-failover.html)
* [Install PX on Kubernetes < 1.6](/kubernetes-run-with-flexvolume.html)
* [Cost calculator for converged container cluster using Kubernetes and Portworx](kubernetes-infrastructure-cost-calculator.html)