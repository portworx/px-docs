---
layout: page
title: "PX-Enterprise Release notes - for RC builds"
keywords: portworx, px-enterprise, release notes
sidebar: home_sidebar
redirect_from:
  - /px-enterprise-release-notes.html
  - /release-notes-1-0-4.html
meta-description: "Stay up to date with the new releases and updates from Portworx. See our latest key features and an explanation of them all!"
---

* TOC
{:toc}

## 1.3.1 (WIP)

This is a patch release with shared volume performance and stability fixes

### Key Fixes:

* Fix namespace client crashes when client list is generated when few client nodes are down.
* Allow read/write snapshots in k8s annotations
* Make adding and removing k8s node labels asynchronous to help with large number volume creations in parallel
* Fix PX crash when a snapshot is taken at the same time as node being marked down because of network failures
* Fix nodes option in docker inline volume create and supply nodes value as semicolon separated values












