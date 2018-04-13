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

### New Features:

* SharedV4 - New Architecture for Shared Volumes - Limited Release

### Key Fixes:

* Make adding and removing k8s node labels asynchronous to help with large number volume creations in parallel
* Fix nodes option in docker inline volume create and supply nodes value as semicolon separated values
* Fix namespace client crashes when client list is generated when few client nodes are down.
* Allow read/write snapshots in k8s annotations











