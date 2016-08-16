---
layout: page
title: "Run Portworx with Docker UCP"
sidebar: home_sidebar
---

You can use Portworx to implement storage for Docker Universal Control Plane (UCP). 
Portworx pools your servers' capacity and is deployed as a container. This section, qualified using Docker 1.12, and Universal Control Plane 1.1.2

>**Note:**<br/>You must run Docker Commercially Supported (CS) Engine

https://docs.docker.com/ucp/installation/install-production/


Install Controller:
```
docker run --rm -it --name ucp \
  -v /var/run/docker.sock:/var/run/docker.sock \
  docker/ucp install -i \
  --host-address <$UCP_PUBLIC_IP>
```

Get Licensed:  https://docs.docker.com/ucp/installation/license/


https://docs.docker.com/swarm/scheduler/filter/
Docker Daemon needs to start with a Label that indicates PX

```
docker.service:
ExecStart=/usr/bin/docker daemon -H fd:// --label pxfabric=px-cluster1
systemctl daemon-reload
systemctl restart docker
(Verify)
“docker info”:
        [...]
        Labels:
            pxfabric=px-cluster1
        [...]
```
...for whichever nodes are running PX.

>**Note:**<br/>You can use the fabric label to specify different PX-clusters


Launching on the cmdline
```
docker  run -d -P -e constraint:pxfabric==px-cluster1 --name db mysql
```

Or on the UCP GUI for launching a contaner:







