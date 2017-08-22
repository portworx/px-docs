---
layout: page
title: "Run PX as a Docker V2 Plugin"
keywords: portworx, px-developer, px-enterprise, plugin, install, configure, container, storage, add nodes
sidebar: home_sidebar
redirect_from: "/run-as-docker-pluginv2.html"
meta-description: "Use these command-line steps to install and configure PX through the Docker Plugin CLI. Follow our example to see for yourself!"
---

* TOC
{:toc}

Starting with Docker v1.13, the Docker has introduced a "managed plugin system", together with a new "v2 plugin architecture".
Please note that the "legacy plugin system" (Docker v1.12 plugins) is still fully supported in the newer Docker versions.

To install and configure Portworx v2 Docker Plugin, please use the steps below.

### Install PX plugin

Before installing the plugin, please:

1. Create the following directories on the host system:

   ```
   $ sudo mkdir -p /etc/pwx /opt/pwx/bin /var/lib/osd /var/cores
   ```

   * these directories are no longer created automatically via v2 Docker plugin, but will be required so that PX-plugin can export ```pxctl``` CLI onto the host, share configuration files, etc.

2. Make sure you have your key-value database ready (ie. preinstall `etcd`), and

3. Ensure host system has some extra disk-storage (ie. `/dev/sdc` disk).


To install Portworx as V2 Docker plugin, please run:

```
$ sudo docker plugin install portworx/px:latest --alias pxd \
  opts="-k etcd://myetc.company.com:2379 -c MY_CLUSTER_ID -s /dev/sdc"

Plugin "portworx/px:latest" is requesting the following privileges:
 - network: [host]
 - mount: [/dev]
 - mount: [/etc/pwx]
 - mount: [/var/lib/osd]
 - mount: [/opt/pwx/bin]
 - mount: [/var/run/docker.sock]
 - mount: [/lib/modules]
 - mount: [/usr/src]
 - mount: [/var/cores]
 - allow-all-devices: [true]
 - capabilities: [CAP_SYS_ADMIN CAP_SYS_MODULE CAP_IPC_LOCK CAP_SYS_PTRACE]
Do you grant the above permissions? [y/N] y
```
You will need to grant the permissions above for the plugin to be installed.

The required permissions are explained below:

```
 - capabilities: [CAP_SYS_ADMIN CAP_SYS_MODULE CAP_IPC_LOCK CAP_SYS_PTRACE]
    > Sets PX to be a privileged plugin. Required to export block device and for other functions.

 - network: [host]
    > Sets communication to be on the host IP address over ports 9001-9003. Future versions will support separate IP addressing for PX.

 - mount: [/dev]
 - allow-all-devices: [true]
    > Allows PX to access all host devices. Note that PX uses only devices/drives specified via `-s /dev/xxx` in opts or config.json.
    
 - mount: [/etc/pwx]
    > the configuration files location.

 - mount: [/var/run/docker.sock]
    > Used by Docker to export volume container mappings.

 - mount: [/var/lib/osd]
    > Location of the exported container mounts. This must be a shared mount.

 - mount: [/opt/pwx/bin]
    > Exports pxctl, the PX command line tool, from the plugin to the host.
```


The description of all of the arguments one can provide to the plugin via ```opts="..." ``` install parameter:

|  Argument | Description                                                                                                                                                                              |
|:---------:|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|     `-c`    | (Required) Specifies the cluster ID that this PX instance is to join. You can create any unique name for a cluster ID.                                                                   |
|     `-k`    | (Required) Points to your key value database, such as an etcd cluster or a consul cluster.                                                                                               |
|     `-s`    | (Optional if -a is used) Specifies the various drives that PX should use for storing the data.                                                                                           |
|     `-d`    | (Optional) Specifies the data interface.                                                                                                                                                 |
|     `-m`    | (Optional) Specifies the management interface.                                                                                                                                           |
|     `-z`    | (Optional) Instructs PX to run in zero storage mode. In this mode, PX can still provide virtual storage to your containers, but the data will come over the network from other PX nodes. |
|     `-f`    | (Optional) Instructs PX to use an unmounted drive even if it has a filesystem on it.                                                                                                     |
|     `-a`    | (Optional) Instructs PX to use any available, unused and unmounted drive.,PX will never use a drive that is mounted.                                                                     |
|     `-A`    | (Optional) Instructs PX to use any available, unused and unmounted drives or partitions. PX will never use a drive or partition that is mounted.                                         |
|     `-x`    | (Optional) Specifies the scheduler being used in the environment. Supported values: "swarm" and "kubernetes".                                                                            |
|  `-userpwd` | (Optional) Username and password for ETCD authentication in the form user:password                                                                                                       |
|    `-ca`    | (Optional) Location of CA file for ETCD authentication.                                                                                                                                  |
|   `-cert`   | (Optional) Location of certificate for ETCD authentication.                                                                                                                              |
|    `-key`   | (Optional) Location of certificate key for ETCD authentication.                                                                                                                          |
| `-acltoken` | (Optional) ACL token value used for Consul authentication.                                                                                                                               |
|   `-token`  | (Optional) Portworx lighthouse token for cluster.                                                                                                                                        |

#### Staged install/startup of v2 Portworx plugin

Sometimes it will be more appropriate to install and start the v2 Portworx plugin "in stages".
This can be achieved using the following steps:

* step 1: Download the PX-Plugin, but do not immediately enable it:

```
sudo docker plugin install --grant-all-permissions --disable --alias pxd portworx/px:latest
sudo docker plugin ls
ID                  NAME                DESCRIPTION                         ENABLED
9c6d7647ec0b        pxd:latest          Portworx Data Services for Docker   false
```

* step 2: Configure PX-Plugin:

```
sudo docker plugin set pxd \
   opts='-k etcd://myetc.company.com:2379 -c MY_CLUSTER_ID -s /dev/sdc -d enp0s8 -m enp0s8'
```

* step 3: Stop the old (v1) PX-Plugin container (if any), and start the v2 PX-plugin:

```
sudo docker stop px-enterprise
sudo docker update --restart=no px-enterprise

sudo docker plugin enable pxd
```

<a name="docker-switch-v1-v2"></a>
#### Upgrading Portworx Container to Portworx v2 Docker plugin

Note that one cannot run the PX-Container and PX-Plugin at the same time.
If you have previously installed Portworx as a Docker container (the "legacy
plugin system", or v1 plugin), please first stop the PX-Container and disable
the automatic startup, like so:

```
sudo docker stop px-enterprise
sudo docker update --restart=no px-enterprise
```

Please make sure to install the Portworx v2 plugin with `--alias pxd` option
during [plugin installation](#install-px-plugin).
This option will enable Docker to find the registered PX-Volumes under new
Portworx v2 plugin management, and transparently update the existing Docker
containers/applications that use the PX-Volumes:


* ie. PX volume used by MySQL _before_ the v1->v2 Plugin update:

```
sudo docker inspect pxMySQL

[...]
  "Mounts": [
    {
      "Type": "volume",
      "Name": "pxMysqlData1",
      "Source": "/var/lib/osd/mounts/pxMysqlData1",
      "Destination": "/var/lib/mysql",
      "Driver": "pxd",
      "Mode": "",
      "RW": true,
      "Propagation": ""
    }
```

* ... and _after_ the v1->v2 Plugin update:

```
sudo docker inspect pxMySQL

[...]
  "Mounts": [
    {
      "Type": "volume",
      "Name": "pxMysqlData1",
      "Source": "/var/lib/docker/plugins/9c6d76...bcd/rootfs",
      "Destination": "/var/lib/mysql",
      "Driver": "pxd",
      "Mode": "",
      "RW": true,
      "Propagation": ""
    }
```


#### Optional - running with a custom config.json

You can also provide the runtime parameters to PX via a configuration file called config.json.  When this is present, you do not need to
pass the runtime parameters via ```opts``` argument.  This maybe useful if you are using tools like chef or puppet to provision your host machines.

1. Download the sample config.json file:
https://raw.githubusercontent.com/portworx/px-dev/master/conf/config.json
2. Create a directory for the configuration file.

   ```
   # sudo mkdir -p /etc/pwx
   ```
   
3. Move the configuration file to that directory. This directory later gets passed in on the Docker command line.

   ```
   # sudo cp -p config.json /etc/pwx
   ```
   
4. Edit the config.json to include the following:
   * `clusterid`: This string identifies your cluster and must be unique within your etcd key/value space.
   * `kvdb`: This is the etcd connection string for your etcd key/value store.
   * `devices`: These are the storage devices that will be pooled from the prior step.


Example config.json:

```json
{
  "clusterid": "make this unique in your k/v store",
  "kvdb": [
      "etcd:https://[username]:[password]@[string].dblayer.com:[port]"
  ],
  "storage": {
    "devices": [
      "/dev/xvdb",
      "/dev/xvdc"
    ]
  }
}
```

At this point, Portworx should be running on your system. To verify, run `docker plugin ls`.

#### Authenticated `etcd` and `consul`
To use `etcd` with authentication and a cafile, use this in your `config.json`:

```json
{
  "kvdb": [
    "etcd:https://<ip1>:<port>",
    "etcd:https://<ip2>:<port>"
  ],
  "username": "root",
  "password": "xxx",
  "cafile": "/etc/pwx/cafile",
}
```

To use `consul` with authentication and a cafile, use this in your `config.json`:

```json
{
  "kvdb": [
    "consul:https://<ip1>:<port>",
    "consul:https://<ip2>:<port>"
  ],
  "username": "root",
  "password": "xxx",
  "cafile": "/etc/pwx/cafile",
}
```

### Access the pxctl CLI
After Portworx V2 plugin is running, you can create, delete & manage storage volumes through the
[Docker volume commands](/scheduler/docker/volume_plugin.html#docker-interaction-with-portworx)
or via the [**pxctl** command line tool](/control/status.html), as you usually would.

A useful pxctl command is `pxctl status`.
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


#### TROUBLESHOOTING NOTES:

* Q: My PX-Plugin won't start! The `docker plugin ls` shows *Enabled=false* even after I ran `docker plugin enable pxd` command.  How can I fix it?
	* A: Please run `journalctl -b -u docker` to get the PX-Plugin log, and:
		* if you spot <U>"bind: address already in use"</U> error messages, please make sure you are _not_ running both PX-Container and PX-Plugin at the same time (ie. check "docker ps" and "docker plugin ls").
		* If you find <U>"PX upgrade in progress. Requires reboot to complete."</U> error message in the log, disable the PX-Container and reboot the host system.
		* **NOTE** that one can disable the PX-Container by running:<br/>`docker stop px-enterprise; docker update --restart=no px-enterprise`

* Q: Docker apps cannot find the PX-Volumes after v1->v2 upgrade. How do I fix this?
	* A1: Make sure you have not omitted the `--alias pxd` option during the [plugin
installation](#install-px-plugin) (ie. command `docker plugin inspect pxd` should work).  Reinstall plugin otherwise.
	* A2: Use `umount` and `pxctl host detach` commands to manually detach the PX-Volume, restart Docker service and the Docker apps that are using the PX-Volumes (or, just reboot the host).

* Q: The [docker volume ls](https://docs.docker.com/engine/reference/commandline/volume_ls/) and
[inspect](https://docs.docker.com/engine/reference/commandline/volume_inspect/) commands failing when run on PX-Volumes after v1->v2 upgrade.
	* A: The PX-Volumes were likely in use (mounted) during the v1->v2 upgrade.  Please restart Docker service to fix this.

* Q: Docker startup is slow, logs show Docker is trying to access `/run/docker/plugins/pxd.sock` file.
	* A: The `/run/docker/plugins/pxd.sock` file should have been removed when the PX-Container services have been stopped.  If by any chance this file still exists on the host, please remove it manually.
