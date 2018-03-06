---
layout: page
title: "Deploy Portworx on Docker Swarm or UCP"
keywords: portworx, architecture, storage, container, cluster, install, docker, swarm, ucp
sidebar: home_sidebar
redirect_from:
  - /scheduler/docker-swarm.html
  - /scheduler/docker-ucp.html
meta-description: "Follow this step-by-step guide to install Portworx on Docker Swarm or UCP.  Try it for yourself today!"
---

* TOC
{:toc}

## Prerequisites

{% include px-prereqs.md %}.

## Identify storage

{% include identify-storage-devices.md %}

## Install

PX runs as a container directly via OCI runC.  This ensures that there are no cyclical dependencies between Docker and PX.

On each swarm node, perform the following steps to install PX.

#### Step 1: Install the PX OCI bundle

{% include runc/runc-install-bundle.md %}

#### Step 2: Configure PX under runC

{% include runc/runc-configure-portworx.md sched-flags="-x swarm" %}

#### Step 3: Starting PX runC

{% include runc/runc-enable-portworx.md %}

>**Note:** If you have previously installed Portworx as a Docker container (as "legacy plugin system", or v1 plugin), and already have PX-volumes allocated and in use by other Docker containers/applications, read [instructions here](/runc/#upgrading-from-px-containers-to-px-oci)

## Adding Nodes

To add nodes to increase capacity and enable high availability, simply repeat these steps on other servers. As long as PX is started with the same cluster ID, they will form a cluster.

## Access the pxctl CLI

{% include pxctl/pxctl-after-docker-install.md %}

## Application Examples

Once you have Portworx up, take a look at an example of running [stateful application with Portworx and Swarm](swarm.html)!
