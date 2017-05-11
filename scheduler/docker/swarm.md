---
layout: page
title: "Run Portworx with Docker Swarm"
keywords: portworx, container, storage, Docker, swarm
sidebar: home_sidebar
redirect_from: "/run-with-docker-swarm.html"
---

* TOC
{:toc}

You can use Portworx to provide storage for your Docker Swarm services. Portworx pools your servers capacity and turns your servers or cloud instances into converged, highly available compute and storage nodes. This section describes how to deploy PX within a Docker Swarm cluster and have PX provide highly available volumes to any application deployed via Docker Swarm.

Below steps demonstrate how to set up a three-node cluster for [Jenkins](https://jenkins.io/).

### Deploy PX container
Refer to [Run with Docker](/install/docker.html) to deploy the Portworx container & create a cluster.

### Create a volume
```
docker volume create -d pxd --name jenkins_vol --opt \
        size=4 --opt block_size=64 --opt repl=3 --opt fs=ext4 --opt shared=true
```
* This command creates a volume called _jenkins_vol_.
* This volume has a replication factor of _3_, which means that the data will be protected on 3 separate nodes.
* Also the volume is shared so multiple swarm nodes can have shared access

### Add labels on Swarm nodes

First, get the replica set for the _jenkins_vol_ using the `pxctl` CLI.
```
sudo /opt/pwx/bin/pxctl volume inspect jenkins_vol

    Volume : 27052673284397061
    Name : jenkins_vol
    Size : 4.0 GiB
    Format : ext4
    HA : 3
    IO Priority : LOW
    Creation time : Apr 4 22:23:32 UTC 2017
    Shared : yes
    Status : up
    State : detached
    Reads : 0
    Reads MS : 0
    Bytes Read : 0
    Writes : 0
    Writes MS : 0
    Bytes Written : 0
    IOs in progress : 0
    Bytes used : 130 MiB
    Replica sets on nodes:
        Set 0
            Node : 192.168.56.103
            Node : 192.168.56.104
            Node : 192.168.56.105
```

For each node you see in the replica sets section of the above output, find the corresponding Docker Swarm node. You can use 
`docker node ls` and `docker node inspect` commands for this purpose.


Once you find the nodes, add a label to each of those nodes as below.
```
docker node update --label-add jenkins_vol=true <node_id>
```
The label `jenkins_vol=true` implies that the node hosts volume _jenkins_vol's_ data.

### Create a service
We will now create a Jenkins service using the newly created volume.

We will use service constraints to influence on which worker node Swarm schedules a container (task) based on the container volume's data location.
```
docker service create --name jenkins \
         --replicas 3 \
         --publish 8082:8080 \
         --publish 50000:50000 \
         -e JENKINS_OPTS="--prefix=/jenkins" \
         --reserve-memory 300m \
         --mount "type=volume,source=jenkins_vol,target=/var/jenkins_home" \
         --constraint 'node.labels.jenkins_vol == true' \
         jenkins
```
* Note how the volume binding is done via `--mount`. This causes the Portworx `jenkins_vol` to get bind mounted at `/var/jenkins_home`, which is where the jenkins Docker container stores it’s data.
* Also note how we put a constraint using `--constraint 'node.labels.jenkins_vol == true'`.

Now Docker Swarm will place the jenkins container _only_ on Swarm nodes that contain our volume's data locally leading to great I/O performance.

### Verify Service
Use following command to verify if various tasks for the service came up.
```
docker service ps jenkins
```

Read more about Portworx Docker Swarm demo [here](https://portworx.com/highly-resilient-jenkins-using-docker-swarm/).
