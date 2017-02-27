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
   --shared                           Specify --shared to make this a globally shared namespace volume
   --passphrase value                 passphrase to use for the PBKDF2 function
   --label value, -l value            Comma separated name=value pairs, e.g name=sqlvolume,type=production
   --size value, -s value             specify size in GB (default: 1)
   --fs value                         filesystem to be laid out: none|xfs|ext4 (default: "ext4")
   --seed value                       optional data that the volume should be seeded with
   --block_size value, -b value       block size in Kbytes (default: 32)
   --repl value, -r value             replication factor [1..3] (default: 1)
   --scale value, --sc value          auto scale to max number [1..1024] (default: 1)
   --io_priority value                IO Priority: [high|medium|low] (default: "low")
   --sticky                           sticky volumes cannot be deleted until the flag is disabled
   --snap_interval value, --si value  snapshot interval in minutes, 0 disables snaps (default: 0)
   --nodes value                      Comma seprated Node Id(s)
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

#### pxctl volume list

`pxctl volume list` or `pxctl v l` lists the volumes that have been created so far.

```
sudo /opt/pwx/bin/pxctl volume list
ID			NAME		SIZE	HA	SHARED	ENCRYPTED	PRIORITY	STATUS
1130856252740468850	cliscale1	1 GiB	3	no	no		LOW		up - detached
1131486256496535679	cliscale	1 GiB	3	no	no		LOW		up - detached
970758537931791410	clitest		1 GiB	1	no	no		LOW		up - detached
1020258566431745338	clihigh  	1 GiB	1	no	no		HIGH		up - detached
2657835878654349872	climedium  	1 GiB	1	no	no		MEDIUM		up - detached
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

Let's do a `pxctl volume inpsect` on the volume again.

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
#### TBD: Elaborate on each option here with example


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


#### TBD: Elaborate on each option here with example

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

#### TBD: Elaborate on each option here with example

### Host related operations

````
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





