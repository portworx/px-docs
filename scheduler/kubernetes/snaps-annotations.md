---
layout: page
title: "Creating a PVC from a Snapshot (Deprecated)"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk, snapshots
sidebar: home_sidebar
---

This document will show you how to take a snapshot of a volume using Portworx and use that snapshot as the volume for a new pod.  It uses MySQL as an example. 

>**Note:** Using annotations to manage snapshots has been deprecated. The suggested
way to manage snapshots on Kuberenetes is now to use STORK. Instructions for
using STORK to manage snapshots can be found
[here](/scheduler/kubernetes/snaps.html)

## Managing snapshots through `kubectl`

### Taking periodic snapshots on a running POD
When you create the Storage Class, you can specify a snapshot schedule on the volume as specified below:
```yaml
    kind: StorageClass
     apiVersion: storage.k8s.io/v1beta1
     metadata:
       name: portworx-io-priority-high
     provisioner: kubernetes.io/portworx-volume
     parameters:
       repl: "1"
       snap_interval:   "24"
       io_priority:  "high"
```

### Creating a snapshot on demand
You can also trigger a new snapshot on a runnig POD by creating a PersitentVolumeClaim as specified in the following `snap.yaml`:

```yaml
kind: PersistentVolumeClaim
     apiVersion: v1
     metadata:
       name: name.snap001-source.pvcsc001
       annotations:
         volume.beta.kubernetes.io/storage-class: portworx-io-priority-high
     spec:
       resources:
         requests:
           storage: 100Gi
```

Note the format of the “name” field.  The format is `name.<new_volume_name>-source.<old_volume_name>`.  This references the parent (source) persistent volume claim.

Now run: 
```
# kubectl create -f snap.yaml
```

### Start a new POD or StatefulSet from a snapshot taken on demand
Similar to the section above, you can also create a POD or a StatefulSet from a PVC that references another PVC with the “source” parameter.  Doing so will create a new POD or StatefulSet that resumes the application from a snapshot of the current volume.
Rolling a POD or StatefulSet back  to an existing or previously taken snapshot.

### Rolling a POD back to a snapshot
To rollback a POD or a StatefulSet back to a previous snapshot, create a new Persistent Volume Claim as follows:

```yaml
kind: PersistentVolumeClaim
     apiVersion: v1
     metadata:
       name: name.rollback001-source.snap001
       annotations:
         volume.beta.kubernetes.io/storage-class: portworx-io-priority-high
     spec:
       resources:
         requests:
           storage: 100Gi   
```

Note the format of the “name” field.  The format is `name.<new_volume_name>-source.<snap_name>`.  This references a previous snapshot.  Now when you create a POD or a StatefulSet from this PVC, it will resume the application from a rolled back version.
You can also create a POD or a StatefulSet that directly references a PV created from a snapshot via kubectl.

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
