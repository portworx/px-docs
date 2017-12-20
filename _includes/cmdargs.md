##### options:

```
-oci <dir>                Specify OCI directory (dfl: /opt/pwx/oci)
-sysd <file>              Specify SystemD service file (dfl: /etc/systemd/system/portworx.service)
-e key=value              Specify extra environment variables
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
-t <token>                [OPTIONAL] Portworx lighthouse token for cluster

```

##### kvdb-options:
```
-userpwd <user:passwd>    Username and password for ETCD authentication
-ca <file>                Specify location of CA file for ETCD authentication
-cert <file>              Specify locationof certificate for ETCD authentication
-key <file>               Specify location of certificate key for ETCD authentication
-acltoken <token>         ACL token value used for Consul authentication
```

##### secrets-options:
```
-secret_type <aws|kvdb|vault>   [OPTIONAL] Specify the secret type to be used by Portworx for cloudsnap and encryption features.
-cluster_secret_key <id>        [OPTIONAL] Specify the cluster wide secret key to be used when using AWS KMS or Vault for volume encryption.
```

##### environment-variables:
```
PX_HTTP_PROXY		[OPTIONAL] If running behind an HTTP proxy, set the PX_HTTP_PROXY variables to your HTTP proxy.
PX_HTTPS_PROXY		[OPTIONAL] If running behind an HTTPS proxy, set the PX_HTTPS_PROXY variables to your HTTPS proxy.
PX_ENABLE_CACHE_FLUSH	[OPTIONAL] Enable cache flush deamon. Set PX_ENABLE_CACHE_FLUSH=yes.
```

Setting environment variables can be done using the -e option.  During PX Runc command line install (-e VAR=VAL).
```
$ sudo /opt/pwx/bin/px-runc install -c MY_CLUSTER_ID -e PX_ENABLE_CACHE_FLUSH=yes -k etcd://myetc.company.com:2379 -s /dev/xvdb -x kubernetes -v /var/lib/kubelet:/var/lib/kubelet:shared
```

Or by manually adding the arguments to the .yaml configuration file.
```
  ...
  ...

containers:
  - name: portworx
    image: portworx/oci-monitor:1.2.11.7
    terminationMessagePath: "/tmp/px-termination-log"
      imagePullPolicy: Always
      args:
        ["-k", "etcd:http://etcdv3-01.portworx.com:2379", "-c", "hose-gke-cluster-1", "-a", "-f",
         "-x", "kubernetes"]
      env:
        - name: "PX_TEMPLATE_VERSION"
          value: "v2"
	- name: "PX_ENABLE_CACHE_FLUSH"
	  value: "yes"

  ...
  ...

```
