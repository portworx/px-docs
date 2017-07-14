---
layout: page
title: "Stateful Frameworks on DCOS with Portworx"
keywords: portworx, container, Mesos, Mesosphere, DCOS, Frameworks, Stateful Applications
meta-description: "Learn about Portworx stateful frameworks for DCOS.  The frameworks extend Mesosphere to allow for the orchestration and usage of the Portworx volumes."
---

* TOC
{:toc}

Since the stateful services in the DCOS universe do not support external volumes, you will need to add additional packages available here in order to use Portworx with these services.

The source code for these services can be found here: [Portworx DCOS-Commons Frameworks](https://github.com/portworx/dcos-commons)

>**Note:**<br/>These frameworks are only supported directly by Portworx.
>Please contact support@portworx.com directly for any support issues related with using this framework.

Please make sure you have installed [Portworx on DCOS](/scheduler/mesosphere-dcos/install.html) before proceeding further.

## What are stateful frameworks?
Stateful frameworks are specifically for applications that have external storage state that needs to be persisted post the lifecycle of the running instance of the framework itself.

The frameworks available in this section extend Mesosphere's frameworks to allow for the orchestration and usage of the Portworx volumes.  These frameworks support the following features with the Portworx volumes:

### Convergence
The frameworks available in this section ensure that the service scheduler launches containers on nodes that are likely to have Portworx's volume local to that host. This gives the application hyper-converged performance, typically preferred by scaleout applications such as Cassandra or HDFS.

### Scaling
Typically, an application has different types of containers that constiture the overall application.  For example, HDFS alone has data node containers and name node containers.  These containers have different instance counts, resources and volume type requirements.  As you scale the application to a larger number of nodes, the frameworks available here properly scale the various components that constitute the application, creating new Portworx volumes on  the fly, as needed.

### Data availability across failures
In the event of a software or physical failure of a host, the framework will re-deploy the failed components of this application onto other hosts, and re-attach the portworx volume maintaining application level high availability.

### Ensuring application aware data placement
In most cases, it is desirable to have containers within an application to reside on different hosts.  It is also desirable to have the data associated with these containers in different failure domains (such as different racks).  These frameworks work in conjunction with Portworx to ensure topgraphically safe container and data placement.

### Cleaning up resources
When an application is scaled down, or terminated, these frameworks ensure that the local system resources on the hosts are properly cleaned up, including removing any external volume mounts.

### Framework level volume consistent operations
The frameworks help coordinate application level volume operations.  An example is snapshots.  When a framework is snapshotted, all the containers that comprise the application are snapshotted in a single consistency group.

## An example of installing a framework
Adding any of the frameworks available from Portworx is simple.  Use the `dcos` CLI to add these external frameworks.  For example, to add the Cassandra framework:

```
$ dcos package repo add --index=0 cassandra-px-aws https://px-dcos.s3.amazonaws.com/v1/cassandra-px/cassandra-px.zip
```

Please refer to the individual frameworks sections in the navigation bar for more details on a specific framework.
