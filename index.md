---
layout: page
title: "Welcome to Portworx Docs"
keywords: portworx, px-enterprise, px-developer, containers, storage
sidebar: home_sidebar
meta-description: "Find out more about Portworx, the persistent storage solution for containers. Come check us out for step-by-step guides and tips!"
---

* TOC
{:toc}

Portworx is a software defined persistent storage solution designed and purpose built for applications deployed as containers, via modern scheduling software such as Kubernetes, Marathon and Swarm.  It is a clustered block storage solution and provides a Cloud-Native layer from which containerized stateful applications programmatically consume storage services directly through the scheduler.  
Portworx volumes are always hyper-converged.  That is, they are exposed on the same host where the application container executes.

Portworx technology:

* Is delivered as a container and gets installed on your servers that run stateful applications.  Portworx volumes are available on the same host where an application container consumes the volume.
* Provides virtual, container-granular data volumes to applications running in containers.
* Is scheduler aware - provides data persistence and HA across multiple nodes, cloud instances, regions, data centers or even clouds.
* Is application aware - applications like Cassandra are deployed as a set of containers, and Portworx is aware of the entire stack.  Data placement and management is done at an application POD level.
* Is designed for enterprise production deployments, with features like BYOK inline encryption, snapshot-and-backup to S3 and support for stateful Blue-Green deployments.
* Manages physical storage that is directly attached to servers, from cloud volumes, or provided by hardware arrays.  It monitors the health of the drives and manages the RAID groups directly, repairing failures when needed.
* Provides programmatic control on your storage resources - volumes and other stateful services can be created and consumed directly via the scheduler and orchestration software tool chain.
* Is radically simple - Portworx is deployed just like any other container - and managed by your scheduler of choice.

{%
    include youtubePlayer.html 
    id = "0zTjOly0vkA"
    title = "Cloud Native Storage"
    description = "Here is a short video that shows how Portworx provides an entire platform of storage services for managing stateful containerized applications in any Cloud or On-Prem data center"
%}

### How it Works
Unlike traditional storage which is designed to provide storage to a host machine or operating system via protocols like iSCSI, NBD or NFS, Portworx directly provides block storage to your applications on the same server where the application is running.
Portworx itself is deployed as a container and runs on every host in your cluster. Application containers consume Portworx volumes directly through the Container Orchestrator.  The following are supported:
* Docker [volume plugins](https://docs.docker.com/engine/extend/plugins_volume/#command-line-changes:be52bcf493d28afffae069f235814e9f)
* [Kubernetes Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#portworx-volume)
* Mesosphere DC/OS [DVDI External Storage Interface](https://docs.mesosphere.com/1.9/storage/external-storage/)
* [CSI](https://github.com/container-storage-interface/spec)

Read more about how Portworx provides storage volumes to your application containers [here](architecture.html).

### Minimum Requirements
* Linux kernel 3.10 or greater
* Docker 1.10 or greater.
* Configure Docker to use shared mounts.  The shared mounts configuration is required, as PX-Developer exports mount points.
  * Run sudo mount --make-shared / in your SSH window
  * If you are using systemd, remove the `MountFlags=slave` line in your docker.service file.
* Minimum resources per server:
  * 4 CPU cores
  * 4 GB RAM
* Additional resources recommended per server:
  * 128 GB Storage
  * 10 GB Ethernet NIC
* Maximum nodes per cluster:
  * Unlimited for the Enterprise License
  * 3 for the Developer License
* Open network ports:
  * Ports 9001, 9002, 9003, 9010, 9012, 9014 must be open for internal network traffic between nodes running PX
* All nodes running PX container must be synchronized in time and recommend setting up NTP to keep the time 
  synchronized between all the nodes
 * Before going production, ensure a 3-node clustered etcd is deployed that PX can use for configuration storage. 
   Follow the instructions here to deploy a clustered etcd. https://coreos.com/etcd/docs/latest/op-guide/clustering.html
   
  
### Install with a Container Orchestrator
Visit the Schedulers section of this documentation, and chose the appropriate installation instructions for your scheduler.

* [Install on Kubernetes](/scheduler/kubernetes/install.html)
* [Install on Mesosphere DCOS](/scheduler/mesosphere-dcos/install.html)
* [Install on Docker](/scheduler/docker/install-standalone.html)
* [Install on Rancher](/scheduler/rancher/install.html)

### Install with runC
You can run Portworx directly via OCI runC.  This will run Portworx as a standalone container without any reliance on the Docker daemon.
[Install with RunC](/runc/)

### Join us on Slack!
[![](/images/slack.png){:height="48px" width="48px" alt="Slack" .slack-icon}](http://slack.portworx.com)

[Contact us](http://portworx.com/contact-us/) to share feedback, work with us, and to request features.
