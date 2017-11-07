---
layout: page
title: "Upgrade Portworx on DCOS (new)"
keywords: portworx, container, dcos, storage, Docker, mesos
---

* TOC
{:toc}

This guide walks through upgrading Portworx deployed on DCOS through the framework available in the DCOS catalog.

### Update the Portworx image in the framework config

The Portworx image to be used on each node is specified by the framework variable PORTWORX_IMAGE_NAME.
To upgrade to a newer version of Portworx you need to point this to the desired version.
For example, if you want to upgrade to v1.2.11 you would set this to "portworx/px-enterprise:1.2.11"

![Portworx image option](/images/dcos-px-image-option.png){:width="655px" height="200px"}

### Restart the Portworx update task

Once the image name has been updated, the service file for Portworx needs to be updated on each node and the Portworx service
needs to be restarted on all the nodes to pick up the new image name. This can be done by force restarting the
update-portworx plan through the dcos cli. This step will perform a rolling restart of Portworx so as not to cause an
outage.

```
$ dcos portworx plan start update-portworx
{
  "message": "Received cmd: start"
}
```

Now wait for the tasks to go to COMPLETE state on all the agents

```
$ dcos portworx plan status update-portworx
update-portworx (COMPLETE)
├─ update-service (COMPLETE)
│  ├─ portworx-0:[install] (COMPLETE)
│  ├─ portworx-1:[install] (COMPLETE)
│  ├─ portworx-2:[install] (COMPLETE)
│  ├─ portworx-3:[install] (COMPLETE)
│  └─ portworx-4:[install] (COMPLETE)
└─ restart-service (COMPLETE)
   ├─ portworx-0:[restart] (COMPLETE)
   ├─ portworx-1:[restart] (COMPLETE)
   ├─ portworx-2:[restart] (COMPLETE)
   ├─ portworx-3:[restart] (COMPLETE)
   └─ portworx-4:[restart] (COMPLETE)
```

At this point your Portworx cluster should be upgraded to the specified version.
