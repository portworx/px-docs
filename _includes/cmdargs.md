##### options:

```
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
