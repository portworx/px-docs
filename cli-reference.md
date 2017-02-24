---
layout: page
title: "CLI Reference"
keywords: portworx, pxctl, command-line tool, cli, reference
sidebar: home_sidebar
---
The Portworx command-line tool, `pxctl`, is available on every node where PX is running.  It is exposed at the host at `/opt/pwx/bin/pxctl`.  The CLI is designed to display human readable output by default.  In addition, every command takes in a `-j` option such that the output is in machine parsable `json` format.
	
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

To view all Portworx commands, run [`pxctl help`](cli-reference.html#pxctl-command-line-help).
## Volume Status
To inspect the status of a given volume, use `pxctl volume inspect <VOLID>`.    Ex:

```
[root@px-k8s-centos-3 ~]# /opt//pwx/bin/pxctl v i fiovol
Volume	:  922203020611857957
	Name            	 :  fiovol
	Size            	 :  300 GiB
	Format          	 :  ext4
	HA              	 :  1
	IO Priority     	 :  LOW
	Shared          	 :  no
	Status          	 :  up
	State           	 :  Attached: e2441f84-246e-4517-84ad-cb1ae33617cd
	Device Path     	 :  /dev/pxd/pxd922203020611857957
	Reads           	 :  274
	Reads MS        	 :  47
	Bytes Read      	 :  1343488
	Writes          	 :  2687248
	Writes MS       	 :  46640947
	Bytes Written   	 :  85384732672
	IOs in progress 	 :  1
	Bytes used      	 :  59 GiB
	Replica sets on nodes:
		Set  0
			Node 	 :  10.100.48.5
```
The fields "Reads MS" and "Write MS" refer to time spent reading or writing, as per [standard convention](https://www.kernel.org/doc/Documentation/ABI/testing/procfs-diskstats)

The "replica sets" provides a list of nodes on which the volume data resides.

## Node and Cluster Status
To see the total storage capacity, use `pxctl status`. In the example below, a three-node cluster has a global capacity of 413 GB. The node on which `pxctl` ran contributed 256 GB to that global capacity.

As nodes join the cluster, `pxctl` reports the updated global capacity.

Example of the status summary from the first node:

```
# pxctl status
Status: PX is operational
Node ID: d0479845-ac95-4dee-aa51-bac2daf22c04
       	IP: 10.0.0.141
       	Local Storage Pool: 1 device
       	Device 	Path   		Media Type     		Size   		Last-Scan
       	1      	/dev/sdc       	STORAGE_MEDIUM_MAGNETIC	932 GiB		19 Aug 16 11:06 PDT
       	total  			-      			932 GiB
Cluster Summary
       	Cluster ID: 04c58dcf-c831-4e90-8476-4c6ff69e6a14
       	Node IP: 10.0.0.141 - Capacity: 550 MiB/932 GiB Online (This node)
       	Node IP: 10.0.0.109 - Capacity: 550 MiB/932 GiB Online
       	Node IP: 10.0.0.84 - Capacity: 549 MiB/932 GiB Online
Global Storage Pool
       	Total Used     	:  1.6 GiB
       	Total Capacity 	:  2.7 TiB
```

If there are any alerts or warnings, those are also displayed in the status output.

## Command Line Help
```
# pxctl help
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

## Manage storage volumes
To create and manage volumes, use `pxctl volume`.  You can use the created volumes directly with Docker with the `-v` option.

The pxctl volume CLI is documented in detail [here](create-manage-storage-volumes.html)

## Cluster operations
The PX cluster can be inspected and managed from any node in the cluster using the `pxctl cluster` CLI sub menu:

```
# pxctl cluster -h
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

Example of `cluster list` for a three node cluster:

```
# pxctl cluster list
Cluster ID: 04c58dcf-c831-4e90-8476-4c6ff69e6a14
Status: OK

Nodes in the cluster:
ID     					DATA IP		CPU    		MEM TOTAL      	MEM FREE       	CONTAINERS     	STATUS
d0479845-ac95-4dee-aa51-bac2daf22c04   	10.0.0.141     	0.03125		33 GB  		31 GB  		N/A    		Online
374d95fa-ffab-4f3c-b06d-ae6cfd2cf0f9   	10.0.0.109     	0.04686		33 GB  		32 GB  		N/A    		Online
273e4389-8368-478f-8ef6-033346ad162c   	10.0.0.84      	0.031245       	33 GB  		32 GB  		N/A    		Online
```

Example of inspecting a node in the cluster in `json` format

```
# pxctl -j cluster inspect 5533acd1-655e-4247-a780-3272bfc863fd
```

```json
{
 "Id": "5533acd1-655e-4247-a780-3272bfc863fd",
 "Cpu": 4.5,
 "MemTotal": 8369946624,
 "MemUsed": 643772416,
 "MemFree": 7726174208,
 "Avgload": 0,
 "Status": 2,
 "GenNumber": 1482001398854514045,
 "Disks": null,
 "MgmtIp": "172.31.8.91",
 "DataIp": "172.31.8.91",
 "Timestamp": "2016-12-17T19:17:57.67877491Z",
 "StartTime": "2016-12-17T19:03:18.854698639Z",
 "Hostname": "ip-172-31-8-91",
 "NodeData": {
  "STORAGE-INFO": {
   "LastError": "",
   "Random4KIops": 0,
   "ReadThroughput": 0,
   "ResourceMdUUID": "",
   "ResourceUUID": "",
   "Resources": {
    "0:1": {
     "id": "1",
     "last_scan": {
      "nanos": 4.14873566e+08,
      "seconds": 1.482001405e+09
     },
     "medium": 1,
     "online": true,
     "path": "/dev/xvdb",
     "rotation_speed": "Unknown",
     "seq_write": 1.1079e+07,
     "size": 1.073741824e+12,
     "used": 2.168958484e+09
    }
   },
   "ResourcesCount": 1,
   "ResourcesLastScan": "Resources Scan OK",
   "ResourcesMd": null,
   "ResourcesMdCount": 0,
   "ResourcesMdLastScan": "",
   "Status": "Up",
   "TotalSize": 1.073741824e+12,
   "Used": 0,
   "WriteThroughput": 0
  },
  "STORAGE-RUNTIME": {
   "MID": "5533acd1-655e-4247-a780-3272bfc863fd",
   "PoolUsage": {
    "0": {
     "TotalAllocated": 1.245540516e+09
    }
   },
   "Usage": {
    "TotalAllocated": 1.245540516e+09
   }
  },
  "storage_stats": {
   "Cpu": 4.5,
   "DiskAvail": 1.071572865516e+12,
   "DiskTotal": 1.073741824e+12,
   "DiskUtil": 2.168958484e+09,
   "Memory": 7,
   "PendingIo": 0
  }
 },
 "NodeLabels": {
  "City": "San Jose",
  "Country": "United States",
  "Data IP": "172.31.8.91",
  "ISP": "Amazon",
  "ISP IP": "54.67.4.138",
  "LAT": "3.73394E+01",
  "LNG": "-1.21895E+02",
  "Managemet IP": "172.31.8.91",
  "Node Count Limit": "3",
  "PX Version": "1.2.0-136e7d1",
  "Region": "CA",
  "Timezone": "America/Los_Angeles",
  "Zip": "95141"
 }
}
```

Note the usage of the `-j` flag.

## Service mode operations
The PX cluster can be serviced using the `pxctl service` sub menu.

```
# pxctl service
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

When there is an operational failure, you can use `pxctl service diags <name-of-px-container>` to generate a complete diagnostics package.  This package will be automatically uploaded to Portworx.  Additionally, the service package can be mailed to Portworx at support@portworx.com.  The package will be available at  `/tmp/diags.tgz` inside the PX container.  You can use `docker cp` to extract the diagnostics package.

You can manage the physical storage drives on a node using the `pxctl service drive` sub menu.

```
# pxctl service drive
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

To rebalance the storage across the drives, use `pxctl service drive rebalance`.  This is useful after prolonged operation of a node.

