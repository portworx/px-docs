---
layout: page
title: "Etcd"
keywords: etcd, portworx, maintenance, kvdb
sidebar: home_sidebar
redirect_from: "/etcd.html"
---

* TOC
{:toc}

Portworx requires a key-value database such as etcd for configuring storage. A highly availbale clustered etcd with persistent storage is preferred.

### Requirements
For production Portworx clusters we recommend the following configuration of an etcd cluster:

1. Etcd Version > 3.1.x
2. Minimum 3 nodes
3. Minimum 4G of memory dedicated to each etcd node.
4. Etcd backed with storage disks.

More detailed set of hardware requirements as recommended by etcd can be found [here](https://coreos.com/etcd/docs/latest/op-guide/hardware.html#example-hardware-configurations)

### Setup

Use one of the two listed methods to setup etcd.

#### Manual Setup

It is highly recommended to follow the detailed step by step process provided by etcd to setup a brand new multi-node cluster.

Follow the steps listed [here](https://coreos.com/etcd/docs/latest/op-guide/clustering.html)


#### Ansible Playbook

Follow [this](https://github.com/portworx/px-docs/blob/gh-pages/etcd/ansible/index.md) ansible playbook to install a 3 node etcd cluster.


### Tuning Etcd

Etcd provides multiple knobs to fine tune the cluster based on your needs. We recommend fine tuning the following three settings.

#### Compaction

etcd keeps an exact history of its keyspace, this history should be periodically compacted to avoid performance degradation and eventual storage space exhaustion. Regular compaction ensures that the memory usage of the etcd process is under check.
The keyspace can be compacted automatically with etcd's time windowed history retention policy, or manually with ``etcd``

We recommend keeping history for last 3 hours. While setting up etcd you can specify the retention policy in the following way:

```
$ etcd --auto-compaction-retention=3
```

#### Database Size (Space Quota)

The space quota in etcd ensures the cluster operates in a reliable fashion. Without a space quota, etcd may suffer from poor performance if the keyspace grows excessively large, or it may simply run out of storage space, leading to unpredictable cluster behavior.

We recommend setting the space quota to max value of 8Gi. While setting up etcd you can specify the space quota in the following way:

```
$ etcd --quota-backend-bytes=$((8*1024*1024*1024))
```

#### Snapshot Policy

Etcd can take periodic snapshots of its keyspace which can be used to restore the etcd cluster in case of a complete disaster. By default etcd takes a snapshot after every 10,000 changes to its key value space. If you want the snapshot strategy to be more aggressive you can tune the frequency in the following way:

```
$ etcd --snapshot-count=5000
```

For a more detailed setup, maintenance and tuning information refer the following coreos etcd reference docs.
- [Maintenance](https://coreos.com/etcd/docs/latest/op-guide/maintenance.html)
- [Tuning](https://coreos.com/etcd/docs/latest/tuning.html)
- [Troubleshooting](https://coreos.com/etcd/docs/3.2.7/op-guide/recovery.html)