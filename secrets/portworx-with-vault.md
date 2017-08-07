## Portworx with Vault
Portworx can integrate with Vault to store your encryption keys/secrets, credentials or passwords. This guide will get a Portworx cluster up which is connected to a Vault endpoint. The vault endpoint could be used to store secrets which will be used for encrypting volumes.

### Setting up Vault
Peruse [this section](https://www.vaultproject.io/intro/getting-started/install.html) for help on setting up Vault in your setup. This includes installation, configuring secrets, etc

## Deploying Portworx

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
All the arguments to the docker run command are explained [here](/install/docker.html). The two new arguments related to Vault are:

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

### Adding Vault Credentials to config.json
>**Note:**<br/>This section is optional is only needed if you intend to provide the PX configuration before installing PX.

If you are deploying PX with your PX configuration created before hand, then add the following `secrets` section to the `/etc/pwx/config.json`:

```
# cat /etc/pwx/config.json
{
	"clusterid": "xzc2ed6f-7e4e-4e1d-8e8c-3a6df1fb61a5",
    "secret": {
        "secret_type": "vault",
        "cluster_secret_key": "string",
         "vault": {
             "VAULT_TOKEN": "string",
             "VAULT_ADDR": "string"
             "VAULT_CACERT": </etc/pwx/path>,
             "VAULT_CAPATH": </etc/pwx/path>,
             "VAULT_CLIENT_CERT": </etc/pwx/path>,
             "VAULT_CLIENT_KEY": </etc/pwx/path>,
             "VAULT_TLS_SERVER_NAME": <>,
        }
    }
    ...
```

## Authenticating with Vault using PX CLI

If you do not wish to set Vault environment variables, you can authenticate PX with Vault using PX CLI. Run the following commands:

```
# /opt/pwx/bin/pxctl secrets vault login
Enter VAULT_ADDRESS: <vault-endpoint-address>
Enter VAULT_TOKEN: ********
Successfully authenticated with Vault.
```

__Important: You need to run this command on all PX nodes, so that you could create and mount encrypted volumes on all nodes__


## Key generation with Vault

The following sections describe the key generation process with PX and
Vault which can be used for encrypting volumes. More info about
encrypted volumes [here](/manage/encrypted-volumes.md)

### Setting cluster wide secret key

A cluster wide secret key is a common key that can be used to encrypt
all your volumes. You can set the cluster secret key using the following command

```
# /opt/pwx/bin/pxctl secrets set-cluster-key
Enter cluster wide secret key: *****
Successfully set cluster secret key!
```

__Important: Make sure that the secret key has been created in Vault__

If the CLI is used to authenticate with Vault, for every restart of PX container it needs to be re-authenticated with Vault by running the `login` command.
