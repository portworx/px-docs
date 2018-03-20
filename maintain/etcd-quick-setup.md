---
layout: page
title: "Etcd Quick Setup"
keywords: etcd, portworx, maintenance, kvdb
sidebar: home_sidebar
redirect_from: "/etcd-quick-setup.html"
---

* TOC
{:toc}

Following guide will setup a 3 node etcd cluster. Etcd will be running as a systemd services on the nodes.

### Requirements

Following are the requirements from the three nodes that form the etcd cluster:

1. The nodes should have static IPs.
2. The nodes should have systemd installed.


### Setup Steps

#### Step1: Download and Install etcd

Get the etcd tar ball from CoreOS official site.

```
$ ETCD_VER=v3.2.7 && curl -L https://storage.googleapis.com/etcd/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o /tmp/etcd.tar.gz
```

You can replace the __ETCD_VER__ with the etcd version you wish to install

Untar the etcd tar ball

```
$ rm -rf /tmp/etcd && mkdir -p /tmp/etcd
$ tar xzvf /tmp/etcd.tar.gz -C /tmp/etcd --strip-components=1
```

Install the etcd binaries

```
$ sudo cp /tmp/etcd/etcd /usr/local/bin/
$ sudo cp /tmp/etcd/etcdctl /usr/local/bin/
```

Repeat the above steps on all the 3 nodes before moving forward.

#### Step2: Setup systemd unit files

Create a systemd environment file __/etc/etcd.conf__ which has the IPs of all the nodes.

```
$ cat /etc/etcd.conf
# SELF_IP is the IP of the node where this file resides.
SELF_IP=70.0.40.154
# IP of Node 1
NODE_1_IP=70.0.40.153
# IP of Node 2
NODE_2_IP=70.0.40.154
# IP of Node 3
NODE_3_IP=70.0.40.155
```

You can copy the above contents in your __/etc/etcd.conf__ and replace the IPs with the IPs of your 3 nodes.

Create a copy of the above file on all the 3 nodes. The contents of the file will remain same except for the __SELF_IP__ which will correspond to the node's IP where the file resides.

Create a systemd unit file for the etcd3 service.

```
$ cat /etc/systemd/system/etcd3.service
[Unit]
Description=etcd
Documentation=https://github.com/coreos/etcd
Conflicts=etcd.service
Conflicts=etcd2.service

[Service]
Type=notify
Restart=always
RestartSec=25s
LimitNOFILE=40000
TimeoutStartSec=20s
EnvironmentFile=/etc/etcd.conf
ExecStart=/bin/sh -c "/usr/local/bin/etcd --name etcd-${SELF_IP} --data-dir /var/lib/etcd --quota-backend-bytes 8589934592 --auto-compaction-retention 3 --listen-client-urls http://${SELF_IP}:2379,http://localhost:2379 --advertise-client-urls http://${SELF_IP}:2379,http://localhost:2379 --listen-peer-urls http://${SELF_IP}:2380 --initial-advertise-peer-urls http://${SELF_IP}:2380 --initial-cluster 'etcd-${NODE_1_IP}=http://${NODE_1_IP}:2380,etcd-${NODE_2_IP}=http://${NODE_2_IP}:2380,etcd-${NODE_3_IP}=http://${NODE_3_IP}:2380' --initial-cluster-token my-etcd-token --initial-cluster-state new"

[Install]
WantedBy=multi-user.target
```

You can copy the above contents in your __/etc/systemd/system/etcd3.service__ . This configuration file has all the etcd configuration parameters set to the recommended values. No further changes are required in this file as it reads the IPs from the custom EnvironmentFile __/etc/etcd.conf__

Create a copy of the above file on all the 3 nodes. The contents of the file will remain same on all the nodes.

#### Step 3: Start etcd3 systemd service.

Make sure the systemd files are setup correctly on all the 3 nodes.

Run the following commands on all the 3 nodes to start etcd.

```
$ sudo systemctl daemon-reload
$ sudo systemctl enable etcd3
$ sudo systemctl start etcd3
```

#### Step 4: Validate etcd setup

Run the following command to check if etcd is setup correctly.

```
$ etcdctl cluster-health
member 56a14e6f53fae617 is healthy: got healthy result from http://70.0.40.154:2379
member 7e34afa2930c40e5 is healthy: got healthy result from http://70.0.40.155:2379
member 8ff90a5cbffc52d4 is healthy: got healthy result from http://70.0.40.153:2379
cluster is healthy
```

Make sure the IPs are displayed correctly and the cluster health is reported __healthy__