---
layout: page
title: "Running PX-Developer and PX-Enterprise in 'air-gap' environments"
keywords: portworx, air-gap
sidebar: home_sidebar
---

Environments that do not permit any outside connectivity are considered an "air-gap" environment.
Such environments preclude the use PX-Enterprise "Lighthouse" console, but can still run PX-Developer or PX-Enterprise.
There are 3 main requirements
- Run a local version of 'etcd'
- Create a customer 'config.json' file
- Launch PX-Entprise manually

## Run a local version of 'etcd'
Use the script below to launch 'etcd', using your own HOST_IP

```
HOST_IP=1.2.3.4
CLUSTER=etcd=http://${HOST_IP}:2380
PORT=4001

# sudo docker run -d --net=host --name etcd quay.io/coreos/etcd \
    /usr/local/bin/etcd \
    --data-dir=data.etcd  --name etcd \
    --initial-advertise-peer-urls http://${HOST_IP}:2380 --listen-peer-urls http://${HOST_IP}:2380 \
    --advertise-client-urls http://${HOST_IP}:$PORT --listen-client-urls http://${HOST_IP}:$PORT \
    --initial-cluster ${CLUSTER} \
    --initial-cluster-state new --initial-cluster-token my-token
```

## Create a custom 'config.json' file
The reference for 'config.json' can be found [here](/config-json.html).
An absolute minimal configuration would look like this:

```
{
    "clusterid": "910b106a-2424-2525-b5c3-0242ac110003",
    "kvdb": [
        "etcd://YOUR_IP:4001"
    ],
    "storage": {
        "devices": [
            "/dev/sdX",   
            "/dev/sdY"
        ]
    },
    "version": "0.3"
}
```

Make sure the list of "devices" includes all disks that will be part of the Portworx fabric.
Ensure the value of "clusterid" is unique.

## Launch Portworx manually

```
# sudo docker run --restart=always --name px -d --net=host \
                 --privileged=true                             \
                 -v /run/docker/plugins:/run/docker/plugins    \
                 -v /var/lib/osd:/var/lib/osd:shared           \
                 -v /dev:/dev                                  \
                 -v /etc/pwx:/etc/pwx                          \
                 -v /opt/pwx/bin:/export_bin:shared            \
                 -v /var/run/docker.sock:/var/run/docker.sock  \
                 -v /var/cores:/var/cores                      \
                 -v /usr/src:/usr/src                          \
                 --ipc=host                                    \
                portworx/px-dev
```

Running **without config.json**:

```
# sudo docker run --restart=always --name px -d --net=host \
                 --privileged=true                             \
                 -v /run/docker/plugins:/run/docker/plugins    \
                 -v /var/lib/osd:/var/lib/osd:shared           \
                 -v /dev:/dev                                  \
                 -v /etc/pwx:/etc/pwx                          \
                 -v /opt/pwx/bin:/export_bin:shared            \
                 -v /var/run/docker.sock:/var/run/docker.sock  \
                 -v /var/cores:/var/cores                      \
                 -v /lib/modules:/lib/modules                  \
                 --ipc=host                                    \
                portworx/px-dev -daemon -k etcd://myetc.company.com:4001 -c MY_CLUSTER_ID -s /dev/nbd1 -s /dev/nbd2
```

NB:  If running CoreOS, then use "-v /lib/modules:/lib/modules" instead of "-v /usr/src:/usr/src"
