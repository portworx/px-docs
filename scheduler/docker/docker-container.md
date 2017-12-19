---
layout: page
title: "Run PX as a Docker V1 Plugin (PX Docker container)"
keywords: portworx, px-developer, px-enterprise, plugin, install, configure, container, storage, add nodes
sidebar: home_sidebar
meta-description: "Find out how to install Portworx using the Docker CLI. Use our step-by-step instructions and see for yourself!"
redirect_from: 
  - /run-as-docker-pluginv1.html
  - /scheduler/docker/install.html
---

* TOC
{:toc}

To install and configure PX as a standalone Docker container, use the command-line steps in this section.

>**Note:**<br/>It is highly recommended to run PX as a plugin.  Use these steps only if you are running an older version of Docker (1.12 or prior).

Run PX as a standalone Docker container by executing the following Docker command:

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
                 -v /opt/pwx/bin:/export_bin                   \
                 -v /var/run/docker.sock:/var/run/docker.sock  \
                 -v /var/cores:/var/cores                      \
                 -v ${HDRS}:${HDRS}                            \
                portworx/px-enterprise -k etcd://myetc.company.com:2379 -c MY_CLUSTER_ID -s /dev/xvdb -s /dev/xvdc
```

>**Important:**<br/>To run the Enterprise version of PX, you must obtain a license key from support@portworx.com.  If you do not have a license key, you can run the `portworx/px-dev` container instead.

#### Command-line arguments to PX

The following arguments are provided to the PX daemon:

|  Argument | Description                                                                                                                                                                              |
|:---------:|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|     `-c`    | (Required) Specifies the cluster ID that this PX instance is to join. You can create any unique name for a cluster ID.                                                                   |
|     `-k`    | (Required) Points to your key value database, such as an etcd cluster or a consul cluster.                                                                                               |
|     `-s`    | (Optional if -a is used) Specifies the various drives that PX should use for storing the data.                                                                                           |
|     `-d`    | (Optional) Specifies the data interface.                                                                                                                                                 |
|     `-m`    | (Optional) Specifies the management interface.                                                                                                                                           |
|     `-z`    | (Optional) Instructs PX to run in zero storage mode. In this mode, PX can still provide virtual storage to your containers, but the data will come over the network from other PX nodes. |
|     `-f`    | (Optional) Instructs PX to use an unmounted drive even if it has a filesystem on it.                                                                                                     |
|     `-a`    | (Optional) Instructs PX to use any available, unused and unmounted drive.,PX will never use a drive that is mounted.                                                                     |
|     `-A`    | (Optional) Instructs PX to use any available, unused and unmounted drives or partitions. PX will never use a drive or partition that is mounted.                                         |
|     `-x`    | (Optional) Specifies the scheduler being used in the environment. Supported values: "swarm" and "kubernetes".                                                                            |
|  `-userpwd` | (Optional) Username and password for ETCD authentication in the form user:password                                                                                                       |
|    `-ca`    | (Optional) Location of CA file for ETCD authentication.                                                                                                                                  |
|   `-cert`   | (Optional) Location of certificate for ETCD authentication.                                                                                                                              |
|    `-key`   | (Optional) Location of certificate key for ETCD authentication.                                                                                                                          |
| `-acltoken` | (Optional) ACL token value used for Consul authentication.                                                                                                                               |
|   `-token`  | (Optional) Portworx lighthouse token for cluster.                                                                                                                                        |
| `-secret_type`   	| (Optional) Instructs PX from which secrets endpoint to fetch secrets from. Supported: vault, aws and kvdb                                                                                	| secretType=vault                                   	|
| `-cluster_secret_key` | (Required for vault secret type) Sets the cluster-wide secretID. This secret will be used to fetch the secret stored in Vault. The secret will be used as a passphrase for encrypting all the volumes 	| clusterSecretKey=mysecretkey        	|

The following Docker runtime command options are explained:

| Option                                       | Description                                                                                                                                         |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------|
| `--privileged`                                 | Sets PX to be a privileged container. Required to export block device and for other functions.                                                      |
| `--net=host`                                   | Sets communication to be on the host IP address over ports 9001 -9003. Future versions will support separate IP addressing for PX.                  |
| `--shm-size=384M`                              | PX advertises support for asynchronous I/O. It uses shared memory to sync across process restarts.                                                  |
| `-v /run/docker/plugins:/run/docker/plugins`   | Specifies that the volume driver interface is enabled.                                                                                              |
| `-v /dev:/dev`                                 | Specifies which host drives PX can see. Note that PX only uses drives specified in config.json. This volume flage is an alternate to --device=\[\]. |
| `-v /etc/pwx/config.json:/etc/pwx/config.json` | The configuration file location.                                                                                                                    |
| `-v /var/run/docker.sock:/var/run/docker.sock` | Used by Docker to export volume container mappings.                                                                                                 |
| `-v /var/lib/osd:/var/lib/osd:shared`          | Location of the exported container mounts. This must be a shared mount.                                                                             |
| `-v /opt/pwx/bin:/export_bin`                  | Exports the PX command line (**pxctl**) tool from the container to the host.                                                                        |

#### Running with a custom config.json

You can also provide the runtime parameters to PX via a configuration file called config.json.  When this is present, you do not need to pass the runtime parameters via the command line.  This maybe useful if you are using tools like chef or puppet to provision your host machines.

1. Download the sample config.json file:
https://raw.githubusercontent.com/portworx/px-dev/master/conf/config.json
2. Create a directory for the configuration file.

   ```
   # sudo mkdir -p /etc/pwx
   ```
   
3. Move the configuration file to that directory. This directory later gets passed in on the Docker command line.

   ```
   # sudo cp -p config.json /etc/pwx
   ```
   
4. Edit the config.json to include the following:
   * `clusterid`: This string identifies your cluster and must be unique within your etcd key/value space.
   * `kvdb`: This is the etcd connection string for your etcd key/value store.
   * `devices`: These are the storage devices that will be pooled from the prior step.


Example config.json:

```
   {
      "clusterid": "make this unique in your k/v store",
      "dataiface": "bond0",
      "kvdb": [
          "etcd:https://[username]:[password]@[string].dblayer.com:[port]"
        ],
      "mgtiface": "bond0",
      “loggingurl”: “http://dummy:80“,
      "storage": {
        "devices": [
          "/dev/xvdb",
          "/dev/xvdc"
        ]
      }
    }
```

>**Important:**<br/>If you are using Compose.IO and the `kvdb` string ends with `[port]/v2/keys`, omit the `/v2/keys`. Before running the container, make sure you have saved off any data on the storage devices specified in the configuration.

Please also ensure "loggingurl:" is specificed in config.json. It should either point to a valid lighthouse install endpoint or a dummy endpoint as shown above. This will enable all the stats to be published to monitoring frameworks like Prometheus

You can now start the Portworx container with the following run command:

```
# sudo docker run --restart=always --name px -d --net=host     \
                 --privileged=true                             \
                 -v /run/docker/plugins:/run/docker/plugins    \
                 -v /var/lib/osd:/var/lib/osd:shared           \
                 -v /dev:/dev                                  \
                 -v /etc/pwx:/etc/pwx                          \
                 -v /opt/pwx/bin:/export_bin                   \
                 -v /var/run/docker.sock:/var/run/docker.sock  \
                 -v /var/cores:/var/cores                      \
                 -v /usr/src:/usr/src                          \
                 -v /lib/modules:/lib/modules                  \
                portworx/px-enterprise
```

At this point, Portworx should be running on your system. To verify, run `docker ps`.

#### Authenticated KVDB
To use `etcd` with authentication and a cafile, use this in your `config.json`:

```json
"kvdb": [
   "etcd:https://<ip1>:<port>",
   "etcd:https://<ip2>:<port>"
 ],
 "cafile": "/etc/pwx/pwx-ca.crt",
 "certfile": "/etc/pwx/pwx-user-cert.crt",
 "certkey": "/etc/pwx/pwx-user-key.key",
```

To use `consul` with an acltoken, use this in your `config.json`:

```json
"kvdb": [
   "consul:http://<ip1>:<port>",
   "consul:http://<ip2>:<port>"
 ],
 "acltoken": "<token>",
```

Alternatively, you could specify and explicit username and password as follows:

```
 "username": "root",
 "password": "xxx",
 "cafile": "/etc/pwx/cafile",
```

#### Run via Compose
You can run PX-Developer with [docker-compose](https://docs.docker.com/compose/install/) to create a storage cluster for containers, as follows:

```
# git clone https://github.com/portworx/px-dev.git
# cd px-dev/quick-start
# docker-compose run portworx -daemon -k etcd://myetc.company.com:4001 -c MY_CLUSTER_ID -s /dev/nbd1 -s /dev/nbd2
```

OR, if you have a custom [px configuration file](https://github.com/portworx/px-dev/edit/master/quick-start/config.json) at `/etc/pwx/config.json`, you can start PX-Developer as follows:

```
# docker-compose up -d
```

