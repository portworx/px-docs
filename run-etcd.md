---
layout: page
title: "Run PX with Docker"
keywords: portworx, px-developer, px-enterprise, install, configure, container, storage, add nodes
sidebar: home_sidebar
---

### Run your own etcd server

We recommend that you run etcd in a container

```
# docker run -d --name etcd 					\
	-v /var/lib/etcd:/var/lib/etcd				\
	--net host --entrypoint=/usr/local/bin/etcd \
	quay.io/coreos/etcd:latest 					\
	--listen-peer-urls 'http://0.0.0.0:2380' 	\
	--data-dir=/var/lib/etcd/					\
	--listen-client-urls 'http://0.0.0.0:2379'  \
	--advertise-client-urls 'http://<your ip>:2379'

# curl -X GET http://127.0.0.1:2379/version
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
