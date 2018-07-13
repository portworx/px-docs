---
layout: page
title: "Portworx on SoftLayer"
keywords: portworx, softlayer, PaaS, IaaS, docker, converged, cloud
sidebar: home_sidebar
redirect_from: "/portworx-on-softlayer.html"
meta-description: "To deploy Portworx on SoftLayer, use this 4 step guide from Portworx. See for yourself how easy it is!"
---

* TOC
{:toc}

This guide shows you how you can easily deploy Portworx on [**SoftLayer**](http://www.softlayer.com/)

### Step 1: Provision Virtual Machine
When chosing an instance, verify that you meet the [minimum requirements](/#minimum-requirements)

Portworx recommends a minimum cluster size of 3 nodes.

### Step 2: Attach Data Disk to SoftLayer VM

SoftLayer lets you choose either local disk or SAN disk. If your environment have nodes with both of these, make sure that there is network connectivity between the nodes.

![SoftLayer Add Disk](/images/softlayer-add-disk.png "Add Disk"){:width="777px" height="637px"}

### Step 3: Install Docker for the appropriate OS Version 
Portworx recommends Docker 1.12 with [Device Mapper](https://docs.docker.com/engine/userguide/storagedriver/device-mapper-driver/#/configure-docker-with-devicemapper).

Note: Portworx requires Docker to allow shared mounts.  This is standard as of Docker 1.12.  
If you are running Docker without shared mounts, please follow the steps listed [here](/knowledgebase/shared-mount-propagation.html)

### Step 4: Launch PX-Enterprise
[Follow the instructions to launch PX-Enterprise](/#install-with-a-container-orchestrator)

Use the docker run command to launch PX-Enterprise, substituting the appropriate multipath devices and network interfaces, as identified from the previous steps.

Alternatively, you can either run the 'px_bootstrap' script from curl, or construct your own [config.json](/control/config-json.html) file.

From the server node running px-enterprise container, you should see the following status:

![PX-Cluster on SoftLayer](/images/softlayer-pxctl-status-updated.png "PX-Cluster on SoftLayer"){:width="854px" height="543px"}


You should also be able to monitor cluster from PX-Enterprise console:

![SoftLayer-Cluster on Lighthouse](/images/softlayer-cluster-on-lighthouse-updated.png "SoftLayer-Cluster on Lighthouse"){:width="1362px" height="586px"}

