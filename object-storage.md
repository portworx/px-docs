---
layout: page
title: "Object Storage with Portworx"
keywords: portworx, minio, object, cluster, storage
sidebar: home_sidebar
---

[Minio](http://minio.io) is a distributed object storage server built for cloud applications and devops.

Portworx perfectly compliments Minio object storage by providing an elastic, scalable, 
container-granular data services fabric underneath the Minio object storage server.

Minio object storage perfectly compliments Portworx by providing a simple object storage 
service layer on top of Portworx data services.

Both products complement each other with their stunning simplicity.

## Create Portworx Persistent Volumes
Minio requires 2 volumes:  one for configuration meta-data, and one for user data.
For example:

```
docker volume create -d pxd --name minio-config --opt size=30G --opt repl=3
docker volume create -d pxd --name minio-export --opt size=30G --opt repl=3
```

## Launch Minio Object Storage Server
To run the Minio Object Storage Server with the Portworx volumes created above:

```
docker run -p 9000:9000 --name minio1 -d \
  -v minio-export:/export \
  -v minio-config:/root/.minio \
  minio/minio server /export 
```

To view the Access Keys needed by the client, view the "docker logs":

```
Endpoint:  http://172.17.0.2:9000  http://127.0.0.1:9000
AccessKey: TPHTH75X6KTQLH6X9Y58
SecretKey: laAfBKWwhI6m+sON4dQcvA5USWoLMDscWXec7c5H
Region:    us-east-1
SQS ARNs:  <none>

Browser Access:
   http://172.17.0.2:9000  http://127.0.0.1:9000

Command-line Access: https://docs.minio.io/docs/minio-client-quickstart-guide
   $ mc config host add myminio http://172.17.0.2:9000 TPHTH75X6KTQLH6X9Y58 laAfBKWwhI6m+sON4dQcvA5USWoLMDscWXec7c5H

Object API (Amazon S3 compatible):
   Go:         https://docs.minio.io/docs/golang-client-quickstart-guide
   Java:       https://docs.minio.io/docs/java-client-quickstart-guide
   Python:     https://docs.minio.io/docs/python-client-quickstart-guide
   JavaScript: https://docs.minio.io/docs/javascript-client-quickstart-guide

Drive Capacity: 28 GiB Free, 29 GiB Total
```

The Minio Object Storage Server can then be easily accessed via the CLI, API or Browser.
See [http://docs.minio.io](http://docs.minio.io/) for further reference.

