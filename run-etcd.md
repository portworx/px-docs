---
layout: page
title: "Run your own etcd server"
keywords: portworx, px-developer, px-enterprise, install, configure, container, storage, add nodes
sidebar: home_sidebar
meta-description: "Instructions for running your own ETCD server in a container. Try today."
---

Portworx recommends running **etcd** in a container

```
export HostIP="YOUR IP ADDRESS"
````
````
docker run --net=host \
   -d --name etcd-v3.1.3 \
   --volume=/tmp/etcd-data:/etcd-data \
   quay.io/coreos/etcd:v3.1.3 \
   /usr/local/bin/etcd \
   --name my-etcd-1 \
   --data-dir /etcd-data \
   --listen-client-urls http://0.0.0.0:2379 \
   --advertise-client-urls http://${HostIP}:2379 \
   --listen-peer-urls http://0.0.0.0:2380 \
   --initial-advertise-peer-urls http://${HostIP}:2380 \
   --initial-cluster my-etcd-1=http://${HostIP}:2380 \
   --initial-cluster-token my-etcd-token \
   --initial-cluster-state new \
   --auto-compaction-retention 1

# curl -X GET http://${HostIP}:2379/version
```

Note that the etcd port is 2379.

For complete instructions, please visit the [Etcd installation documentation](https://coreos.com/etcd/docs/latest/v2/docker_guide.html)

### Compose.io
You can use an existing etcd service or set up your own. This example uses Compose.IO, for its ease of use.

1. Create a new etcd deployment in Compose.IO.
2. Select 256 MB RAM as the memory.
3. Save the connection string, including your username and password. For example:

 https://[username]:[password]@[string].dblayer.com:[port]

 >**Important:**<br/>If you are using Compose.IO and the `kvdb` string ends with `[port]/v2/keys`, omit the `/v2/keys`. Before running the container, make sure you have saved off any data on the storage devices specified in the configuration.

After you set up etcd, you can use the same etcd service for multiple PX clusters.
