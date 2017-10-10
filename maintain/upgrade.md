---
layout: page
title: "Upgrade Portworx"
keywords: upgrade
sidebar: home_sidebar
redirect_from: "/upgrade.html"
meta-description: "Looking to upgrade Portworx Enterprise? Follow these step-by-step instructions and find out how you can upgrade today!"
---

Please visit the scheduler section in the left hand navigation menu in order to use the correct upgrade instructions for your scheduler.  Depending on the orchestration environment, Portworx has different best practices for the upgrade process.

## Upgrading Portworx Standalone

If you have deployed Portworx manually (not through a scheduler), then you can directly upgrade Portworx in a rolling manner as described here.

On each node in the cluster , please execute **'pxctl upgrade'** command as shown below.

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

