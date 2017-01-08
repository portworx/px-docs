---
layout: page
title: "Scale-Down Nodes"
keywords: scale-down
sidebar: home_sidebar
---

## Scale-down Nodes 

How to remove an offline node from a cluster

### Identify the cluster that needs to be managed

```
[root@pxdev1 ~]# sudo /opt/pwx/bin/pxctl status
Status: PX is operational
Node ID: a56a4821-6f17-474d-b2c0-3e2b01cd0bc3
	IP: 147.75.198.197 
 	Local Storage Pool: 2 pools
	Pool	IO_Priority	Size	Used	Status	Zone	Region
	0	LOW		200 GiB	1.0 GiB	Online	default	default
	1	LOW		120 GiB	1.0 GiB	Online	default	default
	Local Storage Devices: 2 devices
	Device	Path				Media Type		SizLast-Scan
	0:1	/dev/mapper/volume-27dbb728	STORAGE_MEDIUM_SSD	200 GiB		08 Jan 17 05:39 UTC
	1:1	/dev/mapper/volume-0a31ef46	STORAGE_MEDIUM_SSD	120 GiB		08 Jan 17 05:39 UTC
	total					-			320 GiB
Cluster Summary
	Cluster ID: bb4bcf13-d394-11e6-afae-0242ac110002
	Node IP: 147.75.198.197 - Capacity: 2.0 GiB/320 GiB Online (This node)
	Node IP: 10.99.117.129 - Capacity: 1.2 GiB/100 GiB Online
	Node IP: 10.99.119.1 - Capacity: 1.2 GiB/100 GiB Online
Global Storage Pool
	Total Used    	:  4.3 GiB
	Total Capacity	:  520 GiB
```

### List the nodes in the cluster

```
# sudo /opt/pwx/bin/pxctl cluster list
Cluster ID: bb4bcf13-d394-11e6-afae-0242ac110002
Status: OK

Nodes in the cluster:
ID					DATA IP		CPU		MEM TOTAL	MEM FREE	CONTAINERS	VERSION		STATUS
a56a4821-6f17-474d-b2c0-3e2b01cd0bc3	147.75.198.197	1.629073	8.4 GB		7.9 GB		N/A		1.1.2-c27cf42	Online
2c7d4e55-0c2a-4842-8594-dd5084dce208	10.99.117.129	0.125156	8.4 GB		8.0 GB		N/A		1.1.3-b33d4fa	Online
5de71f19-8ac6-443c-bd83-d3478c485a61	10.99.119.1	0.25		8.4 GB		8.0 GB		N/A		1.1.3-b33d4fa	Online
```

### List the volumes in the cluster

There is one volume in this cluster that is local to the Node 147.75.198.197

```
# sudo /opt/pwx/bin/pxctl volume list
ID			NAME	SIZE	HA	SHARED	ENCRYPTED	PRIORITSTATUS
845707146523643463	testvol	1 GiB	1	no	no		LOW	up - attached on 147.75.198.197
```
In this case, there is one volume in the cluster and it is attached to node with IP 147.75.198.97

### Identify the node to remove from the cluster

In the example below, Node 147.75.198.197 has been marked offline. 

```
# sudo /opt/pwx/bin/pxctl cluster list
Cluster ID: bb4bcf13-d394-11e6-afae-0242ac110002
Status: OK

Nodes in the cluster:
ID					DATA IP		CPU		MEM TOTAL	MEM FREE	CONTAINERS	VERSION		STATUS
2c7d4e55-0c2a-4842-8594-dd5084dce208	10.99.117.129	5.506884	8.4 GB	8.0 GB		N/A		1.1.3-b33d4fa	Online
5de71f19-8ac6-443c-bd83-d3478c485a61	10.99.119.1	0.25		8.4 GB	8.0 GB		N/A		1.1.3-b33d4fa	Online
a56a4821-6f17-474d-b2c0-3e2b01cd0bc3	147.75.198.197	-		-	N/A		1.1.2-c27cf42	Offline
```

### Attach and Detach the volume in one of the surviving nodes

```
# sudo /opt/pwx/bin/pxctl host attach 845707146523643463
Volume successfully attached at: /dev/pxd/pxd845707146523643463
# sudo /opt/pwx/bin/pxctl host detach 845707146523643463
Volume successfully detached
```

### Delete the local volume that belonged to the offline node

```
# sudo /opt/pwx/bin/pxctl volume delete 845707146523643463
Volume 845707146523643463 successfully deleted.
```

### Delete the node that is offline


```
# sudo /opt/pwx/bin/pxctl cluster delete a56a4821-6f17-474d-b2c0-3e2b01cd0bc3
Node a56a4821-6f17-474d-b2c0-3e2b01cd0bc3 successfully deleted.
```

### List the nodes in the cluster to make sure the node is removed

```
[root@pxdev3 ~]# sudo /opt/pwx/bin/pxctl cluster list
Cluster ID: bb4bcf13-d394-11e6-afae-0242ac110002
Status: OK

Nodes in the cluster:
ID					DATA IP		CPU		MEM TOTAL	MEM FREE	CONTAINERS	VERSION		STATUS
2c7d4e55-0c2a-4842-8594-dd5084dce208	10.99.117.129	4.511278	8.4 GB	8.0 GB		N/A		1.1.3-b33d4fa	Online
5de71f19-8ac6-443c-bd83-d3478c485a61	10.99.119.1	0.500626	8.4 GB	8.0 GB		N/A		1.1.3-b33d4fa	Online
```

### Show the cluster status

```
# sudo /opt/pwx/bin/pxctl status
Status: PX is operational
Node ID: 2c7d4e55-0c2a-4842-8594-dd5084dce208
	IP: 147.75.198.199 
 	Local Storage Pool: 1 pool
	Pool	IO_Priority	Size	Used	Status	Zone	Region
	0	LOW		100 GiB	1.2 GiB	Online	default	default
	Local Storage Devices: 1 device
	Device	Path				Media Type		Size	Last-Scan
	0:1	/dev/mapper/volume-9f6be49c	STORAGE_MEDIUM_SSD	100 GiB08 Jan 17 06:34 UTC
	total					-			100 GiB
Cluster Summary
	Cluster ID: bb4bcf13-d394-11e6-afae-0242ac110002
	Node IP: 10.99.117.129 - Capacity: 1.2 GiB/100 GiB Online (This node)
	Node IP: 10.99.119.1 - Capacity: 1.2 GiB/100 GiB Online
Global Storage Pool
	Total Used    	:  2.3 GiB
	Total Capacity	:  200 GiB

```
