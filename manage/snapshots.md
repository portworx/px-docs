---
layout: page
title: "Create and Manage Snapshots"
keywords: portworx, pxctl, snapshot, reference
sidebar: home_sidebar
redirect_from: "/snapshot.html"
meta-description: "Learn how container volume snapshots can be created explicitly by pxctl snapshot create commands or through a schedule that is set on the volume. Try today!"
---

* TOC
{:toc}

Snapshots are efficient point-in-time read-only copies of volumes. 
Snapshots created can be used to read data from the snapshot, restore data from the snapshot and also create clones from the snapshot. 
They are implemented using a copy-on-write technique, so that they only use space in places where they differ from their parent volume.
Snapshots can be created explicitly by `pxctl snapshot create` commands or through a schedule that is set on the volume.

## `pxctl` Snapshot Commands

Snapshots are managed with the `pxctl volume snapshot` command.
```
NAME:
   pxctl volume snapshot - Manage volume snapshots

USAGE:
   pxctl volume snapshot command [command options] [arguments...]

COMMANDS:
   create, c  Create a volume snapshot
  
OPTIONS:
   --help, -h  show help
```

### Creation Snapshots

To create a user snaphsot for a volume , Use `pxctl snapshot create` command.
```
# pxctl volume snapshot create --name mysnap --label color=blue,fabric=wool myvol
Volume snap successful: 234835613696329810
```

The string of digits in the output is the volume ID of the new snapshot.  You can use this ID(`234835613696329810`) or the name(`mysnap`), to refer
to the snapshot in subsequent `pxctl` commands.  The label values allow you to tag the snapshot with descriptive information of your choosing. 
You can use them to filter the output of the `pxctl volume list` command.

To see more detailed information for a snapshot, you can use `pxctl volume inspect` command
```
# /opt/pwx/bin/pxctl volume inspect mysnap
```

There is an implementation limit of 64 snapshots per volume.

### Listing Snapshots

Snapshots are listed using pxctl volume list command.
```
NAME:
   pxctl volume list - List volumes in the cluster

USAGE:
   pxctl volume list [command options]

OPTIONS:
   --all, -a                 show all volumes, including snapshots
   --node-id value           show all volumes whose replica is present on the given node
   --name value              volume name used during creation if any
   --label pairs, -l pairs   list of comma-separated name=value pairs
   --snapshot, -s            show all snapshots (read-only volumes)
   --snapshot-schedule, --ss show all schedule created snapshots
   --parent value, -p value  show all snapshots created for given volume
```

User created snapshots can be listed using one of the following ways
```
# pxctl volume list --all
ID			NAME									SIZE	HA	SHARED	ENCRYPTED	COMPRESSED	IO_PRIORITY	SCALE	STATUS
234835613696329810	mysnap									1 GiB	1	no	no		no		LOW		1	up - detached
1125771388930868153	myvol									1 GiB	1	no	no		no		LOW		1	up - detached
```
(or)
```
# pxctl volume list --snapshot
ID			NAME									SIZE	HA	SHARED	ENCRYPTED	COMPRESSED	IO_PRIORITY	SCALE	STATUS
234835613696329810	mysnap									1 GiB	1	no	no		no		LOW		1	up - detached
```

All scheduled snapshots can be listed using  --snapshot-schedule option.
```
# pxctl volume list --snapshot-schedule
ID			NAME									SIZE	HA	SHARED	ENCRYPTED	COMPRESSED	IO_PRIORITYSCALE	STATUS
423119103642927058	myvol_periodic_2018_Feb_26_21_12					1 GiB	1	no	no		no		LOW		1up - detached
```

You can filter the results with the --parent and --label options. For instance, --parent myvol will show only snapshots whose parent is myvol, i.e., mysnap in this example.
Giving labels restricts the list to snapshots that have all of the specified labels. For instance, --label fabric=wool would again show mysnap but --label fabric=cotton would produce an empty list.
```
# pxctl volume list --parent myvol --snapshot
ID			NAME	SIZE	HA	SHARED	ENCRYPTED	COMPRESSED	IO_PRIORITY	SCALE	STATUS
234835613696329810	mysnap	1 GiB	1	no	no		no		LOW		1	up - detached

# pxctl volume list --parent myvol --snapshot --label fabric=wool
ID			NAME	SIZE	HA	SHARED	ENCRYPTED	COMPRESSED	IO_PRIORITY	SCALE	STATUS
234835613696329810	mysnap	1 GiB	1	no	no		no		LOW		1	up - detached
```

### Deleting Snapshots

Snapshot can be deleted using `pxctl volume delete` command.
```
NAME:
   pxctl volume delete - Delete a volume

USAGE:
   pxctl volume delete volume-name-or-ID

```

The argument is the name or ID of the snapshot that you wish to delete. The snapshot must be detached in order to delete it.
```
# pxctl volume delete mysnap
Delete volume 'mysnap', proceed ? (Y/N): y
Volume mysnap successfully deleted.
```

### Snapshot Schedules

Snapshot schedules can be created either during volume create or via policies.
Scheduled snapshots have names of the form `<Parent-Name>_<freq>_<creation_time>`, where `<freq>` denotes the schedule frequency, i.e., periodic, daily, weekly, monthly.
For example,
```
myvol_periodic_2018_Feb_26_21_12
myvol_daily_2018_Feb_26_12_00
```

1. Creation of snapshot schedules during volume create
```
NAME:
   pxctl volume create - Create a volume

USAGE:
   pxctl volume create [command options] volume-name

OPTIONS:
   --shared                                      make this a globally shared namespace volum
   --secure                                      encrypt this volume using AES-256
   --secret_key value                            secret_key to use to fetch secret_data for the PBKDF2 function
   --use_cluster_secret                          Use cluster wide secret key to fetch secret_data
   --label pairs, -l pairs                       list of comma-separated name=value pairs
   --size value, -s value                        volume size in GB (default: 1)
   --fs value                                    filesystem to be laid out: none|xfs|ext4 (default: "ext4")
   --block_size size, -b size                    block size in Kbytes (default: 32)
   --repl factor, -r factor                      replication factor [1..3] (default: 1)
   --scale value, --sc value                     auto scale to max number [1..1024] (default: 1)
   --io_priority value, --iop value              IO Priority: [high|medium|low] (default: "low")
   --journal                                     Journal data for this volume
   --io_profile value, --prof value              IO Profile: [sequential|random|db|db_remote] (default: "sequential")
   --sticky                                      sticky volumes cannot be deleted until the flag is disabled [on | off]
   --aggregation_level level, -a level           aggregation level: [1..3 or auto] (default: "1")
   --nodes value                                 comma-separated Node Ids
   --zones value                                 comma-separated Zone names
   --racks value                                 comma-separated Rack names
   --group value, -g value                       group
   --enforce_cg, --fg                            enforce group during provision
   --periodic mins,k, -p mins,k                  periodic snapshot interval in mins,k (keeps 5 by default), 0 disables all schedule snapshots
   --daily hh:mm,k, -d hh:mm,k                   daily snapshot at specified hh:mm,k (keeps 7 by default)
   --weekly weekday@hh:mm,k, -w weekday@hh:mm,k  weekly snapshot at specified weekday@hh:mm,k (keeps 5 by default)
   --monthly day@hh:mm,k, -m day@hh:mm,k         monthly snapshot at specified day@hh:mm,k (keeps 12 by default)
   --policy value, --sp value                    policy names separated by comma
```

There are four scheduling options [--periodic, --daily, --weekly and --monthly], which you can combine as desired.
The example below sets a schedule of periodic snapshot for every 60 min and daily snapshot at 8:00am and weekly snapshot on friday at 23:30pm and monthly snapshot on the 1st of the month at 6:00am.
```
pxctl volume create --periodic 60 --daily @08:00 --weekly Friday@23:30 --monthly 1@06:00 myvol
```

The example below keeps a count of 10 periodic snapshot that triggers every 120 min and 3 daily snapshots that tirggers at 8:00am
```
pxctl volume create --periodic 120,10 --daily @08:00,3 myvol
```
Once the count is reached, the oldest existing one will be deleted if necessary.

2. Creation of snapshot schedules via policies
To create a snapshot policy, use `pxctl sched-policy create` command.
```
NAME:
   pxctl sched-policy create - Create a schedule policy

USAGE:
   pxctl sched-policy create [command options] policy-name

OPTIONS:
   --periodic mins,k, -p mins,k                  periodic snapshot interval in mins,k (keeps 5 by default), 0 disables all schedule snapshots
   --daily hh:mm,k, -d hh:mm,k                   daily snapshot at specified hh:mm,k (keeps 7 by default)
   --weekly weekday@hh:mm,k, -w weekday@hh:mm,k  weekly snapshot at specified weekday@hh:mm,k (keeps 5 by default)
   --monthly day@hh:mm,k, -m day@hh:mm,k         monthly snapshot at specified day@hh:mm,k (keeps 12 by default)
```

The below example creates a policy `p1` with periodic and weekly schedules.
```
# pxctl sched-policy create --periodic 60,5 --weekly sunday@12:00,4 p1
```

### Changing Snapshot Schedule

To change the snapshot schedule for a given volume, use `pxctl volume snap-interval-update` command
```
# pxctl volume snap-interval-update p1,p2
# pxctl volume snap-interval-update --daily @15:00,5 myvol
```

### Disabling Scheduled Snapshots

To disable scheduled snapshot for a given volume, use `--periodic 0` on snap-interval-update.
```
pxctl volume snap-interval-update --periodic 0 myvol
```

### View Snapshot Schedule on Volume

If a schedule is set on a volume and to view that schedule use `pxctl volume inspect` command.
```
# /opt/pwx/bin/pxctl v i myvol
Volume	:  1125771388930868153
	Name            	 :  myvol
	Size            	 :  1.0 GiB
	Format          	 :  ext4
	HA              	 :  1
	IO Priority     	 :  LOW
	Creation time   	 :  Feb 26 18:06:31 UTC 2018
	Snapshot        	 :  daily @15:00,keep last 5
	Shared          	 :  no
	Status          	 :  up
	State           	 :  Attached: minion1
	Device Path     	 :  /dev/pxd/pxd1125771388930868153
	Reads           	 :  54
	Reads MS        	 :  152
	Bytes Read      	 :  1105920
	Writes          	 :  53
	Writes MS       	 :  841
	Bytes Written   	 :  16891904
	IOs in progress 	 :  0
	Bytes used      	 :  48 MiB
	Replica sets on nodes:
		Set  0
			Node 		 :  70.0.34.84 (Pool 0)
	Replication Status	 :  Up

```

### Listing Schedule Policies

To list the schedule policies, Use `pxctl sched-policy  list` command
```
NAME:
   pxctl sched-policy list - List all schedule policies

USAGE:
      pxctl sched-policy list [arguments...]
```

### Update Schedule Policy

To update the schedule policy, Use `pxctl sched-policy  update` command
```
NAME:
  pxctl sched-policy update - Update a schedule policy

USAGE:
   pxctl sched-policy update [command options] policy-name

OPTIONS:
   --periodic mins,k, -p mins,k                  periodic snapshot interval in mins,k (keeps 5 by default), 0 disables all schedule snapshots
   --daily hh:mm,k, -d hh:mm,k                   daily snapshot at specified hh:mm,k (keeps 7 by default)
   --weekly weekday@hh:mm,k, -w weekday@hh:mm,k  weekly snapshot at specified weekday@hh:mm,k (keeps 5 by default)
   --monthly day@hh:mm,k, -m day@hh:mm,k         monthly snapshot at specified day@hh:mm,k (keeps 12 by default)
```

### Delete Schedule Policy

To delete the schedule policy, Use `pxctl sched-policy delete` command.
```
NAME:
   pxctl sched-policy delete - Delete a schedule policy

USAGE:
   pxctl sched-policy delete policy-name
```
