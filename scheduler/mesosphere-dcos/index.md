---
layout: page
title: "Portworx with Mesosphere DCOS"
keywords: portworx, mesos, mesosphere, dcos
sidebar: home_sidebar
---

[Mesosphere DC/OS](https://mesosphere.com/product/) makes it easy to build and run modern distributed applications in production at scale, by pooling resources across an entire datacenter or
cloud. 

While the DC/OS platform works great for stateless applications, many enterprises who have tried to use DC/OS for stateful applications have stumbled when it comes to using the platform for services like databases, queues and key-value stores.

Portworx, which scales up to 1000 nodes per cluster and is used in production by DC/OS users like GE Digital, solves the operational and data management problems enterprises encounter when running stateful applications on DC/OS. 

Portworx lets you:

* run tasks on the same hosts that your data is located on
* avoid pinning services to particular hosts, reducing the value of automating scheduling 
* automate the provisioning on data volumes
* encrypt data at rest and in flight at the container level

Read on for how to install Portworx into your DC/OS cluster and use it with [DC/OS Commons frameworks](https://docs.mesosphere.com/service-docs/) for some of the most popular stateful services.

## Using Portworx with Mesosphere DCOS

 * [Install Portworx for Mesosphere/DCOS](/scheduler/mesosphere-dcos/install.html)
 * [Cassandra on DCOS with Portworx](/scheduler/mesosphere-dcos/cassandra.html)
 * [Hadoop on DCOS with Portworx](/scheduler/mesosphere-dcos/hadoop-hdfs.html)
