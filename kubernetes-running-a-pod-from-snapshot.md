---
layout: page
title: "Run a pod from a snapshot"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, flexvol, pv, pv claim, persistent disk
sidebar: home_sidebar
---
You can use PX to snapshot PVs and use these volumes with new pods in the cluster.  This is useful if you want to snapshot your production data and use that data as part of a test environment. Also, many people use this feature in their Jenkins environment to speed up incremental builds by snapshoting the Jenkins `/home` folder and using it with new Jenkins slaves, rather than pulling the entire directory each time. 

This example will show you a simple example using MySQL.

### Create a snapshot and mount the snapshot to a new mysql pod
#### Using the pxctl CLI to create snaps of your mysql volume

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
#### Now create a snapshot of this database using pxctl.

First use pxctl volume list to see what volume you want to snapshot
````
# /opt/pwx/bin/pxctl v l
ID          NAME                    SIZE  HA  SHARED  ENCRYPTED IO_PRIORITY SCALE STATUS
381983511213673988  pvc-e7e66f98-0915-11e7-94ca-7cd30ac1a138  20 GiB  2 no    no      LOW     0   up - attached on 147.75.105.241
````
Then use pxctl to snapshot your volume
````
/opt/pwx/bin/pxctl snap create 381983511213673988 --name snap-01
Volume successfully snapped: 835956864616765999
````

You can use pxctl to see your snapshot
````
# /opt/pwx/bin/pxctl snap list
ID          NAME  SIZE  HA  SHARED  ENCRYPTED IO_PRIORITY SCALE STATUS
835956864616765999  snap-01 20 GiB  2 no    no      LOW     0   up - detached
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