---
layout: page
sidebar: home_sidebar
title: "Get Started with PX-Developer"
keywords: portworx, px-developer, container, storage, requirements
---
## Step 1: Verify requirements

* Linux kernel 3.10 or greater
* Docker 1.10 or greater, configured with [devicemapper](https://docs.docker.com/engine/userguide/storagedriver/device-mapper-driver/#/configure-docker-with-devicemapper)
* An etcd 2.0 key/value store (Consul coming soon)
* Minimum resources per server:
  * 4 CPU cores
  * 4 GB RAM
* Recommended resources per server:
  * 12 CPU cores
  * 16 GB RAM
  * 128 GB Storage
  * 10Gb
* Maximum nodes per cluster:
  * 20 server nodes

## Step 2: Install and run PX-Developer

See our quick start guides:

* [Run PX-Developer with Docker Compose](run-with-compose.html)
* [Convert x86 Servers to Storage-Capable Nodes](convert-x86-to-storage-nodes.html)

Run Portworx with schedulers:

* [Run Portworx with Kubernetes](run-with-k8s.html)
* [Run Portworx with Mesosphere](run-with-mesosphere.html)
* [Run Portworx with Rancher](run-with-rancher.html)

Run stateful containers with Docker volumes:

* [Application Solutions](application-solutions.html)

Use **pxctl** ([CLI Reference](cli-reference.html)) to directly:

* View the cluster global capacity and health
* Create, inspect, and delete storage volumes
* Attach policies for IOPs prioritization, maximum volume size, and enable storage replication

If you run into an issue:

* [Troubleshooting](troubleshooting.html)

As you use PX-Developer, please share your feedback and ask questions. Find the team on [Google Groups](https://groups.google.com/forum/#!forum/portworx).

If your requirements extend beyond the scope of PX-Developer, please [contact Portworx](http://portworx.com/contact-us/) for information on PX-Enterprise. You can take a tour of the PX-Enterprise console [here](get-started-px-enterprise.html#step-3-take-a-tour-of-the-px-enterprise-web-console).
