---
layout: page
title: "A Production Ops Guide to Deploying Cassandra"
keywords: portworx, px-developer, cassandra, database, cluster, storage
sidebar: home_sidebar
redirect_from: "/cassandra.html"
---

* TOC
{:toc}

## Introduction
[Apache Cassandra](http://cassandra.apache.org/), first developed at Facebook, is an open source distributed database management system designed to handle large amounts of data across commodity servers.

Cassandra has built-in data replication and so is resilient against host failure. Because data replication can also be provided at the storage level by Portworx, a typical question is: [should I ensure high-availability of my database through Cassandra itself, through my storage, or a combination of the two](https://portworx.com/use-case/cassandra-docker-container/)? This Production Operations Guide to Running Cassandra is aimed at helping answer this question by showing how to use Cassandra replication alongside Portworx to speed up recovery times, increase density and simplify operations.

## Background on Cassandra replication
Cassandra is designed for bare-metal deployments with a Cassandra instance tied to a physical server.  This architecture creates a problem when deploying multiple containerized instances of Cassandra via your scheduling software like Kubernetes, Mesos or Docker Swarm since Cassandra containers can be scheduled on hosts that do not have the appropriate data.  We will see how to solve this below, but it is first important to understand how Cassandra's replication works.

Cassandra has two strategies for placing replicas so that it can ensure HA:

`SimpleStrategy`:
SimpleStrategy places the first replica in a ring on a node as determined by the partitioner.  The *partitioner* is a piece of software that determines how to distribute data across multiple nodes. A *ring* is a visual metaphor for multiple Cassandra instances that make up single cluster. Additional replicas are placed on the next nodes in the ring moving clockwise without considering topology, such as rack or datacenter location of individual nodes.

`NetworkTopologyStrategy`:
NetworkTopologyStrategy places replicas in the same datacenter by walking the ring clockwise until reaching the first node in another rack.  NetworkTopologyStrategy attempts to place replicas on distinct racks because nodes in the same rack (or similar physical grouping) often fail at the same time due to power, cooling, or network issues.

The first thing to note is that the SimpleStrategy does not offer reasonable (datacenter-aware) HA guarantees.  So the most common deployment strategy for Cassandra has typically been the NetworkTopologyStrategy.  But NetworkTopologyStrategy was intended for bare-metal deployments, where Cassandra is pinned to a set of physical nodes.  Correspondingly, NetworkTopologyStrategy is hard to implement when deploying multiple Cassandra container instances via a scheduler like Kubernetes or Marathon.

## Advantages of Cassandra with Portworx

The benefits of running Cassandra with Portworx are:

1. *Faster recovery times during a failure.*  
The ability for a block-replicated solution like Portworx to recover from a failure of a node is much faster than deferring to an application like Cassandra to do its own recovery.  This in turn will allow your end users and applications to have a much higher level of application availability (measured by 9's).

2. *Higher density.*  
Achieve higher density by running multiple Cassandra instances from different rings on the same nodes.  This way, you are not allocating a whole node to just one Cassandra instance.

3. *Simplified deployments.*  
Allow your users to deploy Cassandra using the SimpleStrategy while achieving the resiliency of the NetworkTopologyStrategy.  Your end users deploying containerized applications typically do not know the network topology of the data center but Portworx does and can automate the placement of nodes in the ring.

We will look at how to achieve each of these benefits in more detail below.  First, let's look at how Portworx places data.

### Portworx Data Placement Strategies
Portworx is able to ensure performance of a Cassandra cluster due to two key architectural concepts: hyperconvergence and fault domains.

* Hyperconvergence  
Cassandra runs best when the instance and its data are on the same host.  This is called hyperconvergence.  Portworx runs hyperconverged by keeping a Cassandra instance's data local to where the Cassandra instance is deployed, ensuring the best performance possible. Portworx accomplishes this by placing scheduler constraints, such that the scheduler will deploy the Cassandra instance on a node that holds the instance's data.

* Fault domains  
When deploying a Cassandra ring, Portworx will automatically place each instance's data on nodes such that they are separated by racks (fault domains).  This ensures that the data placement automatically achieves the `NetworkTopologyStrategy` without end user configuration.  This feature becomes important when your end users deploy Cassandra clusters themselves without knowledge of the data center topology.

With a general understanding of data placement, let's look at how to achieve the fast recovery times, higher density and simplified deployments outlined above.

### Achieving Faster Recovery Times
When deciding how many replicas to configure in each data center, the two primary considerations are:

1. Can I satisfy reads locally, without incurring cross-datacenter latency?
2. Can I support a variety of failure scenarios?

The two most common ways to configure multi-datacenter clusters are:

#### Two replicas in each datacenter

This configuration uses only Cassandra replication and tolerates the failure of a single node per replication group, while still allowing local reads at a consistency level of ONE.  In this mode, we recommend setting the Portworx volume replication to a factor of 1, which means that Portworx will not replicate the volume.  However, you should still use Portworx, because it will guarantee that the data is placed locally to the node on which the Cassandra instance is deployed by influencing the scheduling decision.  Furthermore, Portworx will place the data associated with different instances of a cluster on nodes that satisfy the NetworkTopologyStrategy automatically, alllowing you to get the benefits of the NetworkTopologyStrategy with the ease of the SimpleStrategy.

#### Three replicas in each datacenter

This confirguation uses both Cassandra replication and Portworx replication together and tolerates either the failure of a one node per replication group at a strong consistency level of LOCAL_QUORUM or multiple node failures per datacenter using consistency level ONE.
Asymmetrical replication groupings are also possible. For example, you can have three replicas in one data center to serve real-time application requests and use a single replica elsewhere for running analytics.

When three replicas are required, Portworx recommends using a Portworx replication factor of 2.  This means that for any volume, Cassandra will replicate it once (as in the Two replica example above), and Portworx will also replicate the volume once.  This allows you to achieve **faster recovery times** on instance or node failures with a space utilization overhead of only 30%.  The secondary Portworx-replicated copies are also placed on nodes such that it meets the NetworkTopologyStrategy constraints.  That is, the data replicated by Portworx itself is on a node in a different rack.

### Achieving Higher Density
A Portworx volume is mounted at `/var/lib/cassandra` in a Cassandra instance.  This volume and its namespace is isolated from other Dockerized Cassandra instances running on the same host.  By leveraging such volume isolation, you can run multiple Cassandra instances (that are part of different clusters) on the same node.

By running multiple Cassandra instances of different rings on the same node, you can achieve higher server and storage utilization.  Portworx pools the local storage drives into one large RAID group.  Each Cassandra volume's data will utilize all spindles on a node.  That is, subsets of a server's drives are not statically allocated to each instance.  Instead, the entire RAID group is made available to each instance running on that server.  This ensure maximum (and fair) bandwidth and IOPS to each Cassandra instance.

While placing replicas, Portworx will make sure that no two Cassandra instances of the same cluster end up on the same server.

### Simplified Deployment via Schedulers
Portworx abstracts the datacenter topology and underlying drives from the infrastructure software deploying the Cassandra clusters.  This in turn lets your end users deploy Cassandra clusters without having to worry about what topology strategy should be used, or how the drives need to be allocated to the various instances of Cassandra.  In effect, there is no static allocation of physical resources to the Cassandra clusters, allowing for programmatic and automated deployments.

## Deploying Cassandra with Portworx
Setting up a Cassandra cluster with Portworx storage takes only a few commands.  The following example scenario creates a three-node Cassandra cluster with Portworx by manually starting Cassandra on each node with Docker.


>**Note:**<br/>The example described here below is typically accomplished by launching all instances of Cassandra in a cluster via a scheduler like Kubernetes of Mesosphere. Manual scheduling is shown simply for clarity.

* 10.0.0.1 is created in Step 1 and is the seed for Cassandra
* 10.0.0.2 is created in Step 3a
* 10.0.0.3 is created in Step 3b

When creating these servers in a public cloud, such as AWS, you can specify each instance's private IP address in place of the 10.0.0.[1-3].

Step 1: Create storage volumes for each instance
To create storage volumes for each instance, run the following command on each server.  Note that `size=4` specifies 4 GB.

>**Note:**<br/>Chose a Portworx replication factor based on the strategies listed above.


     # docker volume create -d pxd --name cassandra_volume --opt \
     size=4 --opt block_size=64 --opt repl=2 --opt fs=ext4


Step 2: Start the Cassandra Docker image on node 1

Use the Docker `-v` option to assign the volume created with `docker volume create`.

* Be sure to substitute your IP address for the 10.0.0.1 placeholder in the `CASSANDRA_BROADCAST_ADDRESS` parameter.

>**Important:**<br/>If you are running an OS with SELinux enabled, a workaround to issue [20834](https://github.com/docker/docker/pull/20834) is to pass the [`security-opt`](/knowledgebase/troubleshooting.html) parameter between `run` and `--name`.


      # docker run --name cassandra1 -d \
      -p 7000:7000 -p 7001:7001 -p 9042:9042 -p 9160:9160 \
      -e CASSANDRA_BROADCAST_ADDRESS=10.0.0.1 \
      -v cassandra_volume:/var/lib/cassandra cassandra:latest


Step 3: Start Cassandra on the other nodes

To create a new volume for the Cassandra instance on the other nodes, run `docker volume create` on each node, as shown in Step 1. Then, the only difference from the previous `docker run` command is the addition of the `-e CASSANDRA_SEEDS=10.0.0.1` parameter. This is a pointer to the IP address of the first Cassandra node.  

Be sure to change the IP addresses in the following examples to the ones used by your instances.

Start Cassandra on node 2

      # docker run --name cassandra2 -d \
     -p 7000:7000 -p 7001:7001 -p 9042:9042 -p 9160:9160 \
     -e CASSANDRA_BROADCAST_ADDRESS=10.0.0.2 \
     -e CASSANDRA_SEEDS=10.0.0.1 \
     -v [DOCKER_CREATE_VOLUME_ID]:/var/lib/cassandra cassandra:latest


Start Cassandra on node 3

      # docker run --name cassandra3 -d \
     -p 7000:7000 -p 7001:7001 -p 9042:9042 -p 9160:9160 \
     -e CASSANDRA_BROADCAST_ADDRESS=10.0.0.3 \
     -e CASSANDRA_SEEDS=10.0.0.1 \
     -v [DOCKER_CREATE_VOLUME_ID]:/var/lib/cassandra cassandra:latest


Use the `nodetool` status command to determine the state of your Cassandra cluster.

      # docker exec -it cassandra1 nodetool status
      
##See Also
For further reading on Cassandra:
*[Cassandra Docker](https://portworx.com/use-case/cassandra-docker-container/) How to run Cassandra in Docker containers
*[Run multiple Cassandra rings on the same hosts](https://portworx.com/run-multiple-cassandra-clusters-hosts/)
*[Cassandra stress test with Portworx](https://docs.portworx.com/applications/cassandra-px-perf-test.html)
*[Run Cassandra on DCOS](https://docs.portworx.com/scheduler/mesosphere-dcos/cassandra.html)
*[Snapshotting Cassandra Container Volumes for CI/CD using Mesosphere DC/OS](https://portworx.com/snapshotting-cassandra-container-volumes-ci-using-mesosphere-dcos/)



