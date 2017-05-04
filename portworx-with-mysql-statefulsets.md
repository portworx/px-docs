---
layout: page
title: "Portworx with mysql stateful sets
keywords: portworx, PX-Developer, container, Kubernetes, storage
sidebar: home_sidebar
---

## Pre-requisites
You need a running Portworx and Kubernetes cluster.

Follow [this](/scheduler/kubernetes.html) guide to setup a Portworx and Kubernetes.

## Create a mysql Statefulset 

### Step1: Create Storage Class.

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


## Create a snapshot and mount the snapshot to a new mysql pod

### Using the pxctl CLI to create snaps of your mysql volume

To demonstrate the capabilities of the SAN like functionality offered by portworx, try creating a snapshot of your mysql volume.

First create a database and a demo table in your mysql container.
````
# mysql --user=root --password=password
MySQL [(none)]> create database pxdemo;
Query OK, 1 row affected (0.00 sec)
MySQL [(none)]> use pxdemo;
Database changed
MySQL [pxdemo]> create table grapevine (counter int unsigned);
Query OK, 0 rows affected (0.04 sec)
MySQL [pxdemo]> quit;
Bye
````
### Now create a snapshot of this database using pxctl.

First use pxctl volume list to see what volume you want to snapshot
````
# /opt/pwx/bin/pxctl v l
ID					NAME										SIZE	HA	SHARED	ENCRYPTED	IO_PRIORITY	SCALE	STATUS
381983511213673988	pvc-e7e66f98-0915-11e7-94ca-7cd30ac1a138	20 GiB	2	no		no			LOW			0		up - attached on 147.75.105.241
````
Then use pxctl to snapshot your volume
````
/opt/pwx/bin/pxctl snap create 381983511213673988 --name snap-01
Volume successfully snapped: 835956864616765999
````

You can use pxctl to see your snapshot
````
# /opt/pwx/bin/pxctl snap list
ID					NAME	SIZE	HA	SHARED	ENCRYPTED	IO_PRIORITY	SCALE	STATUS
835956864616765999	snap-01	20 GiB	2	no		no			LOW			0		up - detached
````

Now you can create a mysql Pod to mount the snapshot

````
kubectl create -f portworx-mysql-snap-pod.yaml
````
[Download example](portworx-mysql-snap-pod.yaml?raw=true)
````
apiVersion: v1
kind: Pod
metadata:
  name: test-portworx-snapped-volume-pod
spec:
  containers:
  - image: mysql:5.6
    name: mysql-snap
    env:
      # Use secret in real usage
    - name: MYSQL_ROOT_PASSWORD
      value: password
    ports:
    - containerPort: 3306
      name: mysql
    volumeMounts:
    - name: snap-01
      mountPath: /var/lib/mysql
  volumes:
  - name: snap-01
    # This Portworx volume must already exist.
    portworxVolume:
      volumeID: "vol1"
````
Inspect that the database shows the cloned tables in the new mysql instance.

````
# mysql --user=root --password=password
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| pxdemo             |
+--------------------+
4 rows in set (0.00 sec)

mysql> use pxdemo;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> show tables;
+------------------+
| Tables_in_pxdemo |
+------------------+
| grapevine        |
+------------------+
1 row in set (0.00 sec)

````
## Failover MYSQL Pod to a different node

### Show Database
````
export MYSQLPOD=$(kubectl get pods -l app=mysql --no-headers | awk '{print $1}')
kubectl logs $MYSQLPOD
kubectl exec -ti $MYSQLPOD -- bash
mysql --user=root --password=password
show databases;
exit
exit
````

### Create a database 

````
export MYSQLPOD=$(kubectl get pods -l app=mysql --no-headers | awk '{print $1}')
kubectl logs $MYSQLPOD
kubectl exec -ti $MYSQLPOD -- bash
mysql --user=root --password=password
create database TEST_1234;
show databases;
exit
exit
````

### Lets find what node the mysql pod is running
````
export MYSQL_NODE=$(kubectl describe pod -l app=mysql | grep Node: | awk -F'[ \t//]+' '{print $2}')
echo $MYSQL_NODE
````
### Mark node as unschedulable.
````
kubectl cordon $MYSQL_NODE
````
### Delete the pod.  
````
kubectl delete pod -l app=mysql
````
### Verify the pod has moved to a different node
````
kubectl describe pods -l app=mysql
````
### Verify we can see the database we created
````
export MYSQLPOD=$(kubectl get pods -l app=mysql --no-headers | awk '{print $1}')
kubectl logs $MYSQLPOD
kubectl exec -ti $MYSQLPOD -- bash
mysql --user=root --password=password
show databases;
exit
exit
````
###  Clean up 

### Bring the node back online
````
kubectl uncordon $MYSQL_NODE
````

### Delete database
````
export MYSQLPOD=$(kubectl get pods -l app=mysql --no-headers | awk '{print $1}')
kubectl logs $MYSQLPOD
kubectl exec -ti $MYSQLPOD -- bash
mysql --user=root --password=password
drop database TEST_1234;
show databases;
exit
````
