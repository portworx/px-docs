---
layout: page
title: "Using Portworx volumes with DCOS"
keywords: portworx, container, Mesos, Mesosphere, DCOS, Cassandra
meta-description: "Learn how Portworx volumes are created, instantiated, and managed by DCOS.  Try Portworx on DC/OS today!"
redirect_from:
  - /run-px-etcd-marathon.html
  - /scheduler/mesosphere-dcos/portworx_volumes.html
---

* TOC
{:toc}

## Using Portworx volumes with DCOS

Portworx volumes are created, instantiated, and [managed by DCOS](http://mesos.apache.org/documentation/latest/isolators/docker-volume/). Portworx volumes can be used with both Docker containers and Mesos/UCR container.

When using Docker containers, volumes are provisioned and mounted using Docker and it's volume drivers directly.

When using Mesos/UCR containers DCOS uses [dvdcli]( https://github.com/codedellemc/dvdcli) to provision and mount volumes.
dvdcli talks to Portworx using the docker plugin API, see here to understand Portworx implementation of the 
[API](/scheduler/docker/volume-plugin.html)

### Marathon framework

#### Docker containers
Here's how you would specify Portworx as a volume driver in a task begin launched via Marathon as Docker container. This would mount the Portworx volume under /data
```
{
  ...
  "container": {
    "type": "DOCKER",
    "docker": {
     ...
      "parameters": [
        {
          "key": "volume-driver",
          "value": "pxd"
        },
        {
          "key": "volume",
          "value": "repl=3,size=500,name=px_vol:/data"
        }
      ]
    ],
    ...
  }
}
```

You can also speciy additional driver options for the volume as key=value pairs in the parameters. For example to create a
volume with replication factor 3:

```
{
  ...
  "container": {
    "type": "DOCKER",
    "docker": {
     ...
      "parameters": [
        {
          "key": "volume-driver",
          "value": "pxd"
        },
        {
          "key": "volume",
          "value": "repl=3,size=500,name=px_vol:/data"
        }
      ]
    ],
    ...
  }
}
```



#### Mesos/UCR containers

Here's how you would specify Portworx as a volume driver in a task begin launched via Marathon as Mesos/UCR container. This would mount the Portworx volume under /data
```
{
  ...
  "cmd" : ...,
  "container" : {
    "type": "MESOS",
    "volumes": [
      {
        "containerPath": "/data",
        "mode": "RW",
        "external": {
          "size": 500,
          "name": "px_vol",
          "provider": "dvdi",
          "options": {
            "dvdi/driver": "pxd"
          }
        }
      }
    ],
    ...
  }
}
```

You can also speciy additional driver options for the volume as key:value pairs. For example to create a volume with
replication factor 3:

```
{
  ...
  "cmd" : ...,
  "container" : {
    "type": "MESOS",
    "volumes": [
      {
        "containerPath": "/data",
        "mode": "RW",
        "external": {
          "size": 500,
          "name": "px_vol",
          "provider": "dvdi",
          "options": {
            "dvdi/repl": "3",
            "dvdi/driver": "pxd"
          }
        }
      }
    ],
    ...
  }
}
```

#### Provisioning Volumes

If the volume `px_vol` does not already exist, a new volume with default parameters will be created. The volume will be
mounted under `/data` in the container Heres's how you can specify inline paramters for volume creation:
See this [link](https://github.com/portworx/px-docs/blob/gh-pages/scheduler/mesosphere-dcos/inline.md) for more information


### Custom Frameworks:
DCOS-Commons frameworks is a collection of tools and APIs that allows defining stateful applications like Cassandra and HDFS
using YAML. Each task in these services is launched as a POD on the agent nodes after resource negotiation. These tasks that 
make up a service can either be statefull or stateless.

If Persistence is required in any of the stateful tasks they need to provide a volume specification that should be used by
the pods. In the upstread dcos-commons framework, these volumes can be of two types: MOUNT and ROOT. These types of disks
are explained [here](http://mesos.apache.org/documentation/latest/multiple-disk)

Since both these types of disks use local storage, in case an agent running a statful task dies or
is restarted it can not be bought up on another agent node.

#### External volumes with custom framework
In order to support External volumes, we have updated the framework to specify PX volumes when starting these applications.
This is done by adding docker volumes using the spec described above to the executor from the service scheduler. Since
these volumes are considered external, there is no persitent reservation required for them

#### Portworx dcos-commons fork

Portworx [fork to dcos-commons](https://github.com/portworx/dcos-commons) allows use of DOCKER volumes in pods.
The following config values that can be specified in the yaml file for pods:
  - docker_volume_driver: Docker driver to be used to mount volumes
  - docker_volume_name: Name of the volume to be used
  - docker_driver_options: Command separated key=value options to be passed to the docker driver (eg "repl=2,shared=true")

### Failovers
With the addition of External volumes, stateful tasks can now failover to any other agent which has enough resources
available.

In the upstream version of the framework, all resources that were reserved for a task were expected to be "permanent" for
that task. So if a failed task was being re-launched it would expect the same resource IDs as the task that just failed
(even for memory and CPU). This did not allow even stateless tasks to fail over to other agents. We have modified the
framework to allow resource reservation such as memory and CPU to not be "permanent", and since PX volumes are not
considered a persistent resource, all statefull tasks can also failover between agents.

When a PX volume is specified to be used in a task, it is added to the ContainerInfo for that task. When this task is
executed on the agent that is chosen, DVDI is used by mesos to attach and mount the PX volume in the path specified. 
When the task is killed, the mesos executor unmounts and detaches the PX volume using DVDI, so they are available to be
mounted on other agent nodes if the service scheduler decides to move the task (eg when constraints are applied to tasks).

An agent running a stateful task can also be killed with the PX volumes mounted. In this case the scheduler will try to 
launch the task on another agent, since there are no local persistent resources for that task. Since the dead agent would
also be marked offline in PX, when this task is launched on another node it would be able to successfully attach and mount
the same PX volume. On the attach on the new node, PX would reconcile data between all the replicas to ensure data
integrity between the replicas.

Note: This would require the PX volumes to created with a replication factor > 1
