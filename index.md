---
layout: page
title: "Welcome to Portworx Docs"
keywords: portworx, px-enterprise, px-developer, containers, storage
sidebar: home_sidebar
youtubeId : 0zTjOly0vkA
---

* TOC
{:toc}

Portworx is a software defined persistent storage solution designed and purpose built for containers.  Portworx is a clustered block storage solution that provides a Cloud-Native layer from which containerized stateful applications programmatically consume storage services directly through schedulers such as Kubernetes, Mesos and Swarm.
Portworx storage is delivered as a container that gets installed on your servers that run stateful applications. 

Portworx technology:

* Provides virtual, container-granular data volumes to applications running in containers.
* Is scheduler aware - provides data persistence and HA across multiple nodes, cloud instances, regions, data centers or even clouds.
* Is application aware - applications like Cassandra are deployed as a set of containers, and Portworx is aware of the entire stack.  Data placement and management is done at an application POD level.
* Manages physical storage that is directly attached to servers, from cloud volumes, or provided by hardware arrays.
* Provides programmatic control on your storage resources - volumes and other stateful services can be created and consumed directly via the scheduler and orchestration software tool chain.
* Is radically simple - Portworx is deployed just like any other container - and managed by your scheduler of choice.

## Data Service Platform
Here is a short video that shows how Portworx provides an entire platform of services for managing stateful containerized applications in any Cloud or On-Prem data center:
{% include youtubePlayer.html id=page.youtubeId %}

## How it Works
Portworx storage is deployed as a container and runs on a cluster of servers. Application containers provision storage directly through the Docker [volume plugins](https://docs.docker.com/engine/extend/plugins_volume/#command-line-changes:be52bcf493d28afffae069f235814e9f) API or the Docker [command-line](https://docs.docker.com/engine/extend/plugins_volume/#command-line-changes:be52bcf493d28afffae069f235814e9f). Administrators and DevOps can alternatively pre-provision storage through the Portworx command-line tool (**pxctl**) and then set storage policies using the PX-Enterprise web console.

Read more about how Portworx provides storage volumes to your application containers [here](architecture.html)

## Minimum Requirements

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
  
## Install
Visit the Schedulers section of this documentation, and chose the appropriate installation instructions for your scheduler.

* [Install on Kubernetes](/scheduler/kubernetes/install.html)
* [Install on Mesosphere DCOS](/scheduler/mesosphere-dcos/install.html)
* [Install on Docker](/scheduler/docker/install-standalone.html)
* [Install on Rancher](/scheduler/rancher/install.html)

## Join us on Slack!
[![](/images/slack.png){:height="48px" width="48px" .slack-icon}](http://slack.portworx.com)

[Contact us](http://portworx.com/contact-us/) to share feedback, work with us, and to request features.
