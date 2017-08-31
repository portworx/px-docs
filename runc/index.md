---
layout: page
title: "Run PX under RunC"
keywords: portworx, px-developer, px-enterprise, plugin, install, configure, container, storage, runc, oci
sidebar: home_sidebar
---

* TOC
{:toc}

To install and configure PX to run directly with RunC, please use the configuration steps described in this section.

>**Note:**<br/>It is highly recommended to include the steps outlined in this document in a systemd unit file, so that PX starts up correctly on every reboot of a host.

## Install the PX OCI bundle
Portworx provides a Docker based installation utility to help deploy the PX OCI
bundle.  This bundle can be installed by running the following Docker container
on your host system:

```
$ sudo docker run --rm -it --privileged=true -v /etc/pwx:/etc/pwx -v /opt/pwx:/opt/pwx \
    portworx/px-base-enterprise-oci
```

>**Note:**<br/>Running the PX OCI bundle does not require Docker, but Docker will still be required to _install_ the PX OCI bundle.  If you do not have Docker installed on your target hosts, you can download this Docker package and extract it to a root tar ball and manually install the OCI bundle.

>**Note:**<br/>The `--privileged=true` flag has been included for backward compatibility.  You may omit this flag when using a newer Docker version (ie. v1.13 or higher), also when installing on systems that do not have SELinux enabled.

## Run PX under RunC

You can run the PX OCI bundle via the `px-runc <install|run>` command.

The `px-runc` command is a helper-tool that does the following:

1. prepares the OCI configuration for PX,
2. prepares the OCI directory for RunC, and
3. starts the PX OCI bundle via RunC command.

For example:
```
# EXAMPLE-1: Run PX OCI bundle interactively (use Ctrl-C to abort):
sudo /opt/pwx/bin/px-runc run -c MY_CLUSTER_ID -k etcd://myetc.company.com:2379 -s /dev/xvdb -s /dev/xvdc

# EXAMPLE-2: Set up PX OCI to run as a service, configured for kubernetes:
sudo /opt/pwx/bin/px-runc install -c MY_CLUSTER_ID -k etcd://myetc.company.com:2379 -s /dev/xvdb -s /dev/xvdc \
   -x kubernetes -v /var/lib/kubelet:/var/lib/kubelet:shared
```

#### Command-line arguments to PX

The following arguments can be provided to the `px-runc` helper tool, which will in turn pass them to the PX daemon:

```
Usage: /opt/pwx/bin/px-runc <run|install> [options]

options:
   -oci <dir>                Specify OCI directory (dfl: /opt/pwx/oci)
   -sysd <file>              Specify SystemD service file (dfl: /etc/systemd/system/portworx.service)
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
   px-runc install -k etcd://70.0.1.65:2379 -c MY_CLUSTER_ID -s /dev/sdc -d enp0s8 -m enp0s8
```

>**Note:**<br/>The volumes and files that are used internally by PX (namely `/dev`, `/etc/resolv.conf`, `/etc/pwx`, `/opt/pwx/bin`, `/var/run/docker.sock`, `/run/docker`, `/lib/modules`, `/usr/src`, `/var/cores` and `/var/lib/osd`) do not have to be specified via the `-v <dir1>:<dir2>` options.


#### Running with a custom config.json

Since PX OCI bundle has _two_ configuration files, it is recommended to initially install the bundle by using the `px-runc install ...` command as described above, rather than supplying custom configuration files.

After the initial installation, you can edit and adjust the:

* PX configuration file at `/etc/pwx/config.json` (see [details](https://docs.portworx.com/control/config-json.html)), or
* OCI spec file at `/opt/pwx/oci/config.json` (see [details](https://github.com/opencontainers/runtime-spec/blob/master/spec.md)).


## Configure systemd to start PX

You can configure the PX OCI service by running the `px-runc install` command.

For example:

```
# Set up PX OCI as systemd service:
sudo /opt/pwx/bin/px-runc install -c MY_CLUSTER_ID -k etcd://myetc.company.com:2379 -s /dev/xvdb

# Reload systemd configurations, enable and start Portworx service
sudo systemctl daemon-reload
sudo systemctl enable portworx
sudo systemctl start portworx
```


Alternatively, one might prefer to first start the PX interactively (ie, to verify the configuration parameters were OK, and the startup was successful), and then install it as a service:


```
# Invoke PX interactively, abort w/ CTRL-C when confirmed it's running:
sudo /opt/pwx/bin/px-runc run -c MY_CLUSTER_ID -k etcd://myetc.company.com:2379 -s /dev/xvdb

[...]
> time="2017-08-18T20:34:23Z" level=info msg="Cloud backup schedules setup done"
> time="2017-08-18T20:34:23Z" level=info msg="Starting REST service on socket : /run/docker/plugins/pxd.sock"
> time="2017-08-18T20:34:23Z" level=info msg="Starting REST service on socket : /var/lib/osd/driver/pxd.sock"
> time="2017-08-18T20:34:23Z" level=info msg="PX is ready on Node: 53f5e87b... CLI accessible at /opt/pwx/bin/pxctl."
[ hit Ctrl-C ]

# Set up PX OCI as systemd service, without reconfiguring (note: passing only 'install' parameter):
sudo /opt/pwx/bin/px-runc install

# Reload systemd configurations, enable and start Portworx service
sudo systemctl daemon-reload
sudo systemctl enable portworx
sudo systemctl start portworx
```
