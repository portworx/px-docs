---
layout: page
title: "Convert x86 Servers to Storage-Capable Nodes"
keywords: portworx, px-developer, install, configure, container, storage, add nodes
sidebar: home_sidebar
---
To install and configure PX-Developer, use the command-line steps in this section. If you use PX-Enterprise, see [Get Started with PX-Enterprise](get-started-px-enterprise.html).

The example in this section uses Amazon Web Services (AWS) Elastic Compute Cloud (EC2) for servers in the cluster. In your deployment, you can use physical servers, another public cloud, or virtual machines.

After you complete this installation, continue with the set up to run stateful containers with Docker volumes:

* [Scale a Cassandra Database with PX-Developer](examples/cassandra.html)
* [Run the Docker Registry with High Availability](examples/registry.html)

>**Important:**<br/>The PX-Developer release requires you to launch or have a pre-existing key/value store, such as etcd or Consul. For more information, see the [etcd example](https://github.com/portworx/px-dev/blob/master/examples/etcd_in_container) for PX-Developer. PX-Enterprise does not have this requirement.

## Step 1: Launch servers

To start, create three servers, following these requirements:

* Image: Must support Docker 1.10 or later, such as:
  * [Red Hat 7.2 (HVM)](https://aws.amazon.com/marketplace/pp/B019NS7T5I) or CentOS
  * CoreOS (1010.6.0 or later)
  * [Ubuntu 14.04 (HVM)](https://aws.amazon.com/marketplace/pp/B00JV9TBA6/ref=mkt_wir_Ubuntu14)
* Instance type: c3.xlarge
* Number of instances: 3
* Storage:
  * /dev/xvda: 8 GB boot device
  * /dev/xvdb: 64 GB for container storage
  * /dev/xvdc: 64 GB for container storage
* Tag (optional): Add value **px-cluster1** as the name

Volumes used for container data can be of any type, such as HDD, SSD, or provisioned IOPs SSDs. On-premises, the underlying storage could also be from a SAN. Portworx applies different policies based on storage device capabilities.

## Step 2: Install and configure Docker

SSH into your first server and perform the general steps below.

1. Follow the Docker install guide to install and start the Docker Service.
2. Verify that your Docker version is 1.10 or later.
3. Configure Docker to use shared mounts.  
     The shared mounts configuration is required, because Portworx exports mount points. For examples, including RedHat/CentOS, CoreOS, and Ubuntu, see [OS Configuration for Shared Mounts](os-config-shared-mounts.html).

## Step 3: Specify storage

Portworx pools the storage devices on your server and creates a global capacity for containers. This example uses the two non-root storage devices (/dev/xvdb, /dev/xvdc) from Step 1 of this section.

>**Important:**<br/>Back up any data on storage devices that will be pooled. Storage devices will be reformatted!

### To view the storage devices on your server

Use this command line:

```
# lsblk
```

Example output:

Note that devices without the partition are shown under the **TYPE** column as **part**.

```
   $ lsblk
    NAME                      MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
    xvda                      202:0    0     8G  0 disk
    └─xvda1                   202:1    0     8G  0 part /
    xvdb                      202:16   0    64G  0 disk
    xvdc                      202:32   0    64G  0 disk
```

### To choose storage devices

Portworx lets you choose the storage devices that it will manage. For example, you might decide to have Portworx manage only a subset of your storage devices. With PX-Enterprise, you can choose storage devices through the PX-Enterprise web console.

With PX-Developer, use the following steps to specify in the config.json file which storage devices you want Portworx to manage. The config.json file in PX-Developer identifies the key/value store for the cluster.

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

    The format for the `kvdb` section is as follows:

```
    kvdb:[
      "etcd:[http/https]://[....]"
    ]
```

>**Important:**<br/>If you are using Compose.IO and the `kvdb` string ends with `[port]/v2/keys`, omit the `/v2/keys`. Before running the container, make sure you have saved off any data on the storage devices specified in the configuration.

## Step 4: Launch the PX-Developer Container

When you run Docker and the Portworx container, Portworx aggregates and manages your storage capacity. As you run the Portworx container on each server, new capacity is added to the cluster.

After Portworx is running, you can create and delete storage volumes through the Docker volume commands or the **pxctl** command line tool, which is exported to /opt/pwx/bin/pxctl. With **pxctl**, you can also inspect volumes, the volume relationships with containers, and nodes.

To view all **pxctl** options, run:

```
# /opt/pwx/bin/pxctl help
```

### To run the Portworx container

For **CentOS** or **Ubuntu**, start the Portworx container with the following run command:

```
# sudo docker run --restart=always --name px-dev -d --net=host \
                 --privileged=true                             \
                 -v /run/docker/plugins:/run/docker/plugins    \
                 -v /var/lib/osd:/var/lib/osd:shared           \
                 -v /dev:/dev                                  \
                 -v /etc/pwx:/etc/pwx                          \
                 -v /opt/pwx/bin:/export_bin:shared            \
                 -v /var/run/docker.sock:/var/run/docker.sock  \
                 -v /var/cores:/var/cores                      \
                 -v /usr/src:/usr/src                          \
                 --ipc=host                                    \
                portworx/px-dev
```

For **CoreOS**, start the Portworx container with the following run command:

```
# sudo docker run --restart=always --name px-dev -d --net=host \
                 --privileged=true                             \
                 -v /run/docker/plugins:/run/docker/plugins    \
                 -v /var/lib/osd:/var/lib/osd:shared           \
                 -v /dev:/dev                                  \
                 -v /etc/pwx:/etc/pwx                          \
                 -v /opt/pwx/bin:/export_bin:shared            \
                 -v /var/run/docker.sock:/var/run/docker.sock  \
                 -v /var/cores:/var/cores                      \
                 -v /lib/modules:/lib/modules                  \
                 --ipc=host                                    \
                portworx/px-dev
```

Runtime command options:

```
--privileged
    > Sets PX-Dev to be a privileged container. Required to export block  device and for other functions.

--net=host
    > Sets communication to be on the host IP address over ports 9001 -9003. Future versions will support separate IP addressing for PX-Dev.

--shm-size=384M
    > PX-Dev advertises support for asynchronous I/O. It uses shared memory to sync across process restarts

-v /run/docker/plugins
    > Specifies that the volume driver interface is enabled.

-v /dev
    > Specifies which host drives PX-Dev can see. Note that PX-Dev only uses drives specified in config.json. This volume flage is an alternate to --device=\[\].

-v /etc/pwx/config.json:/etc/pwx/config.json
    > the configuration file location.

-v /var/run/docker.sock
    > Used by Docker to export volume container mappings.

-v /var/lib/osd:/var/lib/osd:shared
    > Location of the exported container mounts. This must be a shared mount.

-v /opt/pwx/bin:/export_bin:shared
    > Exports the PX command line (**pxctl**) tool from the container to the host.
```

### To view global storage capacity

At this point, Portworx should be running on your system. To verify, run `Docker ps`.

To view the global storage capacity, run:

```
# sudo /opt/pwx/bin/pxctl status
```

The following sample output of `pxctl status` shows that the global capacity for Docker containers is 128 GB.

```
   # /opt/pwx/bin/pxctl status
    Status: PX is operational
    Node ID: 99510ef0-fb89-46b7-a1cc-9468c6354a69
       	IP: 172.31.48.62
       	Local Storage Pool: 1 device
       	Device 	Path   		Media Type     		Size   		Last-Scan
       	1      	/dev/xvdf      	STORAGE_MEDIUM_SSD     	128 GiB 		19 Aug 16 17:24 UTC
       	total  			-      			64 GiB
    Cluster Summary
       	Cluster ID: HARI-DEV-MACHINE2
       	Node IP: 172.31.48.62 - Capacity: 18 MiB/64 GiB Online (This node)
    Global Storage Pool
       	Total Used     	:  18 MiB
       	Total Capacity 	:  128 GiB
```

For more on using **pxctl**, see the [CLI Reference](cli-reference.html).

You have now completed setup of Portworx on your first server. To increase capacity and enable high availability, repeat the same steps on each of the remaining two servers. Run **pxctl** status to view the cluster status. Then, to continue with examples of running stateful applications and databases with Docker and PX-Developer, see [Application Solutions](application-solutions.html).

### To add nodes

To add nodes to increase capacity and enable high availability, complete the JSON configuration on each server:

* If you have the same storage device configuration on every node, copy the config.json you created earlier to all the nodes.
* If you have different storage device configurations on the nodes, make sure to use the same `clusterid` and `kvdb` on all the nodes.
* Then, continue with the [CLI Reference](cli-reference.html) or the [Application Solutions](application-solutions.html).

### To provision a key/value store

You can use an existing etcd service or set up your own. This example uses Compose.IO, for its ease of use.

1. Create a new etcd deployment in Compose.IO.
2. Select 256 MB RAM as the memory.
3. Save the connection string, including your username and password. For example:

 https://[username]:[password]@[string].dblayer.com:[port]

 >**Important:**<br/>If you are using Compose.IO and the `kvdb` string ends with `[port]/v2/keys`, omit the `/v2/keys`. Before running the container, make sure you have saved off any data on the storage devices specified in the configuration.

After you set up etcd, you can use the same etcd service for multiple PX-Developer clusters.
