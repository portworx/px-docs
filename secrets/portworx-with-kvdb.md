---
layout: page
title: "Portworx with etcd"
sidebar: home_sidebar
---

Portworx uses etcd as kvdb to store configuration data. This can also be used store your encryption keys/secrets, credentials or passwords. Since secrets are stored in plain text in kvdb, it is recommended for testing purposes only.


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
                portworx/px-enterprise:latest -daemon -k etcd://myetc.company.com:2379 -c MY_CLUSTER_ID -s \
		/dev/sdb -s /dev/sdc -secret_type kvdb
```
All the arguments to the docker run command are explained [here](/install/docker.html). The new argument related to kvdb secret store is:

```
- secret_type
    > Instructs PX to use its kvdb as the secret endpoint to fetch secrets from
```

kvdb can also be set as secret store using PX CLI which is explained in the next section.

### Adding kvdb as  secret store  to config.json
>**Note:**<br/>This section is optional is only needed if you intend to provide the PX configuration before installing PX.

If you are deploying PX with your PX configuration created before hand, then add the following `secrets` section to the `/etc/pwx/config.json`:

```
# cat /etc/pwx/config.json
{
    "clusterid": "xzc2ed6f-7e4e-4e1d-8e8c-3a6df1fb61a5",
    "secret": {
        "secret_type": "kvdb"
     }
}
```

## Authenticating with kvdb using PX CLI

You can authenticate PX with Kvdb using PX CLI. Run the following command:

```
# /opt/pwx/bin/pxctl pxctl secrets kvdb login
Successful Login to Secrets Endpoint!
** WARNING, this is probably not what you want to do. This login will not be persisted across PX or node reboots. Please put your login information in /etc/pwx/config.json or refer docs.portworx.com for more information
```
If the CLI is used to authenticate with KVDB, for every restart of PX container it needs to be re-authenticated with KVDB by running the `login` command.

__Important: You need to run this command on all PX nodes, so that you could access secrets on all nodes__

