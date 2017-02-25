---
layout: page
title: "CLI Reference"
keywords: portworx, pxctl, command-line tool, cli, reference
sidebar: home_sidebar
---
The Portworx command-line tool, `pxctl`, is available on every node where PX is running.  It is exposed at the host at `/opt/pwx/bin/pxctl`.  The CLI is designed to display human readable output by default.  In addition, every command takes in a `-j` option such that the output is in machine parsable `json` format.
	
In most production deployments, you will provision volumes directly using Docker or your scheduler (such as a Kubernetes pod spec).  However, pxctl also lets you directly provision and manage storage. In addition, the pxctl has a rich set of cluster wide management features which are explained in this document.

## About `pxctl`

All operations from `pxctl` are reflected back into the containers that use Portworx storage. In addition to what is exposed in Docker volumes, `pxctl`:

* Gives access to Portworx storage-specific features, such as cloning a running container's storage.
* Shows the connection between containers and their storage volumes.
* Let you control the Portworx storage cluster, such as adding nodes to the cluster. (The Portworx tools refer to servers managed by Portworx storage as *nodes*.)

The scope of the `pxctl` command is global to the cluster. Running `pxctl` from any node within the cluster therefore shows the same global details. `pxctl` also identifies details specific to that node.

This current release of `pxctl` requires that you run as a privileged user:

```
sudo su
```

The `pxctl` tool is available in the `/opt/pwx/bin/` directory. To run `pxctl` without typing the full directory path each time, add `pxctl` to your PATH as follows:

```
export PATH=/opt/pwx/bin:$PATH
```

Now you can just type `pxctl` and you're ready to start.
