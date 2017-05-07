---
layout: page
title: "Run Portworx with Kubernetes"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk, StatefulSets
sidebar: home_sidebar
---

This document describes how to create a PX StorageClass and a PVC using that storage class to launch a StatefulSet via Kubernetes.

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

## Using scheduler convergence
By modifying your pod spec files you can influence kubernetes to scheduler pods on nodes where the volume is located.

### Using pre-provsioned volumes
If you have already created Portworx volumes out of band without using Kubernetes you can still influence the scheduler to schedule a pod on specific set of nodes.

Lets say you created two volumes viz. `vol1` and `vol2`

At this point, when you create a volume, PX will communicate with Kubernetes to place host labels on the nodes that contain a volume's data blocks.
For example:

```
[root@localhost porx]# kubectl --kubeconfig="/root/kube-config.json" get nodes --show-labels

NAME         STATUS    AGE       LABELS
10.0.7.181   Ready     13d       kubernetes.io/hostname=10.0.7.181,vol2=true,vol3=true
10.0.8.108   Ready     12d       kubernetes.io/hostname=10.0.8.108,vol1=true,vol2=true
```

The label `vol1=true` implies that the node hosts volume vol1's data.

### Using PersistentVolumeClaims
If you used Kubernetes's dynamic volume provisioning with Persistent Volume claims, then instead of the volume names, the claim names would
be used as the node labels. Here is a sample PVC

```
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: pvc-high-01
  annotations:
    volume.beta.kubernetes.io/storage-class: portworx-io-high
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 512Gi
```

Once the PVC gets Bound by kubernetes, you will see the following
labels on the node

```
[root@localhost porx]# kubectl --kubeconfig="/root/kube-config.json" get nodes --show-labels

NAME         STATUS    AGE       LABELS
10.0.7.181   Ready     13d       kubernetes.io/hostname=10.0.7.181,pvc-high-01=true
10.0.8.108   Ready     12d       kubernetes.io/hostname=10.0.8.108,
```

### Scheduling Pods and enabling hyperconvergence

You can now use these labels in the `nodeAffinity` section in your Kubernetes pod spec as explained [here](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity)

For example, your pod may look like:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    env: test
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: "pvc-high-01"
            operator: In
            values:
              - "true"
  containers:
  - name: nginx
    image: nginx
    volumeMounts:
    - name: portworx-volume
      mountPath: /data
  volumes:
  - name: portworx-volume
    persistentVolumeClaim:
      claimName: pvc-high-01
```

In the nodeAffinity section we specify the `required` constraint implies that the specified rules must be met for a pod to schedule onto a node.
The key value in the above spec is set to the claim name as the volume being mounted at `/data` is a persistentVolumeClaim. If you are using
a pre-provisioned volume and not a PVC you will replace the key with PV name like `vol1`
