---
layout: page
title: "Creating a PVC from a Snapshot"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk, snapshots
sidebar: home_sidebar
---

* TOC
{:toc}

This document will show you how to take a snapshot of a volume using Portworx and use that snapshot as the volume for a new pod.

>**Note:** The suggested way to manage snapshots on Kuberenetes is now to use STORK. Instructions for
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

You can trigger a new snapshot on a running POD by creating a PersistentVolumeClaim.

#### Using annotations

Portworx uses a special annotation _px/snapshot-source-pvc_ which can be used to identify the name of the source PVC whose snapshot needs to be taken.

```yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  namespace: prod
  name: ns.prod-name.px-snap-1
  annotations:
    volume.beta.kubernetes.io/storage-class: px-sc
    px/snapshot-source-pvc: px-vol-1
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 6Gi
```

Note the format of the _name_ field  - `ns.<namespace_of_source_pvc>-name.<name_of_the_snapshot>`. The above example takes a snapshot with the name _px-snap-1_ of the source PVC _px-vol-1_ in the _prod_ namespace.
>**Note:**<br/> Annotations support is available from PX Version 1.2.11.6

For using annotations Portworx daemon set requires extra permissions to read annotations from PVC object. Make sure your ClusterRole has the following section

```yaml
- apiGroups: [""]
  resources: ["persistentvolumeclaims"]
  verbs: ["get", "list"]
```

You can run the following command to edit your existing Portworx ClusterRole

```
$ kubectl edit clusterrole node-get-put-list-role
```

##### Clone from a snapshot

You can restore a clone from a snapshot using the following spec file. In 1.3 and higher releases, this is required to create a read-write clone of an existing snapshot as snapshots are read only.

```yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  namespace: prod
  name: ns.prod-name.px-snap-restore
  annotations:
    volume.beta.kubernetes.io/storage-class: px-sc-2
    px/snapshot-source-pvc: ns.prod-name.px-snap-1
spec:
   accessModes:
     - ReadWriteOnce
   resources:
     requests:
       storage: 2Gi
```

The above example restores a volume from the source snapshot PVC _ns.prod-name.px-snap-1_ in the _prod_ namespace.

#### Using inline spec

If you do not wish to use annotations you can take a snapshot by providing the source PVC name in the name field of the claim.  However this method does not allow you to provide namespaces.
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

#### Restoring a pod from a snapshot

To restore a pod to use the created snapshot, use the pvc `name.snap001-source.pvc001` in the pod spec.

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