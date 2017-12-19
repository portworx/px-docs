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

## 1.2.11.0-rc9 Release notes

* Run PX as a storageless node if the underlying pool goes offline
* Improve container attach/detach scenarios where PODs are created or deleted simultaneously over multiple nodes and improve integration around kubernetes
* Run PX as OCI container support - PX will run as a RunC container instead of docker container - Early Access
* Add Read/Write latency statistics
* Add volume name to exported metrics
* Fix diags collection issues where in some cases diags collection can itself hang
* Add checks to maintenance mode to make sure the maintenance mode exit does not happen if there is any drive operation in progress
* Do not exit maintenance mode when drive is added without letting drive rebalance finish
* Improve alerts to have more fine grained alerts for volume and disk related events
* Remove non-px related metrics from Prometheus exports
* Improve node mark down states where a down node's status is properly reflected in kvdb by other nodes
* Increase the number of retries for detaches that happen during volume create
* Add stats for all PX process (virt, res and cpu time)
* Show volume replication status in pxctl volume inspect
* Enqueue snaphots when more snaps happen while a snapshot is in progress
* Do not allow shared and scaled volume settings to co-exist
* Detach encrypted volumes upon docker restarts
* Allow canceling of HA node addition operation when the high-availabilty of volumes are increased by 
  adding a new node to increase the number of replicas
* Rate limit PX alerts
* Enhance IO-Profile=db further and address corner cases found in error injection tests
* Lock all PX processes into memory so they don't get swapped
* Address permissions propagation for shared volumes when wordpress plugins are updated
* Support ASG EBS Volume Templates across AWS Zones
* Rancher Cattle with PX Shared Volumes - Prevent attach to happen before volume is created in the case of 
  shared volumes for successful mounts with Rancher Cattle 
* Display AWS zone information in `pxctl status`
* Kubernetes POD using namespace (shared) volumes do not get terminated properly when the POD using 
  the namespace volume is deleted

### Errata

* When a application POD mounting a shared volume is scheduled on a kubernetes node and if the Portworx container restarts while the mount is in progress, the Mount operation will fail. The application POD needs be restarted when Portworx comes up in that node

* After putting a node into maintenance mode, adding drives, and then running "pxctl service m --exit", the message "Maintenance operation is in progress, cancel operation or wait for completion" doesn't specify which operation hasn't completed. Workaround: Use pxctl to query the status of all three drive operations (add, replace, rebalance). pxctl then reports which drive operations are in progress and allows exiting from maintenance mode if all maintenance operations are completed.

* When running under Kubernetes, adding a node label for a scheduled cloudsnap fails with the error "Failed to update k8s node". A node label isn't needed for cloudsnaps because they are read-only and used only for backup to the cloud.

* When running under Kubernetes, a PVC label created by MySQL POD for the MySQL volume PVC isn't removed from the node labels when the POD is deleted.

* On 3.10 and older Linux kernels when using the Ext4 file system, a volume delete fails with the message "Volume is attached". This issue doesn't occur for scheduled deletes. Workaround: Run pxctl host detach.

* When a cloudsnap is taken when a ha reduce operation is in progress, there is a small window where the cloudsnap operation can fail. In the case of scheduled cloudsnaps, subsequent snaps would succeed. 

* When cloudsnaps are scheduled, sometimes it creates two snapshots at the same time slot instead of one. This will be addressed in the next release.


## 1.2.10.2 Release notes

### Key Features

None

### Key Changes and Issues Addressed

* Fix boot issues with Amazon linux
* Fix issues with shared volume mount and unmount with multiple containers  with kubernetes

## 1.2.10 Release notes

### Key Features

None

### Key Changes and Issues Addressed

* Fix issue when a node running PX goes down, it never gets marked down in the kvdb by other nodes.
* Fix issue when a container in Lighthouse UI always shows as running even after it has exited
* Auto re-attach containers mounting shared volumes when PX container is restarted. 
* Add Linux immutable (CAP_LINUX_IMMUTABLE) when PX is running as Docker V2 Plugin
* Set autocache parameter for shared volumes
* On volume mount, make the path read-only if an unmount comes in if the POD gets deleted or PX is restarted during POD
  creation. On unmount, the delete the mount path.
* Remove the volume quorum check during volume mounts so the mount can be retried until the quorum is achieved
* Allow snapshot volume source to be provided as another PX volume ID and Snapshot ID
* Allow inline snapshot creation in Portworx Kubernetes volume driver using the Portworx Kubernetes volume spec
* Post log messages indicating when logging URL is changed
* Handle volume delete requests gracefully when PX container is starting up
* Handle service account access when PX is running as a container instead of a daemonset when running under kubernetes
* Implement a global lock for kubernetes filter such that all cluster-wide Kubernetes filter operations are 
  coordinated through the lock
* Improvements in unmount/detach handling in kubernetes to handle different POD clean up behaviors for deployments 
  and statefulsets

### Errata

* If two containers using the same shared volume are run in the same node using docker, when one container exits, the container's connection to the volume will get disrupted as well. Workaround is to run containers using shared volume in two different portworx nodes

## 1.2.9 Release notes

>**Important:**<br/> If you are upgrading from an older version of PX (1.2.8 or older) and have PX volumes in attached state, you will need node reboot after upgrade in order for the new version to take effect properly.

### Key Features

* Provide ability to cancel a replication add or HA increase operation
* Automatically decommision a storageless node in the cluster if it has been offline for longer than 48 hours
* [Kubernetes snapshots driver for PX-Enterprise](/scheduler/kubernetes/snaps.html)
* Improve Kubernetes mount/unmount handling with POD failovers and moves


### Key Issues Addressed

* Correct mountpath retrieval for encrypted volumes
* Fix cleanup path maintenance mode exit issue and clean up alerts
* Fix S3 provider for compatibility issues with legacy object storage providers not supporting ListObjectsV2 API correctly.
* Add more cloudsnap related alerts to indicate cloudsnap status and any cloudsnap operation failures.
* Fix config.json for Docker Plugin installs
* Read topology parameters on PX restart so RACK topology information is read correctly on restarts
* Retain environment variables when PX is upgraded via `pxctl upgrade` command
* Improve handling for encrypted scale volumes


## 1.2.8 Release notes

### Key Features

* License Tiers for PX-Enterprise

### Key Issues Addressed

NONE

## 1.2.5 Release notes

### Key Features

* Increase volume limit to 16K volumes

### Key Issues Addressed

* Fix issues with volume CLI hitting a panic when used the underlying devices are from LVM devices
* Fix px bootstrap issues with pre-existing snapshot schedules
* Remove alerts posted when volumes are mounted and unmounted
* Remove duplicate updates to kvdb


## 1.2.4 Release notes

### Key Features

* Support for --racks and --zones option when creating replicated volumes
* Improved replication node add speeds
* Node labels and scheduler convergence for docker swarm
* Linux Kernel 4.11 support
* Unique Cluster-specifc bucket for each cluster for cloudsnaps
* Load balanced cloudsnap backups for replicated PX volumes
* One-time backup schedules for Cloudsnap
* Removed the requirement to have /etc/pwx/kubernetes.yaml in all k8s nodes 


### Key Issues Addressed

* `pxctl cloudsnap credentials` command has been moved under `pxctl credentials`
* Docker inline volume creation support for setting volume aggregation level
* --nodes support for docker inline volume spec
* Volume attach issues after a node restart when container attaching to a volume failed
* PX Alert display issues in Prometheus
* Cloudsnap scheduler display issues where the existing schedules were not seen by some users.
* Removed snapshots from being counted into to total volume count
* Removed non-px related metrics being pushed to Prometheus
* Added CLI feedback and success/failure alerts for `pxctl volume update` command
* Fixed issues with Cloudsnap backup status updates for container restarts


## 1.2.3 Release notes

### Key Features

No new features in 1.2.3. This is a patch release.

### Key Issues Addressed

* Performance improvements for database workloads

## 1.2.2 Release notes

### Key Features

No new features in 1.2.2. This is a patch release.

### Key Issues Addressed

* Fix device detection in AWS autenticated instances

## 1.2.1 Release notes

### Key Features

No new features in 1.2.1. This is a patch release.

### Key Issues Addressed

* Fix issues with pod failovers with encrypted volumes
* Improve performance with remote volume mounts
* Add compatbility for Linux 4.10+ kernels


## 1.2 Release notes

### Key Features

* [AWS Auto-scaling integration with Portworx](/cloud/aws/asg.html) managing EBS volumes for EC2 instances in AWS ASG 
* [Multi-cloud Backup and Restore](/cloud/backups.html) of Portworx Volumes 
* [Encrypted Volumes](/manage/encrypted-volumes.html) with Data-at-rest and Data-in-flight encryption
* [Docker V2 Plugin Support](/scheduler/docker/docker-plugin.html)
* [Prometheus Integeration](/maintain/monitoring/prometheus/index.html)
* [Hashicorp Vault](/secrets/portworx-with-vault.html), [AWS KMS integration](/secrets/portworx-with-aws-kms.html) and 
  Docker Secrets Integration
* [Dynamically resize](/manage/volume-update.html#increase-volume-size) PX Volumes with no application downtime
* Security updates improve PX container security

### Key Issues Addressed

* Issues with volume auto-attach
* Improved network diagnostics on PX container start
* Added an alert when volume state transitions to read-only due to loss of quorum
* Display multiple attached hosts on shared volumes
* Improve shared volume container attach when volume is in resync state
* Allow pxctl to run as normal user
* Improved pxctl help text for commands like pxctl service

### Key Notes

## 1.1.6 Release notes

### Key Features

* Volume Aggregation across multiple nodes to provide scale-out performance
* Self Node Decommission provides ability to for node decommission operations from the node itself
* Automatic decomission of storage-less nodes when they join and leave the cluster as part of a auto-scaling group
* Volume auto-attach and detach for fine grained background processing of volume maintenance operations
* Support rack-aware replication to replicate across racks
* Volume aggregation within a rack

### Key Issues Addressed

* Support PX Volume snapshots via docker volume plugin
* Improved stability and tighter integration for Consul based environments
* Latest Amazon Linux and Debian support
* Rancher catalog support for CoreOS

### Key notes
* COS is now referenced as IO Priority


## 1.1.4 Release notes

### Key Changes

Improve node failure and resync handling

## 1.1.3 Release notes

### Key Features

* Shared volumes (or shared namespace support) [Shared Volumes](/manage/shared-volumes.html)
* Scale Volumes support - Create volumes in scale with single command
* Sticky Volumes support - Create volumes with sticky bit so only a pxctl volume delete can delete it
* Improvements in replication performance
* Debian Linux distro and kernel support

## 1.1.2 Release notes

### Key Features
* Support scaling up to 256 nodes
* Enhanced authentication support for etcd
* Support Kubernetes scheduler placement of containers
* Enhancements to Class of Service to improve better detection on different public clouds. 
* Enhanced drive replacement workflows

### Key Issues Addressed
* Prevent volume updates in maintenance mode from happening
* Fixed netstats calculation to resolve the network throughput display issues
* Improve etcd version check handling in cases where the etcd version is not recieved
* Add support for etcd versions between 2.0 to 2.3

### Key notes
* Note that the shared namespace feature is still in beta.

## 1.1.0 Release notes

### Key Features
* Class of Service Support. Refer to [CoS](/manage/class-of-service.html)
* Lighthouse on-prem for airgapped environments. Refer to [Lighthouse on-prem](/enterprise/lighthouse.html)
* Scale up to 125 nodes


### Key Issues Addressed

* Portworx Flexvolume compatibility fixes with latest Kubernetes
* Changes to improve Marathon and Mesos compatibility
* Fixes to improve maintenance mode entry and exit experience
* REST API improvements for Volume status
* REST API improvements for aggregated node status
* Alert message improvements for HA increase operations
* Fix for shared volume detach failures

### Key notes
* Note that the shared namespace feature is still in beta.


## 1.0.9 Release Notes

* Add Amazon ECS Support. Refer to [Portworx-on-ECS](/portworx-on-ecs.html)

## 1.0.8 Release Notes

* Incremental fixes to the pxctl upgrade that showed version mismatch between the CLI and px daemon after upgrades
* Add support for cloud providers like Packet

## 1.0.7 Release Notes

### Key Features
* Continual online drive health monitoring.

### Key Issues addressed
* Fix for Lighthouse reporting some nodes as online when the entire cluster is down.
* Shared volumes can occasionally cause high CPU spikes.  This has been fixed.
* Improvements to the shared volumes throughput.
* Lighthouse had a bug causing occasional incorrect volume to container mapping.  This has been fixed. 
* Password reset in Lighthouse has been fixed.

## 1.0.6 Release Notes

### Key Features 
* Support for Consul
* Ability to add storage to a head-only node
* Ability to import data from an external storage source
* Ability to bootstrap and deploy PX through external automated procedures.  PX takes command line parameters and does not need a config.json. 
* Support for Rancher

### Key Issues addressed 
* Fix for occasional PX node restart.  Occasionaly during heavy load, a PX node would get marked down by gossip, and asked to restart.  While this did not cause any noticable delay in IO, it would flood the logs with gossip error messages.  This bug has been fixed.
* Minor CLI enhancements around displaying IP addresses instead of node IDs (where possible).








