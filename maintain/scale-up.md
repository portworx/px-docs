---
layout: page
title: "Adding storage to existing PX Cluster Nodes"
keywords: scale-up
sidebar: home_sidebar
redirect_from: "/scale-up.html"
meta-description: "Discover how to add a new node to a PX cluster and how to add additional storage to the PX Cluster once a new node is added.  Try it for yourself today."
---

* TOC
{:toc}

## Adding Storage to exising PX Cluster Nodes 

This section illustrates how to add a new node to a PX cluster and how to add additional storage to the PX Cluster once a new node is added

### Display current cluster status

```
sudo /opt/pwx/bin/pxctl status
Status: PX is operational
Node ID: a56a4821-6f17-474d-b2c0-3e2b01cd0bc3
	IP: 147.75.198.197 
 	Local Storage Pool: 2 pools
	Pool	IO_Priority	Size	Used	Status	Zone	Region
	0	LOW		200 GiB	1.0 GiB	Online	default	default
	1	LOW		120 GiB	1.0 GiB	Online	default	default
	Local Storage Devices: 2 devices
	Device	Path				Media Type		SizLast-Scan
	0:1	/dev/mapper/volume-27dbb728	STORAGE_MEDIUM_SSD	200 GiB		08 Jan 17 16:54 UTC
	1:1	/dev/mapper/volume-0a31ef46	STORAGE_MEDIUM_SSD	120 GiB		08 Jan 17 16:54 UTC
	total					-			320 GiB
Cluster Summary
	Cluster ID: bb4bcf13-d394-11e6-afae-0242ac110002
	Node IP: 147.75.198.197 - Capacity: 2.0 GiB/320 GiB Online (This node)
	Node IP: 10.99.119.1 - Capacity: 1.2 GiB/100 GiB Online
	Node IP: 10.99.117.129 - Capacity: 1.2 GiB/100 GiB Online
Global Storage Pool
	Total Used    	:  4.3 GiB
	Total Capacity	:  520 GiB
```
The above cluster has three nodes and 520GiB of total capacity.

### Add a new node to cluster

Below is an example of how to run PX in a new node so it joins an existing cluster. Note how docker run command is invoked with a cluster token token-bb4bcf4b-d394-11e6-afae-0242ac110002 that has a token- prefix to the cluster ID to which we want to add the new node

```
docker run --restart=always --name px-enterprise -d --net=host --privileged=true -v /run/docker/plugins:/run/docker/plugins -v /var/lib/osd:/var/lib/osd:shared -v /dev:/dev -v /etc/pwx:/etc/pwx -v /opt/pwx/bin:/export_bin:shared -v /var/run/docker.sock:/var/run/docker.sock -v /mnt:/mnt:shared -v /var/cores:/var/cores -v /usr/src:/usr/src -e API_SERVER=http://lighthouse-new.portworx.com portworx/px-enterprise -t token-bb4bcf4b-d394-11e6-afae-0242ac110002 -m team0:0 -d team0
```

Here is how the cluster would look like after a new node is added without any storage

```
sudo /opt/pwx/bin/pxctl status
Status: PX is operational
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
	Node IP: 10.99.119.1 - Capacity: 1.2 GiB/100 GiB Online
	Node IP: 10.99.117.129 - Capacity: 1.2 GiB/100 GiB Online
	Node IP: 147.75.198.197 - Capacity: 2.0 GiB/320 GiB Online
	Node IP: 147.75.104.185 - Capacity: 0 B/0 B Online (This node)
Global Storage Pool
	Total Used    	:  4.3 GiB
	Total Capacity	:  520 GiB
```
Note how the capacity of the cluster has remained unchanged.

### Add more storage to the new node

Added another 100G of storage to this node and the device is seen as /dev/dm-1

```
# multipath -ll
volume-a9e55549 (360014055671ce0d20184a619c27b31d0) dm-1   ,IBLOCK          
size=100G features='0' hwhandler='1 alua' wp=rw
`-+- policy='round-robin 0' prio=1 status=active
  |- 2:0:0:0 sdb 8:16 active ready running
  `- 3:0:0:0 sdc 8:32 active ready running

```

### Enter Maintenance Mode

In order to add more storage to a node, that node must be put in maintenance mode

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

### Add the new drive to cluster to increase the storage

```
sudo /opt/pwx/bin/pxctl service drive add /dev/dm-1
Adding device  /dev/dm-1 ...
Drive add  successful. Requires restart (Exit maintenance mode).
```

### Exit Maintenance Mode

```
sudo /opt/pwx/bin/pxctl service maintenance --exit
PX is now operational.
```

### Check cluster status

As seen below, the 100G of additional capacity is available with total capacity of the cluster going to 620GB

```
sudo /opt/pwx/bin/pxctl status
Status: PX is operational
Node ID: a0b87836-f115-4aa2-adbb-c9d0eb597668
	IP: 147.75.104.185 
 	Local Storage Pool: 1 pool
	Pool	IO_Priority	Size	Used	Status	Zone	Region
	0	LOW		100 GiB	1.0 GiB	Online	default	default
	Local Storage Devices: 1 device
	Device	Path				Media Type		Size	Last-Scan
	0:1	/dev/mapper/volume-a9e55549	STORAGE_MEDIUM_SSD	100 GiB08 Jan 17 21:46 UTC
	total					-			100 GiB
Cluster Summary
	Cluster ID: bb4bcf13-d394-11e6-afae-0242ac110002
	Node IP: 10.99.119.1 - Capacity: 1.2 GiB/100 GiB Online
	Node IP: 147.75.198.197 - Capacity: 2.0 GiB/320 GiB Online
	Node IP: 147.75.104.185 - Capacity: 0 B/100 GiB Online (This node)
	Node IP: 10.99.117.129 - Capacity: 1.2 GiB/100 GiB Online
Global Storage Pool
	Total Used    	:  4.3 GiB
	Total Capacity	:  620 GiB
```





