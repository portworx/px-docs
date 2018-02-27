---
layout: page
title: "Create and Manage Storage Volumes"
keywords: portworx, px-enterprise, storage, volume, create volume, clone volume
sidebar: home_sidebar
redirect_from:
  - /create-manage-storage-volumes.html
  - /manage/create-and-manage.html
  - /manage/volume-sets.html
meta-description: "Create, manage and inspect storage volumes with pxctl CLI. Discover how to use Docker together with Portworx!"
---

* TOC
{:toc}

To create and manage volumes, use `pxctl volume`. You can use the created volumes directly with Docker with the `-v` option.

{% include pxctl/volume/volume-help-1.3.md %}

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

{% include pxctl/volume/volume-create-help-1.3.md %}

### Create with Docker
All `docker volume` commands are reflected into Portworx storage. For example, a `docker volume create` command provisions a storage volume in a Portworx storage cluster.

```
# docker volume create -d pxd --name <volume_name>
```

As part of the `docker volume` command, you can add optional parameters through the `--opt` flag. The option parameters are the same, whether you use Portworx storage through the Docker volume or the `pxctl` commands.

Example of options for selecting the container's filesystem and volume size:

```
# docker volume create -d pxd --name <volume_name> --opt fs=ext4 --opt size=10G
```

## Inline volume spec
PX supports passing the volume spec inline along with the volume name.  This is useful when creating a volume with your scheduler application template inline and you do not want to create volumes before hand.

For example, a PX inline spec can be specified as the following:

```
# docker volume create -d pxd io_priority=high,size=10G,repl=3,name=demovolume
```

This is useful when you need to create a volume dynamically while using docker run.  For example, the following command will create a volume and launch the container dynamically:

```
# docker run --volume-driver pxd -it -v io_priority=high,size=10G,repl=3,name=demovolume:/data busybox sh
```

The above command will create a volume called demovolume with an initial size of 10G, HA factor of 3 and a IO priority level of 3 and start the busybox container.

Each spec key must be comma separated.  The following are supported key value pairs:

```
IO priority      - io_priority=[high|medium|low]
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
		"value": "size=100G,repl=3,io_priority=high,name=mysql_vol:/var/lib/mysql"
	}],
```

## Global Namespace (Shared Volumes)
To use Portworx volumes across nodes and multiple containers, see [Shared Volumes](/manage/shared-volumes.html).

## Inspect volumes
Volumes can be inspected for their settings and usage using the `pxctl volume inspect` sub menu.

{% include pxctl/volume/volume-inspect-example.md %}

You can also inspect multiple volumes in one command.

To inspect the volume in `json` format, use the `-j` flag. Following is a sample output of:

{% include pxctl/volume/volume-inspect-json-example.md %}

## Volume snapshots

You can take snapshots of PX volumes.  Snapshots are thin and do not take additional space.  PX snapshots use branch-on-write so that there is no additional copy when a snapshot is written to.  This is done through B+ Trees.

#### PX version 1.3 and higher

{% include pxctl/volume/volume-snap-help-1.3.md %}

Snapshots are read-only. To restore a volume from a snapshot, use the `pxctl volume restore` command.

#### PX version 1.2

{% include pxctl/volume/volume-snap-help-1.2.md %}

Snapshot volumes can be used as any other regular volume.  For example, they can be passed into `docker run -v snapshot:/mount_path`