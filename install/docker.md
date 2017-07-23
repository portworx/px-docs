---
layout: page
title: "Run PX with Docker"
keywords: portworx, px-developer, px-enterprise, install, configure, container, storage, add nodes
sidebar: home_sidebar
redirect_from: “/run-with-docker-ent.html”
---

* TOC
{:toc}

To install and configure PX via the Docker CLI, use the command-line steps in this section.

>**Important:**<br/>PX stores configuration metadata in a KVDB (key/value store), such as Etcd or Consul. If you have an existing KVDB, you may use that.  If you want to set one up, see the [etcd example](/run-etcd.html) for PX

### Install and configure Docker

PX requires a minimum of Docker version 1.10 to be installed.  Follow the [Docker install](https://docs.docker.com/engine/installation/) guide to install and start the Docker Service.

>**Important:**<br/>If you are running a version prior to Docker 1.12 or running docker on Ubuntu 14.4 LTS, then you *must* configure Docker to allow shared mounts propogation. Please follow [these](/knowledgebase/shared-mount-propogation.html) instructions to enable shared mount propogation.  This is needed because PX runs as a container and it will be provisioning storage to other containers.

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

### Run PX

You can now run PX via the Docker CLI as follows:

```
if `uname -r | grep -i coreos > /dev/null`; \
then HDRS="/lib/modules"; \
else HDRS="/usr/src"; fi
sudo docker run --restart=always --name px -d --net=host       \
                 --privileged=true                             \
                 -v /run/docker/plugins:/run/docker/plugins    \
                 -v /var/lib/osd:/var/lib/osd:shared           \
                 -v /dev:/dev                                  \
                 -v /etc/pwx:/etc/pwx                          \
                 -v /opt/pwx/bin:/export_bin                   \
                 -v /var/run/docker.sock:/var/run/docker.sock  \
                 -v /var/cores:/var/cores                      \
                 -v ${HDRS}:${HDRS}                            \
                portworx/px-dev -k etcd://myetc.company.com:2379 -c MY_CLUSTER_ID -s /dev/sdb -s /dev/sdc
```

Where the following arguments are provided to the PX daemon:

```
-daemon
	> Instructs PX to start in daemon mode.  Other modes are for service users only.

-k
	> Points to your key value database, such as an etcd cluster or a consul cluster.
	
-userpwd
       > username and password for ETCD authentication in the form <user_name>:<passwd>
 
-ca
       > location of CA file for ETCD authentication
       
-cert 
	> location of certificate for ETCD authentication

-key 
	> location of certificate key for ETCD authentication

-acltoken 
	> ACL token value used for Consul authentication

-c
	> Specifies the cluster ID that this PX instance is to join.  You can create any unique name for a cluster ID.

-s
	> Specifies the various drives that PX should use for storing the data.

-a
	> Instructs PX to use any available, unused and unmounted drive.  PX will never use a drive that is mounted.

-A
	> Instructs PX to use any available, unused and unmounted drives or partitions.  PX will never use a drive or partition that is mounted.

-f
	> Optional.  Instructs PX to use an unmounted drive even if it has a filesystem on it.

-z
	> Optional.  Instructs PX to run in zero storage mode.  In this mode, PX can still provide virtual storage to your containers, but the data will come over the network from other PX nodes.

-d
	> Optional.  Specifies the data interface.

-m
	> Optional.  Specifies the management interface.
```

The following Docker runtime command options are explained:

```
--privileged
    > Sets PX to be a privileged container. Required to export block device and for other functions.

--net=host
    > Sets communication to be on the host IP address over ports 9001 -9003. Future versions will support separate IP addressing for PX.

--shm-size=384M
    > PX advertises support for asynchronous I/O. It uses shared memory to sync across process restarts

-v /run/docker/plugins
    > Specifies that the volume driver interface is enabled.

-v /dev
    > Specifies which host drives PX can see. Note that PX only uses drives specified in config.json. This volume flage is an alternate to --device=\[\].

-v /etc/pwx/config.json:/etc/pwx/config.json
    > the configuration file location.

-v /var/run/docker.sock
    > Used by Docker to export volume container mappings.

-v /var/lib/osd:/var/lib/osd:shared
    > Location of the exported container mounts. This must be a shared mount.

-v /opt/pwx/bin:/export_bin
    > Exports the PX command line (**pxctl**) tool from the container to the host.
```

#### Optional - running with config.json

You can also provide the runtime parameters to PX via a configuration file called config.json.  When this is present, you do not need to pass the runtime parameters via the command line.  This maybe useful if you are using tools like chef or puppet to provision your host machines.

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


```json
   {
      "clusterid": "make this unique in your k/v store",
      "dataiface": "bond0",
      "kvdb": [
          "etcd:https://[username]:[password]@[string].dblayer.com:[port]"
        ],
      "mgtiface": "bond0",
      “loggingurl”: “http://dummy:80“,
      "storage": {
        "devices": [
          "/dev/xvdb",
          "/dev/xvdc"
        ]
      }
    }
```

>**Important:**<br/>If you are using Compose.IO and the `kvdb` string ends with `[port]/v2/keys`, omit the `/v2/keys`. Before running the container, make sure you have saved off any data on the storage devices specified in the configuration.

Please also ensure "logginurl:" is specificed in config.json. It should either point to a valid lighthouse install endpoint or a dummy endpoint as shown above. This will enable all the stats to be published to monitoring frameworks like Prometheus

You can now start the Portworx container with the following run command:

```
# sudo docker run --restart=always --name px -d --net=host     \
                 --privileged=true                             \
                 -v /run/docker/plugins:/run/docker/plugins    \
                 -v /var/lib/osd:/var/lib/osd:shared           \
                 -v /dev:/dev                                  \
                 -v /etc/pwx:/etc/pwx                          \
                 -v /opt/pwx/bin:/export_bin                   \
                 -v /var/run/docker.sock:/var/run/docker.sock  \
                 -v /var/cores:/var/cores                      \
                 -v /usr/src:/usr/src                          \
                 -v /lib/modules:/lib/modules                  \
                portworx/px-dev
```

At this point, Portworx should be running on your system. To verify, run `docker ps`.

#### Authenticated `etcd` and `consul`
To use `etcd` with authentication and a cafile, use this in your `config.json`:

```json
"kvdb": [
   "etcd:https://<ip1>:<port>",
   "etcd:https://<ip2>:<port>"
 ],
 "cafile": "/etc/pwx/pwx-ca.crt",
 "certfile": "/etc/pwx/pwx-user-cert.crt",
 "certkey": "/etc/pwx/pwx-user-key.key",
```

To use `consul` with an acltoken, use this in your `config.json`:

```json
"kvdb": [
   "consul:http://<ip1>:<port>",
   "consul:http://<ip2>:<port>"
 ],
 "acltoken": "<token>",
```

Alternatively, you could specify and explicit username and password as follows:

```
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
