---
layout: page
title: "Objectstore on PX Cluster"
keywords: cloud, objectstore
---

## Objectstore on PX Cluster
You can expose a Highly Available S3 compliant Objectstore from a PX Cluster.

Objectstore module has the following commands

```
$ pxctl objectstore
create, c  Create an object store
start      Start the object store
status     Show the status of the object store
stop       Stop the object store
delete     Delete the object store
```

## Create an Objectstore
"Create" option creates the volumes required to run the object store. It takes in an optional parameter (--size) for the size of the data volume. By default it creates a 10GB data volume. It always creates a 1GB Config volume.

```
$ pxctl objectstore create --size 10
```

You can run "volume list" to make sure two shared volumes are created after this step

```
$ pxctl volume list
ID			NAME			SIZE	HA	SHARED	ENCRYPTED	IO_PRIORITY	SCALE	STATUS
1132595193891911100	ObjectStoreConfig	1 GiB	3	yes	no		LOW		0	up - detached
462063265326082265	ObjectStoreData		10 GiB	3	yes	no		LOW		0	up - detached
```

## Start the objectstore on a node
"Start" option starts the object server on the node where it is run. It attaches the volumes on the node if it isn't attached on some other node already. NOTE: You need to run this command as root.

```
$ sudo pxctl objectstore start
Successfully started object store
```

At this point you should be able to access the object browser at http://<node_ip>:9010
You'll need to run this command from every node that you want to access the object store.
On restarting the container the object store does not restart automatically.

## Check the status of the objectstore
This shows the status of the server as well as the access key to login to the object server

```
$ pxctl objectstore status
Object store is running
Access Key: SNKM04SP9P8PCNW6PKDO
Secret Key: va11VEismRQm/vFxheby0PMFXEdl2nyKw3AG8udq
```

Use these credentials to login to the object browser as well as running any s3 commands.
The servers are created with the "us-east-1" region currently.
The objectstore does not have SSL certificates set up, so you'll need to configure your client accordingly.

## Stop the objectstore
You can stop the server on each node by running the stop command.
If the object server is still running on other nodes you'll get a message saying that the volumes will not be detached since they are being used by the objectstore on the other nodes.

```
$ pxctl objectstore stop
Successfully stopped object store
Unmounted object store volumes
stopObjectStore: Will not detach, as volume462063265326082265 is mounted at:/var/list/osd/mounts/objectStoreData
```
When you stop the server on the last node you'll get the following message

```
$ pxctl objectstore stop
Successfully stopped object store
Unmounted object store volumes
Detached object store volumes
```

At this point the 2 volumes should be in detached state:
```
$ pxctl volume list
ID			NAME			SIZE	HA	SHARED	ENCRYPTED	IO_PRIORITY	SCALE	STATUS
1132595193891911100	ObjectStoreConfig	1 GiB	3	yes	no		LOW		0up - detached
462063265326082265	ObjectStoreData		10 GiB	3	yes	no		LOW		0up - detached
```

## Delete the objectstore
You can the the objectstore delete command at this point to delete the volumes. This will fail if the objectstore is still running on any node.

```
$ pxctl objectstore delete
Successfully deleted object store
```

This will delete the 2 volumes that were created for the objectstore. You can not delete the objectstore while it is still running on any node.
