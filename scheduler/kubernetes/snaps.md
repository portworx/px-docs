---
layout: page
title: "Create and use snapshots"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk, snapshots
sidebar: home_sidebar
redirect_from:
  - /scheduler/kubernetes/mount-snapshot-to-pod.html
meta-description: "Learn to take a snapshot of a volume from a Kubernetes persistent volume claim (PVC) and use that snapshot as the volume for a new pod. Try today!"
---

* TOC
{:toc}

This document will show you how to create snapshots of Portworx volumes and use them in pods.  It uses MySQL as an example.

## Managing snapshots with `kubectl`

### Taking snapshots

Following are the different ways in which you can take snapshots of your volume through kubernetes.

#### Periodic snapshots
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

#### On demand Snapshots

You can trigger a new snapshot on a running POD by creating a PersistentVolumeClaim

##### Using annotations

Portworx uses a special annotation `px/snapshot-source-pvc` which can be used to identify the name of the source PVC whose snapshot needs to be taken.

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
Note the format of the `name` field  - `ns.<namespace_of_source_pvc>-name.<name_of_the_snapshot>`. The above example takes a snapshot with the name "px-snap-1" of the source PVC "px-vol-1" in the "prod" namespace.
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

##### Snapshot of a snapshot

You can take a snapshot of a snapshot using the following spec file

```yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  namespace: prod
  name: ns.prod-name.px-snap-2
  annotations:
    volume.beta.kubernetes.io/storage-class: px-sc-2
    px/snapshot-source-pvc: px-snap-1
spec:
   accessModes:
     - ReadWriteOnce
   resources:
     requests:
       storage: 2Gi
```

The above example takes a snapshot with the name "px-snap-2" of the source snapshot "px-snap-1" in the "prod" namespace. Note that `px/snapshot-source-pvc` does not take the actual PVC name of the snapshot "ns.prod-name.px-snap-1" but instead only the name subsection "px-snap-1"

##### Using inline spec

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
