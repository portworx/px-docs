---
layout: page
title: "Disaster Recovery Best Practices"
keywords: disaster recovery, disaster proof, site failure, node failure, power failure
sidebar: home_sidebar
meta-description: "Disaster Recovery Best Practices for Production Deployments of PX.  Try today!"
---

* TOC
{:toc}

Portworx PX-Enterprise comes with many data services features that enable production customers to deploy containerized workloads through many container orchestrators.

This page describes how to configure and setup Portworx for high availability and disaster recovery so customers can easily recover from site-wide failures.

Following are some of the recommended best practices for disaster-preparedness and recovery

### Recoverying from etcd Failure

* Ensure your etcd cluster that is used for storing Portworx configuration data is snapshotted and backed up periodically.
* Ensure the snaps are stored in a different location or cloud storage like S3, so they can be retrived from other sites if one of your side is down
* Follow this link to learn more on how to restore etcd cluster from its snapshots
* The table below shows different etcd failure scenarios, how Portworx reacts to it and the levels of recovery available

The following table summarizes how PX will respond to an etcd disaster and its recovery from a previous snapshot.


| PX state when snapshot was taken | PX state just before disaster | PX state after disaster recovery |
|-----------------|:---------------|:-------------------------------|
| PX running with few volumes | No PX or application activity    | PX is back online. Volumes are intact. No disruption. |
| PX running with few volumes | New volumes created | PX is back online. New Volumes are lost. |
| PX volumes were not in use by application. (Volumes are not attached) | Volumes are now in use by application (Volumes are attached) | PX is back online. The volume which was supposed to be attached is in detached state. Application is in CrashLoopBackOff state. Potentially could lead to data loss. |
| PX volumes were in use by application | Volume are now not in use by application | Volumes which are not in use by the application still stay attached. No data loss involved. |
| All PX nodes are up | No PX Activity | All the expected nodes are still Up |
| All PX nodes are up | A few nodes go down which have volume replica. Current Set changes. | Potentially could lead to data loss/corruption. Current Set is not in sync with what the storage actually has and when PX comes back up it might lead to data corruption |
| A PX node with replica is down. The node is not in current set. | The node is now online and in Current Set. | PX volume starts with older current set, but eventually gets updated current set. No data loss involved. |

### Recovering application data in Portworx Volumes

#### Recovering data from application errors

* Always ensure Portworx volumes are enabled with snapshot schedules so each volume is periodically snapshotted. Portworx recommends setting up an hourly snapshot schedule. Follow this page to see how to setup a [snapshot schedule] (https://docs.portworx.com/manage/snapshots.html#snapshot-schedules)

* The scheduled snaps have a five snapshot limit and they roll-over
* If the user wishes to retain more snapshots, then the snapshots can be scripted via the `pxctl snap` commands and the user can take up to 64 snapshots per volume. In this case, the older snapshots will have to be manually deleted. Visit [snapshots](https://docs.portworx.com/manage/snapshots.html#pxctl-snapshot-commands) for learning more about snapshots

#### Recovering data from cluster failures

* Portworx can periodically upload snapshots to cloud provider of choice, roll up all the snaps up and import that as a volume in the same PX cluster or another PX cluster
* This feature is called Cloudsnaps and is documented [here](https://docs.portworx.com/cloud/backups.html)
* Portworx recommends setting up Cloudsnaps atleast once a day and configure the snaps to be uploaded to a cloud provider or a object store that supports S3 protocol. Portworx current supports AWS S3, Azure Blob Store and Google Drive as the cloudstorage providers




