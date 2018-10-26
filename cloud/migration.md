---
layout: page
title: "Cloud Migration"
keywords: cloud, backup, restore, snapshot, DR, migration
---

* TOC
{:toc}

## Overview
The CloudMigration feature can be used to migrate Portworx volumes between clusters. This requires first pairing up two 
clusters and then starting migration between the two clusters.

The pairing is uni-directional i.e. if you pair Cluster C1 with C2 you can only migrate volumes from C1 to C2.

Cluster Pairing and Migration can be triggered in two ways:

* [Using stork](migration-stork.html). This can be used to migrate volumes as well as Kubernetes resources.
* [Using pxctl](migration-pxctl.html). This can be used to migrate only volumes between two Portworx clusters.

