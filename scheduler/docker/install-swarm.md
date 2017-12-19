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

For Docker Swarm or UCP, install [Portworx as a plugin using this page](/scheduler/docker/docker-plugin.html) on each swarm node.

>**Note:** If you have previously installed Portworx as a Docker container (as "legacy plugin system", or v1 plugin), and already have PX-volumes allocated and in use by other Docker containers/applications, read [instructions here](/scheduler/docker/docker-plugin.html#docker-switch-v1-v2)

Once you have Portworx up, take a look at an example of running [stateful application with Portworx and Swarm](swarm.html)!
