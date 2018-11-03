For encrypting volumes using specific secret keys, you need to provide that key for every create and attach command.

To create an **encrypted** volume using a specific secret through Portworx CLI, run the following command

```
# /opt/pwx/bin/pxctl volume create --secure --secret_key key1 enc_vol
Encrypted volume successfully created: 374663852714325215

```

To create a **shared encrypted** volume run the following command

```
# /opt/pwx/bin/pxctl volume create --shared --secret_key key1 --secure --size 10 enc_shared_vol
Encrypted Shared volume successfully created: 77957787758406722
```

To create an **encrypted** volume using a specific secret through docker, run the following command

```
# docker volume create --volume-driver pxd secret_key=key1,name=enc_vol

```

To create an **encrypted shared** volume using a specific secret through docker, run the following command

```
# docker volume create --volume-driver pxd shared=true,secret_key=key1,name=enc_shared_vol

```

To attach and mount an encrypted volume through docker, run the following command

```
# docker run --rm -it -v secure=true,secret_key=key1,name=enc_vol:/mnt busybox

```
