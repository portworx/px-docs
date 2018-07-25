---
layout: page
title: "Etcd/Consul Recovery"
keywords: disaster recovery, disaster proof, site failure, node failure, power failure, etcd failure
sidebar: home_sidebar
meta-description: "Etcd Disaster Recovery"
---

* TOC
{:toc}

Portworx PX-Enterprise requires a key-value database like etcd or consul to store its metadata and configuration. This key-value database is a critical component for smooth functioning of PX. This page describes how to configure a resilient and highly available etcd cluster and recovery procedures in an event of an etcd disaster.

### Recovering PX keys in etcd/consul

From PX versions > 1.3 when PX nodes loose connectivity with etcd or consul, it dumps all the essential keys and values into a file. This file is dumped under `/var/cores/kvdb_dump` directory on the node.

Each file is dumped with a timestamp when it was generated like `pwx_kvdb_2018-05-25T22:59:08Z.dump`

Each node will dump such a file. Choose one such file which you think has the latest keys and values.

You will need a tool `px-kvdb-restore`, to recover the actual keys and values from this file and put it into your new etcd or consul cluster.

To get access to this tool please contact Portworx Support.

Before running the kvdb restore tool
* Make sure you have a healthy etcd or consul cluster.
* Modify the config.json on all the PX nodes to point to the new etcd or consul cluster.
* Select the node which has the latest key dump and run the restore tool on that node.

#### px-kvdb-restore
```
$ px-kvdb-retore --help
NAME:
px-kvdb-restore run - Runs the px kvdb restore operation.

USAGE:
px-kvdb-restore run [command options] [arguments...]

OPTIONS:
--kvdb_dump_file value Location of the kvdb dump file.
--force Force will delete any existing keys from the kvdb and restore.

```

Here is an example of how to run the restore tool

```
$ px-kvdb-restore --kvdb_dump_file /var/cores/kvdb_dump/pwx_kvdb_2018-05-25T22:59:08Z.dump
```

If the tool finds existing keys under the same cluster ID it aborts the restore. If you are sure that you want to overwrite all the keys then you can run the above
command with the `--force` argument.

### Etcd disaster recovery best practices

* Ensure your etcd cluster that is used for storing Portworx configuration data is snapshotted and backed up periodically. Make sure you follow all the etcd recommendations mentioned [here](/maintain/etcd.html)
* Ensure the snaps are stored in a different location or cloud storage like S3, so they can be retrived from other sites if one of your site is down.
* Follow this [link](https://coreos.com/etcd/docs/latest/op-guide/recovery.html) to learn more on how to restore etcd cluster from its snapshots.

### PX behavior on etcd/consul failure

The following table summarizes how Portworx responds to an etcd or consul disaster and its levels of recovery available.

| PX state when snapshot was taken | PX state just before disaster | PX state after disaster recovery |
|-----------------|:---------------|:-------------------------------|
| PX running with few volumes | No PX or application activity    | PX is back online. Volumes are intact. No disruption. |
| PX running with few volumes | New volumes created | PX is back online. New Volumes are lost. |
| PX volumes were not in use by application. (Volumes are not attached) | Volumes are now in use by application (Volumes are attached) | PX is back online. The volume which was supposed to be attached is in detached state. Application is in CrashLoopBackOff state. Volumes may need to be restored from a previous snapshot. |
| PX volumes were in use by application | Volume are now not in use by application | Volumes which are not in use by the application still stay attached. No data loss involved. |
| All PX nodes are up | No PX Activity | All the expected nodes are still Up |
| All PX nodes are up | A few nodes go down which have volume replica. Current Set changes. | Current Set is not in sync with what the storage actually has and when PX comes back up, the volumes attached on that node may need to be restored from a previous snapshot. |
| A PX node with replica is down. The node is not in current set. | The node is now online and in Current Set. | PX volume starts with older current set, but eventually gets updated current set. No data loss involved. |
