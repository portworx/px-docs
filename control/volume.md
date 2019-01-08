---
layout: page
title: "CLI Reference–Volume"
keywords: portworx, pxctl, command-line tool, cli, reference
sidebar: home_sidebar
redirect_from: "/cli-reference.html"
meta-description: "Explore the CLI reference guide for managing container data volumes using Portworx. Try it today!"
---

* TOC
{:toc}

### Volume Operations
You would normally use your scheduler, such as Kubernetes via `kubectl`, DCOS or Docker to create and manage your volumes.  However, `pxctl` provides a more storage-administrator centric way of performing operations on the volumes in your cluster.

Additional help on each command can be found via pxctl {command name} help

**In Version 1.2.x**

{% include pxctl/volume/volume-help-1.2.md %}

**In Version 1.3 and higher**

{% include pxctl/volume/volume-help-1.3.md %}

#### pxctl volume create

`pxctl volume create`  is used to create a container-granular volume that can later be attached to a host running a container run-time or can be attached to from a container. 

It has the following options available. 

**In Version 1.2.x**

{% include pxctl/volume/volume-create-help-1.2.md %}
 
**In Version 1.3 and higher**

{% include pxctl/volume/volume-create-help-1.3.md %}
 
**In Version 1.5**

Version 1.5 changes the unit for block_size to Bytes. Use the best_effort_location_provisioning option to allocate volumes on nodes, zones, racks in addition to those requested.

```
OPTIONS:
   --block_size size, -b size                    block size in Bytes (default: 4096)
   --best_effort_location_provisioning           requested nodes, zones, racks are optional
```

**In Version 1.6**

Version 1.6 allows user to specify a per volume queue depth setting during create. Older volumes retain their queue depth of 128 while the new default is set to 32. Also available 
is the ability to turn off discard support for volumes. When used, volume is mounted with discard turned off which prevent the FS from releasing space back to the underlying storage.
By default discard support is always on.

```
OPTIONS:
   --queue_depth value, -q value                 block device queue depth [1..256] (default: 32)
   --nodiscard                                   Disable discard support for this volume

```
Here is an example of how to create a  10 GB volume with replication factor set to 3
```
sudo /opt/pwx/bin/pxctl volume create clitest1 --size=10 --repl=3
```
If the command succeeds, it will print the following.
```
Volume successfully created: 508499868375963168
```

For creating volumes with high, medium or low priority, use the following command. If the requested priority is not available, the command will create the next available priority automatically.

```
sudo /opt/pwx/bin/pxctl volume create clihigh --size=1 --repl=3 --iopriority=high
```
##### Aggregated Volumes

For creating an aggregated volume, use the following command.
```
sudo /opt/pwx/bin/pxctl volume create cliaggr --size=1 --repl=2 --aggregation_level=3
```
##### Sticky Volumes

If you want to create a volume that cannot be deleted via other methods and can only be deleted via `pxctl`, use the --sticky flag

```
sudo /opt/pwx/bin/pxctl volume create cliscale --size=1 --repl=3 --sticky
```

##### Volume Sets

For volumes that get created as volume sets, use --scale parameter. This parameter will help you create volumes with similar attributes in each container host in the case of highly scale-out scheduler driven environments. 

```
sudo /opt/pwx/bin/pxctl volume create cliscale1 --size=1 --repl=3 --scale=100
```

##### Encrypted Volumes

For encrypted volumes, pass a '--secure' flag. The secret, by default, is the cluster secret key. A different key maybe passed too.
```
sudo /opt/pwx/bin/pxctl volume create cliencr --secure --size=2 --repl=2
```

##### 512-byte Block Volumes

Default block size for all volumes is 4K. For applications which require the device block size to be 512 bytes, volume should be created using the '--block_size' option. 
```
sudo /opt/pwx/bin/pxctl volume create db2vol --block_size 512 --size=2 --repl=2
```

512 bytes block size is currently not supported with Encrypted Volumes. 

##### Passing Zones and Rack Information

To create volumes within specific zones and/or racks in your deployment use the --zones and --racks options in the volume create command. Specifying zone/rack during volume creation will try to provision storage from the nodes in the specified zone/rack.

```
sudo /opt/pwx/bin/pxctl volume create volZoneA --size=100 --zones=a  --repl=2
sudo /opt/pwx/bin/pxctl volume create volDefRack --racks=defaultRack --repl=2 --size=100
```

##### Volume Distribution to Different Nodes

To distribute volumes on different set of nodes, use --group option. In case there maybe an ambiguous condition use --enforce_cg to enforce group during volume creation. Note: --nodes option takes precedence over the node exclusion from --group option.

```
sudo /opt/pwx/bin/pxctl volume create volFinGrp --group finance --enforce_cg
```

##### Snapshot schedule

Following is an example to specify snapshot schedules when creating a volume.

{% include pxctl/volume/volume-create-snap-sched-example.md %}

#### pxctl volume list

`pxctl volume list` or `pxctl v l` lists the volumes that have been created so far.

```
sudo /opt/pwx/bin/pxctl volume list
ID			NAME		SIZE	HA	SHARED	ENCRYPTED	IO_PRIORITY	SCALE	STATUS
1130856252740468850	cliscale1	1 GiB	3	no	no		LOW		100	up - detached
1131486256496535679	cliscale	1 GiB	3	no	no		LOW		1	up - detached
970758537931791410	clitest1	1 GiB	3	no	no		LOW		1	up - detached
1020258566431745338	clihigh  	1 GiB	1	no	no		HIGH		1	up - detached
2657835878654349872	climedium  	1 GiB	1	no	no		MEDIUM		1	up - detached
1013237432577873530     cliencr      	2 GiB   2       no      yes             LOW             1       up - detached
570354879481121709	cliaggr		1 GiB	2	no	no		LOW		1	up - detached
254582484098891228	volZoneA	100 GiB	2	no	no		LOW		1	up - detached
611963153912324950	volDefRack	100 GiB 2	no	no		LOW		1	up - detached
839994139757433916	volFinGrp	1 GiB	1	no	no		LOW		1	up - detached
```

#### pxctl volume list --node-id

`pxctl volume list --node-id` lists volumes that have data on specified node.

```
pxctl volume list --node-id target_node_id
 
ID                      NAME             SIZE    HA      SHARED  ENCRYPTED      IO_PRIORITY     SCALE   STATUS
970758537931791410      clitest17        1 GiB   3       no      no             LOW             1       up - detached
1013237432577873530     cliencr          2 GiB   3       no      yes            LOW             1       up - detached
```

#### pxctl volume delete

`pxctl volume delete` is used to delete a volume

```
sudo /opt/pwx/bin/pxctl volume delete --help
NAME:
   pxctl volume delete - Delete a volume

USAGE:
   pxctl volume delete [arguments...]   
```

The command can either take the volume name or the volume-id as an argument

```
sudo /opt/pwx/bin/pxctl volume delete clitest1
Volume clitest1 successfully deleted
```

#### pxctl volume inspect

`pxctl volume inspect` help show the additional information about the volume configuration at a much more detailed level

{% include pxctl/volume/volume-inspect-example.md %}

For an aggregated volume,
```
sudo /opt/pwx/bin/pxctl volume inspect cliaggr
Volume	:  570354879481121709
	Name            	 :  cliaggr
	Size            	 :  1.0 GiB
	Format          	 :  ext4
	HA              	 :  2
	IO Priority     	 :  LOW
	Shared          	 :  no
	Status          	 :  up
	State           	 :  detached
	Reads           	 :  0
	Reads MS        	 :  0
	Bytes Read      	 :  0
	Writes          	 :  0
	Writes MS       	 :  0
	Bytes Written   	 :  0
	IOs in progress 	 :  0
	Bytes used      	 :  33 MiB
	Replica sets on nodes:
		Set  0
			Node 	 :  10.99.117.133
			Node	 :  10.99.118.140
		Set  1
			Node	 :  10.99.117.134
			Mode	 :  10.99.118.141
		Set  2
			Node	 :  10.99.117.135
			Mode	 :  10.99.118.142		
```
For an encrypted volume,
```
sudo /opt/pwx/bin/pxctl v i cliencr
Volume  :  1013237432577873530
        Name                     :  cliencr
        Size                     :  2.0 GiB
        Format                   :  ext4
        HA                       :  2
        IO Priority              :  LOW
        Creation time            :  Apr 3 21:11:43 UTC 2017
        Shared                   :  no
        Status                   :  up
        State                    :  detached
        Attributes               :  encrypted
        Reads                    :  0
        Reads MS                 :  0
        Bytes Read               :  0
        Writes                   :  0
        Writes MS                :  0
        Bytes Written            :  0
        IOs in progress          :  0
        Bytes used               :  33 MiB
        Replica sets on nodes:
                Set  0
                        Node     :  172.31.62.60
                        Node     :  172.31.55.8
```

#### pxctl volume update

`pxctl volume update` is used to update a specific parameter of the volume

It has the following options.

```
sudo /opt/pwx/bin/pxctl volume update --help
NAME:
   pxctl volume update - Update volume settings

USAGE:
   pxctl volume update [command options] [arguments...]

OPTIONS:
   --shared value, -s value  set shared setting to on/off
   --sticky on/off           set sticky setting to on/off
   --scale factor            New scale factor [1...1024] (default: 0)
   --size value              New size for the volume (GiB)
 ```

Using the `--shared` flag, the volume namespace sharing across multiple volumes can be turned on or off.

For e.g., for the volume clitest, here is the output of volume inpsect.

{% include pxctl/volume/volume-inspect-example.md %}

The `shared` field is shown as 'no' indicating that this is not a shared volume

```
sudo /opt/pwx/bin/pxctl volume update clitest --shared=on
```

Let's do a `pxctl volume inspect` on the volume again.

```
sudo /opt/pwx/bin/pxctl volume inspect clitest
Volume	:  970758537931791410
	Name            	 :  clitest
	Size            	 :  1.0 GiB
	Format          	 :  ext4
	HA              	 :  1
	IO Priority     	 :  LOW
	Shared          	 :  yes
	Status          	 :  up
	State           	 :  detached
	Reads           	 :  0
	Reads MS        	 :  0
	Bytes Read      	 :  0
	Writes          	 :  0
	Writes MS       	 :  0
	Bytes Written   	 :  0
	IOs in progress 	 :  0
	Bytes used      	 :  33 MiB
	Replica sets on nodes:
		Set  0
			Node 	 :  10.99.117.133
```
As shown above, the volume is shown as `shared=yes` indicating that this is a shared volume

For adding the `--sticky` attribute to a volume, use the following command. 

```
sudo /opt/pwx/bin/pxctl volume update clitest --sticky=on
```

Doing a subsequent inspect on the volume shows the `attributes` field set to `sticky`

```
sudo /opt/pwx/bin/pxctl volume inspect clitest
Volume	:  970758537931791410
	Name            	 :  clitest
	Size            	 :  1.0 GiB
	Format          	 :  ext4
	HA              	 :  1
	IO Priority     	 :  LOW
	Creation time   	 :  Feb 26 08:17:20 UTC 2017
	Shared          	 :  yes
	Status          	 :  up
	State           	 :  detached
	Attributes      	 :  sticky
	Reads           	 :  0
	Reads MS        	 :  0
	Bytes Read      	 :  0
	Writes          	 :  0
	Writes MS       	 :  0
	Bytes Written   	 :  0
	IOs in progress 	 :  0
	Bytes used      	 :  33 MiB
	Replica sets on nodes:
		Set  0
			Node 	 :  10.99.117.133
```
Here is an example of how to update size of an existing volume. Let's create a volume with default parameters. This will create a volume of size 1 GB. We can verify this with volume inspect.
```
sudo /opt/pwx/bin/pxctl volume create vol_resize_test
Volume successfully created: 485002114762355071

sudo /opt/pwx/bin/pxctl volume inspect vol_resize_test
Volume	:  485002114762355071
	Name            	 :  vol_resize_test
	Size            	 :  1.0 GiB
	Format          	 :  ext4
	HA              	 :  1
	IO Priority     	 :  LOW
	Creation time   	 :  Apr 10 18:53:11 UTC 2017
	Shared          	 :  no
	Status          	 :  up
	State           	 :  detached
	Reads           	 :  0
	Reads MS        	 :  0
	Bytes Read      	 :  0
	Writes          	 :  0
	Writes MS       	 :  0
	Bytes Written   	 :  0
	IOs in progress 	 :  0
	Bytes used      	 :  32 MiB
	Replica sets on nodes:
		Set  0
			Node 	 :  172.31.55.104
```
In order to update the size of the volume, a non-shared volume needs to be mounted on one of PX nodes. If it's a shared volume, then this operation can be done from any of the nodes where the volume is attached.

```
sudo /opt/pwx/bin/pxctl host attach vol_resize_test
Volume successfully attached at: /dev/pxd/pxd485002114762355071

sudo mkdir /mnt/voldir

sudo /opt/pwx/bin/pxctl host mount vol_resize_test /mnt/voldir
Volume vol_resize_test successfully mounted at /mnt/voldir
```

Let's update size of this volume to 5 GB. 

```
sudo /opt/pwx/bin/pxctl volume update vol_resize_test --size=5
Update Volume: Volume update successful for volume vol_resize_test
```

We can verify this with volume inspect command.

```
sudo /opt/pwx/bin/pxctl volume inspect vol_resize_test
Volume	:  485002114762355071
	Name            	 :  vol_resize_test
	Size            	 :  5.0 GiB
	Format          	 :  ext4
	HA              	 :  1
	IO Priority     	 :  LOW
	Creation time   	 :  Apr 10 18:53:11 UTC 2017
	Shared          	 :  no
	Status          	 :  up
	State           	 :  Attached: 43109685-e98a-448f-9805-293128e2d78b
	Device Path     	 :  /dev/pxd/pxd485002114762355071
	Reads           	 :  138
	Reads MS        	 :  108
	Bytes Read      	 :  974848
	Writes          	 :  161
	Writes MS       	 :  1667
	Bytes Written   	 :  68653056
	IOs in progress 	 :  0
	Bytes used      	 :  97 MiB
	Replica sets on nodes:
		Set  0
			Node 	 :  172.31.55.104
```

#### pxctl volume ha-update

`pxctl volume ha-update` can be used to increase or decrease the replication factor for a given portworx volume. 
```
sudo /opt/pwx/bin/pxctl volume ha-update --help
NAME:
   pxctl volume ha-update - Update volume HA level

USAGE:
   pxctl volume ha-update [command options] volume-name-or-ID

OPTIONS:
   --repl factor, -r factor  New replication factor [1...3] (default: 0)
   --node value, -n value    comma-separated Node Id(s)
   --zones value             comma-separated Zone names
   --racks value             comma-separated Rack names
```
The volume `clitest` shown in the previous example is a volume with replication factor set to 1. 

Here are the nodes in the cluster.

```
sudo /opt/pwx/bin/pxctl cluster list

Cluster ID: MY_CLUSTER_ID
Status: OK

Nodes in the cluster:
ID					DATA IP		CPU		MEM TOTAL	MEM FREE	CONTAINERS	VERSION		STATUS
fa18451d-9091-45b4-a241-d816357f634b	10.99.117.133	0.5		8.4 GB	7.9 GB		N/A		1.1.6-a879596	Online
b1aa39df-9cfd-4c21-b5d4-0dc1c09781d8	10.99.117.137	0.250313	8.4 GB	7.9 GB		N/A		1.1.6-a879596	Online
bb605ca6-c014-4e6c-8a23-55c967d1a963	10.99.117.135	0.625782	8.4 GB	7.9 GB		N/A		1.1.6-a879596	Online
```

Using `pxctl volume ha-update`, here is how to increase the replication factor. Note, the command below sets the volume to replicate to the node with NodeID b1aa39df-9cfd-4c21-b5d4-0dc1c09781d8
```
sudo /opt/pwx/bin/pxctl volume ha-update clitest --repl=2 --node b1aa39df-9cfd-4c21-b5d4-0dc1c09781d8
```
To use the rack/zone specification instead of a specific node ID, use the --rack/--zone option in the ha-update command
```
sudo /opt/pwx/bin/pxctl volume ha-update --repl=3 --zones=a volZoneA
Update Volume Replication: Replication update started successfully for volume volZoneA
sudo /opt/pwx/bin/pxctl volume ha-update --racks=defaultRack --repl=3 volDefRack
Update Volume Replication: Replication update started successfully for volume volDefRack
```

Once the replication completes and the new node is added to the replication set, the `pxctl volume inspect` shows both the nodes.

```
sudo /opt/pwx/bin/pxctl volume inspect clitest
Volume	:  970758537931791410
	Name            	 :  clitest
	Size            	 :  1.0 GiB
	Format          	 :  ext4
	HA              	 :  2
	IO Priority     	 :  LOW
	Creation time   	 :  Feb 26 08:17:20 UTC 2017
	Shared          	 :  yes
	Status          	 :  up
	State           	 :  detached
	Attributes      	 :  sticky
	Reads           	 :  0
	Reads MS        	 :  0
	Bytes Read      	 :  0
	Writes          	 :  0
	Writes MS       	 :  0
	Bytes Written   	 :  0
	IOs in progress 	 :  0
	Bytes used      	 :  33 MiB
	Replica sets on nodes:
		Set  0
			Node 	 :  10.99.117.133
			Node 	 :  10.99.117.137
```
For a volume created with a --group option the inspect output will reflect the flag as shown below:
```
sudo /opt/pwx/bin/pxctl volume inspect volFinGrp
Volume  :  839994139757433916
        Name                     :  volFinGrp
        Group                    :  finance
        Size                     :  1.0 GiB
        Format                   :  ext4
        HA                       :  1
        IO Priority              :  LOW
        Creation time            :  May 30 19:06:51 UTC 2017
        Shared                   :  no
        Status                   :  up
        State                    :  detached
        Reads                    :  0
        Reads MS                 :  0
        Bytes Read               :  0
        Writes                   :  0
        Writes MS                :  0
        Bytes Written            :  0
        IOs in progress          :  0
        Bytes used               :  32 MiB
        Replica sets on nodes:
                Set  0
                        Node     :  192.168.1.147
```

`pxctl volume alerts` will show when the replication is complete

```
sudo /opt/pwx/bin/pxctl volume alerts
AlertID	VolumeID		Timestamp			Severity	AlertType			Description
25	970758537931791410	Feb 26 22:02:04 UTC 2017	NOTIFY		Volume operation success	Volume (Id: 970758537931791410 Name: clitest) HA updated from 1 to 2
```

The ha-update command can also be used to reduce the replication factor as well.

```
sudo /opt/pwx/bin/pxctl volume ha-update clitest --repl=1 --node b1aa39df-9cfd-4c21-b5d4-0dc1c09781d8
Update Volume Replication: Replication update started successfully for volume clitest
```
Here is the output of the volume inspect command after the replication factor has been reduced to 1

```
sudo /opt/pwx/bin/pxctl volume inspect clitest
Volume	:  970758537931791410
	Name            	 :  clitest
	Size            	 :  1.0 GiB
	Format          	 :  ext4
	HA              	 :  1
	IO Priority     	 :  LOW
	Creation time   	 :  Feb 26 08:17:20 UTC 2017
	Shared          	 :  yes
	Status          	 :  up
	State           	 :  detached
	Attributes      	 :  sticky
	Reads           	 :  0
	Reads MS        	 :  0
	Bytes Read      	 :  0
	Writes          	 :  0
	Writes MS       	 :  0
	Bytes Written   	 :  0
	IOs in progress 	 :  0
	Bytes used      	 :  33 MiB
	Replica sets on nodes:
		Set  0
			Node 	 :  10.99.117.133
```

Here is the output of the volume alerts.

```
25	970758537931791410	Feb 26 22:02:04 UTC 2017	NOTIFY		Volume operation success	Volume (Id: 970758537931791410 Name: clitest) HA updated from 1 to 2
26	970758537931791410	Feb 26 22:58:17 UTC 2017	NOTIFY		Volume operation success	Volume (Id: 970758537931791410 Name: clitest) HA updated 
```
#### pxctl volume ha-update cancel

`pxctl volume ha-update cancel` is a command that can be used to cancel an ongoing request to ha-update a volume
NOTE: Volume may need to be in attached state for this operation.
```
sudo /opt/pwx/bin/pxctl volume ha-update --repl=2 volcanc
Update Volume Replication: Replication update started successfully for volume volcanc
sudo /opt/pwx/bin/pxctl volume ha-update --cancel volcanc
Update Volume Replication: Replication update canceled for volume volcanc
```
An alert is raised when we run this command.
```
sudo /opt/pwx/bin/pxctl sv alerts show
33162 VOLUME 845339212632295104 Jul 26 03:14:42 UTC 2017 NOTIFY Volume operation success Volume volcanc (845339212632295104) ha-increase canceled
```

#### pxctl volume stats

`pxctl volume stats` displays the current stats the in the volume. 

```
sudo /opt/pwx/bin/pxctl volume stats testvol
TS 		Bytes Read  Num Reads Bytes Written  Num Writes IOPS	 IODepth   Read Tput	Write Tput	Latency (ms)
2017-2-26:23 Hrs  315 MB      19242      4.1 kB          1       9621      0         158 MB/s     2.0 kB/s        113     
```

#### pxctl volume requests

This command displays all the pending requests to all the volumes in the cluster

```
sudo /opt/pwx/bin/pxctl volume requests
Only support getting requests for all volumes.
Active requests for all volumes: count = 11
```

#### pxctl volume alerts

`pxctl volume alerts` shows all the alerts that are related to volumes including volume creation, deletion, resynchronization status and other replication factor changes. 

```
sudo /opt/pwx/bin/pxctl volume alerts --help
NAME:
   pxctl volume alerts - Show volume related alerts

USAGE:
   pxctl volume alerts [command options]  

OPTIONS:
   --sev value, -s value    Filter alerts based on severity : [WARN|NOTIFY|ALARM]
   --start value, -t value  Time start : Jan 2 15:04:05 UTC 2006
   --end value, -e value    Time end : Jan 2 15:04:05 UTC 2006
   --all, -a                Specify --all to show cleared alerts in the output
```

`pxctl volume alerts` also can used to filer specific alerts based on the severity. Here are a few examples.

Here is how to filter for alerts with the severity level `WARN`.

```
sudo /opt/pwx/bin/pxctl volume alerts --sev WARN
AlertID	VolumeID		Timestamp			Severity	AlertType			Description
24	970758537931791410	Feb 26 22:00:34 UTC 2017	WARN		Volume operation failure	Volume (Id: 970758537931791410 Name: clitest) HA update from 1 to 2 failed with error: Node 970758537931791410 doesn't exist
```

Here is how to filter for alerts with the severity level `ALARM`.

```
sudo /opt/pwx/bin/pxctl volume alerts --sev ALARM
No volume alerts found 
```

Here is how to filter for alerts with the severity level `NOTIFY`.

```
sudo /opt/pwx/bin/pxctl volume alerts --sev NOTIFY
AlertID	VolumeID		Timestamp			Severity	AlertType			Description

36	415896631698061968	Feb 26 23:55:06 UTC 2017	NOTIFY		Volume operation success	Volume (Name: testvol Id: 415896631698061968 Path: /var/lib/osd/mounts/testvol) unmounted successfully
37	415896631698061968	Feb 26 23:55:26 UTC 2017	NOTIFY		Volume operation success	Volume (Name: testvol Id: 415896631698061968 Path: /var/lib/osd/mounts/testvol) mounted successfully.
38	415896631698061968	Feb 26 23:55:34 UTC 2017	NOTIFY		Volume operation success	Volume (Name: testvol Id: 415896631698061968 Path: /var/lib/osd/mounts/testvol) unmounted successfully
39	415896631698061968	Feb 26 23:55:42 UTC 2017	NOTIFY		Volume operation success	Volume (Name: testvol Id: 415896631698061968 Path: /var/lib/osd/mounts/testvol) mounted successfully.
40	415896631698061968	Feb 26 23:55:50 UTC 2017	NOTIFY		Volume operation success	Volume (Name: testvol Id: 415896631698061968 Path: /var/lib/osd/mounts/testvol) unmounted successfully
41	415896631698061968	Feb 27 00:01:33 UTC 2017	NOTIFY		Volume operation success	Volume (Name: testvol Id: 415896631698061968 Path: /var/lib/osd/mounts/testvol) mounted successfully.
42	415896631698061968	Feb 27 00:01:41 UTC 2017	NOTIFY		Volume operation success	Volume (Name: testvol Id: 415896631698061968 Path: /var/lib/osd/mounts/testvol) unmounted successfully
43	415896631698061968	Feb 27 00:01:54 UTC 2017	NOTIFY		Volume operation success	Volume (Name: testvol Id: 415896631698061968 Path: /var/lib/osd/mounts/testvol) mounted successfully.
44	415896631698061968	Feb 27 00:02:01 UTC 2017	NOTIFY		Volume operation success	Volume (Name: testvol Id: 415896631698061968 Path: /var/lib/osd/mounts/testvol) unmounted successfully
```
#### pxctl volume import

`pxctl volume import` enables import of existing data into a given portworx volume.

The command syntax is as follows.

```
sudo /opt/pwx/bin/pxctl volume import --help
NAME:
   pxctl volume import - Import data into a volume

USAGE:
   pxctl volume import [command options] volume-name-or-ID

OPTIONS:
   --src path  Local source path for the data
```

Here is sample import of data from folder `/root/testtdata` into volume 'testimport'

```
sudo /opt/pwx/bin/pxctl volume import testimport --src /root/testdata
Starting import of  data from /root/testdata into volume testimport...Beginning data transfer from /root/testdata testimport
Imported Bytes :   0% [>---------------------------------------------------------------------------------------------------------------------------] 339ms


Imported Files :   0% [>---------------------------------------------------------------------------------------------------------------------------] 257ms
```
