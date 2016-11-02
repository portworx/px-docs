---
layout: page
title: "Run PX with Docker User Namespaces"
keywords: portworx, install, configure, container, user, namespaces, namespace, security
sidebar: home_sidebar
---
To install and configure PX with Docker user namespaces enabled, use the command-line steps in this section.

### To run the Portworx container

You must enable the `--userns host` directive to Docker

```
# sudo docker run --restart=always --name px -d --net=host \
                 --privileged=true                             \
                 --userns=host                                 \
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
# sudo docker run --restart=always --name px -d --net=host \
                 --privileged=true                             \
                 --userns=host                                 \
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

Running **without config.json**:

```
# sudo docker run --restart=always --name px -d --net=host \
                 --privileged=true                             \
                 --userns=host                                 \
                 -v /run/docker/plugins:/run/docker/plugins    \
                 -v /var/lib/osd:/var/lib/osd:shared           \
                 -v /dev:/dev                                  \
                 -v /etc/pwx:/etc/pwx                          \
                 -v /opt/pwx/bin:/export_bin:shared            \
                 -v /var/run/docker.sock:/var/run/docker.sock  \
                 -v /var/cores:/var/cores                      \
                 -v /lib/modules:/lib/modules                  \
                 --ipc=host                                    \
                portworx/px-dev -daemon -k etcd://myetc.company.com:4001 -c MY_CLUSTER_ID -s /dev/nbd1 -s /dev/nbd2
```

Runtime command options:

```
--privileged
    > Sets PX to be a privileged container. Required to export block  device and for other functions.

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

-v /opt/pwx/bin:/export_bin:shared
    > Exports the PX command line (**pxctl**) tool from the container to the host.
```

### pxctl
After Portworx is running, you can create and delete storage volumes through the Docker volume commands or the **pxctl** command line tool, which is exported to /opt/pwx/bin/pxctl. With **pxctl**, you can also inspect volumes, the volume relationships with containers, and nodes.

To view all **pxctl** options, run:

```
# /opt/pwx/bin/pxctl help
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

You have now completed setup of Portworx on your first server. To increase capacity and enable high availability, repeat the same steps on each of the remaining two servers. Run **pxctl** status to view the cluster status. Then, to continue with examples of running stateful applications and databases with Docker and PX, see [Application Solutions](application-solutions.html).

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

After you set up etcd, you can use the same etcd service for multiple PX clusters.
