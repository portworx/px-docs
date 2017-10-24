---
layout: page
title: "IO Profile tuning on PX volumes"
keywords: portworx, px-enterprise, storage, volume, create volume, clone volume, performance
sidebar: home_sidebar
meta-description: "Create, manage and inspect storage volumes with pxctl CLI. Discover how to use Docker together with Portworx!"
---

By default, PX will try to auto tune the IO profile setting for a given volume by learning from the access patterns.  However, this algorithm can be overridden and a specific profile can be chosen.

The IO profile can be selected while creating the volume via the `io_profile` flag.  For example:

```
# pxctl volume create --size=10 --repl=3 --io_profile=sequential demovolume
or
# docker volume create -d pxd io_priority=high,size=10G,repl=3,io_profile=random,name=demovolume
```

## IO Profile settings
It is highly recommended to let PX decide the correct IO profile tuning.  If you do however override the setting, you should understand the operation of each profile setting.

### Sequential
This optimizes the read ahead algorithm for sequential access.  Use `io_profile=sequential`.

### Random
This records the IO pattern of recent access and optimizes the read ahead and data layout algorithms for short term random patterns.  Use `io_profile=random`.

### DB
This implements a write-back flush coalescing algorithm.  This algorithm attempts to coalesce multiple `syncs` that occur within a 50ms window into a single sync. Coalesced syncs are acknowledged only after copying to all replicas. In order to do this, the algorithm requires a minimum replication (HA factor) of 3. This mode assumes 3 failures do not occur in a 50 ms window. Use `io_profile=db`.

>**Note:**<br/>If there are not enough nodes online, PX will automatically disable this algorithm.
