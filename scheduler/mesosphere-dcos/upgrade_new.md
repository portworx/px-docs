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
To upgrade to a newer version you need to point this to the desired version.
For example, if you want to upgrade to v1.2.11 you would set this to "portworx/px-enterprise:1.2.11"

![Portworx image option](/images/dcos-px-image-option.png){:width="655px" height="200px"}

### Restart the Portworx install task

Once the image name has been updated, the service file for Portworx needs to be updated on each node. This can be done
by restarting the install task through the dcos cli.

```
$ dcos portworx plan force-restart deploy portworx-deploy
"deploy" plan: phase "portworx-deploy" has been restarted.
```

Now wait for the restarted tasks to go to COMPLETE state on all the agents

```
$ dcos portworx plan status deploy
deploy (COMPLETE)
└─ portworx-deploy (COMPLETE)
   ├─ portworx-0:[install] (COMPLETE)
   ├─ portworx-1:[install] (COMPLETE)
   ├─ portworx-2:[install] (COMPLETE)
   ├─ portworx-3:[install] (COMPLETE)
   └─ portworx-4:[install] (COMPLETE)
```

### Restart Portworx on the agents

Once the service file has been updated, the Portworx service needs to be restarted on the agent nodes to pick up the new
image name. This step will perform a rolling restart of Portworx so as not to cause an outage.

```
$ dcos portworx plan start restart-portworx
{
  "message": "Received cmd: start"
}
```

Now wait for the restart-portworx tasks to go to COMPLETE state on all the agents

```
$ dcos portworx plan status restart-portworx
restart (COMPLETE)
└─ portworx-restart (COMPLETE)
   ├─ portworx-0:[restart] (COMPLETE)
   ├─ portworx-1:[restart] (COMPLETE)
   ├─ portworx-2:[restart] (COMPLETE)
   ├─ portworx-3:[restart] (COMPLETE)
   └─ portworx-4:[restart] (COMPLETE)
```

At this point your Portworx cluster should be upgraded to the specified version.
