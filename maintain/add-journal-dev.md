---
layout: page
title: "Adding journal device  to existing PX Nodes"
keywords: journal device
sidebar: home_sidebar
redirect_from:
  - /journal-device.html
meta-description: "Discover how to add a journal device  to a PX node to increase performace."
---

* TOC
{:toc}

## Adding Journal Device to an existing node.

This section illustrates how to add a journal device to an existing node.

### 1. Enter maintenance mode

In order to add journal device to a node, the node must be put in maintenance mode

```
sudo /opt/pwx/bin/pxctl service maintenance --enter
This is a disruptive operation, PX will restart in maintenance mode.
Are you sure you want to proceed ? (Y/N): Y
```

Check if the node is in maintenance mode

```
sudo /opt/pwx/bin/pxctl status
PX is in maintenance mode.  Use the service mode option to exit maintenance mode.
Node ID: a0b87836-f115-4aa2-adbb-c9d0eb597668
	IP: 147.75.104.185 
 	Local Storage Pool: 0 pool
	Pool	IO_Priority	Size	Used	Status	Zone	Region
	No storage pool
	Local Storage Devices: 0 device
	Device	Path	Media Type	Size		Last-Scan
	No storage device
	total		-	0 B
Cluster Summary
	Cluster ID: bb4bcf13-d394-11e6-afae-0242ac110002
	Node IP: 147.75.104.185 - Node ID: a0b87836-f115-4aa2-adbb-c9d0eb597668 In Maintenance
Global Storage Pool
	Total Used    	:  0 B
	Total Capacity	:  0 B

AlertID	Resource	ResourceID				Timestamp	Severity	AlertType		Description
39	CLUSTER		a56a4821-6f17-474d-b2c0-3e2b01cd0bc3	Jan 8 06:01:22 UTC 2017	ALARM		Node state change	Node a56a4821-6f17-474d-b2c0-3e2b01cd0bc3 has an Operational Status: Down
48	NODE		a0b87836-f115-4aa2-adbb-c9d0eb597668	Jan 8 21:45:25 UTC 2017	ALARM		Cluster manager failure	Cluster Manager Failure: Entering Maintenance Mode because of Storage Maintenance Mode
```

### 2. Add the journal device to the node

A journal device  is recommended to be an SSD/NVME. 

```
sudo /opt/pwx/bin/pxctl service drive add -d /dev/nvme01 --journal
Successfully added journal device /dev/nvme010p1
```

NOTE: The journal device is expected to not have any filesystem on it, This can be verified by running `blkid /dev/nvme01`. If it has a filesystem on it and you still want to use it as a journal device, the filesystem should be removed by running `wipefs -a /dev/nvme01`

### 3. Exit maintenance mode

```
sudo /opt/pwx/bin/pxctl service maintenance --exit
```
