---
layout: page
title: "Run Portworx on Docker Datacenter"
keywords: portworx, PX-Developer, container, docker datacenter, docker ucp, docker universal control plane, storage
sidebar: home_sidebar
redirect_from: 
 - /portworx-on-ddc.html
 - /run_portworx_on_ddc.html
meta-description: "It is possible to run Portworx on your Docker Datacenter cluster to run stateful containerized workloads. Learn more here!"
---

* TOC
{:toc}

Portworx has been qualified to work with [Docker Datacenter](https://www.docker.com/products/docker-datacenter)

Docker Datacenter (DDC) has 3 major components:

* Docker Universal Control Plan (UCP)
* Docker Trusted Registry (DTR)
* Docker Commercially Supported Engine (CSE)

Of these elements, Portworx interacts with Docker Commercially Supported Engine (CSE) for Portworx configuration, and with Docker UCP for deployment of applications.

DDC Setup instructions reference AWS, Azure, and Linux environments.   
The default AWS Cloud Formation templates by default do not configure the required local disks needed to run Portworx.  

>**Note:**<br/>Unless you are able to modify AWS Cloud Formation deployment templates, you should not attempt to deploy Portworx on AWS Cloud Formation.

The recommended deployent of Portworx with DDC is bare-metal Linux or Azure.

## Step 1: Obtain DDC License

Running Docker UCP will require a license from Docker for use past the 30-day trial period.
Visit the [Docker Store](https://store.docker.com/bundles/docker-datacenter/purchase?plan=free-trial) to obtain a DDC license.

## Step 2: Install Docker CSE on Nodes

DDC requires that the Docker CSE to be installed.
Follow instructions to install [Docker CSE](https://docs.docker.com/cs-engine/1.13/)

## Step 3:  Install Docker UCP

Visit [Docker docs](https://docs.docker.com/) for instructions on Installing Docker UCP.

## Step 3a: (Optional) Update your docker.service file

Assess the scale of your DDC cluster, especially the number of UCP compute nodes, and the current maximum size of a Portworx cluster.

If your DDC cluster size is less than or equal to the maximum size of a Portworx cluster, then go to Step 4.   You will not need to make use of "constraints".

If your DDC cluster size is greater than the maximum size of a Portworx cluster, then follow these steps to define "constraints".

For UCP to properly identify the nodes running Portworx, the Docker Daemon must start with a Label that indicates Portworx is running. To make that happen, you will need to update the docker.service file.

To find where your docker.service file is located, run the `systemctl` command:

```
[...]
systemctl status docker
[...]

```
Then, replace the existing `ExecStart` line with the one for your Docker version.

**Docker 1.11**

```
[...]
ExecStart=/usr/bin/docker daemon -H fd:// --label pxfabric=px-cluster1
[...]
```

**Docker 1.12**

```
[...]
ExecStart=/usr/bin/dockerd --label pxfabric=px-cluster1
[...]
```

Next, reload `systemctl` and restart the docker daemon:

```
# systemctl daemon-reload
# systemctl restart docker
```

You can now verify that the label is in place for whichever nodes are running Portworx:

```
# docker info
[...]
Labels:
    pxfabric=px-cluster1
[...]
```


>**Note:**<br/>You can use the fabric label to specify different PX-based clusters.

## Step 4: Install Portworx 

Follow the instructions for [Getting Started with Portworx Enterprise](/#install-with-a-container-orchestrator)

Follow the instructions for [Creating a PX-Enterprise Cluster](/enterprise/portworx-via-lighthouse.html#step-1-provision-a-cluster-in-the-px-enterprise-console)

On each of the UCP Nodes, install Portworx **either** through interactive mode by running the [bootstrap curl 
command](/enterprise/portworx-via-lighthouse.html#step-2-run-discovery-and-bootstrap-on-a-server-node), 
**or** in a scripted/autmated method by [running px-enterprise manually](/px-usage.html) and using the token-ID from the Lighthouse "Get Startup Script" window.

## Step 5: Launch a container

At this point, you are ready to launch applications.
For the case where UCP nodes were deployed using "constraints", 
then the following format allows you to launch a container from the command line and restrict it to running on a node that is running Portworx:

```
docker  run -d -P -e constraint:pxfabric==px-cluster1 --name db mysql
```


Or, from the UCP GUI for launching a container, specify a constraint for `pxfabric` as follows:
![UCP GUI constraints](/images/constraints.png){:width="791px" height="148px"}

For more information on Docker Filters and Constraints, see [Swarm filters](https://docs.docker.com/swarm/scheduler/filter/).
