---
layout: page
title: "CLI Reference–Basics"
keywords: portworx, pxctl, command-line tool, cli, reference
sidebar: home_sidebar
redirect_from: "/cli-reference.html"
---

* TOC
{:toc}

The Portworx command-line tool, `pxctl`, is available on every node where PX is running.  It is available at the host at `/opt/pwx/bin/pxctl`.  The CLI is designed to accept and display human readable input and output by default.  In addition, every command takes in a `-j` option such that the output is in machine parsable `json` format.
	
In most production deployments, you will provision volumes directly using Docker or your scheduler (such as a Kubernetes pod spec).  However, pxctl also lets you directly provision and manage storage. In addition, the pxctl has a rich set of cluster wide management features which are explained in this document.

All operations from `pxctl` are reflected back into the containers that use Portworx storage. In addition to what is exposed in Docker volumes, `pxctl`:

* Gives access to Portworx storage-specific features, such as cloning a running container's storage.
* Shows the connection between containers and their storage volumes.
* Let you control the Portworx storage cluster, such as adding nodes to the cluster. (The Portworx tools refer to servers managed by Portworx storage as *nodes*.)

The scope of the `pxctl` command is global to the cluster. Running `pxctl` from any node within the cluster therefore shows the same global details. `pxctl` also identifies details specific to that node.

This current release of `pxctl` requires that you run as a privileged user.  The `pxctl` tool is available in the `/opt/pwx/bin/` directory. To run `pxctl` without typing the full directory path each time, add `pxctl` to your PATH as follows:

```
# sudo su
# export PATH=/opt/pwx/bin:$PATH
```

`pxctl` provides capabilities to perform much more fine-grained control of the PX resources cluster-wide and as seen above offers capabilties to manage volumes, snapshots, cluster resources, hosts in the cluster and software upgrade in the cluster.

Now you can just type `pxctl` and you're ready to start.

### Version
```
# sudo /opt/pwx/bin/pxctl -v
pxctl version 2.2.0-555ffff
```

### Help
To view all the commands offered by pxctl, type 'pxctl help'

```
# sudo /opt/pwx/bin/pxctl help  
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

<a id="pxctl-status"></a>
### Status
The status command gives summary like node details, cluster members, global storage capacity etc.

```
# sudo /opt/pwx/bin/pxctl status
```

The following sample output of `pxctl status` shows that the global capacity for Docker containers is 128 GB.

```
# /opt/pwx/bin/pxctl status
Status: PX is operational
Node ID: 0a0f1f22-374c-4082-8040-5528686b42be
	IP: 172.31.50.10
 	Local Storage Pool: 2 pools
	POOL	IO_PRIORITY	SIZE	USED	STATUS	ZONE	REGION
	0	LOW		64 GiB	1.1 GiB	Online	b	us-east-1
	1	LOW		128 GiB	1.1 GiB	Online	b	us-east-1
	Local Storage Devices: 2 devices
	Device	Path		Media Type		Size		Last-Scan
	0:1	/dev/xvdf	STORAGE_MEDIUM_SSD	64 GiB		10 Dec 16 20:07 UTC
	1:1	/dev/xvdi	STORAGE_MEDIUM_SSD	128 GiB		10 Dec 16 20:07 UTC
	total			-			192 GiB
Cluster Summary
	Cluster ID: 55f8a8c6-3883-4797-8c34-0cfe783d9890
	IP		ID					Used	Capacity	Status
	172.31.50.10	0a0f1f22-374c-4082-8040-5528686b42be	2.2 GiB	192 GiB		Online (This node)
Global Storage Pool
	Total Used    	:  2.2 GiB
	Total Capacity	:  192 GiB
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

### Login/Authentication
You must make PX login to the secrets endpoint when using encrypted volumes and ACLs.

`pxctl secrets` can be used to configure authentication credentials and endpoints - Vault, Amazon KMS, KVDB are currently supported.
Vault example (Note: To install and configure Vault, peruse [this link](https://www.vaultproject.io/intro/getting-started/install.html))
```
# sudo /opt/pwx/bin/pxctl secrets vault login
Enter VAULT_ADDRESS: http://myvault.myorg.com
Enter VAULT_TOKEN: ***
Successfully authenticated with Vault.
```
AWS KMS example
```
# sudo /opt/pwx/bin/pxctl secrets aws login
Enter AWS_ACCESS_KEY_ID [Hit Enter to ignore]: ***
Enter AWS_SECRET_ACCESS_KEY [Hit Enter to ignore]: ***
Enter AWS_SECRET_TOKEN_KEY [Hit Enter to ignore]: ***
Enter AWS_CMK [Hit Enter to ignore]: mykey
Enter AWS_REGION [Hit Enter to ignore]: us-east-1b
Successfully authenticated with AWS.
```
