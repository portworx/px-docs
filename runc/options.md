---
layout: page
title: "Command line options for PX"
keywords: portworx, px-developer, px-enterprise, plugin, install, configure, container, storage, runc, oci
sidebar: home_sidebar
redirect_from:
  - /install/options.html
---

* TOC
{:toc}

## Installation arguments to PX

The following arguments can be provided to PX, which will in turn pass them to the PX daemon:

>**Note:** <br>
>These options are for `runC`.  While these options are a superset of the now deprecated `docker run` method of starting PX, they can still be used with the Docker version of PX.

```
Usage: /opt/pwx/bin/px-runc <run|install> [options]

Options:
   -oci <dir>                Specify OCI directory (dfl: /opt/pwx/oci)
   -sysd <file>              Specify SystemD service file (dfl: /etc/systemd/system/portworx.service)
   -v <dir:dir[:shared,ro]>  Specify extra mounts
   -c                        [REQUIRED] Specifies the cluster ID that this PX instance is to join
   -k                        [REQUIRED] Points to your key value database, such as an etcd cluster or a consul cluster
   -s                        [OPTIONAL if -a is used] Specifies the various drives that PX should use for storing the data
   -d <ethX>                 [OPTIONAL] Specify the data network interface
   -m <ethX>                 [OPTIONAL] Specify the management network interface
   -z                        [OPTIONAL] Instructs PX to run in zero storage mode
   -f                        [OPTIONAL] Instructs PX to use an unmounted drive even if it has a filesystem on it
   -a                        [OPTIONAL] Instructs PX to use any available, unused and unmounted drives
   -A                        [OPTIONAL] Instructs PX to use any available, unused and unmounted drives or partitions
   -x <swarm|kubernetes>     [OPTIONAL] Specify scheduler being used in the environment
   -token <token>            [OPTIONAL] Portworx lighthouse token for cluster
   -secret_type <type>       [OPTIONAL] Specify the secret type to be used by Portworx for cloudsnap and encryption features. Supported values: aws, vault, kvdb
   -cluster_secret_key <key> [OPTIONAL] Specify the cluster wide secret key to be used when using AWS KMS or Vault for volume encryption.

Advanced kvdb-options:
   -userpwd <user:passwd>    Username and password for ETCD authentication
   -ca <file>                Specify location of CA file for ETCD authentication
   -cert <file>              Specify locationof certificate for ETCD authentication
   -key <file>               Specify location of certificate key for ETCD authentication
   -acltoken <token>         ACL token value used for Consul authentication
```
