---
layout: page
title: "Portworx with Vault"
sidebar: home_sidebar
redirect_from:
  - /portworx-with-vault.html
meta-description: "Portworx can integrate with Vault to store your encryption keys/secrets. This guide will get a Portworx cluster connected to a Vault endpoint."
---

* TOC
{:toc}

Portworx can integrate with Vault to store your encryption keys/secrets, credentials or passwords. This guide will get a Portworx cluster connected to a Vault endpoint. The vault endpoint could be used to store secrets that will be used for encrypting volumes.

### Setting up Vault
Peruse [this section](https://www.vaultproject.io/intro/getting-started/install.html) for help on setting up Vault in your setup. This includes installation, configuring secrets, etc

### Kubernetes users

If you are installing Portworx on Kubernetes, when generating the [Portworx Kubernetes spec file](https://install.portworx.com/):

1. Select `vault` from the "Secrets type" list
2. In the environment variables section set [Portworx Vault environment variables](#portworx-vault-environment-variables) to identify Vault endpoint.

To generate Portworx spec for Kubernetes, refer instructions on [Deploy Portworx on Kubernetes](/scheduler/kubernetes/install.html).

If you already have a running Portworx installation, [update `/etc/pwx/config.json`](#adding-vault-credentials-to-configjson) on each node.

### Other users

During installation,

1. Use argument `-secret_type vault -cluster_secret_key <secret-id>` when starting Portworx to specify the secret type as vault and the cluster-wide secret key.
2. Use `-e` docker option to expose the [Portworx vault environment variables](#portworx-vault-environment-variables)

If you already have a running Portworx installation, [update `/etc/pwx/config.json`](#adding-vault-credentials-to-configjson) on each node.

### Portworx vault environment variables
- `VAULT_ADDR=<vault-address>` **Required:** It would be used to connect to the Vault endpoint
- `VAULT_TOKEN=<vault-token>` **Required:** This token will be used for authenticating Portworx with Vault
- `VAULT_CACERT=</etc/pwx/path>`
- `VAULT_CAPATH=/etc/pwx/path>`
- `VAULT_CLIENT_CERT=</etc/pwx/path>`
- `VAULT_CLIENT_KEY=/etc/pwx/path>`
- `VAULT_TLS_SERVER_NAME=<server-name>`

All the above Vault related fields as well as the cluster secret key can be set using Portworx CLI which is explained in the next section.

### Adding Vault Credentials to config.json

This section is relevant for either of the below 2 scenarios
- You are deploying Portworx with your configuration created before hand. Then you want to create a `/etc/pwx/config.json` before starting Portworx installation.
- You already have a working Portworx cluster so each node already has a `/etc/pwx/config.json`

Add the following `secret_type`, `cluster_secret_key` and `vault` section to the `/etc/pwx/config.json` on each node in the cluster:

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

### Key generation with Vault

The following sections describe the key generation process with Portworx and Vault which can be used for encrypting volumes. More info about encrypted volumes [here](/manage/encrypted-volumes.html)

#### Setting cluster wide secret key

A cluster wide secret key is a common key that can be used to encrypt all your volumes. You can set the cluster secret key using the following command.

```
# /opt/pwx/bin/pxctl secrets set-cluster-key
Enter cluster wide secret key: *****
Successfully set cluster secret key!
```
This command needs to be run just once for the cluster. If you have added the cluster secret key through the config.json, the above command will overwrite it. Even on subsequent Portworx restarts, the cluster secret key in config.json will be ignored for the one set through the CLI.

#### (Optional) Authenticating with Vault using Portworx CLI

If you do not wish to set Vault environment variables, you can authenticate Portworx with Vault using Portworx CLI. Run the following command:
```
# /opt/pwx/bin/pxctl secrets vault login \
  --vault-address <vault-endpoint-address> \
  --vault-token <vault-token>
Successfully authenticated with Vault.
```

>**Important:**<br/> You need to run this command on all Portworx nodes, so that you could create and mount encrypted volumes on all nodes.

>**Important:**<br/> Make sure that the secret key has been created in Vault.

If the CLI is used to authenticate with Vault, for every restart of Portworx container it needs to be re-authenticated with Vault by running the `login` command.
