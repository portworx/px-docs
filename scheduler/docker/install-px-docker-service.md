---
layout: page
title: "Deploy Portworx on Docker Swarm or UCP"
keywords: portworx, architecture, storage, container, cluster, install, docker, swarm, ucp
sidebar: home_sidebar
meta-description: "Follow this step-by-step guide to installed Portworx on Docker Swarm or UCP.  Try it for yourself today!"
---

* TOC
{:toc}

## Prerequisites
#### Key value store

PX stores configuration metadata in a KVDB (key/value store), such as Etcd or Consul. 
If you have an existing KVDB, you may use that.  If you want to set one up, see the [etcd example](/run-etcd.html) for PX

#### Docker Swarm

* Follow the [Swarm mode overview](https://docs.docker.com/engine/swarm/) guide to run Docker in Swarm mode. PX requires a minimum of Docker version 1.10 to be installed.
* You *must* configure Docker to allow shared mounts propogation. Please follow [these](/knowledgebase/shared-mount-propogation.html) instructions to enable shared mount propogation.  This is needed because PX runs as a container and it will be provisioning storage to other containers.

#### Identify storage devices

Portworx pools the storage devices on your server and creates a global capacity for containers.

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

Identify the storage devices you will be allocating to PX.  If you are running in a heterogeneous environment, where different nodes have different drives use the `-a -f` parameters instead of `-s`.

## Install

Portworx can be deployed as a Swarm service.
```
$ docker service create --mount type=bind,src=/,dst=/media/host \
                        --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
                        --mode global \
                        --name portworx \
                        portworx/monitor -k etcd://etc.fake.net:2379 -x swarm -c test-cluster -a -f
```
To view status of the service:
```
$ docker service ps portworx
```
The arguments that are given to the service above (-k, -c etc) are described below.

#### Command-line arguments to Portworx daemon <a id="command-line-args-daemon"></a>

The following arguments are provided to the PX daemon:

|  Argument | Description                                                                                                                                                                              |
|:---------:|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|     `-c`    | (Required) Specifies the unique name for the Portworx cluster                                                                                                                            |
|     `-k`    | (Required) Points to your key value database, such as an etcd cluster or a consul cluster.                                                                                               |
|     `-s`    | (Optional if -a is used) Specifies the various drives that PX should use for storing the data.                                                                                           |
|     `-d`    | (Optional) Specifies the data interface.                                                                                                                                                 |
|     `-m`    | (Optional) Specifies the management interface.                                                                                                                                           |
|     `-f`    | (Optional) Instructs PX to use an unmounted drive even if it has a filesystem on it.                                                                                                     |
|     `-a`    | (Optional) Instructs PX to use any available, unused and unmounted drive.,PX will never use a drive that is mounted.                                                                     |
|     `-A`    | (Optional) Instructs PX to use any available, unused and unmounted drives or partitions. PX will never use a drive or partition that is mounted.                                         |
|     `-x`    | (Optional) Specifies the scheduler being used in the environment. "swarm" for Docker Swarm.                                                                                              |
|  `-userpwd` | (Optional) Username and password for ETCD authentication in the form user:password                                                                                                       |
|    `-ca`    | (Optional) Location of CA file for ETCD authentication.                                                                                                                                  |
|   `-cert`   | (Optional) Location of certificate for ETCD authentication.                                                                                                                              |
|    `-key`   | (Optional) Location of certificate key for ETCD authentication.                                                                                                                          |
| `-acltoken` | (Optional) ACL token value used for Consul authentication.                                                                                                                               |
|   `-token`  | (Optional) Portworx lighthouse token for cluster.                                                                                                                                        |

#### Scaling
Portworx is deployed as a `Global Service`.  Therefore it automatically scales as you grow your Swarm cluster.  There are no additional requirements to install Portworx on the new nodes.

#### Access the pxctl CLI
After Portworx is running, you can create, delete & manage storage volumes through the Docker volume commands or the **pxctl** command line tool. 

For more on using **pxctl**, see the [CLI Reference](/control/cli.html).

A useful pxctl command is `pxctl status`
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

Now that you have Portworx up, let's look at an example of running [stateful application with Portworx and Swarm](swarm.html)!

## Upgrade
Following command will perform upgrade with the latest image.
```
$ docker service update --force portworx
```

## Uninstall
```
$ docker service rm portworx
```
>**Note:**<br/>During uninstall, the configuration files (/etc/pwx/config.json and /etc/pwx/.private.json) are not deleted. If you delete /etc/pwx/.private.json, Portworx will lose access to data volumes.
