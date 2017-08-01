---
layout: page
title: "Upgrade Portworx volume plugin"
keywords: portworx, architecture, storage, container, install, docker, upgrade, plugin
sidebar: home_sidebar
---

* TOC
{:toc}

This guide describes upgrading the PX when running in swarm.

## Upgrade

Following command will perform upgrade with the latest image.
```
$ docker service update --force portworx
```
