# Portworx with Vault
This guide will get a Portworx cluster up which is connected to a Vault endpoint. The vault endpoint could be used to store secrets which will be used for encrypting volumes.

### Deploying Portworx

You can start PX on a node via the Docker CLI as follows

```
if `uname -r | grep -i coreos > /dev/null`; \
then HDRS="/lib/modules"; \
else HDRS="/usr/src"; fi
sudo docker run --restart=always --name px -d --net=host       \
                 --privileged=true                             \
                 -v /run/docker/plugins:/run/docker/plugins    \
                 -v /var/lib/osd:/var/lib/osd:shared           \
                 -v /dev:/dev                                  \
                 -v /etc/pwx:/etc/pwx                          \
                 -v /opt/pwx/bin:/export_bin:shared            \
                 -v /var/run/docker.sock:/var/run/docker.sock  \
                 -v /var/cores:/var/cores                      \
                 -v ${HDRS}:${HDRS}                            \
                 -e "VAULT_ADDR=<vault-address>" \
                 -e "VAULT_TOKEN=<vault-token>" \
                portworx/px-enterprise:latest -daemon -k etcd://myetc.company.com:2379 -c MY_CLUSTER_ID -s \
		/dev/sdb -s /dev/sdc -secret_type vault -cluster_secret_key <secret-id>
```
 All the arguments to the docker run command are explained [here](run-with-docker.html). The two new arguments related to Vault are:

```
- secret_type
    > Instructs PX to use Vault as the secret endpoint to fetch secrets from

- cluster_secret_key
    > Sets the cluster-wide secretID. This secret will be used to
    fetch the secret stored in Vault. The secret will be used as a
    passphrase for encrypting all the volumes.
```

You need to add two extra Docker runtime commands

```
-e "VAULT_ADDRESS=<vault-address>"
    > Sets the VAULT_ADDRESS environment variable. It would be used
    to connect to the Vault endpoint.

-e "VAULT_TOKEN=<vault-token>"
    > Sets the VAULT_TOKEN environment variable. This token will be
    used for authenticating PX with Vault.
```

All the above Vault related fields as well as the cluster secret key can be set using PX CLI which is explained in the next section.

### Authenticating with Vault using PX CLI

If you do not wish to set Vault environment variables, you can autenticate PX with Vault using PX CLI. Run the following commands:

```
# /opt/pwx/bin/pxctl secrets login
Enter Secrets Endpoint Type: [kvdb|vault|aws]: vault
Enter VAULT_ADDRESS: <vault-endpoint-address>
Enter VAULT_TOKEN: ********
Successfully authenticated with Vault.
```

__Important: You need to run this command on all PX nodes, so that you could create and mount encrypted volumes on all nodes__

Also you can set the cluster secret key using the following command

```
# /opt/pwx/bin/pxctl secrets set-cluster-key
Enter cluster wide secret key: *****
Successfully set cluster secret key!
```

__Important: Make sure that the secret key has been created in Vault__

If the CLI is used to authenticate with Vault, for every restart of PX container it needs to be re-authenticated with Vault by running the `login` command.

### Encryted Volumes

#### Using cluster wide secret key

You can create encrypted volumes using the cluster wide secret key

```
# /opt/pwx/bin/pxctl volume create --secure --size 10 encrypted_volume
Volume successfully created: 822124500500459627
# /opt/pwx/bin/pxctl volume list
ID	      	     		NAME		SIZE	HA SHARED	ENCRYPTED	IO_PRIORITY	SCALE	STATUS
822124500500459627	 encrypted_volume	10 GiB	1    no yes		LOW		1	up - detached
```

You can attach and mount the encrypted volume

```
# /opt/pwx/bin/pxctl host attach encrypted_volume
Volume successfully attached at: /dev/mapper/pxd-enc822124500500459627
# /opt/pwx/bin/pxctl host mount encrypted_volume /mnt
Volume encrypted_volume successfully mounted at /mnt
```

We do not need to specify a secret key during create or attach of a
volume as it will by default use the cluster wide secret key for
encryption. However you can specify per volume keys which is explained
in the next section.

#### Using per volume secret keys

You can encrypt volumes using different keys instead of the cluster
wide secret key. However you need to specify the key for every create
and attach commands.


```
# /opt/pwx/bin/pxctl volume create --secure --secret_key key1 enc_vol
Volume successfully created: 374663852714325215
# /opt/pwx/bin/pxctl host attach --secret key1 enc_vol
Volume successfully attached at: /dev/mapper/pxd-enc374663852714325215
```

__Important: Make sure secret `key1` exists in Vault__
