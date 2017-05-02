---
layout: page
title: "Create and Manage Storage Volumes"
keywords: portworx, px-enterprise, storage, volume, create volume, clone volume
sidebar: home_sidebar
redirect_from: "/create-manage-storage-volumes.html"
---

To create and manage volumes, use `pxctl volume`. You can use the created volumes directly with Docker with the `-v` option.

```
NAME:
   pxctl volume - Manage volumes

USAGE:
   pxctl volume command [command options] [arguments...]

COMMANDS:
     create, c             Create a volume
     list, l               List volumes in the cluster
     update                Update volume settings
     ha-update, u          Update volume HA level
     snap-interval-update  Update volume configuration
     inspect, i            Inspect a volume
     requests              Show all pending requests
     delete, d             Delete a volume
     stats, st             Volume Statistics
     alerts, a             Show volume related alerts
     import                Import data into a volume

OPTIONS:
   --help, -h  show help
```

## Create volumes
Portworx creates volumes from the global capacity of a cluster. You can expand capacity and throughput by adding a node to the cluster. Portworx protects storage volumes from hardware and node failures through automatic replication.

* Durability: Set replication through policy, using the High Availability setting.
 * Each write is synchronously replicated to a quorum set of nodes.
 * Any hardware failure means that the replicated volume has the latest acknowledged writes.
* Elastic: Add capacity and throughput at each layer, at any time.
 * Volumes are thinly provisioned, only using capacity as needed by the container.
  * You can expand and contract the volume's maximum size, even after data has been written to the volume.

A volume can be created before use by its container or by the container directly at runtime. Creating a volume returns the volume's ID. This same volume ID is returned in Docker commands (such as `Docker volume ls`) as is shown in `pxctl` commands.

Example of creating a volume through `pxctl`, where the volume ID is returned:

```
 # pxctl volume create foobar
 3903386035533561360
```

Throughput is controlled per container and can be shared. Volumes have fine-grained control, set through policy.

 * Throughput is set by the IO Priority setting. Throughput capacity is pooled.
  * Adding a node to the cluster expands the available throughput for reads and writes.
  * The best node is selected to service reads, whether that read is from a local storage devices or another node's storage devices.
  * Read throughput is aggregated, where multiple nodes can service one read request in parallel streams.
* Fine-grained controls: Policies are specified per volume and give full control to storage.
 * Policies enforce how the volume is replicated across the cluster, IOPs priority, filesystem, blocksize, and additional parameters described below.
 * Policies are specified at create time and can be applied to existing volumes.

Set policies on a volume through the options parameter.  These options can also be passed in through the scheduler or using the [inline volume spec](#inline-volume-spec).

Show the available options through the --help command, as shown below:

```
# pxctl volume create --help
NAME:
   pxctl volume create - Create a volume

USAGE:
   pxctl volume create [command options] volume-name

OPTIONS:
   --shared                             make this a globally shared namespace volume
   --passphrase value                   passphrase to use for the PBKDF2 function
   --label pairs, -l pairs              list of comma-separated name=value pairs
   --size value, -s value               volume size in GB (default: 1)
   --fs value                           filesystem to be laid out: none|xfs|ext4 (default: "ext4")
   --block_size size, -b size           block size in Kbytes (default: 32)
   --repl factor, -r factor             replication factor [1..3] (default: 1)
   --scale value, --sc value            auto scale to max number [1..1024] (default: 1)
   --io_priority value, --iop value     IO Priority: [high|medium|low] (default: "low")
   --sticky                             sticky volumes cannot be deleted until the flag is disabled [on | off]
   --snap_interval min, --si min        snapshot interval in minutes, 0 disables snaps (default: 0)
   --daily hh:mm, --sd hh:mm            daily snapshot at specified hh:mm
   --weekly value, --sw value           weekly snapshot at specified weekday@hh:mm
   --monthly value, --sm value          monthly snapshot at specified day@hh:mm
   --aggregation_level level, -a level  aggregation level: [1..3 or auto] (default: "1")
   --nodes value                        comma-separated Node Id(s)
```

### Create with Docker
All `docker volume` commands are reflected into Portworx storage. For example, a `docker volume create` command provisions a storage volume in a Portworx storage cluster.

```
# docker volume create -d pxd --name <volume_name>
```

As part of the `docker volume` command, you can add optional parameters through the `--opt` flag. The option parameters are the same, whether you use Portworx storage through the Docker volume or the `pxctl` commands.

Example of options for selecting the container's filesystem and volume size:

```
  docker volume create -d pxd --name <volume_name> --opt fs=ext4 --opt size=10G
```

## Inline volume spec
PX supports passing the volume spec inline along with the volume name.  This is useful when creating a volume with your scheduler application template inline and you do not want to create volumes before hand.

For example, a PX inline spec can be specified as the following:

```
# docker volume create -d pxd --name cos=3,size=10G,repl=3,name=demovolume
```

This is useful when you need to create a volume dynamically while using docker run.  For example, the following command will create a volume and launch the container dynamically:

```
# docker run --volume-driver pxd -it -v cos=3,size=10G,repl=3,name=demovolume:/data busybox sh
```

The above command will create a volume called demovolume with an initial size of 10G, HA factor of 3 and a IO priority level of 3 and start the busybox container.

Each spec key must be comma separated.  The following are supported key value pairs:

```
IO priority      - cos=[1,2,3]
Volume size      - size=[1..9][G|M|T]
HA factor        - repl=[1,2,3]
Block size       - bs=[4096...]
Shared volume    - shared=true
File System      - fs=[xfs|ext4]
Encryption       - passphrase=secret
```

These inline specs can be passed in through the scheduler application template.  For example, below is a snippet from a marathon configuration file:

```json
"parameters": [
	{
		"key": "volume-driver",
		"value": "pxd"
	},
	{
		"key": "volume",
		"value": "size=100G,repl=3,cos=3,name=mysql_vol:/var/lib/mysql"
	}],
```

## Global Namespace (Shared Volumes)
To use Portworx volumes across nodes and multiple containers, see [Shared Volumes](/manage/shared-volumes.html).

## Inspect volumes
Volumes can be inspected for their settings and usage using the `pxctl volume inspect` sub menu.

```
# pxctl volume inspect v1
Volume  :  774553971874590484
        Name                     :  v1
        Size                     :  1000 GiB
        Format                   :  ext4
        HA                       :  1
        IO Priority              :  LOW
        Shared                   :  no
        Status                   :  up
        State                    :  Attached: 5533acd1-655e-4247-a780-3272bfc863fd
        Device Path              :  /dev/pxd/pxd774553971874590484
        Reads                    :  94
        Reads MS                 :  0
        Bytes Read               :  606208
        Writes                   :  2448
        Writes MS                :  1842492
        Bytes Written            :  158642176
        IOs in progress          :  0
        Bytes used               :  139 MiB
        Replica sets on nodes:
                Set  0
                        Node     :  172.31.8.91
                Set  1
                        Node     :  172.12.8.92
```

You can also inspect multiple volumes in one command.

To inspect the volume in `json` format:

```
# pxctl -j volume inspect v1
```

```json
[{
 "id": "774553971874590484",
 "source": {
  "parent": "",
 },
 "readonly": false,
 "locator": {
  "name": "v1"
 },
 "ctime": "2016-12-17T18:47:07Z",
 "spec": {
  "ephemeral": false,
  "size": "1073741824000",
  "format": "ext4",
  "block_size": "32768",
  "ha_level": "1",
  "cos": "low",
  "dedupe": false,
  "snapshot_interval": 0,
  "shared": false,
  "replica_set": {

  },
  "aggregation_level": 1,
  "encrypted": false,
  "passphrase": "",
  "snapshot_schedule": ""
 },
 "usage": "145285120",
 "last_scan": "2016-12-17T18:47:07Z",
 "format": "ext4",
 "status": "up",
 "state": "attached",
 "attached_on": "5533acd1-655e-4247-a780-3272bfc863fd",
 "device_path": "/dev/pxd/pxd774553971874590484",
 "attach_path": [
  "/var/lib/osd/mounts/v1"
 ],
 "replica_sets": [
  {
   "nodes": [
    "5533acd1-655e-4247-a780-3272bfc863fd"
   ]
  }
 ],
 "error": "",
 "runtime_state": [
  {
   "runtime_state": {
    "FullResyncBlocks": "[{0 0} {-1 0} {-1 0} {-1 0} {-1 0}]",
    "ID": "0",
    "ReadQuorum": "1",
    "ReadSet": "[0]",
    "ReplicaSetCurr": "[0]",
    "ReplicaSetNext": "[0]",
    "ResyncBlocks": "[{0 0} {-1 0} {-1 0} {-1 0} {-1 0}]",
    "RuntimeState": "clean",
    "TimestampBlocksPerNode": "[0 0 0 0 0]",
    "TimestampBlocksTotal": "0",
    "WriteQuorum": "1",
    "WriteSet": "[0]"
   }
  }
 ],
 "secure_device_path": "",
 "background_processing": false
}]
```

Note the use of the `-j` flag.

## Volume snapshots
You can take snapshots of PX volumes.  Snapshots are thin and do not take additional space.  PX snapshots use branch-on-write so that there is no additional copy when a snapshot is written to.  This is done through B+ Trees.

```
# pxctl snap -h
NAME:
   pxctl snap - Manage volume snapshots

USAGE:
   pxctl snap command [command options] [arguments...]

COMMANDS:
     create, c  Create a volume snapshot
     list, l    List volume snapshots in the cluster
     delete, d  Delete a volume snapshot

OPTIONS:
   --help, -h  show help
```

Snapshot volumes can be used as any other regular volume.  For example, they can be passed into `docker run -v snapshot:/mount_path`.

