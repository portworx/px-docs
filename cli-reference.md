---
layout: page
title: "CLI Reference"
keywords: portworx, pxctl, command-line tool, cli, reference
sidebar: home_sidebar
---
The Portworx command-line tool, `pxctl`, is available on every node where PX is running.  It is available at the host at `/opt/pwx/bin/pxctl`.  The CLI is designed to accept and display human readable input and output by default.  In addition, every command takes in a `-j` option such that the output is in machine parsable `json` format.
	
In most production deployments, you will provision volumes directly using Docker or your scheduler (such as a Kubernetes pod spec).  However, pxctl also lets you directly provision and manage storage. In addition, the pxctl has a rich set of cluster wide management features which are explained in this document.

## About `pxctl`

All operations from `pxctl` are reflected back into the containers that use Portworx storage. In addition to what is exposed in Docker volumes, `pxctl`:

* Gives access to Portworx storage-specific features, such as cloning a running container's storage.
* Shows the connection between containers and their storage volumes.
* Let you control the Portworx storage cluster, such as adding nodes to the cluster. (The Portworx tools refer to servers managed by Portworx storage as *nodes*.)

The scope of the `pxctl` command is global to the cluster. Running `pxctl` from any node within the cluster therefore shows the same global details. `pxctl` also identifies details specific to that node.

This current release of `pxctl` requires that you run as a privileged user:

```
sudo su
```

The `pxctl` tool is available in the `/opt/pwx/bin/` directory. To run `pxctl` without typing the full directory path each time, add `pxctl` to your PATH as follows:

```
export PATH=/opt/pwx/bin:$PATH
```

Now you can just type `pxctl` and you're ready to start.

To view all the commands offered by pxctl, type 'pxctl help'

```
sudo /opt/pwx/bin/pxctl help  
NAME:
   pxctl - px cli

USAGE:
   pxctl [global options] command [command options] [arguments...]
   
VERSION:
   1.1.4-6b35842
   
COMMANDS:
     status       Show status summary
     volume, v    Manage volumes
     snap, s      Manage volume snapshots
     cluster, c   Manage the cluster
     service, sv  Service mode utilities
     host         Attach volumes to the host
     upgrade      Upgrade PX
     eula         Show license agreement
     help, h      Shows a list of commands or help for one command

GLOBAL OPTIONS:
   --json, -j     output in json
   --color        output with color coding
   --raw, -r      raw CLI output for instrumentation
   --help, -h     show help
   --version, -v  print the version
```

`pxctl` provides capabilities to perform much more fine-grained control of the PX resources cluster-wide and as seen above offers capabilties to manage volumes, snapshots, cluster resources, hosts in the cluster and software upgrade in the cluster

Let's review each command, options available under command and an example of how those options are used

### Volume Operations

Additional help on each command can be found via pxctl {command name} help

```
sudo /opt/pwx/bin/pxctl volume --help
NAME:
   pxctl volume - Manage volumes

USAGE:
   pxctl volume command [command options] [arguments...]

COMMANDS:
     create, c             Create a volume
     list, l               List volumes in the cluster
     update                Update volume settings
     ha-update, u          Update volume HA level
     snap-interval-update  Update volume configuration
     inspect, i            Inspect a volume
     requests              Show all pending requests
     delete, d             Delete a volume
     stats, st             Volume Statistics
     alerts, a             Show volume related alerts
     import                Import data into a volume

OPTIONS:
   --help, -h  show help
```

#### pxctl volume create

`pxctl volume create`  is used to create a container-granular volume that can later be attached to a host running a container run-time or can be attached to from a container. 

It has the following options available. 

```
sudo /opt/pwx/bin/pxctl volume create --help
NAME:
   pxctl volume create - Create a volume

USAGE:
   pxctl volume create [command options] [arguments...]

OPTIONS:
   --shared                             make this a globally shared namespace volume
   --secure                             encrypt this volume using AES-256
   --secret_key value                   secret_key to use to fetch secret_data for the PBKDF2 function
   --use_cluster_secret                 Use cluster wide secret key to fetch secret_data
   --label pairs, -l pairs              list of comma-separated name=value pairs
   --size value, -s value               volume size in GB (default: 1)
   --fs value                           filesystem to be laid out: none|xfs|ext4 (default: "ext4")
   --block_size size, -b size           block size in Kbytes (default: 32)
   --repl factor, -r factor             replication factor [1..3] (default: 1)
   --scale value, --sc value            auto scale to max number [1..1024] (default: 1)
   --io_priority value, --iop value     IO Priority: [high|medium|low] (default: "low")
   --sticky                             sticky volumes cannot be deleted until the flag is disabled [on | off]
   --snap_interval min, --si min        snapshot interval in minutes, 0 disables snaps (default: 0)
   --daily hh:mm, --sd hh:mm            daily snapshot at specified hh:mm
   --weekly value, --sw value           weekly snapshot at specified weekday@hh:mm
   --monthly value, --sm value          monthly snapshot at specified day@hh:mm
   --aggregation_level level, -a level  aggregation level: [1..3 or auto] (default: "1")
   --nodes value                        comma-separated Node Id(s)
 ```
 
Here is an example of how to create a shared volume with replication factor set to 3
 
```
sudo /opt/pwx/bin/pxctl volume create clitest1 --shared --size=1 --repl=3
```

If the command succeeds, it will print the following.

```
Shared volume successfully created: 508499868375963168
```

For creating volumes with high, medium or low priority, use the following command. If the requested priority is not available, the command will create the next available priority automatically.

```
sudo /opt/pwx/bin/pxctl volume create clihigh --shared --size=1 --repl=3 --iopriority=high
```
If you want to create a volume that cannot be deleted via other methods and can only be deleted via `pxctl`, use the --sticky flag

```
sudo /opt/pwx/bin/pxctl volume create cliscale --shared --size=1 --repl=3 --sticky
```

For volumes that get created as volume sets, use --scale parameter. This parameter will help you create volumes with similar attributes in each container host in the case of highly scale-out scheduler driven envrionments. 

```
sudo /opt/pwx/bin/pxctl volume create cliscale1 --shared --size=1 --repl=3 --scale=100
```

If you want to create an encrypted volume, use the following command. If the node is not already authenticated creation will fail.
```
sudo /opt/pwx/bin/pxctl volume create cliencr --secure --size=2 --repl=2
```

#### pxctl volume list

`pxctl volume list` or `pxctl v l` lists the volumes that have been created so far.

```
sudo /opt/pwx/bin/pxctl volume list
ID			NAME		SIZE	HA	SHARED	ENCRYPTED	IO_PRIORITY	SCALE	STATUS
1130856252740468850	cliscale1	1 GiB	3	no	no		LOW		100	up - detached
1131486256496535679	cliscale	1 GiB	3	no	no		LOW		1	up - detached
970758537931791410	clitest1	1 GiB	3	yes	no		LOW		1	up - detached
1020258566431745338	clihigh  	1 GiB	1	no	no		HIGH		1	up - detached
2657835878654349872	climedium  	1 GiB	1	no	no		MEDIUM		1	up - detached
1013237432577873530     cliencr      	2 GiB   2       no      yes             LOW             1       up - detached
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

```
/opt/pwx/bin/pxctl volume inspect clitest
Volume	:  970758537931791410
	Name            	 :  clitest
	Size            	 :  1.0 GiB
	Format          	 :  ext4
	HA              	 :  1
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

```
sudo /opt/pwx/bin/pxctl volume inspect clitest
Volume	:  970758537931791410
	Name            	 :  clitest
	Size            	 :  1.0 GiB
	Format          	 :  ext4
	HA              	 :  1
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
```

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

#### pxctl volume ha-update

`pxctl volume ha-update` can be used to increase or decrease the replication factor for a given portworx volume. 

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

`pxctl volume alerts` will show when the replication is complete

```
sudo /opt/pwx/bin/pxctl volume alerts
AlertID	VolumeID		Timestamp			Severity	AlertType			Description
25	970758537931791410	Feb 26 22:02:04 UTC 2017	NOTIFY		Volume operation success	Volume (Id: 970758537931791410 Name: clitest) HA updated from 1 to 2
```

The same command can also be used to reduce the replication factor as well.

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

#### pxctl volume stats

`pxctl volume stats` displays the current stats the in the volume. 

```
@px-centos-7-1 ~]# sudo /opt/pwx/bin/pxctl volume stats testvol
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

### Snapshot Operations
```
sudo /opt/pwx/bin/pxctl snap --help
NAME:
   pxctl snap - Manage volume snapshots

USAGE:
   pxctl snap command [command options] [arguments...]

COMMANDS:
     create, c  Create a volume snapshot
     list, l    List volume snapshots in the cluster
     delete, d  Delete a volume snapshot

OPTIONS:
   --help, -h  show help
```
#### pxctl snapshot create
`pxctl snapshot create` creates a snapshot of a volume. The different options and ways to use are shown below:
```
sudo /opt/pwx/bin/pxctl snap create vQuorum1 --name Snap1_on_vQuorum1 --label temp=true,cluster=devops
Volume successfully snapped: 376113877104406866
sudo /opt/pwx/bin/pxctl snap create vQuorum1 --name Snap2_on_vQuorum1 --label temp=true,cluster=production
Volume successfully snapped: 1097649911014990908
sudo /opt/pwx/bin/pxctl snap create vQuorum1 --name Snap3_on_vQuorum1 --label temp=false,cluster=production --readonly
Volume successfully snapped: 118252956373660375
```
* Examples 1, 2 show how could you use labels which can then be used to filter your snapshot list in the display
* Example 3 shows how to make a snapshot readonly

#### pxctl snapshot list
`pxctl snapshot list` lists all snapshots:
```
sudo /opt/pwx/bin/pxctl snap list
ID                      NAME                    SIZE    HA      SHARED  ENCRYPTED       IO_PRIORITY     SCALE   STATUS
376113877104406866      Snap1_on_vQuorum1       50 GiB  2       no      no              LOW             1       up - detached
1097649911014990908     Snap2_on_vQuorum1       50 GiB  2       no      no              LOW             1       up - detached
118252956373660375      Snap3_on_vQuorum1       50 GiB  2       no      no              LOW             1       up - detached
```
To list snapshots based on filter values:
```
sudo /opt/pwx/bin/pxctl snap list --label temp=true
ID                      NAME                    SIZE    HA      SHARED  ENCRYPTED       IO_PRIORITY     SCALE   STATUS
376113877104406866      Snap1_on_vQuorum1       50 GiB  2       no      no              LOW             1       up - detached
1097649911014990908     Snap2_on_vQuorum1       50 GiB  2       no      no              LOW             1       up - detached
sudo /opt/pwx/bin/pxctl snap list --label cluster=devops
ID                      NAME                    SIZE    HA      SHARED  ENCRYPTED       IO_PRIORITY     SCALE   STATUS
376113877104406866      Snap1_on_vQuorum1       50 GiB  2       no      no              LOW             1       up - detached
```
#### pxctl snapshot delete
`pxctl snapshot delete` deletes snapshots (make sure they are detached through host commands):
```
sudo /opt/pwx/bin/pxctl snap delete Snap3_on_vQuorum1
Snapshot Snap3_on_vQuorum1 successfully deleted.
```

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
When there is an operational failure, you can use pxctl service diags <name-of-px-container> to generate a complete diagnostics package. This package will be automatically uploaded to Portworx. Additionally, the service package can be mailed to Portworx at support@portworx.com. The package will be available at /tmp/diags.tgz inside the PX container. You can use docker cp to extract the diagnostics package.
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
Collecting diags
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
Entering maintenance mode
```   
sudo /opt/pwx/bin/pxctl service maintenance --enter 
This is a disruptive operation, PX will restart in maintenance mode.
Are you sure you want to proceed ? (Y/N): y
```

Exiting maintenance mode
```   
sudo /opt/pwx/bin/pxctl service maintenance --exit 
Exiting maintenance mode...
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
sudo /opt/pwx/bin/pxctl service drive add /dev/mapper/volume-3bfa72dd
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
#### pxctl service alerts show
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
#### pxctl service stats
```
sudo /opt/pwx/bin/pxctl service stats network
Hourly Stats
Node	Bytes Sent	Bytes Received
0	17 TB		278 GB
1	0 B		0 B
2	0 B		0 B
```


### Host related operations
```
sudo /opt/pwx/bin/pxctl host --help   
NAME:
   pxctl host - Attach volumes to the host

USAGE:
   pxctl host command [command options] [arguments...]

COMMANDS:
     attach   Attach a volume to the host at a specified path
     detach   Detach a specified volume from the host
     mount    Mount a volume on the host
     unmount  Unmount a volume from the host

OPTIONS:
   --help, -h  show help
```
For the sake of these examples, let us use a volume by name "demovolume" that has just been created using a "volume create" CLI.
```
sudo /opt/pwx/bin/pxctl volume list
ID                      NAME            SIZE    HA      SHARED  ENCRYPTED       IO_PRIORITY     SCALE   STATUS
772733390943400581      demovolume      5 GiB   2       no      no              LOW             1       up - detached
```
#### pxctl host attach
`pxctl host attach` command is used to attach a volume to a host
```
sudo /opt/pwx/bin/pxctl host attach demovolume
Volume successfully attached at: /dev/pxd/pxd772733390943400581
```
Running "volume list" will now show something like:
```
sudo /opt/pwx/bin/pxctl volume list
ID                      NAME            SIZE    HA      SHARED  ENCRYPTED       IO_PRIORITY     SCALE   STATUS
772733390943400581      demovolume      5 GiB   2       no      no              LOW             1       up - attached on 172.31.46.119 *
* Data is not local to the node on which volume is attached.
```
Note: The volume resides on 2 different nodes than the one where it was attached in the above example. Hence the warning.

#### pxctl host detach
`pxctl host detach` command is used to detach a volume from a host
```
sudo /opt/pwx/bin/pxctl host detach demovolume
Volume successfully detached
```
Running "volume list" will now show something like:
```
sudo /opt/pwx/bin/pxctl volume list
ID                      NAME            SIZE    HA      SHARED  ENCRYPTED       IO_PRIORITY     SCALE   STATUS
772733390943400581      demovolume      5 GiB   2       no      no              LOW             1       up - detached
```
#### pxctl host mount
`pxctl host mount` mounts a volume locally on a node at a path, say /mnt/demodir
```
sudo /opt/pwx/bin/pxctl host mount demovolume /mnt/demodir
Volume demovolume successfully mounted at /mnt/demodir
```
Running "volume list" will now show something like:
```
sudo /opt/pwx/bin/pxctl volume list
ID                      NAME            SIZE    HA      SHARED  ENCRYPTED       IO_PRIORITY     SCALE   STATUS
772733390943400581      demovolume      5 GiB   2       no      no              LOW             1       up - attached on 172.31.46.119 *
* Data is not local to the node on which volume is attached.
```
and running "volume inspect" on this volume will show something like:
```
sudo /opt/pwx/bin/pxctl volume inspect demovolume
Volume  :  772733390943400581
        Name                     :  demovolume
        Size                     :  5.0 GiB
        Format                   :  ext4
        HA                       :  2
        IO Priority              :  LOW
        Creation time            :  Feb 27 22:27:36 UTC 2017
        Shared                   :  no
        Status                   :  up
        State                    :  Attached: 5f8b8417-af2b-4ea7-930e-0027f6bbcbd1
        Device Path              :  /dev/pxd/pxd772733390943400581
        Reads                    :  65
        Reads MS                 :  57
        Bytes Read               :  487424
        Writes                   :  1
        Writes MS                :  1
        Bytes Written            :  4096
        IOs in progress          :  0
        Bytes used               :  211 MiB
        Replica sets on nodes:
                Set  0
                        Node     :  172.31.35.130
                        Node     :  172.31.39.201
```

#### pxctl host unmount
`pxctl host unmount` unmounts a volume from a host
```
sudo /opt/pwx/bin/pxctl host unmount demovolume /mnt/demodir
Volume demovolume successfully unmounted at /mnt/demodir
```

### Upgrade related operations
```
sudo /opt/pwx/bin/pxctl upgrade --help
NAME:
   pxctl upgrade - Upgrade PX

USAGE:
   pxctl upgrade [command options] [arguments...]

OPTIONS:
   --tag value, -l value  Specify a PX Docker image tag (default: "latest")
   
```

#### pxctl upgrade
`pxctl upgrade` upgrades the PX version on a node. Note: the container name also needs to be specified in the CLI.
```
sudo /opt/pwx/bin/pxctl upgrade --tag 1.1.6 my-px-enterprise
Upgrading my-px-enterprise to version: portworx/px-enterprise:1.1.6
Downloading PX portworx/px-enterprise:1.1.6 layers...
<Output truncated>
```
It is recommended to upgrade the nodes in a staggered manner so as to maintain quorum and continuity of IOs.




