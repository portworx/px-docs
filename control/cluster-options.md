---
layout: page
title: "CLI Reference–Cluster Options"
keywords: portworx, pxctl, command-line tool, cli, reference
meta-description: "This guide shows you how to use the PXCL CLI to update cluster options."
---

* TOC
{:toc}

#### pxctl cluster options list
Shows the options that are being by this cluster.
```
pxctl cluster options list -h
NAME:
   pxctl cluster options list - List cluster wide options

USAGE:
   pxctl cluster options list
```

#### pxctl cluster options update
Updates the provided option to corresponding value to which takes effect immediately. You can provide all the options together or one at a time.
- `auto-decommission-timeout` is the timeout after which offline storage-less nodes will be automatically decommissioned
- `repl-move-timeout` is the timeout after which offline replicas for volumes will be moved to online nodes

```
pxctl cluster options update -h
NAME:
   pxctl cluster options update - Update cluster wide options

USAGE:
   pxctl cluster options update [command options]

OPTIONS:
   --auto-decommission-timeout value  Timeout (in minutes) after which storage-less nodes will be automatically decommissioned. Timeout cannot be set to zero. (default: 20)
   --repl-move-timeout value          Timeout (in minutes) after which offline replicas will be moved to available nodes. Set timeout to zero to disable replica move (default: 1440)
```
