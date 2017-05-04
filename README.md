---
layout: page
title: "Welcome to Portworx Docs"
keywords: portworx, px-enterprise, px-developer, containers, storage
youtubeId : 0zTjOly0vkA
sidebar: home_sidebar
---

<a href="https://github.com/portworx/px-docs"><img style="position: absolute; top: 0; right: 80; border: 0;" src="https://camo.githubusercontent.com/652c5b9acfaddf3a9c326fa6bde407b87f7be0f4/68747470733a2f2f73332e616d617a6f6e6177732e636f6d2f6769746875622f726962626f6e732f666f726b6d655f72696768745f6f72616e67655f6666373630302e706e67" alt="Fork me on GitHub" data-canonical-src="https://s3.amazonaws.com/github/ribbons/forkme_right_orange_ff7600.png" align=right></a>

Portworx is a software defined persistent storage solution designed and purpose built for containers.  Portworx is a clustered block storage solution deployed itself as a container and provides a Cloud-Native storage solution where applications can programmatically consume stateful services directly through schedulers such as Kubernetes, Mesos and Swarm.
Portworx storage is delivered as a container that gets installed on your servers that run stateful applications. 

Portworx technology:

* Provides virtual, container-granular data volumes to applications running in containers.
* Is scheduler aware - provides data persistence and HA across multiple nodes, cloud instances, regions, data centers or even clouds.
* Is application aware - applications like Cassandra are deployed as a set of containers, and Portworx is aware of the entire stack.  Data placement and management is done at an application POD level.
* Manages physical storage that is directly attached to servers, from cloud volumes, or provided by hardware arrays.
* Provides programmatic control on your storage resources - volumes and other stateful services can be created and consumed directly via the scheduler and orchestration software tool chain.
* Is radically simple - Portworx is deployed just like any other container - and managed by your scheduler of choice.

## Watch the video
Here is a short video that shows how Portworx provides an entire platform of services for managing stateful containerized applications in any Cloud or On-Prem data center:
{% include youtubePlayer.html id=page.youtubeId %}

Portworx technology is available as PX-Enterprise and PX-Developer.

## Join us on Slack!
Join us on [slack](http://slack.portworx.com)

## PX-Enterprise

PX-Enterprise is for DevOps and IT ops teams managing storage for containerized workloads. PX-Enterprise provides multi-cluster and multi-cloud support, where storage under management can be on-premise or in a public cloud like AWS.

* Scale-out storage deployed as a container
* Shared volumes, where multiple containers can share a single filesystem
* Container granular storage operations that work on any cloud, such as
  * Container volume granular snapshots
  * Container volume granular CoS
  * Container volume granular encryption
  * Container volume granular access controls and quota management
* Multi-cluster visibility and management
* Distributed file access
* Web management console with role-based access
* Command-line interface
* RESTful API for automation and statistics

<FORM METHOD="LINK" ACTION="/getting-started/px-enterprise.html">
<INPUT TYPE="submit" VALUE="Get Started with PX-Enterprise">
</FORM>


## PX-Developer

PX-Developer is free, easy-to-deploy scale-out storage for developers. If you're running workloads under your desk and want to be free of managing hardware or need container-granular storage, check out PX-Developer.

PX-Developer features:

* Scale-out storage deployed as a container
* Container-granular controls
* Distributed file access
* Command-line interface
* Support for up three servers per cluster and 1 TB per volume
* Requires an etcd or Consul key/value store

<FORM METHOD="LINK" ACTION="/getting-started/px-developer.html">
<INPUT TYPE="submit" VALUE="Get Started with PX-Developer">
</FORM>
<br/>

[Contact us](http://portworx.com/contact-us/) to share feedback, work with us, and to request features.
