---
layout: page
title: "Deploy Portworx with Docker"
keywords: portworx, architecture, storage, container, cluster, install, docker, compose, systemd, plugin
sidebar: home_sidebar
redirect_from:
 - runpx.html
---

* TOC
{:toc}

This guide describes installing Portworx using the docker CLI.

>**Important:**<br/>PX stores configuration metadata in a KVDB (key/value store), such as Etcd or Consul. If you have an existing KVDB, you may use that.  If you want to set one up, see the [etcd example](/maintain/etcd.html) for PX. Ensure all nodes running PX are synchronized in time and NTP is configured


## Install and configure Docker

* PX requires a minimum of Docker version 1.10 to be installed.  Follow the [Docker install](https://docs.docker.com/engine/installation/) guide to install and start the Docker Service.
* You *must* configure Docker to allow shared mounts propogation. Please follow [these](/knowledgebase/shared-mount-propogation.html) instructions to enable shared mount propogation.  This is needed because PX runs as a container and it will be provisioning storage to other containers.

## Specify storage

Portworx pools the storage devices on your server and creates a global capacity for containers. This example uses the two non-root storage devices (/dev/xvdb, /dev/xvdc).

>**Important:**<br/>Back up any data on storage devices that will be pooled. Storage devices will be reformatted!

To view the storage devices on your server, use the `lsblk` command.

For example:
```
# lsblk
    NAME                      MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
    xvda                      202:0    0     8G  0 disk
    └─xvda1                   202:1    0     8G  0 part /
    xvdb                      202:16   0    64G  0 disk
    xvdc                      202:32   0    64G  0 disk
```
Note that devices without the partition are shown under the **TYPE** column as **part**. This example has two non-root storage devices (/dev/xvdb, /dev/xvdc) that are candidates for storage devices.

Identify the storage devices you will be allocating to PX.  PX can run in a heterogeneous environment, so you can mix and match drives of different types.  Different servers in the cluster can also have different drive configurations.

## Run PX as a Plugin

If you have Docker version 1.13 or higher, it is strongly recommended to install Portworx as a plugin. [Follow these steps](docker-plugin.html) to do so.

To upgrade a previously installed Portworx plugin, [follow these steps](upgrade-standalone.html).

### Optional - Run PX as a container

If you are running Docker version 1.12 or prior, you can run PX as a Docker container.  [Follow these steps](docker-container.html) to do so.

## Adding Nodes
To add nodes to increase capacity and enable high availability, simply repeat these steps on other servers.  As long as PX is started with the same cluster ID, they will form a cluster.

## Access the pxctl CLI
After Portworx is running, you can create and delete storage volumes through the Docker volume commands or the **pxctl** command line tool.

With **pxctl**, you can also inspect volumes, the volume relationships with containers, and nodes. For more on using **pxctl**, see the [CLI
Reference](/control/status.html).

To view the global storage capacity, run:

```
# sudo /opt/pwx/bin/pxctl status
```

The following sample output of `pxctl status` shows that the global capacity for Docker containers is 128 GB.

```
# /opt/pwx/bin/pxctl status
Status: PX is operational
Node ID: 0a0f1f22-374c-4082-8040-5528686b42be
	IP: 172.31.50.10
 	Local Storage Pool: 2 pools
	POOL	IO_PRIORITY	SIZE	USED	STATUS	ZONE	REGION
	0	LOW		64 GiB	1.1 GiB	Online	b	us-east-1
	1	LOW		128 GiB	1.1 GiB	Online	b	us-east-1
	Local Storage Devices: 2 devices
	Device	Path		Media Type		Size		Last-Scan
	0:1	/dev/xvdf	STORAGE_MEDIUM_SSD	64 GiB		10 Dec 16 20:07 UTC
	1:1	/dev/xvdi	STORAGE_MEDIUM_SSD	128 GiB		10 Dec 16 20:07 UTC
	total			-			192 GiB
Cluster Summary
	Cluster ID: 55f8a8c6-3883-4797-8c34-0cfe783d9890
	IP		ID					Used	Capacity	Status
	172.31.50.10	0a0f1f22-374c-4082-8040-5528686b42be	2.2 GiB	192 GiB		Online (This node)
Global Storage Pool
	Total Used    	:  2.2 GiB
	Total Capacity	:  192 GiB
```

You have now completed setup of Portworx on your first server. To increase capacity and enable high availability, repeat the same steps on each of the remaining two servers. Run **pxctl** status to view the cluster status. Then, to continue with examples of running stateful applications and databases with Docker and PX, see [Application Solutions](/application-solutions.html).

## Application Examples

After you complete this installation, continue with the set up to run stateful containers with Docker volumes:

* [Scale a Cassandra Database with PX](/applications/cassandra.html)
* [Run the Docker Registry with High Availability](/applications/docker-registry.html)
