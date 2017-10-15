---
layout: page
sidebar: home_sidebar
title: "Get Started with PX-Developer"
keywords: portworx, px-developer, container, storage, requirements
redirect_from: "/get-started-px-developer.html"
meta-description: "Getting started with PX-Developer? In just two steps, Portworx can have you up and running in no time! Follow the step-by-step instructions today!"
---

* TOC
{:toc}

## Step 1: Verify requirements

* Linux kernel 3.10 or greater
* Docker 1.10 or greater.
* Configure Docker to use shared mounts.  The shared mounts configuration is required, as PX-Developer exports mount points.
  * Run sudo mount --make-shared / in your SSH window
  * If you are using systemd, remove the `MountFlags=slave` line in your docker.service file.
* A key/value store such as Etcd 3.0 or Consul 0.7.0
* Minimum resources per server:
  * 4 CPU cores
  * 4 GB RAM
* Recommended resources per server:
  * 12 CPU cores
  * 16 GB RAM
  * 128 GB Storage
  * 10 GB Ethernet NIC
* Maximum nodes per cluster:
  * 3 server nodes
* Open network ports:
  * Ports 9001 - 9006 must be open for internal network traffic between nodes running PX

## Step 2: Install and run PX-Developer

Select an operating environment to install Portworx:

* [Run Portworx with Kubernetes](/scheduler/kubernetes/install.html)
* [Run Portworx with Mesosphere](/scheduler/mesosphere-dcos/install.html)
* [Run Portworx with Docker](/scheduler/docker/install-standalone.html)
* [Run Portworx with Rancher](/scheduler/rancher/install.html)

Run stateful containers with Portworx:

* [Application Solutions](/application-solutions.html)

Use **pxctl** ([CLI Reference](/control/status.html)) to directly:

* View the cluster global capacity and health
* Create and manage storage volumes
* Advanced management of the PX cluster

If your requirements extend beyond the scope of PX-Developer, please [contact Portworx](http://portworx.com/contact-us/) for information on PX-Enterprise.
