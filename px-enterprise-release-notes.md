---
layout: page
title: "PX-Enterprise Release notes"
keywords: portworx, px-enterprise, release notes
sidebar: home_sidebar
---

## 1.1.3 Release notes

### Key Features

* Shared volumes (or shared namespace support) [Shared Volumes](/shared-volumes.html)
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
* Class of Service Support. Refer to [CoS](/cos.html)
* Lighthouse on-prem for airgapped environments. Refer to [Lighthouse on-prem](/run-lighthouse.html)
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







