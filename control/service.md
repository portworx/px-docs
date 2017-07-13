---
layout: page
title: "CLI Reference–Service"
keywords: portworx, pxctl, command-line tool, cli, reference
sidebar: home_sidebar
redirect_from: "/cli-reference.html"
---

* TOC
{:toc}

### Service Operations 
```
sudo /opt/pwx/bin/pxctl service --help
NAME:
   pxctl service - Service mode utilities

USAGE:
   pxctl service command [command options] [arguments...]

COMMANDS:
     exit, e         Stop the PX daemon
     info, i         Show PX module version information
     call-home       Enable or disable the call home feature
     logs            Display PX logs
     diags, d        creates a new tgz package with minimal essential diagnostic information.
     maintenance, m  Maintenance mode operations
     drive           Storage drive maintenance
     scan            scan for bad blocks
     alerts          System alerts
     stats           System stats

OPTIONS:
   --help, -h  show help
```

#### pxctl service info
Displays all Version info 
```
sudo /opt/pwx/bin/pxctl service info
PX Version:  1.1.4-6b35842
PX Build Version:  6b358427202f19c3174ba14fe65b44cc43a3f5fc
PX Kernel Module Version:  C3141A5E02664E50B5AA5EF
```

#### pxctl service call-home
You can use this command to enable and disable the call home feature
```
sudo /opt/pwx/bin/pxctl service call-home --help
NAME:
   pxctl service call-home - Enable or disable the call home feature

USAGE:
   pxctl service call-home [arguments...]
```
```   
 sudo /opt/pwx/bin/pxctl service call-home enable
Call home feature successfully enabled
```
#### pxctl service logs
Displays the pxctl logs on the system
```
sudo /opt/pwx/bin/pxctl service logs --help
NAME:
   pxctl service logs - Display PX logs

USAGE:
   pxctl service logs [arguments...]
```
   
#### pxctl service diags
When there is an operational failure, you can use pxctl service diags &lt;name-of-px-container&gt; to generate a complete diagnostics package. This package will be automatically uploaded to Portworx. Additionally, the service package can be mailed to Portworx at support@portworx.com. The package will be available at /tmp/diags.tgz inside the PX container. You can use docker cp to extract the diagnostics package.
```
sudo /opt/pwx/bin/pxctl service diags --help
NAME:
   pxctl service diags - creates a new tgz package with minimal essential diagnostic information.

USAGE:
   pxctl service diags [command options] [arguments...]

OPTIONS:
   --output value, -o value  output file name (default: "/tmp/diags.tar.gz")
   --dockerhost value        docker host daemon (default: "unix:///var/run/docker.sock")
   --container value         PX container ID
   --host                    PX running on host
   --live, -l                gets diags from running px
   --upload, -u              upload diags to cloud
   --profile, -p             only dump profile
   --all, -a                 creates a new tgz package with all the available diagnostic information.
```   
```
sudo /opt/pwx/bin/pxctl service diags --container px-enterprise
PX container name provided:  px-enterprise
INFO[0000] Connected to Docker daemon.  unix:///var/run/docker.sock 
Getting diags files...
Generated diags: /tmp/diags.tar.gz
```
#### pxctl service maintenance
Service maintenance command lets the cluster know that it is going down for maintenance. Once the server is offline you can add/remove drives add memory etc... 
```
sudo /opt/pwx/bin/pxctl service maintenance --help
NAME:
   pxctl service maintenance - Maintenance mode operations

USAGE:
   pxctl service maintenance [command options] [arguments...]

OPTIONS:
   --exit, -x   exit maintenance mode
   --enter, -e  enter maintenance mode
```
```   
sudo /opt/pwx/bin/pxctl service maintenance --enter 
This is a disruptive operation, PX will restart in maintenance mode.
Are you sure you want to proceed ? (Y/N): y
```

#### pxctl service drive
You can manage the physical storage drives on a node using the pxctl service drive sub menu.
```
sudo /opt/pwx/bin/pxctl service drive
NAME:
   pxctl service drive - Storage drive maintenance

USAGE:
   pxctl service drive command [command options] [arguments...]

COMMANDS:
     show           Show drives
     add            Add storage
     replace        Replace source drive with target drive
     rebalance, rs  Rebalance storage

OPTIONS:
   --help, -h  show help
```
To rebalance the storage across the drives, use pxctl service drive rebalance. This is useful after prolonged operation of a node.

#### pxctl service drive show
You can use pxctl service drive show to display drive information on the server
```   
sudo /opt/pwx/bin/pxctl service drive show
PX drive configuration:
Pool ID: 0
	IO_Priority: LOW
	Size: 100 GiB
	Status: Online
	Has meta data: Yes
	Drives:
	1: /dev/mapper/volume-e85a42ca, 1.0 GiB allocated of 100 GiB, Online
```	
	
You can add drives to a server using the /opt/pwx/bin/pxctl service drive add command.  To do so the server must be in maintenance mode. 
```
sudo /opt/pwx/bin/pxctl service drive add --help
NAME:
   pxctl service drive add - Add storage

USAGE:
   pxctl service drive add [arguments...]
```
```
sudo /opt/pwx/bin/pxctl  service drive add /dev/mapper/volume-3bfa72dd
Adding device  /dev/mapper/volume-3bfa72dd ...
Drive add  successful. Requires restart (Exit maintenance mode).
```
#### pxctl service scan
You can use pxctl service scan to scan for bad blocks on a drive
```   
 sudo /opt/pwx/bin/pxctl service scan
NAME:
   pxctl service scan - scan for bad blocks

USAGE:
   pxctl service scan command [command options] [arguments...]

COMMANDS:
     start     start scan
     resume    resume paused scan
     pause     pause running scan
     cancel    cancel running scan
     status    scan status
     schedule  examine or set schedule

OPTIONS:
   --help, -h  show help
```
#### pxctl service alerts
pxctl service alerts will show cluster wide alerts.  You can also use service alerts to clear and erase alerts.  
```
sudo /opt/pwx/bin/pxctl service alerts
NAME:
   pxctl service alerts - System alerts

USAGE:
   pxctl service alerts command [command options] [arguments...]

COMMANDS:
     show, a   Show alerts
     clear, c  Clear alerts
     erase     Erase alerts

OPTIONS:
   --help, -h  show help
```

```
sudo /opt/pwx/bin/pxctl service alerts show
AlertID	Resource	ResourceID								Timestamp				Severity	AlertType													Description
17	NODE			492596eb-94f3-4422-8cb8-bc72878d4be5	Mar 2 18:52:47 UTC 2017	ALARM		Cluster manager failure	[CLEARED] Cluster Manager Failure: 	Entering Maintenance Mode because of Storage Maintenance Mode
18	NODE			/dev/mapper/volume-3bfa72dd				Mar 2 18:54:24 UTC 2017	NOTIFY		Drive operation success	Drive added succesfully: 			/dev/mapper/volume-3bfa72dd
19	CLUSTER			8ed1d365-fd1b-11e6-b01d-0242ac110002	Mar 2 19:35:10 UTC 2017	NOTIFY		Node start success	PX is ready on Node: 492596eb-94f3-4422-8cb8-bc72878d4be5. CLI accessible at /opt/pwx/bin/pxctl.

```

#### pxctl service stats
Use pxctl service stats to show storage and network stats cluster wide.
```
sudo /opt/pwx/bin/pxctl service stats
NAME:
   pxctl service stats - System stats

USAGE:
   pxctl service stats command [command options] [arguments...]

COMMANDS:
     storage  Show this node's storage statistics
     network  Show this node's statistics

OPTIONS:
   --help, -h  show help
```
```
sudo /opt/pwx/bin/pxctl service stats network
Hourly Stats
Node	Bytes Sent	Bytes Received
0	17 TB		278 GB
1	0 B		0 B
2	0 B		0 B
```
