---
layout: page
title: "Run PX as OCI Container"
keywords: portworx, px-developer, px-enterprise, plugin, install, configure, container, storage, runc, oci
sidebar: home_sidebar
redirect_from:
  - /scheduler/docker/systemd.html
  - /scheduler/docker/upgrade-standalone.html
  - /scheduler/docker/upgrade-px-plugin.html
---

* TOC
{:toc}

## Why OCI

Running Portworx as a runC container eliminates any cyclical dependencies between a Docker container consuming storage from the Portworx container.  It also enables you to run your Linux containers without a Docker daemon completely, while still getting all of the advantages of a Linux container and cloud native storage from Portworx.

To install and configure PX to run directly with OCI/runC, please use the configuration steps described in this section.

If you are already running PX as a docker container and need to migrate to OCI, following the [migration steps](/runc#upgrading-from-px-containers-to-px-oci).

>**Note:**<br/>It is highly recommended to include the steps outlined in this document in a systemd unit file, so that PX starts up correctly on every reboot of a host.  An example unit file is shown below.

## Install

### Prerequisites

* *SYSTEMD*: The installation below assumes the [systemd](https://en.wikipedia.org/wiki/Systemd) package is installed on your system (i.e. _systemctl_ command works).
    - Note, if you are running Ubuntu 16.04, CentoOS 7 or CoreOS v94 (or newer) the "systemd" is already installed and no actions will be required.
* *SCHEDULERS*: If you are installing PX into **Kubernetes** or **Mesosphere DC/OS** cluster, we recommend to install the scheduler-specific Portworx package, which provides tighter integration, and better overall user experience.
* *FIREWALL*: Ensure ports 9001-9015 are open between the cluster nodes that will run Portworx.
* *NTP*: Ensure all nodes running PX are time-synchronized, and NTP service is configured and running.
* *KVDB*: Please have a clustered key-value database (etcd or consul) installed and ready. For etcd installation instructions refer this [doc](/maintain/etcd.html).
* *STORAGE*: At least one of the PX-nodes should have extra storage available, in a form of unformatted partition or a disk-drive.<br/> Also please note that storage devices explicitly given to Portworx (ie. `px-runc ... -s /dev/sdb -s /dev/sdc3`) will be automatically formatted by PX.

The installation and setup of PX OCI bundle is a 3-step process:

1. Install PX OCI bits
2. Configure PX OCI
3. Enable and start Portworx service

<a name="install_step1"></a>
#### Step 1: Install the PX OCI bundle

{% include runc/runc-install-bundle.md %}

#### Step 2: Configure PX under runC

{% include runc/runc-configure-portworx.md %}

#### Step 3: Starting PX runC

{% include runc/runc-enable-portworx.md %}

##### Advanced usage: Interactive/Foreground mode
Alternatively, one might prefer to first start the PX interactively (for example, to verify the configuration parameters were OK and the startup was successful), and then install it as a service:

```bash
# Invoke PX interactively, abort with CTRL-C when confirmed it's running:
sudo /opt/pwx/bin/px-runc run -c MY_CLUSTER_ID \
    -k etcd://myetc.company.com:2379 \
    -s /dev/xvdb

[...]
> time="2017-08-18T20:34:23Z" level=info msg="Cloud backup schedules setup done"
> time="2017-08-18T20:34:23Z" level=info msg="Starting REST service on socket : /run/docker/plugins/pxd.sock"
> time="2017-08-18T20:34:23Z" level=info msg="Starting REST service on socket : /var/lib/osd/driver/pxd.sock"
> time="2017-08-18T20:34:23Z" level=info msg="PX is ready on Node: 53f5e87b... CLI accessible at /opt/pwx/bin/pxctl."
[ hit Ctrl-C ]
```

<a name="upgrade-px-oci"></a>
## Upgrading the PX OCI bundle

To upgrade the OCI bundle, simply re-run the [installation Step 1](#install_step1) with the `--upgrade` option.
After the upgrade, you will need to restart the Portworx service.

<!--EDITING NOTE: DO NOT correct the "?type=dock" below; test the commands before modifying-->
```bash
latest_stable=$(curl -fsSL 'https://install.portworx.com?type=dock&stork=false' | awk '/image: / {print $2}')
sudo docker run --entrypoint /runc-entry-point.sh \
    --rm -i --privileged=true \
    -v /opt/pwx:/opt/pwx -v /etc/pwx:/etc/pwx \
    $latest_stable --upgrade
sudo systemctl restart portworx
```

## Uninstalling the PX OCI bundle

To uninstall the PX OCI bundle, please run the following:

```bash
# 1: Remove systemd service (if any)
sudo systemctl stop portworx
sudo systemctl disable portworx
sudo rm -f /etc/systemd/system/portworx*.service

# NOTE: if the steps below fail, please reboot the node, and repeat the steps 2..5

# 2: Unmount oci (if required)
grep -q '/opt/pwx/oci /opt/pwx/oci' /proc/self/mountinfo && sudo umount /opt/pwx/oci

# 3: Remove binary files
sudo rm -fr /opt/pwx

# 4: [OPTIONAL] Remove configuration files. Doing this means UNRECOVERABLE DATA LOSS.
sudo rm -fr /etc/pwx
```

<a name="upgrading-from-px-containers-to-px-oci"></a>
## Migrating from PX-Containers to PX-OCI
If you already had PX running as a Docker container and now want to upgrade to runC, follow these instructions:

Step 1: Download and deploy the PX OCI bundle

<!--EDITING NOTE: DO NOT correct the "?type=dock" below; test the commands before modifying-->
```bash
latest_stable=$(curl -fsSL 'https://install.portworx.com?type=dock&stork=false' | awk '/image: / {print $2}')
sudo docker run --entrypoint /runc-entry-point.sh \
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
sudo /opt/pwx/bin/px-runc install -c MY_CLUSTER_ID \
    -k etcd://myetc.company.com:2379 \
    -s /dev/xvdb
```

Step 4: Stop PX-Container and start PX runC

```bash
# Disable and stop PX Docker container
sudo docker update --restart=no px-enterprise
sudo docker stop px-enterprise

# Set up and start PX OCI as systemd service
sudo systemctl daemon-reload
sudo systemctl enable portworx
sudo systemctl start portworx
```

Once you confirm the PX Container -> PX runC upgrade worked, you can permanently delete the `px-enterprise` docker container.

### Logging and Log files

The [systemd(1)](https://en.wikipedia.org/wiki/Systemd) uses a very flexible logging mechanism, where logs can be viewed using the `journalctl` command.

For example:

```bash
# Monitor the Portworx logs
sudo journalctl -f -u portworx

# Get a slice of Portworx logs
sudo journalctl -u portworx --since 09:00 --until "1 hour ago"
```

However, if you prefer to capture Portworx service logs in a separate log file, you will need to modify your host system as follows:

```bash
# Create a rsyslogd(8) rule to separate out the PX logs:
sudo cat > /etc/rsyslog.d/23-px-runc.conf << _EOF
:programname, isequal, "px-runc" /var/log/portworx.log
& stop
_EOF

# Create logrotate(8) configuration to periodically rotate the logs:
sudo cat > /etc/logrotate.d/portworx << _EOF
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
sudo pkill -HUP syslogd
```
