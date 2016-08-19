---
layout: page
title: "CLI Reference"
keywords: portworx, pxctl, command-line tool, cli, reference
sidebar: home_sidebar
---
The Portworx command-line tool, `pxctl`, lets you directly provision and manage storage. You can pre-provision storage and perform management tasks through the Portworx or Docker CLI.

Applications can provision and consume storage through the Docker API. The Portworx documentation references the Docker documentation for information about managing Docker volumes.

## About `pxctl`

All operations from `pxctl` are reflected back into the containers that use Portworx storage. In addition to what is exposed in Docker volumes, `pxctl`:

* Gives access to Portworx storage-specific features, such as cloning a running container's storage.
* Shows the connection between containers and their storage volumes.
* Let you control the Portworx storage cluster, such as adding nodes to the cluster. (The Portworx tools refer to servers managed by Portworx storage as *nodes*.)

The scope of the `pxctl` command is global to the cluster. Running `pxctl` from any node within the cluster therefore shows the same global details. `pxctl` also identifies details specific to that node.

This current release of `pxctl` requires that you run as a privileged user:

```
sudo su
```

The `pxctl` tool is available in the `/opt/pwx/bin/` directory. To run `pxctl` without typing the full directory path each time, add `pxctl` to your PATH as follows:

```
export PATH=/opt/pwx/bin:$PATH
```

Now you can just type `pxctl` and you're ready to start.

To view all Portworx commands, run [`pxctl help`](cli-reference.html#pxctl-command-line-help).

### Overall Node and Cluster Status: `pxctl status`

To see the total storage capacity, use `pxctl status`. In the example below, a three-node cluster has a global capacity of 413 GB. The node on which `pxctl` ran contributed 256 GB to that global capacity.

As nodes join the cluster, `pxctl` reports the updated global capacity.

Example of the status summary from the first node:

```
# pxctl status
Status: PX is operational
Node ID: d0479845-ac95-4dee-aa51-bac2daf22c04
       	IP: 10.0.0.141
       	Local Storage Pool: 1 device
       	Device 	Path   		Media Type     		Size   		Last-Scan
       	1      	/dev/sdc       	STORAGE_MEDIUM_MAGNETIC	932 GiB		19 Aug 16 11:06 PDT
       	total  			-      			932 GiB
Cluster Summary
       	Cluster ID: 04c58dcf-c831-4e90-8476-4c6ff69e6a14
       	Node IP: 10.0.0.141 - Capacity: 550 MiB/932 GiB Online (This node)
       	Node IP: 10.0.0.109 - Capacity: 550 MiB/932 GiB Online
       	Node IP: 10.0.0.84 - Capacity: 549 MiB/932 GiB Online
Global Storage Pool
       	Total Used     	:  1.6 GiB
       	Total Capacity 	:  2.7 TiB
```

### Manage storage volumes: `pxctl volume`

To create and manage volumes, use `pxctl volume`. You can use the created volumes directly with Docker with the `-v` option.

```
NAME:
   pxctl volume - Manage volumes

USAGE:
   pxctl volume command [command options] [arguments...]

COMMANDS:
     create, c           Create a volume
     list, l             List volumes in the cluster
     ha-update, u        Update volume HA level
     ha-reduce, r        Reduce volume HA
     replication-add     Add nodes to a volume replication set
     inspect, i          Inspect a volume
     requests            Show all pending requests
     delete, d           Delete a volume
     stats-history, sth  Volume Statistics
     stats, st           Volume Statistics
     alerts, a           Show volume related alerts

OPTIONS:
   --help, -h  show help
```

Running `cluster list` returns the current global state of the cluster, including usage, the number of containers running per node, and the status of the node within the cluster.

Example of `cluster list` for the same three-node cluster:

```
# pxctl cluster list
Cluster ID: 04c58dcf-c831-4e90-8476-4c6ff69e6a14
Status: OK

Nodes in the cluster:
ID     					DATA IP		CPU    		MEM TOTAL      	MEM FREE       	CONTAINERS     	STATUS
d0479845-ac95-4dee-aa51-bac2daf22c04   	10.0.0.141     	0.03125		33 GB  		31 GB  		N/A    		Online
374d95fa-ffab-4f3c-b06d-ae6cfd2cf0f9   	10.0.0.109     	0.04686		33 GB  		32 GB  		N/A    		Online
273e4389-8368-478f-8ef6-033346ad162c   	10.0.0.84      	0.031245       	33 GB  		32 GB  		N/A    		Online
```

To view the cluster from a container-centric perspective, run `container show`. The output lists the running containers by container ID, the container image/name, and the mounted Portworx storage volume.

Example of `container show` for the same three-node cluster:

```
# pxctl container show
ID           IMAGE        NAMES         VOLUMES STATUS
78adc5102d64 mysql        /clonesql     N/A     Up 5 hours
eae3eac65ea5 google/cadvi /px-dev       N/A     Up 5 hours
5a7850b7cc72 portworx/px- /px-lite      N/A     Up 5 hours
```

## `volume create` and Options

Storage is durable, elastic, and has fine-grained controls. Portworx creates volumes from the global capacity of a cluster. You can expand capacity and throughput by adding a node to the cluster. Portworx protects storage volumes from hardware and node failures through automatic replication.

* Durability: Set replication through policy, using the High Availability setting.
 * Each write is synchronously replicated to a quorum set of nodes.
 * Any hardware failure means that the replicated volume has the latest acknowledged writes.
* Elastic: Add capacity and throughput at each layer, at any time.
 * Volumes are thinly provisioned, only using capacity as needed by the container.
  * You can expand and contract the volume's maximum size, even after data has been written to the volume.

A volume can be created before use by its container or by the container directly at runtime. Creating a volume returns the volume's ID. This same volume ID is returned in Docker commands (such as `Docker volume ls`) as is shown in `pxctl` commands.

>**Note:**<br/>Portworx recommends generally creating volumes "in-band" through `docker volume create`. Employing mixed modes for volume management, including creation, is not generally recommended.

Example of creating a volume through `pxctl`, where the volume ID is returned:

 ```
 # pxctl volume create foobar
  3903386035533561360
 ```

Throughput is controlled per container and can be shared. Volumes have fine-grained control, set through policy.

 * Throughput is set by the Class of Service setting. Throughput capacity is pooled.
  * Adding a node to the cluster expands the available throughput for reads and writes.
  * The best node is selected to service reads, whether that read is from a local storage devices or another node's storage devices.
  * Read throughput is aggregated, where multiple nodes can service one read request in parallel streams.
* Fine-grained controls: Policies are specified per volume and give full control to storage.
 * Policies enforce how the volume is replicated across the cluster, IOPs priority, filesystem, blocksize, and additional parameters described below.
 * Policies are specified at create time and can be applied to existing volumes.

Set policies on a volume through the options parameter. Or, set policies through a Docker Compose file. Using a Kubernetes Pod spec is slated for a future release.

Show the available options through the --help command, as shown below:

```
# pxctl volume create --help
NAME:
   pxctl volume create - Create a volume

USAGE:
   pxctl volume create [command options] [arguments...]

OPTIONS:
   --shared                           Specify --shared to make this a globally shared namespace volume
   --label value, -l value            Comma separated name=value pairs, e.g name=sqlvolume,type=production
   --size value, -s value             specify size in GB (default: 1)
   --fs value                         filesystem to be laid out: none|xfs|ext4 (default: "ext4")
   --seed value                       optional data that the volume should be seeded with
   --block_size value, -b value       block size in Kbytes (default: 32)
   --repl value, -r value             replication factor [1..2] (default: 1)
   --cos value                        Class of Service: [1..9] (default: 1)
   --snap_interval value, --si value  snapshot interval in minutes, 0 disables snaps (default: 0)
```

## Global Namespace (Shared Volumes)

To use Portworx volumes across nodes and multiple containers, see [Shared Volumes](shared-volumes.html).

## `pxctl` Command Line Help

```
# pxctl help
NAME:
   pxctl - px cli

USAGE:
   pxctl [global options] command [command options] [arguments...]

VERSION:
   0.4.3-9da1bcd

COMMANDS:
   status       Show status summary
   volume, v    Manage volumes
   snap, s      Manage volume snapshots
   cluster, c   Manage the cluster
   container    Display containers in the cluster
   service, sv  Service mode utilities
   host         Attach volumes to the host
   eula         Show license agreement
   help, h      Shows a list of commands or help for one command

GLOBAL OPTIONS:
   --json, -j           output in json
   --color              output with color coding
   --raw, -r            raw CLI output for instrumentation
   --help, -h           show help
   --version, -v        print the version
```

## Volumes with Docker

All `docker volume` commands are reflected into Portworx storage. For example, a `docker volume create` command provisions a storage volume in a Portworx storage cluster.

```
# docker volume create -d pxd --name <volume_name>
```

As part of the `docker volume` command, you can add optional parameters through the `--opt` flag. The option parameters are the same, whether you use Portworx storage through the Docker volume or the `pxctl` commands.

Example of options for selecting the container's filesystem and volume size:

```
  docker volume create -d pxd --name <volume_name> --opt fs=ext4 --opt size=10G
```

For more on Docker volumes, refer to  [https://docs.docker.com/engine/reference/commandline/volume_create/](https://docs.docker.com/engine/reference/commandline/volume_create/).
