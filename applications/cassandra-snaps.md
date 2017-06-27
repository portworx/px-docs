---
layout: page
title: "Taking Consistent Cassandra Snapshots"
keywords: portworx, px-developer, cassandra, database, cluster, storage, snapshots, snaps, backup
sidebar: home_sidebar
---

* TOC
{:toc}

## Managing Snapshots
Cassandra snapshots first flush application memory, then create a hardlink to the `SSTable` files.  This means that the snaps are application consistent (mem is flushed) but the snap data itself is still within the volume, so if something were to happen to the underlying volume, you still have a corrupted volume and can't properly roll back.  So these snaps are useful to going back to a point in time

PX snaps create a real usable volume which is distinct and separate from the volume cassandra is currently using.  That means you can can standup a parallel second instance of cassandra from that volume and so on.  However it is crash consistent (cassandra's memory is not flushed)

### Best Practice
nodetool flush and then px snapshot
