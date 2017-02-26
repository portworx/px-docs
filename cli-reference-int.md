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
sudo /opt/pwx/bin/pxctl volume create clitest1 --shared --size=1 --repl=3 --iopriority=high
```
If you want to create a volume that cannot be deleted via other methods and can only be deleted via `pxctl`, use the --sticky flag

```
sudo /opt/pwx/bin/pxctl volume create clitest1 --shared --size=1 --repl=3 --sticky
```

For volumes that get created as volume sets, use --scale parameter. This parameter will help you create volumes with similar attributes in each container host in the case of highly scale-out scheduler driven envrionments. 

```
sudo /opt/pwx/bin/pxctl volume create clitest1 --shared --size=1 --repl=3 --scale=100
```

#### pxctl volume list

`pxctl volume list` or `pxctl v l` lists the volumes that have been created so far.

```
sudo /opt/pwx/bin/pxctl volume list
ID			NAME		SIZE	HA	SHARED	ENCRYPTED	PRIORITY	STATUS
508499868375963168	clitest1	1 GiB	3	yes	no		LOW		up - detached
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
 

#### pxctl volume ha-update

#### pxctl volume stats

#### pxctl volume requests

#### pxctl volume alerts

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





