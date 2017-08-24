---
layout: page
title: "Portworx Alerts"
keywords: portworx, container, storage, alerts, alarms, warnings, notifications
sidebar: home_sidebar
---

## Portworx Alerts

PX provides a way to monitor your cluster using alerts. It has a predefined set of alerts which are listed below. The alerts are broadly classified into the following types based on the Resource on which it is raised

1. Cluster
2. Nodes
3. Disks
4. Volumes

Each alert has a severity from one of the following levels:

1. INFO
2. WARNING
3. ALARM

### List of Alerts

**Alert Codes**|**Alert Type**|**Severity**|**Resource Type**|**Description**
:-----|:-----|:-----:|:-----:|:-----|
0|DriveOperationFailure|ALARM|DRIVE|Triggered when a driver operations such as add or replace fails.
1|DriveOperationSuccess|NOTIFY|DRIVE|Triggered when a driver operations such as add or replace fails.
2|DriveStateChange|WARN|DRIVE|Triggered when there is a change in the driver state viz. Free Disk space goes below the recommended level of 10%.
3|VolumeOperationFailureAlarm|ALARM|VOLUME|Triggered when a volume operation fails. Volume operations could be resize, cloudsnap etc. The alert message will give more info about the specific error case. 
4|VolumeOperationSuccess|NOTIFY|VOLUME|Triggered when a volume operation such as resize succeeds. 
5|VolumeStateChange|WARN|VOLUME|Triggered when there is a change in the state of the volume.
6|VolGroupOperationFailure|ALARM|CLUSTER|Triggered when a volume group operation fails. 
7|VolGroupOperationSuccess|NOTIFY|CLUSTER|Triggered when a volume group operation succeeds. 
8|VolGroupStateChange|WARN|CLUSTER|Triggered when a volume group's state changes.
9|NodeStartFailure|ALARM|CLUSTER|Triggered when a node in the PX cluster fails to start.
10|NodeStartSuccess|NOTIFY|CLUSTER|Triggered when a node in the PX cluster successfully initializes.
11|<Internal PX Alert>|-|-|Alert code used for internal PX book keeping.
12|NodeJournalHighUsage|ALARM|CLUSTER|Triggered when a node's timestamp journal usage is not within limits.
13|IOOperation|ALARM|VOLUME|Triggered when an IO operation such as Block Read/Block Write fails.
14-16|<Internal PX Alerts>|-|-|Alert codes used for internal PX book keeping.
17|PXInitFailure|ALARM|NODE|Triggered when PX fails to initialize on a node.
18|PXInitSuccess|NOTIFY|NODE|Triggered when PX successfully initializes on a node.
19|PXStateChange|WARN|NODE|Triggered when the PX daemon shuts down in error.
20|VolumeOperationFailureWarn|WARN|VOLUME|Triggered when a volume operation fails. Volume operations could be resize, cloudsnap etc. The alert message will give more info about the specific error case. 
21|StorageVolumeMountDegraded|ALARM|NODE|Triggered when PX storage enters degraded mode on a node.
22|ClusterManagerFailure|ALARM|NODE|Triggered when Cluster manager on a PX node fails to start. The alert message will give more info about the specific error case.
23|KernelDriverFailure|ALARM|NODE|Triggered when an incorrect PX kernel module is detected. Indicates that PX is started with an incorrect version of kernel module.
24|NodeDecommissionSuccess|NOTIFY|CLUSTER|Triggered when a node is successfully decommissioned from PX cluster.
25|NodeDecommissionFailure|ALARM|CLUSTER|Triggered when a node could not be decommissioned from PX cluster.
26|NodeDecommissionPending|WARN|CLUSTER|Triggered when a node decommission is kept in pending state as it has data which is not replicated on other nodes.
27|NodeInitFailure|ALARM|CLUSTER|Triggered when PX fails to initialize on a node.
28|<Internal PX Alert>|-|-|Alert code used for internal PX book keeping.
29|NodeScanCompletion|NOTIFY|NODE|Triggered when node media scan completes without error.
30|VolumeSpaceLow|ALARM|VOLUME|Triggered when the free space available in a volume goes below a threshold.
31|ReplAddVersionMismatch|WARN|VOLUME|Triggered when a volume HA update fails with version mismatch.
32|CloudsnapScheduleFailure|ALARM|NODE|Triggered if a cloudsnap schedule fails to configure.
33|CloudsnapOperationUpdate|NOTIFY|VOLUME|Triggered if a cloudsnap schedule is changed successfully.
34|CloudsnapOperationFailure|ALARM|VOLUME|Triggered when a cloudsnap operation fails.
35|CloudsnapOperationSuccess|NOTIFY|VOLUME|Triggered when a cloudsnap operation succeeds.
36|NodeMarkedDown|WARN|CLUSTER|Triggered when a PX node marks another node down as it is unable to connect to it.
37|VolumeCreateSuccess|NOTIFY|VOLUME|Triggered when a volume is successfully created.
38|VolumeCreateFailure|ALARM|VOLUME|Triggered when a volume creation fails.
39|VolumeDeleteSuccess|NOTIFY|VOLUME|Triggered when a volume is successfully deleted.
40|VolumeDeleteFailure|ALARM|VOLUME|Triggered when a volume deletion fails.
41|VolumeMountSuccess|NOTIFY|VOLUME|Triggered when a volume is successfully mounted at the requested path.
42|VolumeMountFailure|ALARM|VOLUME|Triggered when a volume cannot be mounted at the requested path.
43|VolumeUnmountSuccess|NOTIFY|VOLUME|Triggered when a volume is successfully unmounted.
44|VolumeUnmountFailure|ALARM|VOLUME|Triggered when a volume cannot be unmounted. The alert message provides more info about the specific error case.
45|VolumeHAUpdateSuccess|NOTIFY|VOLUME|Triggered when a volume's replication factor (HA factor) is successfully updated.
46|VolumeHAUpdateFailure|ALARM|VOLUME|Triggered when an update to volume's replication factor (HA factor) fails.
47|SnapshotCreateSuccess|NOTIFY|VOLUME|Triggered when a volume is successfully created.Snapshot create success
48|SnapshotCreateFailure|ALARM|VOLUME|Triggered when a volume snapshot creation fails.
49|SnapshotRestoreSuccess|NOTIFY|VOLUME|Triggered when a snapshot is successfully restored on a volume.
50|SnapshotRestoreFailure|ALARM|VOLUME|Triggered when the restore of snapshot fails.
51|SnapshotIntervalUpdateFailure|ALARM|VOLUME|Triggered when an update of the snapshot interval for a volume fails.
52|SnapshotIntervalUpdateSuccess|NOTIFY|VOLUME|Triggered when a snapshot interval of a volume is successfully updated.
53|PXReady|NOTIFY|NODE|Triggered when PX is ready on a node.
54|StorageFailure|ALARM|NODE|Triggered when the provided storage drives could not be mounted by PX.
