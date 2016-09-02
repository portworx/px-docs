---
layout: page
title: "Scale-Up Nodes"
keywords: scale-up
sidebar: home_sidebar
---

## Scale-up Nodes 

To scale up storage and add disks on a given node, use the **pxctl service add** command, as shown below:

```
[root@PX-SM2 ~]# pxctl status
Status: PX is operational
Node ID: 003e61eb-51ba-4d42-bd64-06140b91850a
	IP: 10.0.0.61
 	Local Storage Pool: 1 device
	Device	Path		Media Type		Size		Last-Scan
	1	/dev/nvme0n1	STORAGE_MEDIUM_SSD	745 GiB		02 Sep 16 13:12 PDT
	total			-			745 GiB
Cluster Summary
	Cluster ID: a09b980c-7148-11e6-bb1c-0242ac110003
	Node IP: 10.1.1.61 - Capacity: 17 MiB/746 GiB Online (This node)
	Node IP: 10.0.0.153 - Capacity: 17 MiB/746 GiB Online
Global Storage Pool
	Total Used    	:  34 MiB
	Total Capacity	:  1.5 TiB
[root@PX-SM2 ~]# pxctl service add /dev/sdf
Adding device /dev/sdf...success.
[root@PX-SM2 ~]# pxctl status
Status: PX is operational
Node ID: 003e61eb-51ba-4d42-bd64-06140b91850a
	IP: 10.0.0.61
 	Local Storage Pool: 2 devices
	Device	Path		Media Type		Size		Last-Scan
	1	/dev/nvme0n1	STORAGE_MEDIUM_SSD	745 GiB		02 Sep 16 13:14 PDT
	2	/dev/sdf	STORAGE_MEDIUM_MAGNETIC	2.7 TiB		02 Sep 16 13:14 PDT
	total			-			3.5 TiB
	Warning: Disk sizes are not the same.  Disk usage will be suboptimal due to RAID striping.
Cluster Summary
	Cluster ID: a09b980c-7148-11e6-bb1c-0242ac110003
	Node IP: 10.1.1.61 - Capacity: 17 MiB/3.5 TiB Online (This node)
	Node IP: 10.0.0.153 - Capacity: 17 MiB/746 GiB Online
Global Storage Pool
	Total Used    	:  34 MiB
	Total Capacity	:  4.2 TiB
```
