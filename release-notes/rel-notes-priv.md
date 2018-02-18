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

## 1.3.0 (WIP)

Upgrade Note 1: Upgrade to 1.3 requires a node restart in non-k8s environments. In k8s environments, the cluster does a rolling upgrade

Uprade Note 2: Ensure all nodes in PX cluster are running 1.3 version before increasing replication factor for the volumes

### Feature updates and noteworthy changes

* Volume create command additions to include volume clone command and integrate snap commands
* Improved snapshot workflows 
  * Group snapshots
  * Clones - full volume copy created from a snapshot
  * Changes to snapshot CLI. See Snapshot CLI reference guide
  * Creating scheduled snapshots policies per volume
* Improved resync performance when a node is down for a long time and restarted with accumulated data in the surviving nodes
* Improved performance for database workloads by separating transaction logs to a seperate device
* Added PX signature to drives so drives cannot be accidentally re-used even if the cluster has been deleted. (TBD: Point to documentation on how the signature can be erased drives can be reused)
* Per volume cache attributes for shared volumes
* https support for API end-points
* Portworx Open-Storage scaling groups support for AWS ASG - Workflow improvements
  * Added command `pxctl cloud list` to list all the drives created via ASG
* Integrated kvdb - Early Access - Limited Release for small clusters less than 10 nodes
* Object store (S3) support - Beta

### New CLI Additions and changes to existing ones
* Added `pxctl service node-wipe` to wipe PX metadata from a decommisioned node in the cluster
* Change `snap_interval` parameter to `periodic`


### Issues addressed

* PWX-4518 - Add a confirmation prompt for `pxctl volume delete` operations
* PWX-4655 - Improve "PX Cluster Not In Quorum" Message in `pxctl status` to give additional information. 
* PWX-4504 - Show all the volumes present in the node in the CLI
* PWX-4475 - Parse io_profile in inline volume spec
* PWX-4479 - Fix io_priority versions when labeling cloudsnaps
* PWX-4378 - Add read/write latency stats to the volume statistics
* PWX-4923 - Add vol_ prefix to read/write volume latency statistics
* PWX-4288 - Handle app container restarts attached to a shared volume if the mountpath was unmounted via unmount command
* PWX-4372 - Gracefully handle trial license expiry and PX cluster reinstall
* PWX-4544 - PX OCI install is unable to proceed with aquasec container installed
* PWX-4531 - Add OS Distribution and Kernel version display in `pxctl status`
* PWX-4547 - cloudsnap display catalog with volume name hits "runtime error: index out of range"
* PWX-4585 - handle kvdb server timeouts with improved retry mechanism
* PWX-4665 - Do not allow drive add to a pool if a rebalance operation is already in progress
* PWX-4691 - Do not allow snapshots on down nodes or if the node is maintenance mode
* PWX-4397 - Set the correct zone information for all replica-sets
* PWX-4375 - Add `pxctl upgrade` support for OCI containers
* PWX-4733 - Remove Swarm Node ID check dependencies for PX bring up
* PWX-4484 - Limit replication factor increases to a limit of three at a time within a cluster and one per node
* PWX-4090 - Reserve space in each pool to handle rebalance operations
* PWX-4544 - Handle ./aquasec file during OCI-Install so PX can be installed in environments with aquasec
* PWX-4497 - Enable minio to mount shared volumes
* PWX-4551 - Improve `pxctl volume inspect` to show pools on which volumes are allocated, replica nodes and replication add
* PWX-4884 - Prevent replication factor increases if all the nodes in the cluster are not running 1.3.0
* PWX-4504 - Show all the volumes present on a node in CLI with a `--node` option











