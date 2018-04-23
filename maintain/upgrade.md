---
layout: page
title: "Upgrade Portworx"
keywords: upgrade, update, portworx
sidebar: home_sidebar
redirect_from: "/upgrade.html"
meta-description: "Looking to upgrade Portworx Enterprise? Follow these step-by-step instructions and find out how you can upgrade today!"
---

If you use a scheduler, refer to its page below

- [Kubernetes](https://docs.portworx.com/scheduler/kubernetes/upgrade.html)
- [Mesosphere DC/OS](https://docs.portworx.com/scheduler/mesosphere-dcos/upgrade-oci.html)
- [Docker](https://docs.portworx.com/runc/#upgrade-px-oci)

## Upgrading Portworx Standalone

If you have deployed Portworx manually (not through a scheduler), then you can directly upgrade Portworx in a rolling manner as described here.

On each node in the cluster , please execute `pxctl upgrade` command as shown below.

```
# pxctl upgrade px-enterprise
Upgrading px-enterprise to the latest version
Downloading latest PX enterprise layers...
Pulling from portworx/px-enterprise
Digest: sha256:5e6fa51a8cd0b2028e70243d480983df07a419228be85031fca9f5a5be0cad2b
Status: Image is up to date for portworx/px-enterprise:latest
Removing old PX enterprise layers...
Starting latest PX Enterprise...

# pxctl --version
pxctl version 1.0.0-a28e0a4
```

