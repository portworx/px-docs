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

NOTE: Setting environment variables can be done using the `-e` option, during [PX-OCI](/runc/#step-2-configure-px-under-runc)
or [PX Docker Container](/scheduler/docker/docker-container.html) command line install (e.g. add `-e VAR=VALUE` option).

```bash
# Example PX-OCI config with extra "PX_ENABLE_CACHE_FLUSH" environment variable
$ sudo /opt/pwx/bin/px-runc install -e PX_ENABLE_CACHE_FLUSH=yes \
    -c MY_CLUSTER_ID -k etcd://myetc.company.com:2379 -s /dev/xvdb
```
