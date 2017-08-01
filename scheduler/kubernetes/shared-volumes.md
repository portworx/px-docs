---
layout: page
title: "Create shared PVC"
keywords: portworx, pre-provisioned volumes, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk, StatefulSets
sidebar: home_sidebar
meta-description: "Looking for a volume which could be shared between your applications  in a Kubernetes cluster? Follow this step-by-step tutorial on how to use portworx shared volumes with k8s."
---

This document describes how to use portworx shared volumes in your Kubernetes cluster.

### Provision a Shared Volume
#### Step1: Create Storage Class

Create the storageclass:
```
# kubectl create -f examples/volumes/portworx/portworx-shared-sc.yaml
```

Example:

```yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1beta1
metadata:
    name: px-shared-sc
provisioner: kubernetes.io/portworx-volume
parameters:
   repl: "1"
   shared: "true"
```
[Download example](/k8s-samples/portworx-volume-shared-sc.yaml?raw=true)

Note the ``shared`` field in the list of parameters is set to true.
Verifying storage class is created:

```
# kubectl describe storageclass portworx-sc
Name:	  	   px-shared-sc
IsDefaultClass:	   No
Annotations:	   <none>
Provisioner:	   kubernetes.io/portworx-volume
Parameters:	   repl=1,shared=true
Events:			<none>
```

#### Step2: Create Persistent Volume Claim.

Creating the persistent volume claim:

```
# kubectl create -f examples/volumes/portworx/portworx-volume-shared-pvc.yaml
```

Example:

```yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
   name: px-shared-pvc
   annotations:
     volume.beta.kubernetes.io/storage-class: px-shared-sc
spec:
   accessModes:
     - ReadWriteMany
   resources:
     requests:
       storage: 10Gi
```
[Download example](/k8s-samples/portworx-volume-shared-pvc.yaml?raw=true)
Note the accessMode for this PVC is set to ``ReadWriteMany`` so the kubernetes allows mounting this PVC on multiple pods.

Verifying persistent volume claim is created:

```
# kubectl get pvc
NAME            STATUS    VOLUME                                   CAPACITY   ACCESSMODES   STORAGECLASS   AGE
px-shared-pvc   Bound     pvc-a38996b3-76e9-11e7-9d47-080027b25cdf 10Gi       RWX           px-shared-sc   12m

```
#### Step3: Create Pods which uses Persistent Volume Claim.

We will start two pods which use the same shared volume.
Starting pod-1
```
# kubectl create -f examples/volumes/portworx/portworx-volume-shared-pod-1.yaml
```

Example:

```yaml
     apiVersion: v1
     kind: Pod
     metadata:
       name: pod1
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
           claimName: px-shared-pvc
```
[Download example](/k8s-samples/portworx-volume-shared-pod-1.yaml?raw=true)

Starting pod-2
```
# kubectl create -f examples/volumes/portworx/portworx-volume-shared-pod-2.yaml
```

Example:

```yaml
     apiVersion: v1
     kind: Pod
     metadata:
       name: pod2
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
           claimName: px-shared-pvc
```
[Download example](/k8s-samples/portworx-volume-shared-pod-2.yaml?raw=true)


Verifying pods are running:

```
# kubectl get pods
NAME      READY     STATUS    RESTARTS   AGE
pod1      1/1       Running   0          2m
pod2      1/1       Running   0          1m
```
