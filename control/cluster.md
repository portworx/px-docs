---
layout: page
title: "CLI Reference–Cluster"
keywords: portworx, pxctl, command-line tool, cli, reference
sidebar: home_sidebar
redirect_from: "/cli-reference.html"
---

* TOC
{:toc}

### Cluster Operations

```
sudo /opt/pwx/bin/pxctl cluster --help
NAME:
   pxctl cluster - Manage the cluster

USAGE:
   pxctl cluster command [command options] [arguments...]

COMMANDS:
     list, l              List nodes in the cluster
     inspect, i           Inspect a node
     delete, d            Delete a node
     alerts, a            Show cluster wide alerts
     node-alerts          Show node related alerts
     provision-status, p  Show cluster provision status
     drive-alerts         Show drive related alerts

OPTIONS:
   --help, -h  show help
```


#### pxctl cluster list
Shows all nodes in the portworx cluster
```
sudo /opt/pwx/bin/pxctl cluster list --help
NAME:
   pxctl cluster list - List nodes in the cluster

USAGE:
   pxctl cluster list [arguments...]
```
```
sudo /opt/pwx/bin/pxctl cluster list
Cluster ID: 8ed1d365-fd1b-11e6-b01d-0242ac110002
Status: OK

Nodes in the cluster:
ID					DATA IP		CPU		MEM TOTAL	MEM FREE	CONTAINERS	VERSION		STATUS
bf9eb27d-415e-41f0-8c0d-4782959264bc	147.75.99.243	0.125078	34 GB		33 GB		N/A		1.1.4-6b35842	Online
7d97f9ea-a4ff-4969-9ee8-de2699fa39b4	147.75.99.171	0.187617	34 GB		33 GB		N/A		1.1.4-6b35842	Online
492596eb-94f3-4422-8cb8-bc72878d4be5	147.75.99.189	0.125078	34 GB		33 GB		N/A		1.1.4-6b35842	Online
```
#### pxctl cluster inspect
Use pxctl cluser inspect to get information on a node in the cluster.  
```
sudo /opt/pwx/bin/pxctl cluster inspect --help
NAME:
   pxctl cluster inspect - Inspect a node

USAGE:
   pxctl cluster inspect [arguments...]
```
```
sudo /opt/pwx/bin/pxctl cluster inspect 492596eb-94f3-4422-8cb8-bc72878d4be5
ID       	:  492596eb-94f3-4422-8cb8-bc72878d4be5
Mgmt IP  	:  147.75.99.189
Data IP  	:  147.75.99.189
CPU      	:  0.8755472170106317
Mem Total	:  33697398784
Mem Used 	:  702279680
Status  	:  Online
Containers:	There are no running containers on this node.
```
#### pxctl cluster delete
Use this command to delete a node in the cluster

```
sudo /opt/pwx/bin/pxctl cluster delete --help
NAME:
   pxctl cluster delete - Delete a node

USAGE:
   pxctl cluster delete [arguments...]
```

```
sudo /opt/pwx/bin/pxctl cluster delete bf9eb27d-415e-41f0-8c0d-4782959264bc
node bf9eb27d-415e-41f0-8c0d-4782959264bc deleted successfully
```

#### pxctl cluster alerts
Shows cluster wide alerts
```
sudo /opt/pwx/bin/pxctl cluster alerts -help
NAME:
   pxctl cluster alerts - Show cluster wide alerts

USAGE:
   pxctl cluster alerts [command options] [arguments...]

OPTIONS:
   --sev value, -s value    Filter alerts based on severity : [WARN|NOTIFY|ALARM]
   --start value, -t value  Time start : Jan 2 15:04:05 UTC 2006
   --end value, -e value    Time end : Jan 2 15:04:05 UTC 2006
   --all                    Specify --all to show cleared alerts in the output
```

```
sudo /opt/pwx/bin/pxctl cluster alerts
AlertID	ClusterID	Timestamp	Severity	AlertType	Description
```

#### pxctl cluster node-alerts
Shows node alerts 
```
sudo /opt/pwx/bin/pxctl cluster node-alerts --help
NAME:
   pxctl cluster node-alerts - Show node related alerts

USAGE:
   pxctl cluster node-alerts [command options] [arguments...]

OPTIONS:
   --sev value, -s value    Filter alerts based on severity : [WARN|NOTIFY|ALARM]
   --start value, -t value  Time start : Jan 2 15:04:05 UTC 2006
   --end value, -e value    Time end : Jan 2 15:04:05 UTC 2006
   --all                    Specify --all to show cleared alerts in the output
```

```
sudo /opt/pwx/bin/pxctl cluster node-alerts
AlertID	NodeID					Timestamp		Severity	AlertType		Description
20	7d97f9ea-a4ff-4969-9ee8-de2699fa39b4	Mar 3 20:20:20 UTC 2017	ALARM		Cluster manager failure	Cluster Manager Failure: Entering Maintenance Mode because of Storage Maintenance Mode
```

#### pxctl cluster provision-status

Shows nodes in the cluster based on IO Priority high, medium and low.  

```
sudo /opt/pwx/bin/pxctl cluster provision-status --help
NAME:
   pxctl cluster provision-status - Show cluster provision status

USAGE:
   pxctl cluster provision-status [command options] [arguments...]

OPTIONS:
   --io_priority value  IO Priority: [high|medium|low] (default: "low")
```

```
sudo /opt/pwx/bin/pxctl cluster provision-status --io_priority low
Node					Node Status	Pool	Pool Status	IO_Priority	Size	Available	Used	Provisioned	ReserveFactor	Zone	Region
492596eb-94f3-4422-8cb8-bc72878d4be5	Online		0	Online		LOW		100 GiB	99 GiB		1.0 GiB	0 B		default	default
492596eb-94f3-4422-8cb8-bc72878d4be5	Online		1	Online		LOW		200 GiB	199 GiB		1.0 GiB	0 B		50		default	default
7d97f9ea-a4ff-4969-9ee8-de2699fa39b4	Online		0	Online		LOW		100 GiB	92 GiB		8.2 GiB	70 GiB		default	default
bf9eb27d-415e-41f0-8c0d-4782959264bc	Online		0	Online		LOW		150 GiB	149 GiB		1.0 GiB	0 B		default	default
```

#### pxctl cluster drive-alerts
Shows cluster wide drive alerts
```
sudo /opt/pwx/bin/pxctl cluster drive-alerts --help
NAME:
   pxctl cluster drive-alerts - Show drive related alerts

USAGE:
   pxctl cluster drive-alerts [command options] [arguments...]

OPTIONS:
   --sev value, -s value    Filter alerts based on severity : [WARN|NOTIFY|ALARM]
   --start value, -t value  Time start : Jan 2 15:04:05 UTC 2006
   --end value, -e value    Time end : Jan 2 15:04:05 UTC 2006
   --all                    Specify --all to show cleared alerts in the output
```   
