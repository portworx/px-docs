---
layout: page
title: "Deploy Portworx on Mesosphere DCOS"
keywords: portworx, mesos, mesosphere, dcos
sidebar: home_sidebar
---

[Mesosphere DC/OS](https://mesosphere.com/product/) makes it easy to build and run modern distributed applications in production at scale, by pooling resources across an entire datacenter or
cloud. 

While the DC/OS platform works great for stateless applications, many enterprises who have tried to use DC/OS for stateful applications at scale have stumbled when it comes to using the platform for services like databases, queues and key-value stores.

Portworx, which scales up to 1000 nodes per cluster and is used in production by DC/OS users like GE Digital, solves the operational and data management problems enterprises encounter when running stateful applications on DC/OS. 

Unlike the default DC/OS volume driver, Portworx lets you:

* dynamically create volumes for tasks at run time, no more submitting tickets for storage provisioning
* dynamically and automatically resize volumes based on demand while task is running
* run tasks on the same hosts that your data is located on for optimum performance
* avoid pinning services to particular hosts, reducing the value of automated scheduling 
* avoid fragile block device mount/unmount operations that block or delay failover operations
* encrypt data at rest and in flight at the container level

Read on for how to use Portworx to provide [persistent storage for Mesosphere DC/OS and marathon](https://portworx.com/use-case/persistent-storage-dcos/)and use it with [DC/OS Commons frameworks](https://docs.mesosphere.com/service-docs/) for some of the most popular stateful services.

## Using Portworx with Mesosphere DCOS

 * [Install Portworx for Mesosphere/DCOS](/scheduler/mesosphere-dcos/install.html)
 * [Cassandra on DCOS with Portworx](/scheduler/mesosphere-dcos/cassandra.html)
 * [Hadoop on DCOS with Portworx](/scheduler/mesosphere-dcos/hadoop-hdfs.html)
 * [Kafka on DCOS with Portworx](/scheduler/mesosphere-dcos/kafka.html)
 * [Elasticsearch on DCOS with Portworx](/scheduler/mesosphere-dcos/elasticsearch.html)
