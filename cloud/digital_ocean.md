---
layout: page
title: "Portworx on the Digital Ocean Cloud Platform"
keywords: portworx, digital ocean, PaaS, IaaS, docker, converged
sidebar: home_sidebar
---

* TOC
{:toc}

This guide shows you how you can easily deploy Portworx on the [**digitalocean.com** cloud platform](http://digitalocean.com)
using [Terraform](http://terraform.io) infrastructure automation.

Following these simple instructions you can have a 3-node Portworx cluster up and running in under 5 minutes.

Other supported bare metal cloud providers are

* [Packet.net](/cloud/packet.html)
* [Rackspace](/cloud/rackspace.html)

Pre-requisites:   You will need to have a valid Digital Ocean account

### Step 1: Install Terraform

Download, unzip and install Terraform for your particular OS distro from the main [Terraform Download site](https://www.terraform.io/downloads.html)

### Step 2: Clone the Terraporx Repository

```
git clone https://github.com/portworx/terraporx.git
cd terraporx/digital_ocean
```

### Step 3: Select your OS Distro
This Digital Ocean repository currently supports 3 different Linux OS flavors: 

* CoreOS
* Ubuntu16
* CentOS7

Select the OS distro of your choice.

The scripts for Ubuntu and CentOS will both install the current version 
of **'docker-ce'** and launch a single **'etcd'** container for the Portworx required 'kvdb'.

CoreOS will configure **user_data** to launch the internal **'etcd2'** service and also launch **'px-dev'** as a 'systemd' service.

### Step 4: Configure your Terraform variables

The following variable definitions are required:

* 'do_token'  : Your Digital Ocean API key.  Obtain or generate your token from here [https://cloud.digitalocean.com/settings/api/tokens](https://cloud.digitalocean.com/settings/api/tokens)
* 'region'    : These scripts require block storage, which is only available in the regions **FRA1, NYC1, SFO2 and SGP1**
* 'size'      : These are the valid instance sizes : *"2gb", "4gb", "8gb", "16gb", "32gb", "48gb", "64gb"*
* 'volsize'   : These are the valid external volume sizes (in GB):  *100, 250, 500, 1000, 2000*
* 'prefix'    : An arbitrary distinguishing name for your cluster prefix


In addition for CoreOS, you will need to supply a *'discovery_url'* for the 'etcd' service.

### Step 5: Create your cluster

### Step 6: (optional)  Tear down your cluster
