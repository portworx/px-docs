---
layout: page
title: "Maintenance Mode"
keywords: maintenance
sidebar: home_sidebar
---

Maintenance Mode is useful for cases where a node needs to be physically decommissioned.
The most common cases would be for Disk/DIMM/NIC replacement.
For these instances, follow these steps:

### Enter Maintenance Mode 
Run **"pxctl service repair -e"**.
This takes Portworx out of an "Operational" state for a given node.  Perform whatever physical maintenance is needed.

### Restart Portworx
Run **"docker restart px-enterprise"**.
This restarts the Portworx fabric on a given node.

### Exit Maintenance Mode
Run **"pxctl service repair -x"**.
This puts Portworx back in to "Operational" state for a given node.

### Example

```
[root@PX-SM2 ~]# pxctl status
Status: PX is operational
Node ID: 30fa483f-9874-4b38-a4d4-bb8ae8e261fa
	IP: 10.0.0.61
 	Local Storage Pool: 3 devices
	Device	Path		Media Type		Size		Last-Scan
	1	/dev/nvme0n1	STORAGE_MEDIUM_SSD	745 GiB		09 Sep 16 13:30 PDT
	2	/dev/sdf	STORAGE_MEDIUM_MAGNETIC	2.7 TiB		09 Sep 16 13:30 PDT
	3	/dev/sdg	STORAGE_MEDIUM_MAGNETIC	2.7 TiB		09 Sep 16 13:30 PDT
	total			-			6.2 TiB
	Warning: Disk sizes are not the same, therefore disk usage will be suboptimal. For best disk utilization, please use disks of identical size.
Cluster Summary
	Cluster ID: 910b106a-7617-11e6-b5c3-0242ac110003
	Node IP: 10.1.1.61 - Capacity: 17 MiB/6.2 TiB Online (This node)
	Node IP: 10.1.1.153 - Capacity: 17 MiB/746 GiB Online
Global Storage Pool
	Total Used    	:  34 MiB
	Total Capacity	:  6.9 TiB
[root@PX-SM2 ~]# pxctl service remove /dev/sdf
Are you sure? (Y/N): Y
success.
[root@PX-SM2 ~]# pxctl service remove /dev/sdg
Are you sure? (Y/N): Y
success.
[root@PX-SM2 ~]# pxctl status
Status: PX is operational
Node ID: 30fa483f-9874-4b38-a4d4-bb8ae8e261fa
	IP: 10.0.0.61
 	Local Storage Pool: 2 devices
	Device	Path		Media Type		Size		Last-Scan
	1	/dev/nvme0n1	STORAGE_MEDIUM_SSD	745 GiB		09 Sep 16 13:43 PDT
	total			-			745 GiB
Cluster Summary
	Cluster ID: 910b106a-7617-11e6-b5c3-0242ac110003
	Node IP: 10.1.1.61 - Capacity: 17 MiB/3.5 TiB Online (This node)
	Node IP: 10.1.1.153 - Capacity: 17 MiB/746 GiB Online
Global Storage Pool
	Total Used    	:  34 MiB
	Total Capacity	:  4.2 TiB
[root@PX-SM2 ~]# pxctl service repair -e
This is a disruptive operation, PX will restart in maintenance mode.
Are you sure you want to proceed ? (Y/N): Y
PX is not running on this host.
[root@PX-SM2 ~]# pxctl status
PX is not running on this host

[ Power-off machine.  Perform any needed maintenance ]

[root@PX-SM2 ~]# docker restart px-enterprise
px-enterprise
[root@PX-SM2 ~]# pxctl service repair -x
PX is now operational.
[root@PX-SM2 ~]# pxctl status
Status: PX is operational
Node ID: 30fa483f-9874-4b38-a4d4-bb8ae8e261fa
	IP: 10.0.0.61
 	Local Storage Pool: 1 device
	Device	Path		Media Type		Size		Last-Scan
	1	/dev/nvme0n1	STORAGE_MEDIUM_SSD	745 GiB		09 Sep 16 13:46 PDT
	total			-			745 GiB
Cluster Summary
	Cluster ID: 910b106a-7617-11e6-b5c3-0242ac110003
	Node IP: 10.1.1.61 - Capacity: 17 MiB/746 GiB Online (This node)
	Node IP: 10.1.1.153 - Capacity: 17 MiB/746 GiB Online
Global Storage Pool
	Total Used    	:  34 MiB
	Total Capacity	:  1.5 TiB
[root@PX-SM2 ~]#
```
