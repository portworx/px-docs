---
layout: page
title: "Upgrade Portworx volume plugin with Swarm"
keywords: portworx, architecture, storage, container, install, docker, upgrade, plugin
sidebar: home_sidebar
---

* TOC
{:toc}

This guide describes upgrading PX when running in swarm.

## Upgrade

Following command will perform upgrade with the latest image.
```
$ docker service update --force portworx
```

If you are running PX as a plugin in a swarm cluster follow the upgrade instructions [here](/scheduler/docker/upgrade-standalone.html)