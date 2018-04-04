---
layout: page
title: "Specifying Portworx Constraints in your Application"
keywords: portworx, PX-Developer, container, Mesos, Mesosphere, constraints
sidebar: home_sidebar
redirect_from:
  - /scheduler/mesosphere-dcos/px_with_constraints.html
meta-description: "Learn how to use constraints on your DCOS cluster to control where Mesos schedules your stateful applications. Read our guide today!"
---

Whenever possible, Portworx should be deployed on all nodes within a Mesos/Mesosphere/DCOS cluster.
Portworx clusters can scale up to 1000 nodes. Portworx clusters can also include nodes that contribute no storage, 
but operate as "head-only" nodes to facilitate [auto-scaling groups](/cloud/aws/asg.html).

However, when Portworx cannot be installed on all nodes, Mesos 'constraints' should be used
to ensure that services depending on Portworx will only get scheduled on nodes
that are part of a Portworx cluster.

## Install DCOS CLI or Apache Mesos
For Mesosphere, follow the instructions for installing [Mesosphere DCOS](https://dcos.io/install) and the [DCOS CLI](https://docs.mesosphere.com/1.7/usage/cli/install).
Use the DCOS CLI command `dcos node` to identify which nodes in the Mesos cluster are the Agent nodes.

If not using Mesosphere, then follow the instructions appropriate for your OS distribution and environment to install both Apache Mesos and Marathon. 

## Add constraints on slave nodes
If the size of your Mesos cluster is larger than the maximum number of nodes supported for a Portworx release,
or if it is not possible to install Portworx on all nodes in the Mesos cluster,
then you will need to use Mesos "constraints", in order to restrict/constrain jobs that use Portworx volumes to only run
on Mesos-slave nodes where Portworx is running.   (Please check the Portworx release notes for maximum Portworx cluster size).
Otherwise, Portworx recommends simply deploying Portworx on all nodes in a Mesos cluster, thereby avoiding the need to use "constraints".

The following steps are required only for configuring and using "constraints".

For each Mesosphere Agent node or Mesos-slave that is participating in the PX cluster, 
specify Mesos attributes that allow for affinity of tasks to nodes that are part of the Portworx cluster.

If using Mesosphere/DCOS:

```
# echo MESOS_ATTRIBUTES=pxfabric:pxclust1 >> /var/lib/dcos/mesos-slave-common
# rm -f /var/lib/mesos/slave/meta/slaves/latest
# systemctl restart dcos-mesos-slave.service
# systemctl status dcos-mesos-slave.service -l
```

If using Apache Mesos:

```
# mkdir -p /etc/default/mesos-slave/attributes
# echo pxclust1 > /etc/default/mesos-slave/attributes/pxfabric
# rm -f /var/lib/mesos/slave/meta/slaves/latest
# systemctl restart mesos-slave
# systemctl status mesos-slave -l
```

Please note that restarting a dcos/mesos-slave to change the MESOS_ATTRIBUTES will cause the node to register under a new UUID.

## Deploy Portworx with 'constraints'
When deploying the Portworx framework you would then add the following constraint to node.placement_constraint
```
pxfabric:LIKE:pxclust1
```

This should be used in addition to the "hostname:UNIQUE" constraint.

## Consume Portworx with constraints
The following example shows how to use constraints for running `mysql` only on nodes where Portworx is installed.

```json
{
    "id": "mysql",
    "cpus": 0.5,
    "mem": 256,
    "instances": 1,
    "container": {
        "type": "DOCKER",
        "docker": {
            "image": "mysql:5.6.27",
            "parameters": [
                    {
                       "key": "volume-driver",
                       "value": "pxd"
                    },
                    {
                       "key": "volume",
                       "value": "mysql_vol:/var/lib/mysql"
                    }],
            "network": "BRIDGE",
              "portMappings": [
                {
                  "containerPort": 3306,
                  "hostPort": 32000,
                  "protocol": "tcp"
                }
                ]
        }
    },
    "constraints": [
            [
              "pxfabric",
              "LIKE",
              "pxclust1"
            ]],
    "env": {
        "MYSQL_ROOT_PASSWORD": "password"
    },
      "minimumHealthCapacity" :0,
      "maximumOverCapacity" : 0.0
}
```
[Download example](/scheduler/mesosphere-dcos/px-marathon-mysql-constraints.json?raw=true)


