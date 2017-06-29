---
layout: page
title: "PX-Enterprise Release notes"
keywords: portworx, px-enterprise, release notes
sidebar: home_sidebar
redirect_from: "/px-enterprise-release-notes.html"
---

* TOC
{:toc}

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

* [AWS Auto-scaling integration with Portworx](/cloud/aws-ec2-asg.html) managing EBS volumes for EC2 instances in AWS ASG 
* [Multi-cloud Backup and Restore](/cloud/backups.html) of Portworx Volumes 
* [Encrypted Volumes](/manage/encrypted-volumes.html) with Data-at-rest and Data-in-flight encryption
* [Docker V2 Plugin Support](/scheduler/docker/docker-plugin.html)
* [Prometheus Integeration](/maintain/prometheus.html)
* [Hashicorp Vault](https://docs.portworx.com/portworx-with-vault.html), [AWS KMS integration](https://docs.portworx.com/portworx-with-aws-kms.html) and 
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
* Lighthouse on-prem for airgapped environments. Refer to [Lighthouse on-prem](/enterprise/on-premise-lighthouse.html)
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







