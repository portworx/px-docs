---
layout: page
title: "Run PX via upstart"
keywords: portworx, px-developer, px-enterprise, plugin, install, configure, container, storage, runc, oci, upstart
redirect_from:
  - /runc-with-upstart.html
  - /runc/upstart/index.html
---

* TOC
{:toc}

This document describes how to manually install Portworx on older Linux hosts (e.g. Ubuntu 14.04) that use the
[upstart](https://en.wikipedia.org/wiki/Upstart) for the service management.

For more information about Portworx installation, please see [docs.portworx.com/runc](/runc).


## Install

### Prerequisites

* *UPSTART*: Please double-check your system uses [upstart](https://en.wikipedia.org/wiki/Upstart) instead of
[systemd](https://en.wikipedia.org/wiki/Systemd) service management (e.g. run `initctl version`).
    - If you are running `systemd` service management (e.g. validate via `systemctl is-system-running`), please refer to our
[regular installation](/runc) instructions.
* *SCHEDULERS*: This type of installation does not support advanced integrations with schedulers such as _Kubernetes_
or _Mesosphere DC/OS_.  If you require such integration, please contact us at support@portworx.com .
* *FIREWALL*: Ensure ports 9001-9015 are open between the cluster nodes that will run Portworx.
* *NTP*: Ensure all nodes running PX are time-synchronized, and NTP service is configured and running.
* *KVDB*: Please have a clustered key-value database (etcd or consul) installed and ready. For etcd installation instructions refer this [doc](/maintain/etcd.html).
* *STORAGE*: At least one of the PX-nodes should have extra storage available, in a form of unformatted partition or a disk-drive.<br/> Also please note that storage devices explicitly given to Portworx (ie. `px-runc ... -s /dev/sdb -s /dev/sdc3`) will be automatically formatted by PX.

The installation and setup of PX OCI bundle is a 3-step process:

1. Install PX OCI bits
2. Configure PX OCI
3. Enable and start Portworx service

<a name="install_step1"></a>

### Step 1: Install the PX OCI bundle

Portworx provides a Docker based installation utility to help deploy the PX OCI
bundle.  This bundle can be installed by running the following Docker container
on your host system:

```bash
# Uncomment appropriate `REL` below to select desired Portworx release
REL=""          # DEFAULT portworx release
#REL="/1.4"     # 1.4 portworx release
#REL="/1.5"     # 1.5 portworx release
#REL="/1.6"     # 1.6 portworx release

latest_stable=$(curl -fsSL "https://install.portworx.com$REL/?type=dock&stork=false" | awk '/image: / {print $2}')

# Download OCI bits (reminder, you will still need to run `px-runc install ..` after this step)
sudo docker run --entrypoint /runc-entry-point.sh \
    --rm -i --privileged=true \
    -v /opt/pwx:/opt/pwx -v /etc/pwx:/etc/pwx \
    $latest_stable
```

>**Note:**<br/>Running the PX OCI bundle does not require Docker, but Docker will still be required to _install_ the PX OCI bundle.


### Step 2: Configure PX under runC

Now that you have downloaded and installed the PX OCI bundle, you can use the the `px-runc install` command from the bundle to configure Portworx.

The _px-runc_ command is a helper-tool that does the following:

1. prepares the OCI directory for runC
2. prepares the runC configuration for PX
3. used by systemd/upstart to start the PX OCI bundle

Installation example:

```bash
#  Basic installation
sudo /opt/pwx/bin/px-runc install -c MY_CLUSTER_ID \
    -k etcd://myetc.company.com:2379 \
    -s /dev/xvdb -s /dev/xvdc \
    -sysd /dev/null
```


#### Command-line arguments:

<a name="opts"></a>
**Options**

```
-c                        [REQUIRED] Specifies the cluster ID that this PX instance is to join
-k                        [REQUIRED] Points to your key value database, such as an etcd cluster or a consul cluster
-s                        [REQUIRED unless -a is used] Specifies the various drives that PX should use for storing the data
-e key=value              [OPTIONAL] Specify extra environment variables
-v <dir:dir[:shared,ro]>  [OPTIONAL] Specify extra mounts
-d <ethX>                 [OPTIONAL] Specify the data network interface
-m <ethX>                 [OPTIONAL] Specify the management network interface
-z                        [OPTIONAL] Instructs PX to run in zero storage mode
-f                        [OPTIONAL] Instructs PX to use an unmounted drive even if it has a filesystem on it
-a                        [OPTIONAL] Instructs PX to use any available, unused and unmounted drives
-A                        [OPTIONAL] Instructs PX to use any available, unused and unmounted drives or partitions
-j                        [OPTIONAL] Specifies a journal device for PX.  Specify a persistent drive like /dev/sdc or use auto (recommended)
-x <swarm|kubernetes>     [OPTIONAL] Specify scheduler being used in the environment
-r <portnumber>           [OPTIONAL] Specifies the portnumber from which PX will start consuming. Ex: 9001 means 9001-9020
```

* additional PX-OCI -specific options:

```
-oci <dir>                [OPTIONAL] Specify OCI directory (default: /opt/pwx/oci)
-sysd <file>              [OPTIONAL] Specify SystemD service file (default: /etc/systemd/system/portworx.service)
```

**KVDB options**

```
-userpwd <user:passwd>    [OPTIONAL] Username and password for ETCD authentication
-ca <file>                [OPTIONAL] Specify location of CA file for ETCD authentication
-cert <file>              [OPTIONAL] Specify location of certificate for ETCD authentication
-key <file>               [OPTIONAL] Specify location of certificate key for ETCD authentication
-acltoken <token>         [OPTIONAL] ACL token value used for Consul authentication
```

**Secrets options**

```
-secret_type <aws|dcos|docker|k8s|kvdb|vault>   [OPTIONAL] Specify the secret type to be used by Portworx for cloudsnap and encryption features.
-cluster_secret_key <id>        [OPTIONAL] Specify the cluster wide secret key to be used when using AWS KMS or Vault for volume encryption.
```

<a name="env-variables"></a>
**Environment variables**

```
PX_HTTP_PROXY         [OPTIONAL] If running behind an HTTP proxy, set the PX_HTTP_PROXY variables to your HTTP proxy.
PX_HTTPS_PROXY        [OPTIONAL] If running behind an HTTPS proxy, set the PX_HTTPS_PROXY variables to your HTTPS proxy.
PX_ENABLE_CACHE_FLUSH [OPTIONAL] Enable cache flush deamon. Set PX_ENABLE_CACHE_FLUSH=true.
PX_ENABLE_NFS         [OPTIONAL] Enable the PX NFS daemon. Set PX_ENABLE_NFS=true.
```

>**Note:**<br/>Setting environment variables can be done using the `-e` option, during command line install (e.g. add `-e VAR=VALUE` option), like in the example below:

```bash
# Example PX-OCI config with extra "PX_ENABLE_CACHE_FLUSH" environment variable
sudo /opt/pwx/bin/px-runc install -e PX_ENABLE_CACHE_FLUSH=yes \
    -c MY_CLUSTER_ID -k etcd://myetc.company.com:2379 -s /dev/xvdb -sysd /dev/null

```

#### Examples

Using etcd:

```
px-runc install -k etcd://my.company.com:2379 -c MY_CLUSTER_ID -s /dev/sdc -s /dev/sdb2 -sysd /dev/null
px-runc install -k etcd://70.0.1.65:2379 -c MY_CLUSTER_ID -s /dev/sdc -d enp0s8 -m enp0s8 -sysd /dev/null
```

Using consul:

```
px-runc install -k consul://my.company.com:8500 -c MY_CLUSTER_ID -s /dev/sdc -s /dev/sdb2 -sysd /dev/null
px-runc install -k consul://70.0.2.65:8500 -c MY_CLUSTER_ID -s /dev/sdc -d enp0s8 -m enp0s8 -sysd /dev/null
```

>**Note:**<br/>Please note that the `px-runc install ...` command might produce a warning "Could not enable portworx-reboot".  Please note that this warning is safe to ignore.


### Step 3: Configure Portworx service, and start it

Run the command below to create the `/etc/init/portworx.conf` _upstart_-config file that controls Portworx service:

```bash
sudo cat > /etc/init/portworx.conf << '_EOF'
description "Portworx OCI service"
author "Portworx"
start on stopped rc RUNLEVEL=[345]

env max_retries=300
respawn

pre-start exec /opt/pwx/bin/runc delete -f portworx
script
    date +"%F %T,%3N INFO STARTUP:: Starting Portworx OCI $0 $@"
    exec /opt/pwx/bin/px-runc run --name portworx
end script

post-stop script
    pgpid=$(/opt/pwx/bin/runc list | awk '/^portworx/{print $2}')
    if [ "x$pgpid" != x ] && [ $pgpid -gt 0 ]; then
        date +"%F %T,%3N INFO SHUTDOWN:: Stopping Portworx OCI service"
        /opt/pwx/bin/runc kill portworx
        cnt=0
        while [ $cnt -le $max_retries ]; do
            pids=$(ps --no-headers -o pid -g $pgpid | xargs)
            if [ "x$pids" = x ]; then
                exit 0
            elif [ $cnt -ge $max_retries ]; then
                date +"%F %T,%3N WARN TIMEOUT:: Killing PIDs $pids"
                kill -9 $pids
                exit 1
            else
                cnt=$((cnt+1))
                sleep 1
            fi
        done
    fi
end script
_EOF
```

Once this is done, we can start and control PX runC directly via upstart:

```bash
# Reload upstart configurations, and start Portworx service
sudo initctl reload-configuration
sudo initctl start portworx

## NOTE: The following commands also work:
# sudo initctl stop portworx
# sudo initctl restart portworx
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
sudo initctl restart portworx
```

## Uninstalling the PX OCI bundle

To uninstall the PX OCI bundle, please run the following:

```bash
# Step 1: Remove upstart service (if any)
sudo upstart stop portworx
sudo rm -f /etc/init/portworx.conf
sudo initctl reload-configuration

# NOTE: if the steps below fail, please reboot the node, and repeat the steps 2..5

# Step 2: Unmount oci (if required)
grep -q '/opt/pwx/oci /opt/pwx/oci' /proc/self/mountinfo && sudo umount /opt/pwx/oci

# Step 3: Remove binary files
sudo rm -fr /opt/pwx

# Step 4: [OPTIONAL] Remove configuration files. Doing this means UNRECOVERABLE DATA LOSS.
sudo rm -fr /etc/pwx
```

## Limitations

_NFSv4 SUPPORT_: The upstart-controlled Portworx does not support the experimental NFSv4 shared volumes.
Because of this, the following commands/operations **will not work**:

* running `px-runc install -enable-shared-v4 ...`
* running `px-runc install -enable-shared-and-shared-v4 ...`
* using `ENABLE_SHARED_v4` environment variable<br/> (e.g. `env ENABLE_SHARED_v4=true px-runc install ...`)
* using `ENABLE_SHARED_AND_SHARED_v4` environment variable<br/> (e.g. `env ENABLE_SHARED_AND_SHARED_v4=true px-runc install ...`)


## Miscellaneous

### Logging and Log files

The [upstart](https://en.wikipedia.org/wiki/Upstart) keeps the Portworx logs by default in `/var/log/upstart/portworx.log` file.


In case one requires a separate log-file that is not managed by `upstart`, please do the following:

```bash
# Step 1: patch the portworx service file to add `logfile`:
cd / && sudo patch -p0 << '_EOF'
--- etc/init/portworx.conf.orig	2018-10-17 18:50:20.985316762 -0700
+++ etc/init/portworx.conf	2018-10-17 18:51:38.913315321 -0700
@@ -4,2 +4,3 @@

+env logfile=/var/log/portworx.log
 env max_retries=300
@@ -9,2 +10,3 @@
 script
+    exec >> $logfile 2>&1
     date +"%F %T,%3N INFO STARTUP:: Starting Portworx OCI $0 $@"
@@ -14,2 +16,3 @@
 post-stop script
+    exec >> $logfile 2>&1
     pgpid=$(/opt/pwx/bin/runc list | awk '/^portworx/{print $2}')
_EOF

# Step 2: reload / restart portworx service:
sudo initctl reload-configuration
sudo initctl stop portworx
sudo initctl start portworx

# Step 3: configure `logrotate` to manage the log-file rotations:
sudo cat > /etc/logrotate.d/portworx << _EOF
/var/log/portworx.log {
  minsize 50M
  daily
  rotate 5
  missingok
  compress
  notifempty
  nocreate
  postrotate
      initctl restart portworx >/dev/null 2>&1 || true
  endscript
}
_EOF
```
