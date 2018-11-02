Use the following command to set the cluster wide secret key when using IBM Key Protect

```
$ /opt/pwx/bin/pxctl secrets set-cluster-key --secret <passphrase>
Successfully set cluster secret key!

```

The `<passphrase>` in the above command will be used for encrypting the volumes. The cluster wide secret key needs to be set only once.

__Important: DO NOT overwrite the cluster wide secret key, else any existing volumes using it will not be usable__