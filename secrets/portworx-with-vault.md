---
layout: page
title: "Portworx with Vault"
sidebar: home_sidebar
redirect_from:
  - /portworx-with-vault.html
meta-description: "Portworx can integrate with Vault to store your encryption keys/secrets. This guide will get a Portworx cluster up which is connected to a Vault endpoint."
---

* TOC
{:toc}

Portworx can integrate with Vault to store your encryption keys/secrets, credentials or passwords. This guide will get a Portworx cluster up which is connected to a Vault endpoint. The vault endpoint could be used to store secrets which will be used for encrypting volumes.

### Setting up Vault
Peruse [this section](https://www.vaultproject.io/intro/getting-started/install.html) for help on setting up Vault in your setup. This includes installation, configuring secrets, etc

### Kubernetes users

If you are installing Portworx on Kubernetes, when generating the Portworx Kubernetes spec file:
1. Use `secretType=vault` to specify the secret type as vault
2. Use `clusterSecretKey=<key>` to set the cluster-wide secret ID. This secret will be used to fetch the secret stored in Vault. The secret will be used as a passphrase for encrypting all the volumes.
3. Use `env=KEY1=VALUE1,KEY2=VALUE2` to set [Portworx vault environment variables](#portworx-vault-environment-variables) to identify vault endpoint.

Instructions on generating the Portworx spec for Kubernetes are available [here](/scheduler/kubernetes/install.html).

If you already have a running Portworx installation, [update `/etc/pwx/config.json` on each node](#adding-vault-credentials-to-configjson).

### Docker & Docker plugin users

If you are installing Portworx as a Docker container or a plugin,
1. Use `-secret_type vault -cluster_secret_key <secret-id>` when starting Portworx to specify the secret type as vault and the cluster-wide secret ID.
2. Use `-e` docker option to expose the [Portworx vault environment variables](#portworx-vault-environment-variables)

If you already have a running Portworx installation, [update `/etc/pwx/config.json` on each node](#adding-vault-credentials-to-configjson).

### Portworx vault environment variables
- `VAULT_ADDR=<vault-address>` : It would be used to connect to the Vault endpoint.
- `VAULT_TOKEN=<vault-token>` : This token will be used for authenticating PX with Vault.
- `VAULT_CACERT=</etc/pwx/path>`
- `VAULT_CAPATH=/etc/pwx/path>`
- `VAULT_CLIENT_CERT=</etc/pwx/path>`
- `VAULT_CLIENT_KEY=/etc/pwx/path>`
- `VAULT_TLS_SERVER_NAME=<server-name>`

All the above Vault related fields as well as the cluster secret key can be set using PX CLI which is explained in the next section.

### Adding Vault Credentials to config.json

This section is relevant for either of the below 2 scenarios
- You are deploying PX with your PX configuration created before hand. So you want to create a `/etc/pwx/config.json` before starting Portworx installation.
- You already have a working Portworx cluster so each node already has a `/etc/pwx/config.json`

Add the following `secret_type`, `cluster_secret_key` and `vault` section to the `/etc/pwx/config.json`:

```
# cat /etc/pwx/config.json
{
    "clusterid": "<cluster-id>",
    "secret": {
        "secret_type": "vault",
        "cluster_secret_key": "mysecret",
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
}
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
encrypted volumes [here](/manage/encrypted-volumes.html)

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
