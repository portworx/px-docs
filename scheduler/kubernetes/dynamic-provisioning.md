---
layout: page
title: "Dynamic Provisioning"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk, StatefulSets
sidebar: home_sidebar
meta-description: "Looking to use a dynamically provisioned volume with Kubernetes?  Follow this step-by-step tutorial on how to dynamically provision volumes with k8s."
---
* TOC
{:toc}

This document describes how to dynamically provision a volume using Kubernetes and Portworx.

### Using Dynamic Provisioning
Using Dynamic Provisioning and Storage Classes you don't need to create Portworx volumes out of band and they will be created automatically.
Using Storage Classes objects an admin can define the different classes of Portworx Volumes that are offered in a cluster. Following are the different parameters that can be used to define a Portworx Storage Class

| Name              	| Description                                                                                                                                                                                                                                                            	| Example                	|
|-------------------	|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	|------------------------	|
| fs                	| Filesystem to be laid out: none\|xfs\|ext4                                                                                                                                                                                                                               	| fs: "ext4"               	|
| block_size        	| Block size                                                                                                                                                                                                                                                             	| block_size: "32k"        	|
| repl              	| Replication factor for the volume: 1\|2\|3                                                                                                                                                                                                                                	| repl: "3"                	|
| shared            	| Flag to create a globally shared namespace volume which can be used by multiple pods                                                                                                                                                                                   	| shared: "true"         	|
| priority_io       	| IO Priority: low\|medium\|high                                                                                                                                                                                                                                           	| priority_io: "high"    	|
| io_profile       	| IO Profile can be used to override the I/O algorithm Portworx uses for the volumes. Supported values are [db](/maintain/performance/tuning.html#db), [sequential](/maintain/performance/tuning.html#sequential), [random](/maintain/performance/tuning.html#random), [cms](/maintain/performance/tuning.html#cms)                                                                                                                                                                                                                                           	| io_profile: "db"    	|
| group             	| The group a volume should belong too. Portworx will restrict replication sets of volumes of the same group on different nodes. If the force group option 'fg' is set to true, the volume group rule will be strictly enforced. By default, it's not strictly enforced. 	| group: "volgroup1"       	|
| fg                	| This option enforces volume group policy. If a volume belonging to a group cannot find nodes for it's replication sets which don't have other volumes of same group, the volume creation will fail.                                                                    	| fg: "true"             	|
| label             	| List of comma-separated name=value pairs to apply to the Portworx volume                                                                                                                                                                                               	| label: "name=mypxvol"    	|
| nodes             	| Comma-separated Portworx Node ID's to use for replication sets of the volume                                                                                                                                                                                           	| nodes: "minion1,minion2" 	|
| aggregation_level 	| Specifies the number of replication sets the volume can be aggregated from                                                                                                                                                                                             	| aggregation_level: "2"   	|
| snap_schedule     	| Snapshot schedule (PX 1.3 and higher). {% include snap-schedule-format.md %}          	| snap_schedule: periodic=60,10<br><br>snap_schedule: daily=12:00,4<br><br>snap_schedule: weekly=sunday@12:00,2<br><br>snap_schedule: monthly=15@12:00     	|
| snap_interval     	| Snapshot interval in minutes. 0 disables snaps. Minimum value: 60                                                                                                                                                                                                      	| snap_interval: "120"     	|
| sticky     	| Flag to create sticky volumes that cannot be deleted until the flag is disabled                                                                                                                                                                                                      	| sticky: "true"     	|
| journal     	| (PX 1.3 and higher) Flag to indicate if you want to use journal device for the volume's metadata. This will use the journal device that you used when installing Portworx. As of PX version 1.3, it is recommended to use a journal device to absorb PX metadata writes. Default: false                                                                                                                                                                                             	| journal: "true"     	|

### Provision volumes
#### Step1: Create Storage Class.

Create the storageclass:

```
# kubectl create -f examples/volumes/portworx/portworx-sc.yaml
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
     volume.beta.kubernetes.io/storage-class: portworx-sc
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
    Namespace:      default
    StorageClass:   portworx-sc
    Status:	      	Bound
    Volume:         pvc-e5578707-c626-11e6-baf6-08002729a32b
    Labels:	      	<none>
    Capacity:	    2Gi
    Access Modes:   RWO
    No Events.
```
Persistent Volume is automatically created and is bounded to this pvc.

Verifying persistent volume claim is created:

```
# kubectl describe pv pvc-e5578707-c626-11e6-baf6-08002729a32b
    Name: 	      	pvc-e5578707-c626-11e6-baf6-08002729a32b
    Labels:        	<none>
    StorageClass:  	portworx-sc
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

{% include k8s-non-root-access.md %}

### Delete volumes
For dynamically provisioned volumes using StorageClass and PVC (PersistenVolumeClaim), if a PVC is deleted, the corresponding Portworx volume will also get deleted. This is because Kubernetes, for PVC, creates volumes with a reclaim policy of deletion. So the volumes get deleted on PVC deletion.

To delete the PVC and the volume, you can run `kubectl delete -f <pvc_spec_file.yaml>`
