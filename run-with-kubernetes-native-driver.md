---
layout: page
title: "Run Portworx with Kubernetes Native Driver"
keywords: portworx, PX-Developer, container, Kubernetes, storage
sidebar: home_sidebar
---

Portworx can be used as a storage provider for your Kubernetes cluster. Portworx pools your servers capacity and turns your servers
or cloud instances into converged, highly available compute and storage nodes.

We have added a native driver in Kubernetes that will integrate with PX to dynamically provision volumes for your Pods.
The native portworx driver in Kubernetes supports the following features:

1. Dynamic Volume Provisioning
2. Storage Classes
3. Persistent Volume Claims
4. Persistent Volumes

>**Note:**<br/>The native driver will be available publicly with the upcoming Kubernetes 1.6 release.  Currently e have backported the native driver with the existing Kubernetes 1.5 release.  To try out the Kubernetes native driver [contact us](https://portworx.com/contact-us/) and we will provide you with a tar ball which has the pre-compiled kubernetes binaries linked with the Portworx native driver.

## Prerequisites

1. Kubernetes Cluster
Start a  Kubernetes cluster started using the pre-compiled binaries with Portworx native driver

2. Portworx Cluster
Run a Portworx instance on all of your Kubernetes nodes (master and slave).

>**Note:**<br/>We recommend running a storage less node on Kubernetes master as no pods will be scheduled on that node.

You can use the following command:

For CentOS

```
# sudo docker run --restart=always --name px -d --net=host \
    --privileged=true                             \
    -v /run/docker/plugins:/run/docker/plugins    \
    -v /var/lib/osd:/var/lib/osd:shared           \
    -v /dev:/dev                                  \
    -v /etc/pwx:/etc/pwx                          \
    -v /opt/pwx/bin:/export_bin                   \
    -v /var/run/docker.sock:/var/run/docker.sock  \
    -v /var/cores:/var/cores                      \
    -v /var/lib/kubelet:/var/lib/kubelet:shared   \
    -v /usr/src:/usr/src                          \
    --ipc=host                                    \
    portworx/px-dev:latest -daemon -k etcd://myetc.company.com:2379 -c
    MY_CLUSTER_ID -s /dev/sdb -s /dev/sdc
```

For CoreOS and VMWare Photon

```
# sudo docker run --restart=always --name px -d --net=host \
   --privileged=true                             \
   -v /run/docker/plugins:/run/docker/plugins    \
   -v /var/lib/osd:/var/lib/osd:shared           \
   -v /dev:/dev                                  \
   -v /etc/pwx:/etc/pwx                          \
   -v /opt/pwx/bin:/export_bin:shared            \
   -v /var/run/docker.sock:/var/run/docker.sock  \
   -v /var/cores:/var/cores                      \
   -v /lib/modules:/lib/modules                  \
   -v /var/lib/kubelet:/var/lib/kubelet:shared   \
   --ipc=host                                    \
   portworx/px-dev:latest -daemon -k etcd://myetc.company.com:4001 -c
   -MY_CLUSTER_ID -s /dev/sdb -s /dev/sdc
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
[Download example](k8s-samples/portworx-volume-pod.yaml?raw=true)

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
Make sure to replace <vol-id>, <size> and <fs-type> in the above spec with
the ones that you used while creating the volume.

[Download example](k8s-samples/portworx-volume-pv.yaml?raw=true)

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
[Download example](k8s-samples/portworx-volume-pvc.yaml?raw=true)

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
[Download example](k8s-samples/portworx-volume-pvcpod.yaml?raw=true)

Verifying pod is created:

```
# kubectl get pod pvpod
    NAME      READY     STATUS    RESTARTS   AGE
    pvpod       1/1     Running   0          48m        
```

## Using Dynamic Provisioning

Using Dynamic Provisioning and Storage Classes you don't need to
create Portworx volumes out of band and they will be created automatically.

### Storage Classes

Using Storage Classes objects an admin can define the different classes of Portworx Volumes
that are offered in a cluster. Following are the different parameters that can be used to define a Portworx
Storage Class

```
- fs: filesystem to be laid out: none|xfs|ext4 (default: `ext4`)
- block_size: block size in Kbytes (default: `32`)
- repl: replication factor [1..3] (default: `1`)
- io_priority: IO Priority: [high|medium|low] (default: `low`)
- snap_interval: snapshot interval in minutes, 0 disables snaps (default: `0`)
- aggregation_level: specifies the number of replication sets the volume can be aggregated from (default: `1`)
- ephemeral: ephemeral storage [true|false] (default `false`)
```

#### Step1: Create Storage Class.

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
[Download example](k8s-sample/portworx-volume-pvcsc.yaml?raw=true)

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
[Download example](k8s-samples/portworx-volume-pvcscpod.yaml?raw=true)

Verifying pod is created:

```
# kubectl get pod pvpod
   NAME      READY     STATUS    RESTARTS   AGE
   pvpod       1/1     Running   0          48m        
```
