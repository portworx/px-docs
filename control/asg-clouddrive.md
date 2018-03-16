---
layout: page
title: "CLI Reference"
keywords: portworx, pxctl, command-line tool, cli, reference
sidebar: home_sidebar
redirect_from: "/cli-reference.html"
---

* TOC
{:toc}

### CloudDrive operations

Portworx when running in ASG mode provides a set of CLI commands to display the information about all EBS volumes
and their attachment information.

#### Cloud Drive Help
```
# /opt/pwx/bin/pxctl clouddrive --help
NAME:
   pxctl clouddrive - Manage cloud drives

USAGE:
   pxctl clouddrive command [command options] [arguments...]

COMMANDS:
     list, l       List all the cloud drives currently being used
     inspect, i    Inspect and view all the drives of a DriveSet

OPTIONS:
   --help, -h  show help
```

{% include asg/cli.md list="# /opt/pwx/bin/pxctl clouddrive list" inspect="# /opt/pwx/bin/pxctl clouddrive inspect --nodeid ip-172-20-53-168.ec2.internal" %}
