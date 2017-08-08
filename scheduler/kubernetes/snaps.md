---
layout: page
title: "Create and use snapshots"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk, snapshots
sidebar: home_sidebar
meta-description: "Learn to take a snapshot of a volume from a Kubernetes persistent volume claim (PVC) and use that snapshot as the volume for a new pod. Try today!"
---
* TOC
{:toc}

This document will show you how to create snapshots of Portworx volumes and use them in pods.  It uses MySQL as an example. 

## Managing snapshots through `kubectl`

### Creating snapshots

#### Creating periodic snapshots
When you create a StorageClass, you can specify a snapshot schedule on the volume as specified below. This allows to snapshot the persistent data of the running pod using the volume.
```yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1beta1
  metadata:
    name: portworx-repl-1-snap-internal
provisioner: kubernetes.io/portworx-volume
parameters:
  repl: "1"
  snap_interval: "240"
```
Above spec will take snapshots of the _portworx-repl-1-snap-internal_ PVC every 240 minutes.

#### Creating a snapshot on demand
You can also trigger a new snapshot on a running POD by creating a PersistentVolumeClaim as specified in the following spec:
```yaml
kind: PersistentVolumeClaim
apiVersion: v1
  metadata:
    name: name.snap001-source.pvc001
    annotations:
      volume.beta.kubernetes.io/storage-class: portworx-repl-1-snap-internal
spec:
  resources:
    requests:
      storage: 1Gi
```
Note the format of the “name” field. The format is `name.<new_snap_name>-source.<old_volume_name>`. Above example references the parent (source) persistent volume claim _pvc001_ and creates a snapshot by the name _snap001_. 

### Using snapshots
#### Listing snapshots
To list snapshots taken by Portworx, use the `/opt/pwx/bin/pxctl volume snapshot list` command. For example:
```bash
# /opt/pwx/bin/pxctl volume snapshot list
ID			NAME	SIZE	HA	SHARED	IO_PRIORITY	SCALE STATUS
1067822219288009613	snap001	1 GiB	2	no	LOW		1	up - detached
```

You can use the ID or NAME of the snapshots when using them to restore a volume.

#### Restoring a volume from a snapshot
To rollback a pod back to a previous snapshot, use a `PersistentVolumeClaim` that is created with the following format. Following spec creates a PVC that is restored from a previous Portworx snapshot called _snap001_. 

```yaml
kind: PersistentVolumeClaim
apiVersion: v1
  metadata:
    name: name.rollback001-source.snap001
    annotations:
      volume.beta.kubernetes.io/storage-class: portworx-repl-1-snap-internal
spec:
  resources:
    requests:
      storage: 1Gi   
```

Note the format of the “name” field.  The format is `name.<new_volume_name>-source.<snap_name>`.  Above example references a source snapshot _snap001_ and creates a volume _rollback001_ from it..  

Now when you create a POD from this PVC, it will resume the application from a rolled back version.

## Managing snapshots through `pxctl`

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
[Download example](/k8s-samples/portworx-mysql-snap-pod.yaml?raw=true)
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
