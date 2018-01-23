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

## 1.3.0-rc2 

### Feature updates and noteworthy changes

* Volume create command additions to include volume clone command and integrate snap commands
* Improved snapshot workflows 
* Improved resync performance when a node is down for a long time and restarted
* Improved performance for database workloads by separating transaction logs to a seperate device
* https support for API end-points
* Portworx Open-Storage scaling groups support for AWS ASG - Workflow improvements
* Integrated kvdb - Early Access - Limited Release
* Object store (S3) support - Beta

### Issues addressed

* PWX-4518 - Add a confirmation prompt for `pxctl volume delete` operations
* PWX-4504 - Show all the volumes present in the node in the CLI
* PWX-4475 - Parse io_profile in inline volume spec
* PWX-4479 - Fix io_priority versions when labeling cloudsnaps
* Delete cloudsnap schedules if volume has been deleted
* PWX-4378 - Add read/write latency stats to the volume statistics
* PWX-4923 - Add vol_ prefix to read/write volume latency statistics
* PWX-4288 - Handle app container restarts attached to a shared volume if the mountpath was unmounted via unmount command









