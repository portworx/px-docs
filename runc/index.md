---
layout: page
title: "Run PX under runC"
keywords: portworx, px-developer, px-enterprise, plugin, install, configure, container, storage, runc, oci
sidebar: home_sidebar
redirect_from:
  - /scheduler/docker/systemd.html
---

* TOC
{:toc}

## Why runC

Running Portworx as a runC container eliminates any cyclical dependancies between a Docker container consuming storage from the Portworx container.  It also enables you to run your Linux containers without a Docker daemon completely, while still getting all of the advantages of a Linux container and cloud native storage from Portworx.

To install and configure PX to run directly with runC, please use the configuration steps described in this section.

>**Note:**<br/>It is highly recommended to include the steps outlined in this document in a systemd unit file, so that PX starts up correctly on every reboot of a host.  An example unit file is shown below.

### Prerequisites

* *SYSTEMD*: The installation below assumes the [systemd](https://en.wikipedia.org/wiki/Systemd) package is installed on your system (i.e. `systemctl` command works).
    - Note, if you are running Ubuntu 16.04, CentoOS 7 or CoreOS v94 (or newer) the "systemd" is already installed and no actions will be required.
* *SCHEDULERS*: If you are installing PX into `Kubernetes` or `Mesosphere DC/OS` cluster, we recommend to install the scheduler-specific Portworx package, which provides tighter integration, and better overall user experience.
* *FIREWALL*: Ensure ports 9001-9015 are open between the cluster nodes that will run Portworx.
* *NTP*: Ensure all nodes running PX are time-synchronized, and NTP service is configured and running.
* *KVDB*: Please have a clustered key-value database (etcd or consul) installed and ready. For etcd installation instructions refer this [doc](/maintain/etcd.html).
* *STORAGE*: At least one of the PX-nodes should have extra storage available, in a form of unformatted partition or a disk-drive.<br/> Also please note that storage devices explicitly given to Portworx (ie. `px-runc ... -s /dev/sdb -s /dev/sdc3`) will be automatically formatted by PX.

### Install

The installation and setup of PX OCI bundle is a 3-step process:

1. Install PX OCI bits
2. Configure PX OCI
3. Enable and start Portworx service

<a name="install_step1"></a>
#### Step 1: Install the PX OCI bundle
Portworx provides a Docker based installation utility to help deploy the PX OCI
bundle.  This bundle can be installed by running the following Docker container
on your host system:

```bash
# Get latest stable release tag (ie. portworx/px-enterprise:1.2.11.6)
$ latest_stable=$(curl -fsSL 'https://install.portworx.com?type=dock' | awk '/image: / {print $2}')

# Download OCI bits (reminder, you will still need to run `px-runc install ..` after this step)
$ sudo docker run --entrypoint /runc-entry-point.sh \
    --rm -i --privileged=true \
    -v /opt/pwx:/opt/pwx -v /etc/pwx:/etc/pwx \
    $latest_stable
```

>**Note:**<br/>Running the PX OCI bundle does not require Docker, but Docker will still be required to _install_ the PX OCI bundle.  If you do not have Docker installed on your target hosts, you can download this Docker package and extract it to a root tar ball and manually install the OCI bundle.

#### Step 2: Configure PX under runC

Now that you have downloaded and installed the PX OCI bundle, you can use the the `px-runc install` command from the bundle to configure `systemd` to start PX runC.

The `px-runc` command is a helper-tool that does the following:

1. prepares the OCI directory for runC
2. prepares the runC configuration for PX
3. used by `systemd` to start the PX OCI bundle

Installation examples:

```bash
# EXAMPLE-1: Basic installation
$ sudo /opt/pwx/bin/px-runc install -c MY_CLUSTER_ID \
    -k etcd://myetc.company.com:2379 \
    -s /dev/xvdb -s /dev/xvdc

# EXAMPLE-2: Installation configured for Kubernetes:
$ sudo /opt/pwx/bin/px-runc install -c MY_CLUSTER_ID \
    -k etcd://myetc.company.com:2379 \
    -s /dev/xvdb -s /dev/xvdc -x kubernetes \
    -v /var/lib/kubelet:/var/lib/kubelet:shared
```

##### Command-line arguments to PX runC

The following arguments can be provided to the `px-runc` helper tool, which will in turn pass them to the PX daemon:

```
Usage: /opt/pwx/bin/px-runc <run|install> [options]
```

{% include cmdargs.md %}


##### Examples:
Using etcd:
```
px-runc run -k etcd://my.company.com:2379 -c MY_CLUSTER_ID -s /dev/sdc -s /dev/sdb2
px-runc install -k etcd://70.0.1.65:2379 -c MY_CLUSTER_ID -s /dev/sdc -d enp0s8 -m enp0s8
px-runc install -k etcd://70.0.1.65:2379 -c MY_CID -f -a -x kubernetes -v /var/lib/kubelet:/var/lib/kubelet:shared
```

Using consul:
```
px-runc run -k consul://my.company.com:8500 -c MY_CLUSTER_ID -s /dev/sdc -s /dev/sdb2
px-runc install -k consul://70.0.2.65:8500 -c MY_CLUSTER_ID -s /dev/sdc -d enp0s8 -m enp0s8
px-runc install -k consul://70.0.2.65:8500 -c MY_CID -f -a -x kubernetes -v /var/lib/kubelet:/var/lib/kubelet:shared
```

##### Modifying the PX configuration

Since PX OCI bundle has _two_ configuration files, it is recommended to initially install the bundle by using the `px-runc install ...` command as described above, rather than supplying custom configuration files.

After the initial installation, you can modify the following files and restart the PX runC container:

* PX configuration file at `/etc/pwx/config.json` (see [details](https://docs.portworx.com/control/config-json.html)), or
* OCI spec file at `/opt/pwx/oci/config.json` (see [details](https://github.com/opencontainers/runtime-spec/blob/master/spec.md)).

#### Step 3: Starting PX runC
Once you install the PX OCI bundle and `systemd` configuration from the steps above, you can start and control PX runC directly via `systemd`:

```bash
# Reload systemd configurations, enable and start Portworx service
$ sudo systemctl daemon-reload
$ sudo systemctl enable portworx
$ sudo systemctl start portworx
```

##### Interactive mode
Alternatively, one might prefer to first start the PX interactively (for example, to verify the configuration parameters were OK and the startup was successful), and then install it as a service:

```bash
# Invoke PX interactively, abort with CTRL-C when confirmed it's running:
$ sudo /opt/pwx/bin/px-runc run -c MY_CLUSTER_ID \
    -k etcd://myetc.company.com:2379 \
    -s /dev/xvdb

[...]
> time="2017-08-18T20:34:23Z" level=info msg="Cloud backup schedules setup done"
> time="2017-08-18T20:34:23Z" level=info msg="Starting REST service on socket : /run/docker/plugins/pxd.sock"
> time="2017-08-18T20:34:23Z" level=info msg="Starting REST service on socket : /var/lib/osd/driver/pxd.sock"
> time="2017-08-18T20:34:23Z" level=info msg="PX is ready on Node: 53f5e87b... CLI accessible at /opt/pwx/bin/pxctl."
[ hit Ctrl-C ]
```

### Upgrading the PX OCI bundle

To upgrade the OCI bundle, please re-run the [installation Step 1](#install_step1) with the `--upgrade` option.
After the upgrade, you will need to restart the Portworx service.

<!--EDITING NOTE: DO NOT correct the "?type=dock" below; test the commands before modifying-->
```bash
$ latest_stable=$(curl -fsSL 'https://install.portworx.com?type=dock' | awk '/image: / {print $2}')
$ sudo docker run --entrypoint /runc-entry-point.sh \
    --rm -i --privileged=true \
    -v /opt/pwx:/opt/pwx -v /etc/pwx:/etc/pwx \
    $latest_stable --upgrade
$ sudo systemctl restart portworx
```

<a name="upgrading-from-px-containers-to-px-oci"></a>
## Migrating from PX-Containers to PX-OCI
If you already had PX running as a Docker container and now want to upgrade to runC, follow these instructions:

Step 1: Download and deploy the PX OCI bundle

<!--EDITING NOTE: DO NOT correct the "?type=dock" below; test the commands before modifying-->
```bash
$ latest_stable=$(curl -fsSL 'https://install.portworx.com?type=dock' | awk '/image: / {print $2}')
$ sudo docker run --entrypoint /runc-entry-point.sh \
    --rm -i --privileged=true \
    -v /opt/pwx:/opt/pwx -v /etc/pwx:/etc/pwx \
    $latest_stable
```

Step 2: Inspect your existing PX-Containers, record arguments and any custom mounts:

Inspect the mounts so these can be provided to the runC installer.

>**Note:**<br/>Mounts for `/dev`, `/proc`, `/sys`, `/etc/pwx`, `/opt/pwx`, `/run/docker/plugins`, `/usr/src`, `/var/cores`, `/var/lib/osd`, `/var/run/docker.sock` can be safely ignored (omitted).<br/>Custom mounts will need to be passed to PX-OCI in the next step, using the following notation:<br/>`px-runc install -v <Source1>:<Destination1>[:<Propagation1 if shared,ro>] ...`

```bash
# Inspect Arguments
{% raw %}$ sudo docker inspect --format '{{.Args}}' px-enterprise {% endraw %}
[ -c MY_CLUSTER_ID -k etcd://myetc.company.com:2379 -s /dev/xvdb ]

# Inspect Mounts
{% raw %}$ sudo docker inspect --format '{{json .Mounts}}' px-enterprise | python -mjson.tool {% endraw %}
[...]
    {
        "Destination": "/var/lib/kubelet",
        "Mode": "shared",
        "Propagation": "shared",
        "RW": true,
        "Source": "/var/lib/kubelet",
        "Type": "bind"
    },
```

Step 3: Install the PX OCI bundle

Remember to use the arguments from your PX Docker installation.

```bash
$ sudo /opt/pwx/bin/px-runc install -c MY_CLUSTER_ID \
    -k etcd://myetc.company.com:2379 \
    -s /dev/xvdb
```

Step 4: Stop PX-Container and start PX runC

```bash
# Disable and stop PX Docker container
$ sudo docker update --restart=no px-enterprise
$ sudo docker stop px-enterprise

# Set up and start PX OCI as systemd service
$ sudo systemctl daemon-reload
$ sudo systemctl enable portworx
$ sudo systemctl start portworx
```

Once you confirm the PX Container -> PX runC upgrade worked, you can permanently delete the `px-enterprise` docker container.


### Uninstalling the PX OCI bundle

To uninstall the PX OCI bundle, please run the following:

```bash
# 1: Remove systemd service (if any)
$ sudo systemctl stop portworx
$ sudo systemctl disable portworx
$ sudo rm -f /etc/systemd/system/portworx*.service

# NOTE: if the steps below fail, please reboot the node, and repeat the steps 2..5

# 2: Unmount oci (if required)
$ grep -q '/opt/pwx/oci /opt/pwx/oci' /proc/self/mountinfo && sudo umount /opt/pwx/oci

# 3: Remove binary files
$ sudo rm -fr /opt/pwx

# 4: [OPTIONAL] Remove configuration files
$ sudo rm -fr /etc/pwx
```

### Logging and Log files

The [systemd(1)](https://en.wikipedia.org/wiki/Systemd) uses a very flexible logging mechanism, where logs can be viewed using the `journalctl` command.

For example:

```bash
# Monitor the Portworx logs
$ sudo journalctl -f -u portworx

# Get a slice of Portworx logs
$ sudo journalctl -u portworx --since 09:00 --until "1 hour ago"
```

However, if you prefer to capture Portworx service logs in a separate log file, you will need to modify your host system as follows:

```bash
# Create a rsyslogd(8) rule to separate out the PX logs:
$ sudo cat > /etc/rsyslog.d/23-px-runc.conf << _EOF
:programname, isequal, "px-runc" /var/log/portworx.log
& stop
_EOF

# Create logrotate(8) configuration to periodically rotate the logs:
$ sudo cat > /etc/logrotate.d/portworx << _EOF
/var/log/portworx.log {
    daily
    rotate 7
    compress
    notifempty
    missingok
    postrotate
        /usr/bin/pkill -HUP syslogd 2> /dev/null || true
    endscript
}
_EOF

# Signal syslogd to reload the configurations:
$ sudo pkill -HUP syslogd
```
