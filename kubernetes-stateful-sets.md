---
layout: page
title: "Using Kubernetes stateful sets"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, flexvol, pv, pv claim, persistent disk
sidebar: home_sidebar
---
[StatefulSets](https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/) are a powerful feature of Kubernetes that allow you to treat a group of related pods, say your MySQL cluster of 1 master and 2 slaves, as an atomic unit.  PX works with StatefulSets.  This example shows StatefulSets with MySQL but it would work with any multi-node database.

### Create a mysql Statefulset 

#### Step1: Create Storage Class.

````
# kubectl create -f portworx-mysql-sc.yaml
````

[Download example](portworx-mysql-sc.yaml?raw=true)
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
Name:   portworx-repl2
IsDefaultClass: No
Annotations:  <none>
Provisioner:  kubernetes.io/portworx-volume
Parameters: repl=2,snap_interval=70
No events.

````

#### Step2: Create a Statefulset 

````
# kubectl create -f portworx-mysql-statefulset.yaml
````

[Download example](portworx-mysql-statefulset.yaml?raw=true)

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

#### Verifying statefulset is created

````
# kubectl describe statefulset mysql-statefull
Name:     mysql-statefull
Namespace:    default
Image(s):   mysql:5.6
Selector:   app=mysql
Labels:     app=mysql
Replicas:   1 current / 1 desired
Annotations:    <none>
CreationTimestamp:  Tue, 14 Mar 2017 22:33:31 +0000
Pods Status:    1 Running / 0 Waiting / 0 Succeeded / 0 Failed
No volumes.
Events:
  FirstSeen LastSeen  Count From    SubObjectPath Type    Reason      Message
  --------- --------  ----- ----    ------------- --------  ------      -------
  14m   14m   1 {statefulset }      Normal    SuccessfulCreate  pvc: mysql-vol-01-mysql-statefull-0
  14m   14m   1 {statefulset }      Normal    SuccessfulCreate  pet: mysql-statefull-0

````
You can verify that the pvc and petset were created.

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