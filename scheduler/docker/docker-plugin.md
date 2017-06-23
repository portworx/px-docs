---
layout: page
title: "Run PX as a Docker V2 Plugin"
keywords: portworx, px-developer, px-enterprise, plugin, install, configure, container, storage, add nodes
sidebar: home_sidebar
redirect_from: "/run-as-docker-pluginv2.html"
---

* TOC
{:toc}

To install and configure PX via the Docker Plugin CLI, use the command-line steps in this section.

>**Important:**<br/>PX stores configuration metadata in a KVDB (key/value store), such as Etcd or Consul. If you have an existing KVDB, you may use that.  If you want to set one up, see the [etcd example](/run-etcd.md) for PX

### Install and configure Docker

PX V2 plugin requires a minimum of Docker version 1.12 to be installed.  Follow the [Docker install](https://docs.docker.com/engine/installation/) guide to install and start the Docker Service.

### Specify storage

Portworx pools the storage devices on your server and creates a global capacity for containers. This example uses the two non-root storage devices (/dev/xvdb, /dev/xvdc).

>**Important:**<br/>Back up any data on storage devices that will be pooled. Storage devices will be reformatted!

To view the storage devices on your server

Use this command line:

```
# lsblk
```

Example output:

Note that devices without the partition are shown under the **TYPE** column as **part**.

```
# lsblk
    NAME                      MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
    xvda                      202:0    0     8G  0 disk
    └─xvda1                   202:1    0     8G  0 part /
    xvdb                      202:16   0    64G  0 disk
    xvdc                      202:32   0    64G  0 disk
```

Identify the storage devices you will be allocating to PX.  PX can run in a heterogeneous environment, so you can mix and match drives of different types.  Different servers in the cluster can also have different drive configurations.

### Install PX plugin

To install Portworx as V2 Docker plugin follow these steps

```
$ mkdir -p /etc/pwx
$ mkdir -p /opt/pwx/bin
$ mkdir -p /var/lib/osd
$ mkdir -p /var/cores
```

We need to create these directories on the host, so that the plugin can export ```pxctl``` CLI onto the host and also a few configuration files.

>**Important:**<br/>The `--alias pxd` option is important if you are upgrading from a non-plugin Portworx install to this plugin-based method.

```
$ sudo docker plugin install portworx/px:latest --alias pxd opts="-k etcd://myetc.company.com:2379 -c MY_CLUSTER_ID -s /dev/xvdb -s /dev/xvdc"
Plugin "portworx/px:latest" is requesting the following
privileges:
 - network: [host]
 - mount: [/dev]
 - mount: [/etc/pwx]
 - mount: [/var/lib/osd]
 - mount: [/opt/pwx/bin]
 - mount: [/var/run/docker.sock]
 - mount: [/lib/modules]
 - mount: [/usr/src]
 - mount: [/var/cores]
 - allow-all-devices: [true]
 - capabilities: [CAP_SYS_ADMIN CAP_SYS_MODULE CAP_IPC_LOCK]
Do you grant the above permissions? [y/N] y
```
You will need to grant the above set of permissions for the plugin to be installed.

The description of the arguments provided to the plugin install ```opts``` parameter are described below.

|  Argument | Description                                                                                                                                                                              |
|:---------:|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|     `-c`    | (Required) Specifies the cluster ID that this PX instance is to join. You can create any unique name for a cluster ID.                                                                   |
|     `-k`    | (Required) Points to your key value database, such as an etcd cluster or a consul cluster.                                                                                               |
|     `-s`    | (Optional if -a is used) Specifies the various drives that PX should use for storing the data.                                                                                           |
|     `-d`    | (Optional) Specifies the data interface.                                                                                                                                                 |
|     `-m`    | (Optional) Specifies the management interface.                                                                                                                                           |
|     `-z`    | (Optional) Instructs PX to run in zero storage mode. In this mode, PX can still provide virtual storage to your containers, but the data will come over the network from other PX nodes. |
|     `-f`    | (Optional) Instructs PX to use an unmounted drive even if it has a filesystem on it.                                                                                                     |
|     `-a`    | (Optional) Instructs PX to use any available, unused and unmounted drive.,PX will never use a drive that is mounted.                                                                     |
|     `-A`    | (Optional) Instructs PX to use any available, unused and unmounted drives or partitions. PX will never use a drive or partition that is mounted.                                         |
|     `-x`    | (Optional) Specifies the scheduler being used in the environment. Supported values: "swarm" and "kubernetes".                                                                            |
|  `-userpwd` | (Optional) Username and password for ETCD authentication in the form user:password                                                                                                       |
|    `-ca`    | (Optional) Location of CA file for ETCD authentication.                                                                                                                                  |
|   `-cert`   | (Optional) Location of certificate for ETCD authentication.                                                                                                                              |
|    `-key`   | (Optional) Location of certificate key for ETCD authentication.                                                                                                                          |
| `-acltoken` | (Optional) ACL token value used for Consul authentication.                                                                                                                               |
|   `-token`  | (Optional) Portworx lighthouse token for cluster.                                                                                                                                        |


The privileges that PX plugin uses are explained below:

```
 - capabilities: [CAP_SYS_ADMIN CAP_SYS_MODULE CAP_IPC_LOCK]
    > Sets PX to be a privileged plugin. Required to export block device and for other functions.

 - network: [host]
    > Sets communication to be on the host IP address over ports 9001 -9003. Future versions will support separate IP addressing for PX.

 - mount: [/dev]
    > Specifies which host drives PX can see. Note that PX only uses drives specified in config.json. This volume flage is an alternate to --device=\[\].

 - mount: [/etc/pwx]
    > the configuration file location.

 - mount: [/var/run/docker.sock]
    > Used by Docker to export volume container mappings.

 - mount: [/var/lib/osd]
    > Location of the exported container mounts. This must be a shared mount.

 - mount: [/opt/pwx/bin]
    > Exports the PX command line (**pxctl**) tool from the container to the host.
```

#### Optional - running with config.json

You can also provide the runtime parameters to PX via a configuration file called config.json.  When this is present, you do not need to
pass the runtime parameters via ```opts``` argument.  This maybe useful if you are using tools like chef or puppet to provision your host machines.

1. Download the sample config.json file:
https://raw.githubusercontent.com/portworx/px-dev/master/conf/config.json
2. Create a directory for the configuration file.

   ```
   # sudo mkdir -p /etc/pwx
   ```
   
3. Move the configuration file to that directory. This directory later gets passed in on the Docker command line.

   ```
   # sudo cp -p config.json /etc/pwx
   ```
   
4. Edit the config.json to include the following:
   * `clusterid`: This string identifies your cluster and must be unique within your etcd key/value space.
   * `kvdb`: This is the etcd connection string for your etcd key/value store.
   * `devices`: These are the storage devices that will be pooled from the prior step.


Example config.json:

```
   {
      "clusterid": "make this unique in your k/v store",
      "kvdb": [
          "etcd:https://[username]:[password]@[string].dblayer.com:[port]"
        ],
      "storage": {
        "devices": [
          "/dev/xvdb",
          "/dev/xvdc"
        ]
      }
    }
```

At this point, Portworx should be running on your system. To verify, run `docker plugin ls`.

#### Authenticated `etcd` and `consul`
To use `etcd` with authentication and a cafile, use this in your `config.json`:

```json
"kvdb": [
   "etcd:https://<ip1>:<port>",
   "etcd:https://<ip2>:<port>"
 ],
 "username": "root",
 "password": "xxx",
 "cafile": "/etc/pwx/cafile",
```

To use `consul` with authentication and a cafile, use this in your `config.json`:

```json
"kvdb": [
   "consul:https://<ip1>:<port>",
   "consul:https://<ip2>:<port>"
 ],
 "username": "root",
 "password": "xxx",
 "cafile": "/etc/pwx/cafile",
```

### Access the pxctl CLI
After Portworx is running, you can create and delete storage volumes through the Docker volume commands or the **pxctl** command line tool, which is exported to /opt/pwx/bin/pxctl. With **pxctl**, you can also inspect volumes, the volume relationships with containers, and nodes.

To view all **pxctl** options, run:

```
# /opt/pwx/bin/pxctl help
```

To view global storage capacity


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

For more on using **pxctl**, see the [CLI Reference](/control/cli.html).

You have now completed setup of Portworx on your first server. To increase capacity and enable high availability, repeat the same steps on each of the remaining two servers. Run **pxctl** status to view the cluster status. Then, to continue with examples of running stateful applications and databases with Docker and PX, see [Application Solutions](/application-solutions.html).

### Adding Nodes

To add nodes to increase capacity and enable high availability, simply repeat these steps on other servers.  As long as PX is started with the same cluster ID, they will form a cluster.

### Application Examples

After you complete this installation, continue with the set up to run stateful containers with Docker volumes:

* [Scale a Cassandra Database with PX](/applications/cassandra.html)
* [Run the Docker Registry with High Availability](/applications/docker-registry.html)
