---
layout: page
title: "Release notes 1.0.4"
keywords: portworx, px-enterprise, release notes
sidebar: home_sidebar
---
Portworx released PX-Enterprise 1.0.4 on September 15, 2016.

## Summary and features

**Scale-out fabric for containers**
* Description.
* Benefits.

**Lighthouse, a web console to manage multi-tenancy**
* Will the console be branded with the name Lighthouse?
* Lighthouse (or "The PX-Enterprise web console") provides storage management for all of your PX-Enterprise deployments, including on-premises clusters and in public clouds.
* Lighthouse (or "The console") monitors health and capacity and lets you provide container-granular storage.

## Limits

Following are the supported limits as tested and qualified by Portworx.

* 35 nodes per cluster
* 100 volumes per node
* 12 devices per node
* 96 TB per node
* 30 snapshots per volume
* 3 replicas per volume

## Support matrix

* OS Versions: Linux kernel versions 3.10.x through 4.4.x
* Docker versions: Minimum 1.10
* For minimum hardware recommendations, refer to [Get Started with PX-Enterprise](http://docs.portworx.com/get-started-px-enterprise.html).

## Schedulers

PX-Enterprise is tested and qualified against the following schedulers:

* Docker UCP running in swarm mode (minimum version 1.12)
* Mesos, Mesosphere, and DC/OS (minimum version 1.7)
* Rancher (minimum version 1.1.3)

## Shared volumes

PX-Enterprise 1.0.X contains experimental support for the shared volumes feature. For this release, shared volumes will not perform as well as non-shared volumes. Portworx will address this issue in an upcoming minor release.

## Known issues

* Issue placeholder
* Issue placeholder

## Documentation

For all Portworx reference documentation, please visit [docs.portworx.com](http://docs.portworx.com).
