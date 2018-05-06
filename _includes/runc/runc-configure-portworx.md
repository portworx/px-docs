Now that you have downloaded and installed the PX OCI bundle, you can use the the `px-runc install` command from the bundle to configure systemd to start PX runC.

The _px-runc_ command is a helper-tool that does the following:

1. prepares the OCI directory for runC
2. prepares the runC configuration for PX
3. used by systemd to start the PX OCI bundle

Installation example:

```bash
#  Basic installation

sudo /opt/pwx/bin/px-runc install -c MY_CLUSTER_ID \
    -k etcd://myetc.company.com:2379 \
    -s /dev/xvdb -s /dev/xvdc {{ include.sched-flags }}
```


##### Command-line arguments

{% include cmdargs.md %}

##### Examples

Using etcd:
```
px-runc install -k etcd://my.company.com:2379 -c MY_CLUSTER_ID -s /dev/sdc -s /dev/sdb2 {{ include.sched-flags }}
px-runc install -k etcd://70.0.1.65:2379 -c MY_CLUSTER_ID -s /dev/sdc -d enp0s8 -m enp0s8 {{ include.sched-flags }}
```

Using consul:
```
px-runc install -k consul://my.company.com:8500 -c MY_CLUSTER_ID -s /dev/sdc -s /dev/sdb2 {{ include.sched-flags }}
px-runc install -k consul://70.0.2.65:8500 -c MY_CLUSTER_ID -s /dev/sdc -d enp0s8 -m enp0s8 {{ include.sched-flags }}
```

##### Modifying the PX configuration

After the initial installation, you can modify the PX configuration file at `/etc/pwx/config.json` (see [details](https://docs.portworx.com/control/config-json.html)) and restart Portworx using `systemctl restart portworx`.
