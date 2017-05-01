---
layout: page
title: "Scale-Down Nodes"
keywords: scale-down
sidebar: home_sidebar
redirect_from: "/scale-down.html"
---

## Removing offline Nodes 

How to remove an offline node from a cluster. For information on nodes with no storage that have been offline for an extended period, peruse the section titled "Automatic decommission of storage less nodes"

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
## Removing a functional node from a cluster
A functional PX node may need to be removed from the cluster. In this section, we'll demonstrate:
 1- the removal of a node by running commands on itself and
 2- the removal of a node from another node.
The below output from a pxctl status command clarifies the state of the cluster and the different node IPs and node IDs.
```
[root@ip-172-31-46-119 ~]# /opt/pwx/bin/pxctl status
Status: PX is operational
Node ID: 5f8b8417-af2b-4ea7-930e-0027f6bbcbd1
        IP: 172.31.46.119
        Local Storage Pool: 1 pool
        POOL    IO_PRIORITY     SIZE    USED    STATUS  ZONE    REGION
        0       LOW             64 GiB  11 GiB  Online  c       us-east-1
        Local Storage Devices: 1 device
        Device  Path            Media Type              Size            Last-Scan
        0:1     /dev/xvdf       STORAGE_MEDIUM_SSD      64 GiB          25 Feb 17 21:13 UTC
        total                   -                       64 GiB
Cluster Summary
        Cluster ID: 0799207a-eec6-4fc6-a5f1-d4a612b74cc3
        IP              ID                                      Used    Capacity        Status
        172.31.40.38    ec3ed4b9-68d5-4e83-a7ce-2bc112f5f131    11 GiB  64 GiB          Online
        172.31.37.211   17a6fb2c-0d19-4bae-a73f-a85e0514ae8b    11 GiB  64 GiB          Online
        172.31.35.130   a91175b6-ff69-4eff-8b7f-893373631483    11 GiB  64 GiB          Online
        172.31.45.106   048cc2f8-022e-47d9-b600-2eeddcd64d51    11 GiB  64 GiB          Online
        172.31.45.56    f9cb673e-adfa-4e4f-a99a-ec8e1420e645    11 GiB  64 GiB          Online
        172.31.46.119   5f8b8417-af2b-4ea7-930e-0027f6bbcbd1    11 GiB  64 GiB          Online (This node)
        172.31.39.201   355ee6aa-c7eb-4ac6-b16b-936b1b58aa24    11 GiB  64 GiB          Online
        172.31.33.151   871c503d-fa6e-4599-a533-41e70a72eafd    11 GiB  64 GiB          Online
        172.31.33.252   651ca0f4-c156-4a14-b2f3-428e727eb6b8    11 GiB  64 GiB          Online
Global Storage Pool
        Total Used      :  99 GiB
        Total Capacity  :  576 GiB
```

### Placing the node in maintenance mode
After identifying the node to be removed (see section "Identify the node to remove from the cluster" above), place the node in maintenance mode. 
```
[root@ip-172-31-45-106 centos]# /opt/pwx/bin/pxctl service maintenance --enter
This is a disruptive operation, PX will restart in maintenance mode.
Are you sure you want to proceed ? (Y/N): y
Entered maintenance mode.
```
or
```
[root@ip-172-31-33-252 centos]# /opt/pwx/bin/pxctl service maintenance --enter -y
Entered maintenance mode.
```
The 2nd command merely skips the confirmation prompt by specifying "-y".

### Run the cluster delete command
Example 1 shows cluster delete command from a different node.
```
[root@ip-172-31-46-119 ~]# /opt/pwx/bin/pxctl cluster delete 048cc2f8-022e-47d9-b600-2eeddcd64d51
Node 048cc2f8-022e-47d9-b600-2eeddcd64d51 successfully deleted.
```
Example 2 shows cluster delete command from itself.
```
[root@ip-172-31-33-252 centos]# /opt/pwx/bin/pxctl cluster delete 651ca0f4-c156-4a14-b2f3-428e727eb6b8
Node 651ca0f4-c156-4a14-b2f3-428e727eb6b8 successfully deleted.
```
### Prevention of data loss
If any node hosts a volume with replication factor = 1, then we disallow decommissioning of such a node because there is data loss.

One possible workaround to go through with the decommission of such a node is to increase the replication of single replica volumes by running "volume ha-update".

Once completely replicated onto another node, then re-attempt the node decommission. This time, the volume already has another replica on another node and so decommissioning the node will reduce the replication factor of the volume and remove the node.

## Automatic decommission of storage less nodes
 * Storage less nodes that are initialized and added to the cluster may not be needed once they complete their tasks (for ex in a scheduler workflow). If they are taken offline/destroyed, the cluster will still retain the nodes and mark them as offline.
 * If eventually a majority of such nodes exist, the cluster won't have quorum nodes that are online. The solution is to run cluster delete commands and remove such nodes. This gets more laborious with more such nodes or frequency of such nodes added and taken down.
 * To help with this, PX waits until a grace period of 10 min. After this period offline nodes with no storage will be removed from the cluster. There is no CLI command needed to turn on or trigger this feature.
