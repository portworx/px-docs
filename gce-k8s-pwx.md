---
layout: page
title: "Create a scaleout converged container cluster using Kubernetes and Portworx in GCE"
keywords: portworx, PaaS, IaaS, docker, kubernetes, converged, bare metal
sidebar: home_sidebar
---

This guide shows you how you can easily deploy a hyper converged (compute and storage) cluster in any cloud (GCE, AWS, Azure) with Kubernetes and Portworx.

## Step 1: Select your cloud instance type
You can use any cloud instances (like EC2) with persistent storage.  Portworx will automatically detect the performance of the volumes and match the CoS levels to the containers appropriately.  Portworx will also aggregate the capacity across all the cloud instances to provide a global pool of virtual, highly available storage to Kubernetes.

Compatible instance and storage options for popular cloud providers are:

| Provider | Instance Options | Storage Options |
|--------- |------------------|-----------------|
| AWS | [Any EC2 instance type](https://aws.amazon.com/ec2/instance-types/) | [GP2, IO1 or ST1](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EBSVolumeTypes.html) |
| GCE | [Any GCE instance type](https://cloud.google.com/compute/docs/machine-types) | [Persistent disks and SSDs](https://cloud.google.com/compute/docs/disks/) |
| Azure | [Any Linux VM](https://azure.microsoft.com/en-us/pricing/details/virtual-machines/linux/?cdn=disable) | [Disk storage type](https://azure.microsoft.com/en-us/pricing/details/storage/disks/) |

Supported bare metal cloud providers are

* Scaleway.  Use this image: [https://www.scaleway.com/imagehub/docker/](https://www.scaleway.com/imagehub/docker/)
* Digital Ocean
* Rackspace
* Packet.io

When chosing an instance, verify that you meet the minimum requirements available at [http://docs.portworx.com/get-started-px-enterprise.html#step-1-verify-requirements](http://docs.portworx.com/get-started-px-enterprise.html#step-1-verify-requirements)

Portworx recommends a minimum cluster size of 3 nodes.

## Step 2: Configure the host software

A recent enough Linux distribution is typically all that is needed.  We recommend one of the following:

* Ubuntu Xenial+
* CentOS 7.0+
* RHEL 7+
* CoreOS 1192.1.0+

Next, install Docker.  Portworx recommends Docker 1.12 with [Device Mapper](https://docs.docker.com/engine/userguide/storagedriver/device-mapper-driver/#/configure-docker-with-devicemapper).

Note: Portworx requires Docker to allow shared mounts.  This is standard as of Docker 1.12.  If you are running Docker without shared mounts, please follow the steps listed at http://docs.portworx.com/os-config-shared-mounts.html.

## Step 3: Deploy PX with Kubernetes
At this point, you have everything you need to deploy Portworx with Kubernetes to create a hyperconverged compute with storage cluster.

Visit [Run Portworx with Kubernetes](http://docs.portworx.com/run-with-k8s.html) to get portworx and kubernetes running on all the nodes in your cluster.

## An example BOM
In an example deployment, we used GCE to deploy a 30 node Portworx with Kubernetes cluster.  The cost breakdown (minus the Portworx Enterprise licence fees) to run this 30 node cluster per hour was as follows:

### Bill of Materials

| Material | Type | Details | Cost per hour |
|----------|------|------|
| Compute Instance|n1-standard-4|4 CPU cores, 4 GB RAM with 375 GB local SSD|$0.20|
| Linux Distro |Ubuntu Xenial | 4.4.0-38-generic | $0.0 |
| Container Engine | Docker | 1.12 with device mapper | $0.0 |
| Scheduler | Kubernetes | v1.4.3 | $0.0 |

### Hourly compute costs
Based on the above BOM, the total hourly cost for the 30 node converged container cluster was $6.

### Monthly storage costs

GCEs disk pricing information is available at https://cloud.google.com/compute/pricing.

Each instance in our reference deployment had a local 375 GB SSD volume.  Google charges $0.17 per GB.  Therefore each instance cost us $63.75 per month.  The total cost of storage per month for the 30 node cluster was $1912.50.

### Total monthly breakdown

In total, we had a 30 node cluster with the following properties:

|Resource|Amount|
|------|------|
|CPU|120 cores|
|Memory| 120 GB|
|Storage| 11.250 TB|

The total monthly cost to run this in GCE was:

|Item|Cost|
|------|------|
|Storage|$1912.50|
|Compute|$4320.0|
|Total|$6232.50|
