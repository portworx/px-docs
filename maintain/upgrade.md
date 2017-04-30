---
layout: page
title: "Upgrade Portworx"
keywords: upgrade
sidebar: home_sidebar
---

## Upgrading Portworx 

Upgrading Portworx Enterprise is performed as a rolling upgrade.
On each node in the cluster , please execute **'pxctl upgrade'** command as shown below.

```
[root@PX-SM2 ~]# pxctl upgrade px-enterprise
Upgrading px-enterprise to the latest version
Downloading latest PX enterprise layers...
Pulling from portworx/px-enterprise
Digest: sha256:5e6fa51a8cd0b2028e70243d480983df07a419228be85031fca9f5a5be0cad2b
Status: Image is up to date for portworx/px-enterprise:latest
Removing old PX enterprise layers...
Starting latest PX Enterprise...
[root@PX-SM2 ~]# pxctl --version
pxctl version 1.0.0-a28e0a4
```

