---
layout: page
title: "Maintenance Commands"
keywords: service, maintenance, drive removal, drive replacement, pool list, pool priority
sidebar: home_sidebar
redirect_from: "/maintenance.html"
---

* TOC
{:toc}
Service level commands are related to maintenance of drives and drive pools.
The most common cases would be for Disk addition/replacement

Here are some of the commands that are needed for maintenance operations

## Some general maintenance commands

### Enter Maintenance Mode 
Run **"pxctl service maintenance --enter"**.
This takes Portworx out of an "Operational" state for a given node.  Perform whatever physical maintenance is needed.

### Restart Portworx
Run **"docker restart px-enterprise"**.
This restarts the Portworx fabric on a given node.

### Exit Maintenance Mode
Run **"pxctl service maintenance --exit"**.
This puts Portworx back in to "Operational" state for a given node.

### Drive management example

The drive management commands are organized under `pxctl service drive` command

```
/opt/pwx/bin/pxctl service drive

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

Here is a typical workflow on how to identify and replace drives. 

## Show the list of drives in the system

```
/opt/pwx/bin/pxctl service drive show
 
PX drive configuration:
Pool ID: 0
	IO_Priority: LOW
	Size: 7.3 TiB
	Status: Online
	Has meta data: No
	Drives:
	1: /dev/sde, 3.0 GiB allocated of 7.3 TiB, Online
Pool ID: 1
	IO_Priority: HIGH
	Size: 1.7 TiB
	Status: Online
	Has meta data: Yes
	Drives:
	1: /dev/sdj, 1.0 GiB allocated of 1.7 TiB, Online
```

## Add drives to the cluster

### Step 1: Enter Maintenance Mode 

```
/opt/pwx/bin/pxctl service  maintenance --enter
This is a disruptive operation, PX will restart in maintenance mode.
Are you sure you want to proceed ? (Y/N): y
PX is not running on this host.
```

### Step 2: Add drive to the system

For e.g., Add drive /dev/sdb to PX cluster

```
/opt/pwx/bin/pxctl service drive add /dev/sdb
Adding device  /dev/sdb ...
Drive add  successful. Requires restart (Exit maintenance mode).
```

### Step 3: Exit Maintenance mode 

```
/opt/pwx/bin/pxctl service  maintenance --exit
PX is now operational
```

Check if the drive is added using drive show command

```
/opt/pwx/bin/pxctl service drive show
PX drive configuration:

Pool ID: 0
	IO_Priority: LOW
	Size: 15 TiB
	Status: Online
	Has meta data: No
	Drives:
	2: /dev/sdb, 0 B allocated of 7.3 TiB, Online
	1: /dev/sde, 3.0 GiB allocated of 7.3 TiB, Online
Pool ID: 1
	IO_Priority: HIGH
	Size: 1.7 TiB
	Status: Online
	Has meta data: Yes
	Drives:
	1: /dev/sdj, 1.0 GiB allocated of 1.7 TiB, Online
```

## Replace a drive that is already part of the Portworx Cluster

### Step 1: Enter Maintenance mode

```
/opt/pwx/bin/pxctl service  maintenance --enter
This is a disruptive operation, PX will restart in maintenance mode.
Are you sure you want to proceed ? (Y/N): y

PX is not running on this host.
```

### Step 2: Replace old drive with a new drive

Ensure the replacement drive is already available in the system. 

For e.g., Replace drive /dev/sde with /dev/sdc

```
/opt/pwx/bin/pxctl service drive replace --source /dev/sde --target /dev/sdc --operation start
"Replace operation is in progress"
```

Check the replace status

```
/opt/pwx/bin/pxctl service drive replace --source /dev/sde --target /dev/sdc --operation status
"Started on 16.Dec 22:17:06, finished on 16.Dec 22:17:06, 0 write errs, 0 uncorr. read errs\n"
```


### Step 3: Exit Maintenance mode 

```
/opt/pwx/bin/pxctl service  maintenance --exit
PX is now operational
```

### Step 4: Check if the drive has been successfully replaced

```
/opt/pwx/bin/pxctl service drive show
PX drive configuration:
Pool ID: 0
	IO_Priority: LOW
	Size: 15 TiB
	Status: Online
	Has meta data: No
	Drives:
	1: /dev/sdc, 3.0 GiB allocated of 7.3 TiB, Online
	2: /dev/sdb, 0 B allocated of 7.3 TiB, Online
Pool ID: 1
	IO_Priority: HIGH
	Size: 1.7 TiB
	Status: Online
	Has meta data: Yes
	Drives:
	1: /dev/sdj, 1.0 GiB allocated of 1.7 TiB, Online
```
## Storage pool commands
Storage pools are automatically created by selected like disks in terms of capacity and capability. These pools are classified as High/Medium/Low based on IOPS and latency. 

Help for storage pool commands is available as:

```
/opt/pwx/bin/pxctl service pool -h

NAME:
   pxctl service pool update - Update pool properties

USAGE:
   pxctl service pool update [command options] pool ID

OPTIONS:
   --io_priority value  io_priority: low|medium|high

[root@ip-172-31-2-134 porx]# bin/pxctl service pool -h
NAME:
   pxctl service pool - Storage pool maintenance

USAGE:
   pxctl service pool command [command options] [arguments...]

COMMANDS:
     show    Show pools
     update  Update pool properties

OPTIONS:
   --help, -h  show help
```

### List Storage pools
This is an alias for /opt/pwx/bin/pxctl service drive show

```
/opt/pwx/bin/pxctl service pool show
PX drive configuration:
Pool ID: 0
	IO_Priority: LOW
	Size: 15 TiB
	Status: Online
	Has meta data: No
	Drives:
	1: /dev/sdc, 3.0 GiB allocated of 7.3 TiB, Online
	2: /dev/sdb, 0 B allocated of 7.3 TiB, Online
Pool ID: 1
	IO_Priority: HIGH
	Size: 1.7 TiB
	Status: Online
	Has meta data: Yes
	Drives:
	1: /dev/sdj, 1.0 GiB allocated of 1.7 TiB, Online
```

### Update Storage pool priority classification

Portworx benchmarks drives and classifies them as high/medium/low. However, sometimes it is desirable for the operator to explicity designate a classification. This can be done like so:
```
/opt/pwx/bin/pxctl service update -h
NAME:
   pxctl service pool update - Update pool properties

USAGE:
   pxctl service pool update [command options] pool ID

OPTIONS:
   --io_priority value  io_priority: low|medium|high

```

To update pool 0 priority to 'MEDIUM'

```
 /opt/pwx/bin/pxctl service pool update 0 --io_priority medium
```
