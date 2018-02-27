---
layout: page
title: "Performance Tuning"
keywords: portworx, px-enterprise, storage, volume, create volume, clone volume, performance
sidebar: home_sidebar
meta-description: "Create, manage and inspect storage volumes with pxctl CLI. Discover how to use Docker together with Portworx!"
redirect_from:
  - /manage/io_profile.html
  - /manage/io-profile.html
---

Portworx has best practices for both global container level optimization, as well as volume granular optimization.

## Global performance tuning
As of PX version 1.3, it is recommended to use a journal device to absorb PX metadata writes.  Journal writes are small with frequent syncs and therefore only SSD/NVME should be configured as a journal device.

The journal device should be 2GB.  Using a larger device will not help, since PX will only use 2GB of the journal device.  The journal device can be specified via the `-j` option during installation, documented [here](/runc/options.html#options).

If you are upgrading to 1.3 and want to add a journal device to an existing node, follow [these instructions](/maintain/add-journal-dev.html).

## Volume granular performance tuning
By default, PX will try to auto tune the IO profile setting for a given volume by learning from the access patterns.  However, this algorithm can be overridden and a specific profile can be chosen.

The IO profile can be selected while creating the volume via the `io_profile` flag.  For example:

```
# pxctl volume create --size=10 --repl=3 --io_profile=sequential demovolume
or
# docker volume create -d pxd io_priority=high,size=10G,repl=3,io_profile=random,name=demovolume
```

It is highly recommended to let PX decide the correct IO profile tuning.  If you do however override the setting, you should understand the operation of each profile setting.

### Sequential
This optimizes the read ahead algorithm for sequential access.  Use `io_profile=sequential`.

### Random
This records the IO pattern of recent access and optimizes the read ahead and data layout algorithms for short term random patterns.  Use `io_profile=random`.

### CMS
This is useful for content management systems, like WordPress.  This option applies to a PX shared (global namespace) volume.  It implements an attribute cache and supports async writes.  This increases the PX memory footprint by 100MB.  Use `io_profile=cms`.

### DB
This implements a write-back flush coalescing algorithm.  This algorithm attempts to coalesce multiple `syncs` that occur within a 50ms window into a single sync. Coalesced syncs are acknowledged only after copying to all replicas. In order to do this, the algorithm requires a minimum replication (HA factor) of 3. This mode assumes all replicas do not fail (kernel panic or power loss) simultaneously in a 50 ms window. Use `io_profile=db`.

>**Note:**<br/>If there are not enough nodes online, PX will automatically disable this algorithm.
