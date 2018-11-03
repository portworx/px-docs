Cluster wide secret key is basically a key value pair where the value part is the secret that is used as a passphrase for encrypting volumes. A cluster wide secret key is the default key that can be used to encrypt all the volumes.

To create a volume using a cluster wide secret key run the following command

```
# /opt/pwx/bin/pxctl volume create --secure --size 10 encrypted_volume
Volume successfully created: 822124500500459627
# /opt/pwx/bin/pxctl volume list
ID	      	     		NAME		SIZE	HA SHARED	ENCRYPTED	IO_PRIORITY	SCALE	STATUS
822124500500459627	 encrypted_volume	10 GiB	1    no yes		LOW		1	up - detached
```

To create a **shared encrypted** volume using the cluster wide secret key run the following command

```
# /opt/pwx/bin/pxctl volume create --shared --secure --size 10 encrypted_volume
Encrypted Shared volume successfully created: 77957787758406722
```

You can attach and mount the encrypted volume

```
# /opt/pwx/bin/pxctl host attach encrypted_volume
Volume successfully attached at: /dev/mapper/pxd-enc822124500500459627
# /opt/pwx/bin/pxctl host mount encrypted_volume /mnt
Volume encrypted_volume successfully mounted at /mnt
```

When using cluster wide secret key, the secret key does not need to be provided in any of the commands. When no secret key is provided in the pxctl volume commands, PX defaults to using the cluster wide secret key **if set**