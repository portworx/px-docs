---
layout: page
title: "StatefulSets"
keywords: portworx, stateful sets, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk
sidebar: home_sidebar
redirect_from:
  - /portworx-with-mysql-statefulsets.html
---

* TOC
{:toc}

[StatefulSets](https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/) are a feature of Kubernetes that are  valuable for applications that require one or more of the following:

* Stable, unique network identifiers.
* Stable, persistent storage.
* Ordered, graceful deployment and scaling.
* Ordered, graceful deletion and termination.

This document demonstrates how to use StatefulSets with Kubernetes and Portworx using MySQL as an example.

## Create a mysql Statefulset 

### Step1: Create Storage Class.

````
# kubectl create -f portworx-mysql-sc.yaml
````

[Download example](/k8s-samples/portworx-mysql-sc.yaml?raw=true)
````
kind: StorageClass
apiVersion: storage.k8s.io/v1beta1
metadata:
   name: portworx-repl2
provisioner: kubernetes.io/portworx-volume
parameters:
  repl: "2"
  snap_interval:   "70"

````
Verify the storageclass is created

````
# kubectl describe storageclass  portworx-repl2
Name:		portworx-repl2
IsDefaultClass:	No
Annotations:	<none>
Provisioner:	kubernetes.io/portworx-volume
Parameters:	repl=2,snap_interval=70
No events.

````

### Step2: Create a Statefulset 

````
# kubectl create -f portworx-mysql-statefulset.yaml
````

[Download example](/k8s-samples/portworx-mysql-statefulset.yaml?raw=true)

````
---
apiVersion: v1
kind: Service
metadata:
  name: mysql-01
  labels:
    app: mysql
spec:
  ports:
  - port: 3306
    name: mysql
  clusterIP: None
  selector:
    app: mysql
---
apiVersion: apps/v1beta1
kind: StatefulSet
metadata:
  name: mysql-statefull
spec:
  serviceName: "mysql"
  replicas: 1
  template:
    metadata:
      labels:
        app: mysql
    spec:
      terminationGracePeriodSeconds: 10
      containers:
      - name: mysql
        image: mysql:5.6
        env:
          # Use secret in real usage
        - name: MYSQL_ROOT_PASSWORD
          value: password
        ports:
        - containerPort: 3306
          name: mysql
        volumeMounts:
        - name: mysql-vol-01
          mountPath: /var/lib/mysql
  volumeClaimTemplates:
  - metadata:
      name: mysql-vol-01
      annotations:
        volume.beta.kubernetes.io/storage-class: portworx-repl2
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 20Gi
````

### Verifying statefulset is created

````
# kubectl describe statefulset mysql-statefull
Name:			mysql-statefull
Namespace:		default
Image(s):		mysql:5.6
Selector:		app=mysql
Labels:			app=mysql
Replicas:		1 current / 1 desired
Annotations:		<none>
CreationTimestamp:	Tue, 14 Mar 2017 22:33:31 +0000
Pods Status:		1 Running / 0 Waiting / 0 Succeeded / 0 Failed
No volumes.
Events:
  FirstSeen	LastSeen	Count	From		SubObjectPath	Type		Reason			Message
  ---------	--------	-----	----		-------------	--------	------			-------
  14m		14m		1	{statefulset }			Normal		SuccessfulCreate	pvc: mysql-vol-01-mysql-statefull-0
  14m		14m		1	{statefulset }			Normal		SuccessfulCreate	pet: mysql-statefull-0

````
You can verify that the pvc and pet were created
