---
layout: page
title: "GroupSnapshots"
keywords: portworx, pxctl, command-line tool, cli, reference
sidebar: home_sidebar
redirect_from: "/cli-reference.html"
meta-description: "Explore the CLI reference guide for taking group snapshots of container data volumes using Portworx. Try it today!"
---

* TOC
{:toc}

### Group Snapshot Operations
```
/opt/pwx/bin/pxctl volume snapshot group -h
NAME:
   pxctl volume snapshot group - Create group snapshots for given group id or labels
USAGE:
   pxctl volume snapshot group [command options] [arguments...]
OPTIONS:
   --group value, -g value  group id
   --label pairs, -l pairs  list of comma-separated name=value pairs

Take snapshot for volumes with label “v1=x1”:

opt/pwx/bin/pxctl volume snapshot group --label v1=x1
Volume 549285969696152595 : Snapshot 1026872711217134654
Volume 952350606466932557 : Snapshot 218459942880193319


Take snapshot for volumes created with group “group1”

/opt/pwx/bin/pxctl volume snapshot group --group “group1”
Volume 273677465608441312 : Snapshot 609476927441905746

```
