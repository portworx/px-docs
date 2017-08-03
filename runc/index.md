---
layout: page
title: "Run PX under RunC"
keywords: portworx, px-developer, px-enterprise, plugin, install, configure, container, storage, runc, oci
sidebar: home_sidebar
---

* TOC
{:toc}

To install and configure PX to run directly with RunC, use the command-line steps in this section.

>**Note:**<br/>It is highly recommended to include the steps outlined in this document in a systemd unit file, so that PX starts up correctly on every reboot of a host.

## Install the PX OCI bundle
Portworx provides a Docker based installation utility to help deploy the PX OCI bundle.  This bundle can be installed by running the following Docker container on your host system:

```
# docker run --rm -it -v /opt:/opt -v /etc/pwx:/etc/pwx portworx/px-oci-installer
```

>**Note:**<br/>If you do not have Docker installed on your target hosts, you can download this Docker package and extract it to a root tar ball and manually install the OCI bundle.

## Run PX under RunC

You can now run the PX OCI bundle by executing the following three commands:

```
# sudo mount -o bind,private /etc/pwx/oci /etc/pwx/oci
# sudo /opt/pwx/bin/runc create -b /etc/pwx/oci px
# sudo /opt/pwx/bin/runc exec -d px daemon
```

For example:
```
# sudo /opt/pwx/bin/runc exec -d px daemon -k etcd://myetc.company.com:2379 -c MY_CLUSTER_ID -s /dev/xvdb -s /dev/xvdc
```

#### Command-line arguments to PX <a id="command-line-args-daemon"></a>

The following arguments are provided to the PX daemon:

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

#### Running with a custom config.json

You can also provide the runtime parameters to PX via a configuration file called config.json.  When this is present, you do not need to pass the runtime parameters via the command line.  This maybe useful if you are using tools like chef or puppet to provision your host machines.

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

```
   {
      "clusterid": "make this unique in your k/v store",
      "dataiface": "bond0",
      "kvdb": [
          "etcd:https://[username]:[password]@[string].dblayer.com:[port]"
        ],
      "mgtiface": "bond0",
      “loggingurl”: “http://dummy:80“,
      "storage": {
        "devices": [
          "/dev/xvdb",
          "/dev/xvdc"
        ]
      }
    }
```

>**Important:**<br/>If you are using Compose.IO and the `kvdb` string ends with `[port]/v2/keys`, omit the `/v2/keys`. Before running the container, make sure you have saved off any data on the storage devices specified in the configuration.

Please also ensure "loggingurl:" is specificed in config.json. It should either point to a valid lighthouse install endpoint or a dummy endpoint as shown above. This will enable all the stats to be published to monitoring frameworks like Prometheus

## Configure systemd to start PX
Create a `systemd` unit file:

```
/etc/systemd/system/portworx.service
```

Add the following as the contents of that file:

```
[Unit]
Description=Portworx Container
Before=docker.service
[Service]
TimeoutStartSec=0
Restart=always
ExecStartPre=/bin/mount -o bind,private /etc/pwx/oci /etc/pwx/oci
ExecStartPre=/opt/pwx/bin/runc create -b /etc/pwx/oci px
ExecStart=/opt/pwx/bin/runc exec -d px daemon -k etcd://myetc.company.com:2379 \
      -c MY_CLUSTER_ID -s /dev/xvdb -s /dev/xvdc
KillMode=control-group
[Install]
WantedBy=multi-user.target
```

You must edit the above template to provide the cluster and node initialization options.
