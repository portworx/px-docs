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
   1.2.0-75d0dbb
   
COMMANDS:
     status         Show status summary
     volume, v      Manage volumes
     snap, s        Manage volume snapshots
     cluster, c     Manage the cluster
     service, sv    Service mode utilities
     host           Attach volumes to the host
     secrets        Manage Secrets
     upgrade        Upgrade PX
     eula           Show license agreement
     cloudsnap, cs  Backup and restore snapshots to/from cloud
     objectstore    Manage the object store
     help, h        Shows a list of commands or help for one command

GLOBAL OPTIONS:
   --json, -j     output in json
   --color        output with color coding
   --raw, -r      raw CLI output for instrumentation
   --help, -h     show help
   --version, -v  print the version
```

`pxctl` provides capabilities to perform much more fine-grained control of the PX resources cluster-wide and as seen above offers capabilties to manage volumes, snapshots, cluster resources, hosts in the cluster and software upgrade in the cluster

Let's review each command, options available under command and an example of how those options are used

### Login/Authentication
`pxctl secrets` can be used to configure authentication credentials and endpoints - Vault, Amazon KMS, KVDB are currently supported.
Vault example
```
sudo /opt/pwx/bin/pxctl secrets vault login
Enter VAULT_ADDRESS: http://myvault.myorg.com
Enter VAULT_TOKEN: ***
Successfully authenticated with Vault.
```
AWS KMS example
```
sudo /opt/pwx/bin/pxctl secrets aws login
Enter AWS_ACCESS_KEY_ID [Hit Enter to ignore]: ***
Enter AWS_SECRET_ACCESS_KEY [Hit Enter to ignore]: ***
Enter AWS_SECRET_TOKEN_KEY [Hit Enter to ignore]: ***
Enter AWS_CMK [Hit Enter to ignore]: mykey
Enter AWS_REGION [Hit Enter to ignore]: us-east-1b
Successfully authenticated with AWS.
```

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

For creating an aggregated volume, use the following command.
```
sudo /opt/pwx/bin/pxctl volume create cliaggr --size=1 --repl=2 --aggregation_level=3
```

If you want to create a volume that cannot be deleted via other methods and can only be deleted via `pxctl`, use the --sticky flag
```
sudo /opt/pwx/bin/pxctl volume create cliscale --shared --size=1 --repl=3 --sticky
```

For volumes that get created as volume sets, use --scale parameter. This parameter will help you create volumes with similar attributes in each container host in the case of highly scale-out scheduler driven environments. 
```
sudo /opt/pwx/bin/pxctl volume create cliscale1 --shared --size=1 --repl=3 --scale=100
```


For encrypted volumes, pass a '--secure' flag. The secret, by default, is the cluster secret key. A different key maybe passed too.
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
570354879481121709	cliaggr		1 GiB	2	no	no		LOW		1	up - detached

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
     logging-url, l  Cluster wide logging-url settings

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

#### pxctl service logging-url
Use pxctl service logging-url to show, set and reset logging-url cluster wide.
```
sudo /opt/pwx/bin/pxctl service logging-url
NAME:
   pxctl service logging-url - Cluster wide logging-url settings

USAGE:
   pxctl service logging-url command [command options] [arguments...]

COMMANDS:
     show, l   Shows currently configured logging-url
     set, s    Sets the logging-url for the cluster
     reset, r  Resets the logging-url for the cluster

OPTIONS:
   --help, -h  show help
```
```
sudo /opt/pwx/bin/pxctl service logging-url set http://www.statspoint.com
Setting logging-url  http://www.statspoint.com ...
Successfully updated logging-url to http://www.statspoint.com
```
```
sudo /opt/pwx/bin/pxctl service logging-url show
logging-url: http://www.statspoint.com
```
```
sudo /opt/pwx/bin/pxctl service logging-url reset
Resetting logging-url ...
Successfully reset logging-url
```
```
Reset will remove the configured logging-url.
sudo /opt/pwx/bin/pxctl service logging-url show
logging-url: Not configured.
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

For an encrypted volume, if you are not using the cluster secret pass in '--secret_key &lt;key&gt;'. Otherwise the cluster secret key will be used.
```
sudo /opt/pwx/bin/pxctl host attach cliencr
Volume successfully attached at: /dev/mapper/pxd-enc1013237432577873530
```

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

### Cloudsnap operations
Help for specific cloudsnap commands can be found by running the following command

Note: All cloudsnap operations requires secrets login to configured endpoint with/without encryption. Please refer pxctl secrets cmd help.
#### pxctl cloudsnap --help
```
sudo /opt/pwx/bin/pxctl cloudsnap --help
NAME:
   pxctl cloudsnap - Backup and restore snapshots to/from cloud

USAGE:
   pxctl cloudsnap command [command options] [arguments...]

COMMANDS:
     backup, b          Backup a snapshot to cloud
     restore, r         Restore volume to a cloud snapshot
     list, l            List snapshot in cloud
     status, s          Report status of active backups/restores
     schedule, sc       Update cloud-snap schedule
     credentials, cred  Manage cloud-snap credentials

OPTIONS:
   --help, -h  show help
```

#### pxctl cloudsnap credentials
This command is used to create/list/validate/delete the credentials for cloud providers. These credentials will be used for cloudsnap of volume to the cloud.  

Note: It will create a bucket with the portworx cluster ID to use for the backups
```
sudo /opt/pwx/bin/pxctl cloudsnap credentials
NAME:
   pxctl cloudsnap credentials - Manage cloud-snap credentials

USAGE:
   pxctl cloudsnap credentials command [command options] [arguments...]

COMMANDS:
     create, c    Create a credential for cloud-snap
     list, l      List all credentials for cloud-snap
     delete, d    Delete a credential for cloud-snap
     validate, v  Validate a credential for cloud-snap

OPTIONS:
   --help, -h  show help
```

#### pxctl cloudsnap credentials list
`pxctl cloudsnap credentials list` is used to list all configured credential keys
```
sudo /opt/pwx/bin/pxctl cloudsnap credentials list

S3 Credentials
UUID						REGION			ENDPOINT			ACCESS KEY			SSL ENABLED	ENCRYPTION
ffffffff-ffff-ffff-1111-ffffffffffff		us-east-1		s3.amazonaws.com		AAAAAAAAAAAAAAAAAAAA		false		false

Azure Credentials
UUID						ACCOUNT NAME		ENCRYPTION
ffffffff-ffff-ffff-ffff-ffffffffffff		portworxtest		false
```

#### pxctl cloudsnap credentials create
`pxctl cloudsnap credentials create` is used to create/configure credentials for various cloud providers
```
sudo /opt/pwx/bin/pxctl cloudsnap cred create --provider s3 --s3-access-key AAAAAAAAAAAAAAAA --s3-secret-key XXXXXXXXXXXXXXXX --s3-region us-east-1 --s3-endpoint s3.amazonaws.com
Credentials created successfully
```

#### pxctl cloudsnap credentials delete
`pxctl cloudsnap credentials delete` is used to delete the credentials from the cloud providers.
```
sudo /opt/pwx/bin/pxctl cloudsnap cred delete --uuid ffffffff-ffff-ffff-1111-ffffffffffff
Credential deleted successfully
```

#### pxctl cloudsnap credentials validate
`pxctl cloudsnap credentials validate` validates the existing credentials
```
sudo /opt/pwx/bin/pxctl cloudsnap cred validate --uuid ffffffff-ffff-ffff-1111-ffffffffffff
Credential validated successfully
```

#### pxctl cloudsnap backup
`pxctl cloudsnap backup` command is used to backup a single volume to the configured cloud provider through credential command line. 
If it will be the first backup for the volume a full backup of the volume is generated. If it is not the first backup, it only generates an incremental backup from the previous full/incremental backup.
If a single cloud provider credential is created then there is no need to specify the credentials on the command line.
```
sudo /opt/pwx/bin/pxctl cloudsnap backup vol1
Cloudsnap backup started successfully
```
If multiple cloud providers credentials are created then need to specify the credential to use for backup on command line
```
sudo /opt/pwx/bin/pxctl cloudsnap backup vol1 --cred-uuid ffffffff-ffff-ffff-1111-ffffffffffff 
Cloudsnap backup started successfully
```
Note: All cloudsnap backup/Restores can be monitored through CloudSnap status command which is described in following sections

#### pxctl cloudsnap restore
`pxctl cloudsnap restore` command is used to restore a successful backup from cloud. (Use cloudsnap list command to get the cloudsnap Id). It requires cloudsnap Id (to be restored) and credentials. 
Restore happens on any node in the cluster where storage can be provisioned. In this release, restored volume will be of replication factor 1. 
This volume can be updated to different repl factors using volume ha-update command.
```
sudo /opt/pwx/bin/pxctl cloudsnap restore --snap gossip12/181112018587037740-545317760526242886
Cloudsnap restore started successfully: 315244422215869148
```
Note: All cloudsnap backup/Restores can be monitored through CloudSnap status command which is described in following sections

#### pxctl cloudsnap status
`pxctl cloudsnap status` can be used to check the status of cloudsnap operations
```
sudo /opt/pwx/bin/pxctl cloudsnap status
SOURCEVOLUME		STATE		BYTES-PROCESSED	TIME-ELAPSED		COMPLETED			          ERROR
1040525385624900824	Restore-Done	11753581193	8m32.231744596s		Wed, 05 Apr 2017 06:57:08 UTC
1137394071301823388	Backup-Done	11753581193	1m46.023734966s		    Wed, 05 Apr 2017 05:03:42 UTC
13292162184271348	Backup-Done	27206221391	4m25.740022954s		    Wed, 05 Apr 2017 22:39:41 UTC
454969905909227504	Backup-Active	91944386560	4h8m19.283242837s
827276927130532677	Restore-Failed	0									             Failed to authenticate creds ID
```

#### pxctl cloudsnap list
`pxctl cloudsnap list` is used to list all the cloud snapshots
```
sudo /opt/pwx/bin/pxctl cloudsnap list --cred-uuid ffffffff-ffff-ffff-1111-ffffffffffff --all
SOURCEVOLUME 			CLOUD-SNAP-ID									CREATED-TIME				STATUS
vol1			gossip12/181112018587037740-545317760526242886		Sun, 09 Apr 2017 14:35:28 UTC		Done
```
Filtering on cluster ID or volume ID is available and can be done as follows:
```
sudo /opt/pwx/bin/pxctl cloudsnap list --cred-uuid ffffffff-ffff-ffff-1111-ffffffffffff --src vol1
SOURCEVOLUME 		CLOUD-SNAP-ID					CREATED-TIME				STATUS
vol1			1137394071301823388-283948499973931602		Wed, 05 Apr 2017 04:50:35 UTC		Done
vol1			1137394071301823388-674319852060841900		Wed, 05 Apr 2017 05:01:56 UTC		Done

sudo /opt/pwx/bin/pxctl cloudsnap list --cred-uuid ffffffff-ffff-ffff-1111-ffffffffffff --cluster cs25
SOURCEVOLUME 		CLOUD-SNAP-ID					CREATED-TIME				STATUS
vol1			1137394071301823388-283948499973931602		Wed, 05 Apr 2017 04:50:35 UTC		Done
vol1			1137394071301823388-674319852060841900		Wed, 05 Apr 2017 05:01:56 UTC		Done
volshared1		13292162184271348-457364119636591866		Wed, 05 Apr 2017 22:35:16 UTC		Done
```


