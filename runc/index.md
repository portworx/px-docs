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
Portworx provides a Docker based installation utility to help deploy the PX OCI
bundle.  This bundle can be installed by running the following Docker container
on your host system:

```
$ sudo docker run --rm -it -v /etc/pwx:/etc/pwx -v /opt/pwx:/opt/pwx portworx/px-base-enterprise-oci
```

>**Note:**<br/>If you do not have Docker installed on your target hosts, you can download this Docker package and extract it to a root tar ball and manually install the OCI bundle.

## Run PX under RunC

You can run the PX OCI bundle via the `px-runc <install|run>` command.

The `px-runc` command is a helper-tool that does the following:

1. prepares the OCI configuration for PX,
2. prepares the OCI directory for RunC, and
3. starts the PX OCI bundle via RunC command.

For example:
```
# EXAMPLE-1: Run PX OCI bundle interactively:
sudo /opt/pwx/bin/px-runc run -c MY_CLUSTER_ID -k etcd://myetc.company.com:2379 -s /dev/xvdb -s /dev/xvdc

# EXAMPLE-2: Set up PX OCI service for kubernetes:
sudo /opt/pwx/bin/px-runc install -c MY_CLUSTER_ID -k etcd://myetc.company.com:2379 -s /dev/xvdb -s /dev/xvdc \
   -x kubernetes -v /var/lib/kubelet:/var/lib/kubelet:shared
```

#### Command-line arguments to PX <a id="command-line-args-daemon"></a>

The following arguments can be provided to the `px-runc` helper tool, which will in turn pass them to the PX daemon:

```
Usage: /opt/pwx/bin/px-runc <run|install> [options]

options:
   -oci <dir>                Specify OCI directory (dfl: /etc/pwx/oci)
   -v <dir:dir[:shared,ro]>  Specify extra mounts
   -c                        [REQUIRED] Specifies the cluster ID that this PX instance is to join
   -k                        [REQUIRED] Points to your key value database, such as an etcd cluster or a consul cluster
   -s                        [OPTIONAL if -a is used] Specifies the various drives that PX should use for storing the data
   -d <ethX>                 Specify the data network interface
   -m <ethX>                 Specify the management network interface
   -z                        Instructs PX to run in zero storage mode
   -f                        Instructs PX to use an unmounted drive even if it has a filesystem on it
   -a                        Instructs PX to use any available, unused and unmounted drives
   -A                        Instructs PX to use any available, unused and unmounted drives or partitions
   -x <swarm|kubernetes>     Specify scheduler being used in the environment
   -token <token>            Portworx lighthouse token for cluster

kvdb-options:
   -userpwd <user:passwd>    Username and password for ETCD authentication
   -ca <file>                Specify location of CA file for ETCD authentication
   -cert <file>              Specify locationof certificate for ETCD authentication
   -key <file>               Specify location of certificate key for ETCD authentication
   -acltoken <token>         ACL token value used for Consul authentication

examples:
   px-runc run -k etcd://my.company.com:4001 -c MY_CLUSTER_ID -s /dev/sdc -s /dev/sdb2
   px-runc install -k etcd:70.0.0.65:2379 -c MY_CLUSTER_ID -s /dev/sdc -d eth1 -m eth1
```

>**Note:**<br/>The volumes and files that are used internally by PX (namely `/dev`, `/etc/resolv.conf`, `/etc/pwx`, `/opt/pwx/bin`, `/var/run/docker.sock`, `/run/docker`, `/lib/modules`, `/usr/src`, `/var/cores` and `/var/lib/osd`) do not have to be specified via the `-v <dir1>:<dir2>` options.


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
      "loggingurl": "http://dummy:80",
      "storage": {
        "devices": [
          "/dev/xvdb",
          "/dev/xvdc"
        ]
      }
    }
```

For more information on the `config.json` format, refer to [this guide](https://docs.portworx.com/control/config-json.html)

>**Important:**<br/>If you are using Compose.IO and the `kvdb` string ends with `[port]/v2/keys`, omit the `/v2/keys`. Before running the container, make sure you have saved off any data on the storage devices specified in the configuration.

Please also ensure "loggingurl:" is specified in config.json. It should either point to a valid lighthouse install endpoint or a dummy endpoint as shown above. This will enable all the stats to be published to monitoring frameworks like Prometheus

## Configure systemd to start PX

You can configure the PX OCI service by running the `px-runc install` command.

For example:

```
# Set up PX OCI service:
sudo /opt/pwx/bin/px-runc install -c MY_CLUSTER_ID -k etcd://myetc.company.com:2379 -s /dev/xvdb -s /dev/xvdc

# Reload systemd configurations and start Portworx service
sudo systemctl daemon-reload
sudo systemctl start portworx
```
