---
layout: page
title: "Cassandra as Marathon Service"
keywords: portworx, container, Mesos, Mesosphere, DCOS, Cassandra, marathon
meta-description: "For help installing and running Cassandra on DCOS as Marathon service, use the guide from Portworx! Achieve more with Portworx backing your cluster."
---

* TOC
{:toc}

DC/OS provides a Cassandra service that makes it easy to deploy and manage [Cassandra on Mesosphere DC/OS](/scheduler/mesosphere-dcos/cassandra.html). If you want to deploy your own Marathon service for Cassandra with Portworx, you can follow this guide.

>**Note:**<br/>This is a sample setup. You will have to tweak it for advanced Cassandra configurations.

Please make sure you have installed [Portworx on DC/OS](/scheduler/mesosphere-dcos/install.html) before proceeding further. To run Cassandra in Marathon, we will have to divide it in two different services - one for the seed node and the other for the remaining Cassandra cluster.

## Cassandra seed node
Let's deploy a service called `cassandra-seed` using the service config below. Notice in the docker parameters, we are specifying a Portworx volume `CassandraSeed` with size `20GiB`.
```json
{
    "id": "cassandra-seed",
    "instances": 1,
    "cpus": 1,
    "mem": 4096,
    "env": {
        "CASSANDRA_CLUSTER_NAME": "DemoCluster",
        "CASSANDRA_SEEDS": "cassandra-seed.marathon.mesos"
    },
    "container": {
        "type": "DOCKER",
        "docker": {
            "image": "cassandra:3.11.2",
            "parameters": [
                {
                    "key": "volume-driver",
                    "value": "pxd"
                },
                {
                    "key": "volume",
                    "value": "size=20,name=CassandraSeed:/var/lib/cassandra"
                }
            ],
            "portMappings": [
                {
                    "containerPort": 7000,
                    "hostPort": 0,
                    "name": "storage",
                    "protocol": "tcp"
                },
                {
                    "containerPort": 7001,
                    "hostPort": 0,
                    "name": "ssl",
                    "protocol": "tcp"
                },
                {
                    "containerPort": 7199,
                    "hostPort": 0,
                    "name": "jmx",
                    "protocol": "tcp"
                },
                {
                    "containerPort": 9042,
                    "hostPort": 0,
                    "name": "native-client",
                    "protocol": "tcp"
                },
                {
                    "containerPort": 9160,
                    "hostPort": 0,
                    "name": "thrift-client",
                    "protocol": "tcp"
                }
            ]
        }
    }
}
```

## Cassandra nodes
Once you have the Cassandra seed node running, you can deploy the rest of the Cassandra nodes in the cluster. Assuming we are deploying a 3 node Cassandra cluster, let's deploy the second service with 2 instances, which will constitute the rest of the cluster. In this service, we will use Portworx scale volumes with `scale=2` in volume parameters. Scale volumes will create volumes on demand up to the given scale, with the given name and a numerical suffix.
```json
{
    "id": "cassandra",
    "instances": 2,
    "cpus": 1,
    "mem": 4096,
    "env": {
        "CASSANDRA_CLUSTER_NAME": "DemoCluster",
        "CASSANDRA_SEEDS": "cassandra-seed.marathon.mesos"
    },
    "container": {
        "type": "DOCKER",
        "docker": {
            "image": "cassandra:3.11.2",
            "parameters": [
                {
                    "key": "volume-driver",
                    "value": "pxd"
                },
                {
                    "key": "volume",
                    "value": "size=20,scale=2,name=CassandraNode:/var/lib/cassandra"
                }
            ],
            "portMappings": [
                {
                    "containerPort": 7000,
                    "hostPort": 0,
                    "name": "storage",
                    "protocol": "tcp"
                },
                {
                    "containerPort": 7001,
                    "hostPort": 0,
                    "name": "ssl",
                    "protocol": "tcp"
                },
                {
                    "containerPort": 7199,
                    "hostPort": 0,
                    "name": "jmx",
                    "protocol": "tcp"
                },
                {
                    "containerPort": 9042,
                    "hostPort": 0,
                    "name": "native-client",
                    "protocol": "tcp"
                },
                {
                    "containerPort": 9160,
                    "hostPort": 0,
                    "name": "thrift-client",
                    "protocol": "tcp"
                }
            ]
        }
    }
}
```

## Verify installation
You can see the Portworx volumes being dynamically created as the service starts:
```bash
$ /opt/pwx/bin/pxctl volume list
ID                      NAME                    SIZE    HA      SHARED  ENCRYPTED       COMPRESSED      IO_PRIORITY     SCALE   STATUS        HA-STATE
988666862549536606      CassandraNode           20 GiB  1       no      no              no              LOW             2       up - attached on 192.168.65.111        Up
704404558737513328      CassandraNode_001       20 GiB  1       no      no              no              LOW             1       up - attached on 192.168.65.121        Up
811306021938813972      CassandraSeed           20 GiB  1       no      no              no              LOW             0       up - attached on 192.168.65.131        Up
```

You can use `nodetool` to check the status of the Cassandra cluster:
```bash
$ nodetool status -p 7199
Datacenter: datacenter1
=======================
Status=Up/Down
|/ State=Normal/Leaving/Joining/Moving
--  Address         Load       Tokens       Owns (effective)  Host ID                               Rack
UN  192.168.65.121  264.38 KiB  256          64.8%             7d3fa3b1-0494-4a53-a715-5eb20e8f2e87  rack1
UN  192.168.65.131  241.46 KiB  256          66.5%             edd69665-0262-4677-979d-e48cf355e963  rack1
UN  192.168.65.111  243.24 KiB  256          68.8%             ea0fe102-867b-4fd9-b875-167f90c056b2  rack1
```

## Scale Cassandra cluster
You can scale the Cassandra cluster by increasing the instance count of the `cassandra` service. Before you do that you need to update the Portworx volume to scale first. You can update the scale of a Portworx volume using Portworx CLI:
```bash
$ /opt/pwx/bin/pxctl volume update --scale=3 CassandraNode
```