---
layout: page
title: "Upgrade Portworx on DCOS"
keywords: portworx, container, dcos, storage, Docker, mesos
sidebar: home_sidebar
meta-description: "Updating Portworx version on your DCOS cluster is simple. Follow this guide to find out how."
---

* TOC
{:toc}

This guide walks through upgrading Portworx deployed on DCOS

### Upgrade the Portworx image in the systemd service file

On each agent node where Portworx is installed, edit the `/etc/systemd/system/portworx.service` file and change the docker image tag for
the Portworx image to the desired version. For instance if you want to upgrade from 1.2.9 to 1.2.10, change "portworx/px-enterprise:1.2.9" to "portworx/px-enterprise:1.2.10"

### Restart the Portworx service

```
sudo systemctl daemon-reload
sudo systemctl restart portworx
```

### Restart the node if required

Upgrades between some versions require a reboot of the node. If a reboot is required, Portworx will be in initializting state
after the service restart. The Portworx logs will also mention that a reboot is required.
