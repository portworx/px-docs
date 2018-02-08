---
layout: page
title: "Portworx with etcd"
sidebar: home_sidebar
meta-description: "Test storing your encryption keys with etcd for encrypted Portworx volumes."
---

Portworx uses etcd as kvdb to store configuration data. This can also be used store your encryption keys/secrets, credentials or passwords. Since secrets are stored in plain text in kvdb, it is recommended for testing purposes only.

### Kubernetes users

If you are installing Portworx on Kubernetes, use `secretType=kvdb` when generating the Portworx Kubernetes spec file.

If you already have a running Portworx installation, [update `/etc/pwx/config.json` on each node](#kvdb-config-json).

### Docker & Docker plugin users

If you are installing Portworx as a Docker container or a plugin, use `-secret_type kvdb` when starting Portworx to specify the secret type as kvdb.

If you already have a running Portworx installation, [update `/etc/pwx/config.json` on each node](#kvdb-config-json).

### <a name="kvdb-config-json"></a> Adding kvdb as secret store to config.json

This section is relevant for either of the below 2 scenarios
- You are deploying PX with your PX configuration created before hand. So you want to create a `/etc/pwx/config.json` before starting Portworx installation.
- You already have a working Portworx cluster so each node already has a `/etc/pwx/config.json`

Add the following `secret_type` section to the `/etc/pwx/config.json`:

```
# cat /etc/pwx/config.json
{
    "clusterid": "<cluster-id>",
    "secret": {
        "secret_type": "kvdb"
     }
}
```

### Authenticating with kvdb using PX CLI

You can authenticate PX with Kvdb using PX CLI. Run the following command:

```
# /opt/pwx/bin/pxctl pxctl secrets kvdb login
Successful Login to Secrets Endpoint!
** WARNING, this is probably not what you want to do. This login will not be persisted across PX or node reboots. Please put your login information in /etc/pwx/config.json or refer docs.portworx.com for more information
```
If the CLI is used to authenticate with KVDB, for every restart of PX container it needs to be re-authenticated with KVDB by running the `login` command.

__Important: You need to run this command on all PX nodes, so that you could access secrets on all nodes__

