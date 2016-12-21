---
layout: page
title: "Run PX with Docker"
keywords: portworx, px-developer, px-enterprise, install, configure, container, storage, add nodes
sidebar: home_sidebar
---

### Run your own etcd server

We recommend that you run etcd in a container

```
# docker run --name etcd -d --net host quay.io/coreos/etcd

2016/05/14 05:01:21 etcdserver: published {Name:default ClientURLs:[http://localhost:2379]} to cluster 7e27652122e8b2ae
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
