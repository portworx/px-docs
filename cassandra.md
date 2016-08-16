---
layout: page
title: "Scale a Cassandra Database with PX-Developer"
sidebar: home_sidebar
---
# Scale a Cassandra Database with PX-Developer

Apache Cassandra is an open source distributed database management system designed to handle large amounts of data across commodity servers. Setting up a Cassandra cluster with Portworx storage takes only a few commands.

The following example scenario creates a three-node Cassandra cluster. The example has three servers:

* 10.0.0.1 is created in Step 1 and is the seed for Cassandra
* 10.0.0.2 is created in Step 3a
* 10.0.0.3 is created in Step 3b

When creating these servers in a public cloud, such as AWS, you can specify the each instance's private IP address in place of the 10.0.0.[1-3].

## Step 1: Create storage volumes for each instance
To create storage volumes for each instance, run the following command on each server. Note that `size=4` specifies 4 GB.

```
docker volume create -d pxd --opt name=cassandra_volume --opt \
    size=4 --opt block_size=64 --opt repl=1 --opt fs=ext4
```

The output of the command is the volume identifier, referred to as `DOCKER_CREATE_VOLUME_ID` in the command-line examples in the Portworx documentation. To later retrieve the volume identifier, run `docker volume ls`.

## Step 2: Start the Cassandra Docker image on node 1

Use the Docker `-v` option to assign the volume created with `docker volume create`.

* To retrieve the `DOCKER_CREATE_VOLUME_ID` passed into the `-v` option, run `docker volume ls`.
* Be sure to substitute your IP address for the 10.0.0.1 placeholder in the `CASSANDRA_BROADCAST_ADDRESS` parameter.

>**Important:**<br/>If you are running an OS with SELinux enabled, a workaround to issue [20834](https://github.com/docker/docker/pull/20834) is to pass the [`security-opt`](https://github.com/portworx/px-dev/blob/master/faq.md) parameter between `run` and `--name`.

```
docker run --name cassandra1 -d \
    -p 7000:7000 -p 7001:7001 -p 9042:9042 -p 9160:9160 \
    -e CASSANDRA_BROADCAST_ADDRESS=10.0.0.1 \
    -v [DOCKER_CREATE_VOLUME_ID]:/var/lib/cassandra cassandra:latest
```

## Step 3: Start Docker on the other nodes

To create a new volume for the Cassandra instance on the other nodes, run `docker volume create` on each node, as shown in Step 1. Then, the only difference from the previous `docker run` command is the addition of the `-e CASSANDRA_SEEDS=10.0.0.1` parameter. This is a pointer to the IP address of the first Cassandra node.  

Be sure to change the IP addresses in the following examples to the ones used by your instances.

### `docker run` command for Cassandra node 2
 ```
    docker run --name cassandra2 -d \
    -p 7000:7000 -p 7001:7001 -p 9042:9042 -p 9160:9160 \
    -e CASSANDRA_BROADCAST_ADDRESS=10.0.0.2 \
    -e CASSANDRA_SEEDS=10.0.0.1 \
    -v [DOCKER_CREATE_VOLUME_ID]:/var/lib/cassandra cassandra:latest
```

### `docker run` command for Cassandra node 3

```
    docker run --name cassandra3 -d \
    -p 7000:7000 -p 7001:7001 -p 9042:9042 -p 9160:9160 \
    -e CASSANDRA_BROADCAST_ADDRESS=10.0.0.3 \
    -e CASSANDRA_SEEDS=10.0.0.1 \
    -v [DOCKER_CREATE_VOLUME_ID]:/var/lib/cassandra cassandra:latest
```

It can take up to 30 seconds for Cassandra to start up on each node. To determine when your cluster is ready for use, view the logs. You should see messages that each node is part of the cluster.
