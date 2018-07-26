---
layout: page
title: "Deploy Portworx with Docker"
keywords: portworx, architecture, storage, container, cluster, install, docker, compose, systemd, plugin
sidebar: home_sidebar
redirect_from:
 - /runpx.html
 - /run-with-docker.html
 - /scheduler/docker/install-px-docker-service.html
 - /scheduler/docker/docker-plugin.html
---

* TOC
{:toc}

This guide describes installing Portworx using the docker CLI.

>**Important:**<br/>PX stores configuration metadata in a KVDB (key/value store), such as Etcd or Consul. If you have an existing KVDB, you may use that.  If you want to set one up, see the [etcd example](/maintain/etcd.html) for PX. Ensure all nodes running PX are synchronized in time and NTP is configured

## Install and configure Docker

* PX requires a minimum of Docker version 1.10.  Follow the [Docker install](https://docs.docker.com/engine/installation/) guide to install and start the Docker Service.
* You *must* configure Docker to allow shared mounts propagation. Please follow [these](/knowledgebase/shared-mount-propagation.html) instructions to enable shared mount propagation.  This is needed because PX runs as a container and it will be provisioning storage to other containers.

## Identify storage

{% include identify-storage-devices.md %}

## Install PX via OCI runC

PX runs as a container directly via OCI runC.  This ensures that there are no cyclical dependencies between Docker and PX.

[Follow these steps](/runc/index.html) to install PX.

## Adding Nodes

To add nodes to increase capacity and enable high availability, simply repeat these steps on other servers. As long as PX is started with the same cluster ID, they will form a cluster.

## Access the pxctl CLI

{% include pxctl/pxctl-after-docker-install.md %}

## Application Examples

After you complete this installation, continue with the set up to run stateful containers with Docker volumes:

* [Scale a Cassandra Database with PX](/applications/cassandra.html)
* [Run the Docker Registry with High Availability](/applications/docker-registry.html)
* [Other application Solutions](/application-solutions.html)
