---
layout: page
title: "Docker interraction with Portworx"
keywords: portworx, container, Mesos, Mesosphere, DCOS, Cassandra
---

* TOC
{:toc}

## Docker interraction with Portworx

Portworx implements the Docker Volume Plugin Specificaton (https://docs.docker.com/engine/extend/plugins_volume/).

The plugin API allows creation, instantiation, and lifecycle management of Portworx volumes. This allows direct use by Docker, Docker swarm, and DCOS via
dvdcli (https://github.com/codedellemc/dvdcli).

###  Discovery

Docker scans the plugin directory (/run/docker/plugins) on startup and whenever a user or a container requests a plugin by name.
When the Portworx container is run, a unix domain socket `pxd.sock` is exported under /var/run/docker/plugins directory.  Portworx volumes are shown as owned by volume driver `pxd`.

### Create

See https://docs.docker.com/engine/reference/commandline/volume_create/

Portworx volume are created by specifying volume driver as `pxd`.

Here is an example of how to create a 10GB volume with replication factor set to 3

```
docker volume create --driver pxd \
           --opt size=10G \
           --opt repl = 3 \
           --name my_portworx_vol

```

Docker looks in its cache before sending the create request to Portworx.  For this reason, we recommend to not mix-and-match create and delete operations with pxctl and docker.  If a volume with the same name is created again, it is a No-op.

#### Use of options in docker volume create

```
Options:
    --opt shared                        make this a globally shared namespace volume
    --opt secure                        encrypt this volume using AES-256
    --opt secret_key=value              secret_key to use to fetch secret_data for the PBKDF2 function
    --opt size=value                    volume size in GB (default: 1)
    --opt fs=value                      filesystem to be laid out: none|xfs|ext4 (default: "ext4")
    --opt block_size=value              block size in Kbytes (default: 32)
    --opt repl=value                    replication factor [1..3] (default: 1)
    --opt scale=value                   auto scale to max number [1..1024] (default: 1)
    --opt io_priority=value             IO Priority: [high|medium|low] (default: "low")
    --opt sticky                        sticky volumes cannot be deleted until the flag is disabled [on | off]
    --opt snap_interval=value           snapshot interval in minutes, 0 disables snaps (default: 0)
    --opt aggregation_level=value       aggregation level: [1..3 or auto] (default: "1")
    --opt nodes=value                   comma-separated Node Id(s)

```
#### Snapshot

There is no explicit Snapshot operation via Docker plugin API. However, this can be achieved via the create operation. Specifying a `parent` operation will create a snapshot.

The following command creates the volume `snap_of_my_portworx_vol` by taking a snapshot of `my_portworx_vol`

```
docker volume create --driver pxd \
           --opt parent=my_portworx_vol  \
           --name snap_of_my_portworx_vol
```

Snapshots can then be used as a regular Portworx volume.

### Mount

Mount operation mounts the Portworx volume in the propagated mount location. If the device is un-attached, `Mount` will implicitly perform an attach as well. Mounts are reference counted and are idempotent. The same volume can be mounted at muliple locations on the same node. The same device can be mounted at the same location multiple times.

#### Attach

The docker plugin API does not have an Attach call. The Attach call is called internally via Mount on the first mount call for the volume.

Portworx exports virtual block devices in the host namespace. This is done via the Portworx Container running on the system and does *not* rely on an external protocol such as iSCSI or NBD. Portworx virtual block devices only exist in host kernel memory. Two interesting consequences of this architecture is
1) volumes can be unmounted from dead/disconnected nodes
2) IOs on porworx can survive a Portworx restart.

Portworx volume can be attached to any participating node in the cluster, although it can be attached to only one node at any given point in time. The node where the Portworx volume is attached is deemed the transaction coordinator and all I/O access to the volume is arbitrated by that node.

Attach is idempotent - multiple attach calls of a volume on the same node will return success. Attach on a node will return a failure, if the device is attached on a different node. Port

The following command will instantiate a virtual block device in the host namespace and mount it under propagated mount location. The mounted volume  is then bind mounted under /data in the busybox container.

```
docker run -it -v my_portworx_vol:/data busybox c
```

Running it again will create a second instance of busybox, another bind mount and the Portworx volume reference count will be at 2. Both containers need to exit for the Portworx volume to be unmounted (and detached).

### Unmount

Umount operation unmounts the Portworx volume from the propagated mount location. If this is the last surviving mount on a volume, then the volume is detached as well. Once succesfully unmounted the volume can be mounted on any other node in the system.

#### Detach

The docker plugin API does not have an Detach call. The Detach call is called internally via Unmount on the last unmount call for the volume.

Detach operation involves unexporting the virtual block device from the host namespace. Similar to attach, this is again accomplished via the Portworx container and does not require any external protocol. Detach is idempotent, multiple calls to detach on the same device will return success.  Detach is not allowed if the device is mounted on the system.


### Remove

Remove will delete the underlying Portworx volume and all associated data. The operation will fail if the volume is mounted.

The following command will remove the volume `my_portworx_vol`

```
docker volume rm my_portworx_vol
```

### Capabilities
The portworx volume driver identifies itself as a `global` driver.  Portworx operations can be executed on any node in the cluster. Portworx volumes can be used and managed from any node in the cluster.
