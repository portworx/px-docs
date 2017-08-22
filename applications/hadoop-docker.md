---
layout: page
title: "A Production Ops Guide to Deploying Hadoop in Docker Containers"
keywords: portworx, px-developer, hadoop, yarn, database, cluster, storage
sidebar: home_sidebar
redirect_from:
  - /reference-architecture/sdn.html
---

* TOC
{:toc}

# Target Audience
This document is intended for Dev and Ops teams that meet one or more of the following conditions:

* You are heavily over provisioned.  You run Hadoop clusters in silos, and every time you need to bring up a silo, you create a new physical (cloud or on prem) hardware footprint to host this Hadoop cluster.  Virtualization is not an option, since you want to get bare-metal performance.
You have unused clusters that are consuming storage and compute resources.  Since they are pinned to physical infrastructure, it is difficult to reuse resources.
* You desire to host a common platform as a service for multiple Hadoop end users (internal customers).  You also want to run other data services like Cassandra on this same infrastructure.
* Your HDFS data lakes have inconsistencies.  Since you create multiple silos for each Hadoop cluster, you are unable to audit or validate the correctness of the data in the data lakes.  Since these data lakes are created separately from the deployment of your Hadoop cluster, you have no control over the governance of its data.
* You are spending too much time with manual resources used to create silos.  Your end users are unable to deploy Hadoop clusters without IT intervention and out of band compute and storage provisioning.  You want to get to a mode where clusters can be deployed in a self-service, programmatic manner.

# Introduction
Apache Hadoop, inspired by work first done at Google,  is a collection of services designed for the distributed processing of large data sets across clusters of commodity servers.  It was developed out of the need to analyze very large datasets without requiring super computer resources.  The Hadoop ecosystem includes many projects, some of most popular include:

Hadoop Common – contains libraries and utilities needed by other Hadoop modules;

Hadoop Distributed File System (HDFS) – a distributed file-system that stores data on commodity machines, providing very high aggregate bandwidth across the cluster;

Hadoop YARN – a platform responsible for managing computing resources in clusters and using them for scheduling users' applications

Hadoop MapReduce – an implementation of the MapReduce programming model for large-scale data processing.

Hbase- A scalable, distributed database that supports structured data storage for large tables.

Hive - A data warehouse infrastructure that provides data summarization and ad hoc querying.

HDFS manages the persistence layer for Hadoop, with stateless services like YARN speaking to HDFS.  HDFS has built-in data replication and so is resilient against host failure. Because data replication can also be provided at the storage level by Portworx, a typical question is: should I ensure high-availability of my Hadoop workloads through HDFS itself, through my storage, or a combination of the two? This Production Operations Guide to Running Hadoop is aimed at helping answer this question by showing how to use HDFS replication alongside Portworx to speed up recovery
times, increase density and simplify operations.

# Deploying Hadoop as Containers
Traditionally, Hadoop has been deployed directly on bare metal servers in a siloed environment.  As the number of Hadoop instances and deployments grow, managing multiple silos becomes problematic.  The specific issues with managing multiple Hadoop silos on fixed physical infrastructure are:

* Under utilization of server and storage resources.
* Manual out of band storage and compute provisioning for each new deployment.
* Creation of multiple conflicting data lakes (data inconsistencies between silos).
* Zombie resources after the completion of a job.

Typically, some form of virtualization is needed to manage any large application deployment to solve these issues.  Virtual machines however add a layer of overhead that is not conducive to big data deployments.  This is where the advent of containers becomes useful.  By deploying Hadoop inside of Linux containers, you can get the power of virtualization with bare metal performance.  You also empower a DevOps model of deploying applications - one in which out-of-band IT is not involved as your application owners deploy and scale their Hadoop clusters.

# HDFS Architectural Background
For the purposes of this discussion, there are a few important architectural components of HDFS that need to be understood.

HDFS is composed of a few specialized services.  They include:

*NameNode*
The NameNode stores cluster metadata and decides where data blocks are written and reads are served.  Only one NameNode is ever in control of a cluster. However, when running Hadoop in HA mode, there are two NameNodes, one Active
(master) and one Standby (slave).  If the Active node dies, the Standby node takes over.

*JournalNode*
The JournalNode is responsible for coordinating the Active and Standby NameNodes. Any change to the Active NameNode is synchronously replicated to the Standby NameNode.

*DataNode*
DataNodes store the the actual blocks of data.  The data in a Hadoop cluster is distributed amongst N DataNodes that make up the cluster. Additional copies of the blocks are also placed on DataNodes according to the replication factor configured on the NameNode.

*Designed for Converged Deployments*
Hadoop is designed for bare-metal deployments of commodity servers “a la Google” with a Yarn or other job running on the same physical host that has the data needed for the job. These various components of HDFS were designed to run on dedicated servers with local drives.  Scale of capacity is achieved by increasing the number of instances of each of these components.  That is, HDFS is designed to scale horizontally, not vertically by adding more capacity to anyone node.  This in turn makes the use of external storage systems such as SAN or NAS undesirable for HDFS deployments.

#Advantages of Hadoop with Portworx

This data locality is important for performance and simplified operations.   However, when using containers to run Hadoop, data locality creates a problem. Deploying multiple containerized instances of Hadoop via your scheduling software like Kubernetes, Mesos or Docker Swarm can result in Yarn or other jobs running in containers on hosts that do not have the appropriate data, significantly reducing performance. Portworx solves this problem and in doing so brings five significance benefits.

The benefits of running Hadoop with Portworx are:
* Enable Hadoop to run on a cloud-native storage infrastructure that is managed the same way, whether you run on-premise or in any public cloud
* Faster recovery times during a failure for Data, Name and Journal nodes.
* Increased resource utilization because multiple Hadoop clusters can be safely run on the same hosts
* Improved Hadoop performance with data locality or hyperconvergence
* Dynamic resizing of HDFS volumes with no downtime
* Simplified installation and configuration of Hadoop via Portworx frameworks
Let’s look at each in turn.

![Running Hadoop in containers with Portworx](/images/px-hadoop-docker-containers-architecture.png){:width="655px" height="200px"}

## Enable Hadoop to run on a cloud-native storage infrastructure that is managed the same way, whether you run on-premise or in any public cloud
The goal behind creating a PaaS is to host multiple application deployments on the same set of hardware resources regardless of the infrastructure type (private or public cloud).  This way you get maximum resource utilization for any application on any platform.

In order to accomplish this, you need cloud native compute scheduling software such as Kubernetes or Mesosphere.  Portworx compliments this by providing a cloud native storage platform which serves as a common denominator across diverse cloud and data center architectures.  Using software-defined data layer, any application can programmatically allocate and consume stateful services without having to plan for different storage architectures.  With Portworx and modern scheduling and orchestration software, you architect your application deployment once, and reuse it on any infrastructure.  Equally important is the ability for your end users to create these resources directly via the orchestration software without having to involve and rely on traditional, out-of-band IT methods.

## Faster recovery times during a node failure
Hardware and network failures are a part of normal operations. For this reason, modern software like Hadoop, designed to run on commodity servers where failures are common, can recover from these failures automatically.  Though automated, recovery is a time consuming operation and reduces cluster performance during recovery. Portworx can help your Hadoop cluster recover from that failure faster than using HDFS’ own built in replication while at the same time taking advantage of HDFS replication for improved read/write performance.  The rest of this section describes how.

### A failover example
Let’s take a look at what happens when a DataNode in our Hadoop cluster fails.

Let’s assume that we have a readily available pool of brand-new nodes that can take the place of our failed data node. The issue is that this new and willing replacement has no data — its disks are blank, as we would hope if we are practicing immutable infrastructure. This is where HDFS replication comes in.

### HDFS replication
When a DataNode has not been in contact via a heartbeat with the NameNode for 10 minutes (or some other period of time configured by the Hadoop admin), the NameNode will instruct a DataNode with the necessary blocks to asynchronously replicate the data to other DataNodes in order to maintain the necessary replication factor.
So, if the admin has configured a replication factor of 3, and a DataNode containing one replica falls out of the cluster, the NameNode will replicate the data to one new DataNode.

There are 2 implications of this process.

1- Rebuilding a DataNode replica from scratch is a time consuming operation.
The amount of time depends on the total size of the replica and the available I/O in the cluster.  For largest data sets, recovering a DataNode can take an hour or more.

2- While the rebuild operation is taking place, the read and write performance of the rest of the cluster suffers.
This is because while replication can happen fastest if all I/O is used for replication, this would bring cluster performance down to zero during the rebuild operation.  Therefore, the NameNode throttles re-replication traffic to two outbound replication streams per DataNode, per heartbeat.  This is configurable via dfs.namenode.replication.max-streams, however turning this up reduces cluster performance even more.  The effect of this is worse if you have compounded or multiple failures in your cluster and need to rebuild multiple nodes.

### Portworx replication
So while HDFS itself is capable of recovering from a failure, it is an expensive and time-consuming operation.
Portworx takes a different approach, allowing for nearly instant failover in the case of a DataNode failure. Portworx replication is synchronous and done at the block layer.  This means that we can transparently replicate a single HDFS DataNode volume multiple times, giving us a backup to use if something fails.

Because Portworx uses block layer replication, the Portworx replica of the HDFS DataNode volume is identical.  This means that if the node with our HDFS DataNode volume fails, we can immediately switch over to our Portworx replica. Essentially – Portworx is creating a backup volume that we can use to “slide and replace” under the DataNode container in the event of a node failure. This bypasses the re-replication phase completely and drastically reduces the amount of time taken to failover a HDFS DataNode.

How does this work?  Let’s image the same scenario as above where we have lost a DataNode which is replaced by a new empty node. With HDFS only, we’ve seen that we’d need to re-replicate all the data before we can serve reads and writes again from that DataNode and that this takes some time and reduces our performance in the meantime.
With Portworx however, we can immediately use one of the Portworx replicas for the new Hadoop container and start absorbing writes. This will happen much faster than the bootstrap operation of HDFS alone.
Basically the new DataNode will come up with the same identity as the node that died because Portworx is replicating the data at the block layer.

In this scenario, where we have just lost a node from our cluster – Portworx has helped us to recover quickly by allowing the replica of the volume to be used right away.

## Increase read/write throughput while reducing recovery time

The key to the above process is to use the lower-layer Portworx replication to add resilience and failover to a single DataNode volume instead of relying on HDFS to replicate data. This helps us reduce recovery time but what if we wanted to increase our read/write throughput at the same time?

We can combine the two types of replication in a single cluster and get the best of both worlds:
* Use HDFS replication to increase our capacity to process queries
* Use Portworx replication to decrease our total time to recovery

Essentially, Portworx offers a backup volume for each HDFS volume enabling a “slide and replace” operation in the event of failover. Compare this to the bootstrap operation and you can see how Portworx can reduce recovery time.
By using a replicated Portworx volume for your HDFS containers and then turning up HDFS replication, you get the best of both worlds: high query throughput and reduced time to recovery.

## Increase resource utilization by safely running multiple Hadoop clusters on the same hosts

The above operational best practices have been concerned with reliability and performance.  Now we can look at efficiency.  Most organizations run multiple Hadoop clusters, and when each cluster is architectured as outlined above, you can achieve fast and reliable performance.  However, since Hadoop is a resource intensive application, the costs of operating multiple clusters can be considerable.  It would be nice if multiple clusters could be run on the same hosts. This is possible with Portworx.

### Volume provisioning and isolation
First, Portworx can provide container-granular volumes to multiple HDFS Data, Name and Journal Nodes running on the same host.  On prem, these volumes can use local direct attached storage which Portworx formats as a block device and “slices” up for each container.  Alternatively in the cloud, a single or multiple network-attached blocked devices like AWS EBS or Google Persistent disk can be used, likewise with Portworx slicing each block device into multiple container-granular block devices.

Since Portworx is application aware, you can pass in the equivalent of a Hadoop cluster id as a group id in volume. Using this id Portworx will make sure that it does not colocate data for two stateful nodes (Data, Name and Journal) instances that belong to the same cluster on the same node. Each of your clusters will be spread across the cluster, maximizing resilience in the face of hardware failure.  This model can be extended for as many clusters as your hardware and network can support.

In principle, it is possible to set up multiple Hadoop clusters on the same hosts without a scheduler.  This requires additional cluster members to use different ports for the HDFS containers and update the corresponding hdfs-site.xml file. However, this option is complex to configure and moves teams away from the automation that speeds up deployments and reduces errors.

### Enforcing SLA with resource limits
Portworx and a container scheduler like DCOS, Kubernetes or Swarm can enable resource isolation between containers from different Hadoop clusters running on the same server.  Using this, each Hadoop cluster can achieve application level SLAs based on business requires.  This works by using schedulers to enforce compute constraints like CPU and Memory and using Portworx to enforce I/O priority.  Portworx can reserve varying levels of disk IOPS and bandwidth for different containers from each Hadoop cluster.  All of these constraints are at the container granular level.

This way, you can have one Yarn job prioritized over another based on the app SLA to your business user.  Maximizing your resource utilization while still guaranteeing performance.

## Improve Hadoop performance with hyperconvergence
Chances are if you are running Hadoop, read and write performance of jobs is important to you.  Hadoop was designed to run in bare metal environments where each server offers its own disk as the storage media.  The idea of running an app on the same machine as its storage is called “hyperconvergence”.  Hadoop will always get the best performance using this setup because the map() and reduce() operations of put a lot of pressure on the network.
“Hadoop splits files into large blocks and distributes them across nodes in a cluster. It then transfers packaged code into nodes to process the data in parallel. This approach takes advantage of data locality, where nodes manipulate the data they have access to. This allows the dataset to be processed faster and more efficiently”
Source: https://en.wikipedia.org/wiki/Apache_Hadoop

Local storage is preferred because in addition to better performance, shared storage is a single point of failure that works against the resiliency built into HDFS.

So direct attached storage is the best approach but in many data centers, this is not an obvious setup.  In on prem data centers, there is often a SAN available but that is network-attached storage, not local storage.  Many companies also have a Ceph or Gluster cluster that they try to use for centralized storage.  Both SAN and Ceph/Gluster, however, don’t deliver the performance that Hadoop likes.  On the one hand, the centralized nature of SAN storage increases the network latency and reduces throughput to which Hadoop is sensitive.  On the other hand, Ceph and Gluster, as file-based storage systems, are not optimized for database workloads, again, reducing performance.
In the cloud, we are usually talking about VMs which, besides not being bare metal, are often backed onto an external block device like Amazon EBS which because it is network attached, suffers the SAN-like latencies described above that you don’t get with direct storage media.

Portworx helps in both these situations because it can force your scheduler–Kubernetes, Mesosphere DC/OS or Docker Swarm–to run your Hadoop client container only on a host that has a copy of the data.

Portworx enforces these types of scheduling decisions using host labels. By labeling hosts based on which volumes they have and passing these constraints to the scheduler, your containers will run in the location that minimizes rebuilds and maximizes performance using direct attached storage.


## Dynamically resize HDFS volumes with no downtime
A defining attribute of big data applications is not just that they are big, but that they grow. DevOps teams running Hadoop clusters regularly discover that they have outgrown the previously provisioned storage for HDFS DataNodes. Provisioning additional storage typically requires DevOps to open a ticket for IT or storage admins to perform the task, which would end up taking hours, or even days. At the admin level, provisioning additional storage requires either migrating data to new larger volumes or performing multiple steps which lead to additional downtime.
Consider a business-critical BI cluster running a Yarn job on top of a HDFS data node that was provisioned with a 500GB volume because the DevOps thought that was sufficient headroom for the application. But then there is a burst of data ingestion, causing the DataNode to run out of space.
Portworx provides a programmatic way for DevOps to instantly increase the size of already-provisioned volumes without having to take either the application or the the underlying volumes offline. It involves running just one command which provisions more storage on the existing PX nodes, increases the size of the block device and then resizes the filesystem, all in a matter of seconds.

Here’s how you can check if your volume is full and then increase its size.

1. Run the volume inspect command.This should tell you the capacity of the volume and how much is used.
```
$ /opt/pwx/bin/pxctl volume inspect hdfs_volume

         Volume                   	:  658175664581050143
         Name        	             :  hdfs_volume
         Size        	             :  500 GiB
         Format      	             :  ext4
         HA          		         :  3
         IO Priority 	             :  LOW
         Creation time	       	 :  Feb 25 22:52:17 UTC 2017
         Shared      	             :  no
         Status      		         :  up
         State       	 	        :  Attached: 643ca9a6-972e-41d3-8a84-a2b27b21a1cc
         Device Path 	        	 :  /dev/pxd/pxd658175664581050143
         Reads       	             :  32
         Reads MS    	       	  :  44
         Bytes Read  	        	 :  352256
         Writes      		     	:  61
         Writes MS   	        	 :  104
         Bytes Written          	  :  536870912000
         IOs in progress       	   :  0
         Bytes used  	        	 :  500 GiB
         Replica sets on nodes:
                     Set  0
                                 Node  :  192.168.56.101
                                 Node  :  192.168.56.106
                               Node  :  192.168.56.105
```

You can see that the volume above is full, since all the space is used up.

2. Run the resize command to increase the size of the volume per your new requirement.
```
$/opt/pwx/bin/pxctl volume update hdfs_volume –-size 1000
```
Resize Volume: Volume hdfs_volume resized to 1000GB

3. Run volume inspect again and you’ll see that the size of the volume has been increased.
```
$/opt/pwx/bin/pxctl volume inspect hdfs_volume
         Volume                   	:  658175664581050143
         Name        	             :  hdfs_volume
         Size        	 	        :  1000 GiB
         Format      	             :  ext4
         HA          		         :  3
         IO Priority 	             :  LOW
         Creation time           	 :  Feb 25 22:52:17 UTC 2017
         Shared      	             :  no
         Status      		         :  up
         State    	    	        :  Attached: 643ca9a6-972e-41d3-8a84-a2b27b21a1cc
         Device Path 	        	 :  /dev/pxd/pxd658175664581050143
         Reads       	             :  32
         Reads MS    	       	  :  44
         Bytes Read  	        	 :  352256
         Writes      		         :  122
         Writes MS   	        	 :  232
         Bytes Written          	  :  536870912000
         IOs in progress       	   :  0
         Bytes used  	        	 :  500 GiB
         Replica sets on nodes:
                     Set  0
                                 Node    :  192.168.56.101
                                 Node    :  192.168.56.106
                                 Node    :  192.168.56.105
``

## Simplified installation and configuration of Hadoop
Hadoop is a complex application to run.  Just a basic production Hadoop install requires: Active and Standby NameNodes, Journal Nodes, Data Nodes, Zookeeper Failover Controllers and Yarn nodes.
The complexity related to installation and configuration increases when you have multiple Hadoop clusters.
Running Hadoop with Portworx dramatically simplies this in two main ways.

### Simplifying storage provisioning
With Portworx all volumes used for Data, Journal and Name nodes are virtually provisioned at container granularity. Operations such as snapshots, encryption, compression and others are not a cluster, or storage wide property, but rather per container. This is a key aspect, because it turns the operational experience over to the application owner (DevOps teams) and not the IT admin (so you can avoid slow, static and out of band storage provisioning).

### Simplifying Hadoop deployments with the DCOS framework
Additionally, Portworx makes it easy to deploy specific data services, in this case Hadoop, by understanding how all the different pieces fit together.  Portworx runs with any schedule, but customers have been particularly excited about our DCOS frameworks so this document will discuss that.
Here we will see how easy it is to set up a 3 node Hadoop cluster running on DCOS. The framework will create:
* 3 Journal Nodes,
* 2 Name Nodes, 2 Nodes for the Zookeeper Failover Controller,
* 3 Data Nodes and 3 Yarn Nodes.
* The Data and Yarn nodes will be co-located on the same physical host to maximize performance.
* The number of Data and Yarn can later be increased via DCOS after installation to scale the service.

Adding the repository for the service:

For this step you will need to login to a node which has the dcos cli installed and is authenticated to your DCOS cluster.

Run the following command to add the repository to your DCOS cluster:
$ dcos package repo add --index=0 hadoop-px https://px-dcos.s3.amazonaws.com/v1/hadoop-px/hadoop-px.zip

Once you have run the above command you should see the Hadoop-PX service available in your universe

![Hadoop-PX in DCOS Universe](/images/dcos-hadoop-px-universe.png){:width="655px" height="200px"}

#### Installation

##### Default Install
If you want to use the defaults, you can now run the dcos command to install the service

```
$ dcos package install --yes hadoop-px
```

You can also click on the “Install” button on the WebUI next to the service and then click “Install Package”.

##### Advanced Install
If you want to modify the default, click on the “Install” button next to the package on the DCOS UI and then click on “Advanced Installation”

Here you have the option to change the service name, volume name, volume size, and provide any additional options that you want to pass to the docker volume driver. You can also configure other Hadoop related parameters on this page including the number of Data and Yarn nodes for the Hadoop cluster.

![Hadoop-PX install options](/images/dcos-hadoop-px-install-options.png){:width="655px" height="200px"}

Click on “Review and Install” and then “Install” to start the installation of the service.

##### Install Status

Once you have started the install you can go to the Services page to monitor the status of the installation.

![Hadoop-PX on services page](/images/dcos-hadoop-px-service.png){:width="655px" height="200px"}

If you click on the Hadoop-PX service you should be able to look at the status of the nodes being created. There will be one service for the scheduler, 3 for Journal Nodes, 2 for the Name Nodes, 2 for the Zookeeper Failover Controllers, 3 for the Data Nodes and 3 for the Yarn Nodes.

![Hadoop-PX install started](/images/dcos-hadoop-px-started-install.png){:width="655px" height="200px"}

When the Scheduler service as well as all the Hadoop containers nodes are in Running (green) status, you should be ready to start using the Hadoop cluster.

![Hadoop-PX install finished](/images/dcos-hadoop-px-finished-install.png){:width="655px" height="200px"}

If you check your Portworx cluster, you should see multiple volumes that were automatically created using the options provided during install, one for each of the Journal, Name and Data nodes.

![Hadoop-PX volumes](/images/dcos-hadoop-px-volume-list.png){:width="655px" height="200px"}

If you run the “dcos service” command you should see the hadoop-px service in ACTIVE state with 13 running tasks

```
$ dcos service
NAME                         HOST                    ACTIVE  TASKS  CPU    MEM    DISK  ID
hadoop-px                 10.0.0.135                  True     13   9.0  32768.0  0.0   5c6438b2-1f63-4c23-b62a-ad0a7d354a91-0113
marathon                  10.0.4.21                   True     1    1.0   1024.0  0.0   01d86b9c-ca2c-4c3c-9d9f-d3a3ef3e3911-0001
metronome                 10.0.4.21                   True     0    0.0    0.0    0.0   01d86b9c-ca2c-4c3c-9d9f-d3a3ef3e3911-0000
```

### Scaling the Data Nodes
You do not need to create additional volumes of perform to scale up your cluster. Just go to the Hadoop service page, click on the three dots on the top right corner of the page, select “Data”, scroll down and increase the nodes parameter to the desired nodes.
Click on “Review and Run” and then “Run Service”. The service scheduler should restart with the updated node count and create more Data nodes. Please make sure you have enough resources and nodes available to scale up the number of nodes. You also need to make sure Portworx is installed on all the agents in the DCOS cluster.
Additionally, as mentioned above, you can also increase the capacity of your HDFS DataNodes by using the pxctl volume update command without taking the service offline.

## Reference Guide for deploying Hadoop as a Service

In this section, we cover a reference architecture for creating a PaaS like Hadoop environment.  In this reference architecture, we used:
* HPE DL360 for the DC/OS control plane nodes or similar
* HPE Apollo servers for the Hadoop clusters or similar
* HPE 5900 based networking or similar
* DC/OS version 1.9
* Portworx version 1.2.9
* RHEL Atomic as the base Linux distribution

![Hadoop Reference Architecture rack diagram](/images/hadoop-ra-1.png){:width="655px" height="200px"}

There are 2 types of server modules used in this RA:
* Management and head nodes - these nodes run as a DC/OS master node and run the control plane services such as Zookeeper.
* Worker nodes - These nodes run the actual Hadoop clusters.  These are hyper converged compute and storage nodes.  

There are two types of worker nodes used:
* Tier 1 worker node with 45TB of SSD storage (24+4 x 1.6TB hot plug LFF SAS-SSD drives)
* Tier 2 worker nodes with 26.9TB of SSD storage (24+4 x 960GB hot plug LFF SATA-SSD drives)

Installation Step 1
Install DC/OS such that the management and head nodes are used as the DC/OS master nodes and the the Apollo 4200 worker nodes are the Mesos agent nodes.  The Hadoop clusters will be scheduled on these nodes.

Installation Step 2
Once DC/OS has been installed, deploy Portworx.  First deploy the Portworx framework using the instructions detailed here: https://docs.portworx.com/scheduler/mesosphere-dcos/install.html

Next, install the Portworx framework for Big Data by following the instructions detailed here: https://docs.portworx.com/scheduler/mesosphere-dcos/hadoop-hdfs.html

Two-Rack Deployment Overview
The picture below depicts this architecture deployed in a two-rack environment:

![Hadoop Reference Architecture two rack diagram](/images/hadoop-ra-2.png){:width="655px" height="200px"}

## Conclusions
There are two main goals achieved by this reference architecture
Leveraging homogeneous server architectures for the physical data center scale-out strategy.  As compute and capacity demands increase, the data center is scaled in terms of modular DAS based Apollo 4200 worker nodes.
Leveraging cloud native compute and storage software such as DC/OS and Portworx to administer a common denominator, self provisioned programmable and composable application environment.

Using these two components, you can deploy a Hadoop-as-a-Service platform in a way that end users can deploy any big-data job in a self provisioned, self-assisted manner.  This architecture will work on any on-prem data center while maintaining portability to public cloud.
