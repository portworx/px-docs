---
layout: page
title: "PX-Enterprise Release notes"
keywords: portworx, px-enterprise, release notes
sidebar: home_sidebar
redirect_from:
  - /px-enterprise-release-notes.html
  - /release-notes-1-0-4.html
meta-description: "Stay up to date with the new releases and updates from Portworx. See our latest key features and an explanation of them all!"
---

* TOC
{:toc}

## 1.4.0-rc1 (Preview Release Only - NOT FOR PRODUCTION)
Expected GA date: 05/14


### Key Features

* 3DSnaps - Ability to take [application-consistent](https://docs.portworx.com/scheduler/kubernetes/snaps.html)
  snapshots cluster wide (Available in 05/14 GA version)
  * Volume Group snapshots - Ability to take crash-consistent snapshots on group of volumes based on a user-defined label 
* GCP/GKE automated disk management based on [disk templates](https://docs.portworx.com/cloud/gcp/gke.html#disk-template)
* [Kubernetes per volume secret support](https://docs.portworx.com/scheduler/kubernetes/pvc-encryption.html) to enable 
  volume encryption keys per Kubernetes PVC and using the Kubernetes secrets for key storage
* DC/OS vault integration - Use [Vault integrated with DC/OS](https://docs.portworx.com/secrets/portworx-with-dcos-secrets.html)
* Support port mapping used by PX from 9001-9015 to a custom port number range by passing the starting 
  port number in [install arguments](https://docs.portworx.com/runc/options.html#installation-arguments-to-px)
* Provide ability to do a [license tranfer](https://docs.portworx.com/getting-started/px-licensing.html#px-enterprise-license) from one cluster to another cluster



### Key Fixes:

To be updated soon

## 1.3.1.1

This is a minor update to the previous 1.3.1 release

* Fix to make node resync process yield better to application I/O  when some of nodes are down for a longer period of time 
  and brought back up thereby triggering the resync process.

## 1.3.1

This is a patch release with shared volume performance and stability fixes

### Key Fixes:

* Fix namespace client crashes when client list is generated when few client nodes are down.
* Allow read/write snapshots in k8s annotations
* Make adding and removing k8s node labels asynchronous to help with large number volume creations in parallel
* Fix PX crash when a snapshot is taken at the same time as node being marked down because of network failures
* Fix nodes option in docker inline volume create and supply nodes value as semicolon separated values

## 1.3.0.1

This is a patch update with the following fix

* PWX-5115 - Fix `nodes` option in [docker inline volume create](https://docs.portworx.com/scheduler/docker/volume-plugin.html#replicaset) and supply nodes value as semicolon separated values

## 1.3.0 

***Upgrade Note 1***: Upgrade to 1.3 requires a node restart in non-k8s environments. In k8s environments, the cluster does a rolling upgrade

***Upgrade Note 2***: Ensure all nodes in PX cluster are running 1.3 version before increasing replication factor for the volumes

***Upgrade Note 3***: Container information parsing code has been disabled and hence the PX-Lighthouse up to 1.1.7 version will not show the container information page. This feature will be back in future releases and with the new lighthouse

### Feature updates and noteworthy changes

* Volume create command additions to include volume clone command and integrate snap commands
* Improved snapshot workflows 
  * Clones - full volume copy created from a snapshot
  * Changes to snapshot CLI.
  * Creating scheduled snapshots policies per volume
  * ***Important*** From 1.3 onwards, all snapshots are readonly. If the user wishes to create a read/write snapshot, a volume    clone can be created from the snapshot
* Improved resync performance when a node is down for a long time and restarted with accumulated data in the surviving nodes
* Improved performance for database workloads by separating transaction logs to a seperate journal device
* Added PX signature to drives so drives cannot be accidentally re-used even if the cluster has been deleted. 
* Per volume cache attributes for shared volumes
* https support for API end-points
* Portworx Open-Storage scaling groups support for AWS ASG - Workflow improvements
  * Allow specifying input EBS volumes in the format "type=gp2,size=100". (this is documented)
  * Instead of adding labels to EBS volumes, PX now stores all the information related to them in kvdb. 
    All the EBS volumes it creates and attaches are listed in kvdb and this information is then used to 
    find out EBS volumes being used by PX nodes
  * Added command `pxctl cloud list` to list all the drives created via ASG
* Integrated kvdb - Early Access - Limited Release for small clusters less than 10 nodes

### New CLI Additions and changes to existing ones
* Added `pxctl service node-wipe` to wipe PX metadata from a decommisioned node in the cluster
* Change `snap_interval` parameter to `periodic` in `pxctl volume` commands
* Add schduler information in `pxctl status` display
* Add info about cloudvolumes CLI [k8s](https://docs.portworx.com/cloud/aws/kops-asg.html#corelating-ebs-volumes-with-portworx-nodes) , [others](https://docs.portworx.com/cloud/aws/asg.html#corelating-ebs-volumes-with-portworx-nodes)
* `pxctl service add --journal -d <device>` to add journal device support

### Issues addressed

* PWX-4518 - Add a confirmation prompt for `pxctl volume delete` operations
* PWX-4655 - Improve "PX Cluster Not In Quorum" Message in `pxctl status` to give additional information. 
* PWX-4504 - Show all the volumes present in the node in the CLI
* PWX-4475 - Parse io_profile in inline volume spec
* PWX-4479 - Fix io_priority versions when labeling cloudsnaps
* PWX-4378 - Add read/write latency stats to the volume statistics
* PWX-4923 - Add vol_ prefix to read/write volume latency statistics
* PWX-4288 - Handle app container restarts attached to a shared volume if the mountpath 
             was unmounted via unmount command
* PWX-4372 - Gracefully handle trial license expiry and PX cluster reinstall
* PWX-4544 - PX OCI install is unable to proceed with aquasec container installed
* PWX-4531 - Add OS Distribution and Kernel version display in `pxctl status`
* PWX-4547 - cloudsnap display catalog with volume name hits "runtime error: index out of range"
* PWX-4585 - handle kvdb server timeouts with improved retry mechanism
* PWX-4665 - Do not allow drive add to a pool if a rebalance operation is already in progress
* PWX-4691 - Do not allow snapshots on down nodes or if the node is maintenance mode
* PWX-4397 - Set the correct zone information for all replica-sets
* PWX-4375 - Add `pxctl upgrade` support for OCI containers
* PWX-4733 - Remove Swarm Node ID check dependencies for PX bring up
* PWX-4484 - Limit replication factor increases to a limit of three at a time within a cluster and one per node
* PWX-4090 - Reserve space in each pool to handle rebalance operations
* PWX-4544 - Handle ./aquasec file during OCI-Install so PX can be installed in environments with aquasec
* PWX-4497 - Enable minio to mount shared volumes
* PWX-4551 - Improve `pxctl volume inspect` to show pools on which volumes are allocated, 
             replica nodes and replication add
* PWX-4884 - Prevent replication factor increases if all the nodes in the cluster are not running 1.3.0
* PWX-4504 - Show all the volumes present on a node in CLI with a `--node` option
* PWX-4824 - `pxctl volume inspect` doesn't show replication set information properly when one ndoe is out of quorum
* PWX-4784 - Support SELinux in 4.12.x kernels and above by setting SELinux context correctly
* PWX-4812 - Handle Kernel upgrades correctly
* PWX-4814 - Synchronize snapshot operations per node
* PWX-4471 - Enhancements to OCI Mount propogation to automount relevant scheduler dirs
* PWX-4721 - When large number of volumes are cloudsnapped at the same time, PX container hits a panic
* PWX-4789 - Handle cloudsnaps errors when the schedule has been moved or deleted
* PWX-4709 - Support for adding CloudDrive (EBS volume) to an existing node in a cluster
* PWX-4777 - Fix issues with `pxctl volume inspect` on shared volumes hanging when a large number 
             of volume inspects are done
* PWX-4525 - `pxctl status` shows invalid cluster summary in some nodes when performing an upgrade from 1.2 to 1.3
* PWX-3071 - Provide ability to force detach a remote mounted PX volume from a single node when node is down
* PWX-4772 - Handle storage full conditions more gracefully when the backing store for a px volume gets full
* PWX-4757 - Improve PX initialization during boot to handle out of quorum volumes gracefully.
* PWX-4747 - Improve simultaneous large number of volume creates and volume attach/detach in multiple nodes
* PWX-4467 - Fix hangs when successive volume inspects come to the same volume with cloudsnap in progress
* PWX-4420 - Fix race between POD delete and volume unmounts
* PWX-4206 - Under certain conditions, creating a snap using k8s PVC creates a new volume instead of snapshot
* PWX-4207 - Fix nil pointer dereferences when creating snapshots via k8s


### Errata

* PWX-3982 After putting a node into maintenance mode, adding drives, and then running "pxctl service m --exit", the message "Maintenance operation is in progress, cancel operation or wait for completion" doesn't specify which operation hasn't completed. Workaround: Use pxctl to query the status of all three drive operations (add, replace, rebalance). pxctl then reports which drive operations are in progress and allows exiting from maintenance mode if all maintenance operations are completed.

* PWX-4016 When running under Kubernetes, adding a node label for a scheduled cloudsnap fails with the error "Failed to update k8s node". A node label isn't needed for cloudsnaps because they are read-only and used only for backup to the cloud.

* PWX-4021 In case of a failure while a read-only snapshot create operation is in progress, Portworx might fail to come back up. This can happen if the failure coincides with snapshot creation's file system freeze step, which is required to fence incoming IOs during the operation. To recover from this issue, reboot the node.

* PWX-4027 Canceling a service drive replace operation fails with the message "Replace cancel failed - Not in progress". However, if you try to exit maintenance mode, the status message indicates that a maintenance operation is in progress. Workaround: Wait for the drive replace operation to finish. The replace operation might be in a state where it can't be canceled. Cancel operations are performed when possible.

* PWX-4039 When running Ubuntu on Azure, an XFS volume format fails. Do not use XFS volumes when running Ubuntu on Azure.

* PWX-4043 When a Portworx POD gets deleted in Kubernetes, no alerts are generated to indicate the POD deletion via kubectl.

* PWX-4050 For a Portworx cluster that's about 100 nodes or greater: If the entire cluster goes down with all the nodes off line, as nodes come on line a few nodes get restarted because they are marked offline. A short while after, the system converges and the entire cluster becomes operational. No user intervention required.

* Key Management with AWS KMS doesn't work anymore because of API changes on the AWS side. Will be fixed in an upcoming release. Refer to this link for additional details. https://github.com/aws/aws-cli/issues/1043

* When shared volumes are configured with io_profile=cms, it results in the px-ns process restarting occasionally.

## 1.2.23.0

This is a minor update that fixes an panic seen in some k8s environments when the user upgraded from a older version of PX to 1.2.22

PWX-5107 - Check if node spec is present before adding the node for volume state change events

## 1.2.22.0

* Support SELinux enable in kernels 4.12.x and above
* Support automatic kernel upgrades. If you expect your environment to upgrade kernels automatically, Portworx recommends to uprade to 1.2.22.0

## 1.2.20.0

* Minor update to enhance write performance for remote moounts with shared volumes
* 4.15.3 Linux kernel support

### Errata (Errata remains the same from 1.2.11.0 release)

* PWX-3982 After putting a node into maintenance mode, adding drives, and then running "pxctl service m --exit", the message "Maintenance operation is in progress, cancel operation or wait for completion" doesn't specify which operation hasn't completed. Workaround: Use pxctl to query the status of all three drive operations (add, replace, rebalance). pxctl then reports which drive operations are in progress and allows exiting from maintenance mode if all maintenance operations are completed.
* PWX-4014 The pxctl cloudsnap schedule command creates multiple backups for the scheduled time. This issue has no functional impact and will be resolved in the upcoming release.
* PWX-4016 When running under Kubernetes, adding a node label for a scheduled cloudsnap fails with the error "Failed to update k8s node". A node label isn't needed for cloudsnaps because they are read-only and used only for backup to the cloud.
* PWX-4017 An incremental cloudsnap backup command fails with the message "Failed to open snap for backup". Logs indicates that the backup wasn't found on at least on one of the nodes where the volume was provisioned. Workaround: Trigger another backup manually on the nodes that failed.
* PWX-4021 In case of a failure while a read-only snapshot create operation is in progress, Portworx might fail to come back up. This can happen if the failure coincides with snapshot creation's file system freeze step, which is required to fence incoming IOs during the operation. To recover from this issue, reboot the node.
* PWX-4027 Canceling a service drive replace operation fails with the message "Replace cancel failed - Not in progress". However, if you try to exit maintenance mode, the status message indicates that a maintenance operation is in progress. Workaround: Wait for the drive replace operation to finish. The replace operation might be in a state where it can't be canceled. Cancel operations are performed when possible.
* PWX-4039 When running Ubuntu on Azure, an XFS volume format fails. Do not use XFS volumes when running Ubuntu on Azure.
* PWX-4043 When a Portworx POD gets deleted in Kubernetes, no alerts are generated to indicate the POD deletion via kubectl.
* PWX-4050 For a Portworx cluster that's about 100 nodes or greater: If the entire cluster goes down with all the nodes off line, as nodes come on line a few nodes get restarted because they are marked offline. A short while after, the system converges and the entire cluster becomes operational. No user intervention required.
* Key Management with AWS KMS doesn't work anymore because of API changes on the AWS side. Will be fixed in an upcoming release. Refer to this link for additional details. https://github.com/aws/aws-cli/issues/1043
* PWX-4721 - When cloud-snap is performed on large number of volumes, it results in a PX container restart. Workaround is to run cloudsnaps on up to 10 volumes concurrently.

## 1.2.18.0

### Fixed issues

* Improve file import and untar performance when shared volumes are used by Wordpress and tune for wordpress plugin behavior

### Errata (Errata remains the same from 1.2.11.0 release)

* PWX-3982 After putting a node into maintenance mode, adding drives, and then running "pxctl service m --exit", the message "Maintenance operation is in progress, cancel operation or wait for completion" doesn't specify which operation hasn't completed. Workaround: Use pxctl to query the status of all three drive operations (add, replace, rebalance). pxctl then reports which drive operations are in progress and allows exiting from maintenance mode if all maintenance operations are completed.
* PWX-4014 The pxctl cloudsnap schedule command creates multiple backups for the scheduled time. This issue has no functional impact and will be resolved in the upcoming release.
* PWX-4016 When running under Kubernetes, adding a node label for a scheduled cloudsnap fails with the error "Failed to update k8s node". A node label isn't needed for cloudsnaps because they are read-only and used only for backup to the cloud.
* PWX-4017 An incremental cloudsnap backup command fails with the message "Failed to open snap for backup". Logs indicates that the backup wasn't found on at least on one of the nodes where the volume was provisioned. Workaround: Trigger another backup manually on the nodes that failed.
* PWX-4021 In case of a failure while a read-only snapshot create operation is in progress, Portworx might fail to come back up. This can happen if the failure coincides with snapshot creation's file system freeze step, which is required to fence incoming IOs during the operation. To recover from this issue, reboot the node.
* PWX-4027 Canceling a service drive replace operation fails with the message "Replace cancel failed - Not in progress". However, if you try to exit maintenance mode, the status message indicates that a maintenance operation is in progress. Workaround: Wait for the drive replace operation to finish. The replace operation might be in a state where it can't be canceled. Cancel operations are performed when possible.
* PWX-4039 When running Ubuntu on Azure, an XFS volume format fails. Do not use XFS volumes when running Ubuntu on Azure.
* PWX-4043 When a Portworx POD gets deleted in Kubernetes, no alerts are generated to indicate the POD deletion via kubectl.
* PWX-4050 For a Portworx cluster that's about 100 nodes or greater: If the entire cluster goes down with all the nodes off line, as nodes come on line a few nodes get restarted because they are marked offline. A short while after, the system converges and the entire cluster becomes operational. No user intervention required.
* Key Management with AWS KMS doesn't work anymore because of API changes on the AWS side. Will be fixed in an upcoming release. Refer to this link for additional details. https://github.com/aws/aws-cli/issues/1043

## 1.2.16.2

* This is a minor update that fixes volume size not updating whenever the content of the encrypted volume is deleted

## 1.2.16.1

This is a minor update which adds a new flag to limit or disable the generation of core files (`-e PXCORESIZE=<size>`). 
A value of 0 will disable cores 


## 1.2.16.0

This is a minor update with performance enhancements for shared volumes to support large number of directories and files.

### Fixed issues 

* Shared volume access latency improvements when managing filesystems with large number of directories and files

### Errata (Errata remains the same from 1.2.11.0 release)

* PWX-3982 After putting a node into maintenance mode, adding drives, and then running "pxctl service m --exit", the message "Maintenance operation is in progress, cancel operation or wait for completion" doesn't specify which operation hasn't completed. Workaround: Use pxctl to query the status of all three drive operations (add, replace, rebalance). pxctl then reports which drive operations are in progress and allows exiting from maintenance mode if all maintenance operations are completed.
* PWX-4014 The pxctl cloudsnap schedule command creates multiple backups for the scheduled time. This issue has no functional impact and will be resolved in the upcoming release.
* PWX-4016 When running under Kubernetes, adding a node label for a scheduled cloudsnap fails with the error "Failed to update k8s node". A node label isn't needed for cloudsnaps because they are read-only and used only for backup to the cloud.
* PWX-4017 An incremental cloudsnap backup command fails with the message "Failed to open snap for backup". Logs indicates that the backup wasn't found on at least on one of the nodes where the volume was provisioned. Workaround: Trigger another backup manually on the nodes that failed.
* PWX-4021 In case of a failure while a read-only snapshot create operation is in progress, Portworx might fail to come back up. This can happen if the failure coincides with snapshot creation's file system freeze step, which is required to fence incoming IOs during the operation. To recover from this issue, reboot the node.
* PWX-4027 Canceling a service drive replace operation fails with the message "Replace cancel failed - Not in progress". However, if you try to exit maintenance mode, the status message indicates that a maintenance operation is in progress. Workaround: Wait for the drive replace operation to finish. The replace operation might be in a state where it can't be canceled. Cancel operations are performed when possible.
* PWX-4039 When running Ubuntu on Azure, an XFS volume format fails. Do not use XFS volumes when running Ubuntu on Azure.
* PWX-4043 When a Portworx POD gets deleted in Kubernetes, no alerts are generated to indicate the POD deletion via kubectl.
* PWX-4050 For a Portworx cluster that's about 100 nodes or greater: If the entire cluster goes down with all the nodes off line, as nodes come on line a few nodes get restarted because they are marked offline. A short while after, the system converges and the entire cluster becomes operational. No user intervention required.

## 1.2.14.0
This is a minor update to support the older linux kernel versions (4.4.0.x) that ships with Ubuntu distributions

## 1.2.12.1
This is a minor update to support Openshift with SELinux enabled as well as verify with SPECTRE/Meltdown kernel patches

* Verified with the latest kernel patches for SPECTRE/Meltdown issue for all major Linux distros

## 1.2.12.0
This is a minor update to enhance meta data performance on a shared namespace volume.

### Fixed issues
* Readdir performance for directories with a large number of files (greater 128K file count in a single directory)
* PX running on AWS AutoScalingGroup now handles existing devices attached with names such as `/dev/xvdcw` which have an extra letter at the end.
* Occasionally, containers that use shared volumes could get a "transport end point disconnected" error when PX restarts.  This has been resolved.
* Fixed an issue where Portworx failed to resolve Kubernetes services by their DNS names if user sets the Portworx DaemonSet DNS Policy as `ClusterFirstWithHostNet`.
* PWX- 4078 When PX runs in 100s of nodes, a few nodes show high memory usage. 



## 1.2.11.10
This is a minor update to address an issue with installing a reboot service while upgrading a runC container.

### Fixed issues
* When upgrading a runC container, the new version will correctly install a reboot service.  A reboot service (systemd service) is needed to reduce the wait time before a PX device returns with a timeout when the PX service is down.  Without this reboot service, a node can take 10 minutes to reboot.

## 1.2.11.9

### Fixed issues

* Pass volume name as part of the metrics end point so Prometheus/Grafana can display with volume name
* Add current ha level of the volume and io_priority of the volumes to the metrics endpoint
* Abort all pending I/Os the the pxd device during a reboot so speed up reboots
* Move the px-ns internal port from 7000 to 9013
* Remove the unnecessary warning string "Data is not local to the node"
* Add px_ prefix to all volume labels

### Errata 

* Do not manually unmount a volume by using linux `umount` command for shared volume mounts. This errata applies to the previous versions of PX as well.

## 1.2.11.8

### Fixed issues

* Fix resync mechanism for read-only snapshots
* Improve log space utilization by removing old log files based on space usage

### Errata 

* Do not manually unmount a volume by using linux `umount` command for shared volume mounts. This errata applies to the previous versions of PX as well.

## 1.2.11.7

### Fixed issues

* Suppress un-necessary log prints about cache flush
* PWX-4272 Handle remote host shutdowns gracefully for shared volumes. In the past this could leave stray TCP connections.

### Errata 

* Do not manually unmount a volume by using linux `umount` command for shared volume mounts. This errata applies to the previous versions of PX as well.

## 1.2.11.6 Release notes

### Fixed issues

* Provide capability to drop system cache on-demand (for a select workloads and large memory system) and turn it off by default

## 1.2.11.5 Release notes

### Key Features and Changes

* PWX-4178 Perform snapshots in kubernetes via [annotations](https://docs.portworx.com/scheduler/kubernetes/snaps.html#using-annotations)

## 1.2.11.4 Release notes

### Key Features and Changes

* PX-Enterprise container is now available in [OCI Format](https://docs.portworx.com/runc/)
* Enhancements for db workloads to handle slow media

### Fixed issues

* PWX-4224 Ignore `sticky` flag when purging old snapshots after a cloudsnap is completed.
* PWX-4220 `pxctl status` shows the first interface IP address instead of the mgmt. IP

## 1.2.11.3 Release notes

### Fixed Issues

* Shared volume performance improvements
* Do not take a a inline snap in k8s when no valid candidate pvcs are found

## 1.2.11.2 Release notes

### Fixed Issues

* Increase file descriptors to support large number of shared volumes

## 1.2.11.1 Release notes

### Fixed Issues

* Fix file descriptors not being released after reporting containers attached to a shared volume

## 1.2.11.0 Release notes

### Key Features and Changes
* You can now update volume labels. The pxctl volume update command has a new option, --label pairs. Specify a list of comma-separated name=value pairs. For example, if the current labels are x1=v1,x2=v2:

   The option "--labels x1=v4" results in the labels x1=v4,x2=v2.

   The option "--labels x1=" results in the labels x2=v2 (removes a label).

* Improvements to alerts:
   - Additional alerts indicate the cluster status in much more finer detail. This document has more details on all the alerts posted by PX: [https://docs.portworx.com/maintain/monitoring/portworx-alerts.html](https://docs.portworx.com/maintain/monitoring/portworx-alerts.html)
   - Rate limiting for alerts so that an alert isn't repeatedly posted within a short timeframe.

* You can now update the io_profile field by using the `pxctl volume update` command so the parameter can be enabled for existing volumes. 

### Fixed Issues
* PWX-3146 Portworx module dependencies fail to load for openSUSE Leap 42.2, Kernel 4.4.57-18.3-default.
* PWX-3362 If a node is in maintenance mode because of disk errors, the node isn't switched to a storage-less node. As a result, other resources on the node (such as CPU and memory) aren't usable.
* PWX-3448 When Portworx statistics are exported, they include the volume ID instead of the volume name.
* PWX-3472 When snapshots are triggered on large number of volumes at the same time, the snap operation fails.
* PWX-3528 Volume create option parsing isn't unified across Kubernetes, Docker, and pxctl.
* PWX-3544 Improvements to PX Diagnostics - REST API to retrieve and upload diagnostics for a node or cluster. Diagnostics run using the REST API includes vmstat output and the output of pxctl cluster list and pxctl -j volume list. The diagnostics also include netstat -s before the node went down.
* PWX-3558 px-storage dumps core while running an HA increase on multiple volumes during stress.
* PWX-3577 When Portworx is running in a container environment, it should allow mounts on only those directories which are bind mounted. Otherwise, Portworx hangs during a docker stop.
* PWX-3585 If Portworx stops before a container that's using its volume stops, the container mght get stuck in the D state (I/O in kernel). As a result 'systemctl stop docker' takes 10 minutes as does system shutdown. The default PXD_TIMEOUT to error out IOs is 10 minutes, but should be configurable.
* PWX-3591 Storage isn't rebalanced after a drive add operation and before exiting maintenance mode.
* PWX-3600 Volume HA update operations on snapshots cannot be canceled.
* PWX-3602 Removing a node from a cluster fails with the message "Could not find any volumes that match ID(s)".
* PWX-3606 Portworx metrics now include the following: Disk read and write latency stats, volume read and write latency stats, and per process stats for CPU and virtual/resident memory.
* PWX-3612 When creating or updating a volume, disallow ability to set both the "shared" and "scale" options.
* PWX-3614 A volume inspect returns the wrong error message when one node in the cluster is down: Could not find any volumes that match ID(s).
* PWX-3620 The volume inspect command doesn't show the replication set status, such as whether the replication set has down members or is in a clean or resync state.
* PWX-3632 After a Kubernetes pod terminates and the Portworx volume unmount/cleanup fails, the kubelet logs include "Orphaned pod &lt;name&gt; found, but volume paths are still present on disk."
* PWX-3648 After all nodes in a cluster go offline: If a node doesn't restart when the other nodes restart, the other restarting nodes don't mark that node as offline.
* PWX-3665 The Portworx live core collection hangs sometimes.
* PWX-3666 The pxctl service diags command doesn't store all diagnostics for all nodes in the same lcoation. All diagnostics should appear in /var/cores.
* PWX-3672 The watch function stops after a large time change, such as 7 hours, on the cluster.
* PWX-3678 The pxctl volume update command interprets the -s option as -shared instead of -size and displays the message "invalid shared flag".
* PWX-3700 Multiple alerts appear after a drive add succeeds.
* PWX-3701 The alert raised when a node enters maintenance mode specifes the node index instead of the node ID.
* PWX-3704 After backing up a volume that's in maintenance mode to the cloud, restoring the volume to any online node fails.
* PWX-3709 High CPU usage occurs while detaching a volume with MySQL in Docker Swarm mode.
* PWX-3743 In the service alerts output in the CLI, the Description items aren't aligned.
* PWX-3746 When a Portworx upgrade requires a node reboot, the message "Upgrade done" shouldn't print.
* PWX-3747 When a node exits from maintenance mode, it doesn't generate an alert.
* PWX-3764 The px-runc install command on a coreOS node fails to configure the PX OCI service and generates the error "invalid cross-device link".
* PWX-3777 When running under Kubernetes, pods using a shared volume aren't available after the volume becomes read-only.
* PWX-3778 After adding a drive to a storage-less node fails: A second attempt succeeds but there is no message that the drive add succeeded.
* PWX-3793 When running in Kubernetes, if an unmount fails for a shared volume with the error "volume not mounted", the volume is stuck in a terminating state.
* PWX-3817 When running under Kubernetes, a WordPress pod is stuck in terminating for almost ten minutes.
* PWX-3820 When running Portworx as a Docker V2 plugin: After a service create --replicas command, a volume is mounted locally on a MySQL container instead of a Portworx container. The Swarm service fails with the error "404 Failed to locate volume: Cannot locate volume". To avoid this issue, you can now specify the volume-driver with the service create command.
* PWX-3825 When a node is in a storage down state because the pool is out of capacity: A drive add fails with the error "Drive add start failed. drive size &lt;size&gt; too big" during an attempt to add the same size disk.
* PWX-3829 Container status in the Portworx Lighthouse GUI isn't updated properly from Portworx nodes.
* PWX-3843 Portworx stats include metrics for utilized and available bytes, but not for total bytes (px\_cluster\_disk\_total_bytes). As a result, alerts can't be generated in Prometheus for storage utilization.
* PWX-3844 When you add a snapshot schedule to a volume, the alert type is "Snapshot Interval update failure" instead of "Snapshot interval update success".
* PWX-3850 If the allocated io\_priority differs from the requested io_priority, no associated alert is generated.
* PWX-3851 When two Postgres pods attempted to use the same volume, one of the Postgres pods mounted a local volume instead of a Portworx volume.
* PWX-3859 After adding a volume template to an Auto Scaling Group and Portworx adds tags to the volume: If you stop that cluster and then start a new cluster with the same volume, without removing the tags, a message indicates that the cluster is already initialized. The message should indicate that it failed to attach template volumes because the tag is already used. You can then manually remove the tags from the stopped cluster.
* PWX-3862 A volume is stuck in the detaching state indefinitely due to an issue in etcd.
* PWX-3867 When running under Kubernetes, a pod using namespace volumes generates the messages "Orphaned pod &lt;pod&gt; found, but volume paths are still present on disk".
* PWX-3868 A PX cluster shows an extra node when running with ASG templates enabled if the AWS API returns an error when the PX container is booting up.
* PWX-3871 Added support for dot and hyphen in source and destination names in Kubernetes inline spec for snapshots.
* PWX-3873 When running under Kubernetes, a volume detach fails on a regular volume, with the message "Failed to detach volume: Failed with status -16", and px-storage dumps core.
* PWX-3875 After volume unmount and mount commands are issued in a quick succession, sometimes the volume mount fails.
* PWX-3878 When running under Kubernetes, a Postgres pod gets stuck in a terminating state during when the POD gets deleted.
* PWX-3879 During volume creation on Kubernetes, node labels aren't applied on Kubernetes nodes.
* PWX-3888 An HA increase doesn't use the node value specified in the command if the node is from a different region.
* PWX-3895 The pxctl volume list command shows a volume but volume inspect cannot find it.
* PWX-3902 If a Portworx container is started with the API_SERVER pointing to Lighthouse and etcd servers are also provided, the Portworx container doesn't send statistics to Lighthouse.
* PWX-3906 Orphaned pod volume directories can remain in a Kubernetes cluster after an unmount.
* PWX-3912 During a container umount, namespace volumes might show the error "Device or resource busy".
* PWX-3916 Portworx rack information isn't updated when labels are applied to a Kubernetes node.
* PWX-3933 The size of a volume created by using a REST API call isn't rounded to the 4K boundary.
* PWX-3935 Lighthouse  doesn't show container information when Portworx is run as a Docker V2 plugin.
* PWX-3936 A volume create doesn't ignore storage-less nodes in a cluster and thus fails, because it doesn't allocate the storage to available nodes.
* PWX-3946 On a node where a cloudsnap schedule is configured: If the node gets decommissioned, the schedule isn't configured for the new replica set.
* PWX-3947 Simultaneous mount and unmount likely causes a race in teardown and setup.
* PWX-3968 If Portworx can't find a volume template in an Auto Scaling Group, it dumps core and keeps restarting.
* PWX-3971 Portworx doesn't install on an Azure Ubuntu 14 Distro with 3.13.0-32-generic kernel.
* PWX-3972 When you start a multi-node, multi-zone Auto Scaling Group with a max-count specified, Portworx doesn't start on all nodes.
* PWX-3974 When running under Kubernetes, a WordPress app writes data to the local filesystem after a shared volume remount failure (due to RPC timeout errors) during node start.
* PWX-3997 When running under Kubernetes, deleting Wordpress pods results in orphaned directories.
* PWX-4000 A drive add or replace fails when Portworx is in a storage full/pool offline state.
* PWX-4012 When using shared volumes: During a WordPress plugin installation, the WordPress pod prompts for FTP site permissions. Portworx now passes the correct GID and UUID to WordPress.
* PWX-4049 Adding and removing Kubernetes node labels can fail during node updates.
* PWX-4051 Previous versions of Portworx logged too many "Etcd did not return any transaction responses" messages. That error is now rate-limited to log only a few times.
* PWX-4083 When volume is in a down state due to a create failure, but is still attached without a shared volume export, the detach fails with the error "Mountpath is not mounted".
* PWX-4085 When running under Kubernetes, too many instances of this message get generated: “Kubernetes node watch channel closed. Restarting the watch.."
* PWX-4131 Specifying -a or -A for providing disks to PX needs to handle mpath & raid drives/partitions as well
### Errata

* PWX-3982 After putting a node into maintenance mode, adding drives, and then running "pxctl service m --exit", the message "Maintenance operation is in progress, cancel operation or wait for completion" doesn't specify which operation hasn't completed. Workaround: Use pxctl to query the status of all three drive operations (add, replace, rebalance). pxctl then reports which drive operations are in progress and allows exiting from maintenance mode if all maintenance operations are completed.
* PWX-4014 The pxctl cloudsnap schedule command creates multiple backups for the scheduled time. This issue has no functional impact and will be resolved in the upcoming release.
* PWX-4016 When running under Kubernetes, adding a node label for a scheduled cloudsnap fails with the error "Failed to update k8s node". A node label isn't needed for cloudsnaps because they are read-only and used only for backup to the cloud.
* PWX-4017 An incremental cloudsnap backup command fails with the message "Failed to open snap for backup". Logs indicates that the backup wasn't found on at least on one of the nodes where the volume was provisioned. Workaround: Trigger another backup manually on the nodes that failed.
* PWX-4021 In case of a failure while a read-only snapshot create operation is in progress, Portworx might fail to come back up. This can happen if the failure coincides with snapshot creation's file system freeze step, which is required to fence incoming IOs during the operation. To recover from this issue, reboot the node.
* PWX-4027 Canceling a service drive replace operation fails with the message "Replace cancel failed - Not in progress". However, if you try to exit maintenance mode, the status message indicates that a maintenance operation is in progress. Workaround: Wait for the drive replace operation to finish. The replace operation might be in a state where it can't be canceled. Cancel operations are performed when possible.
* PWX-4039 When running Ubuntu on Azure, an XFS volume format fails. Do not use XFS volumes when running Ubuntu on Azure.
* PWX-4043 When a Portworx POD gets deleted in Kubernetes, no alerts are generated to indicate the POD deletion via kubectl.
* PWX-4050 For a Portworx cluster that's about 100 nodes or greater: If the entire cluster goes down with all the nodes off line, as nodes come on line a few nodes get restarted because they are marked offline. A short while after, the system converges and the entire cluster becomes operational. No user intervention required.


## 1.2.10.2 Release notes

### Key Features

None

### Key Changes and Issues Addressed

* Fix boot issues with Amazon linux
* Fix issues with shared volume mount and unmount with multiple containers  with kubernetes

## 1.2.10 Release notes

### Key Features

None

### Key Changes and Issues Addressed

* Fix issue when a node running PX goes down, it never gets marked down in the kvdb by other nodes.
* Fix issue when a container in Lighthouse UI always shows as running even after it has exited
* Auto re-attach containers mounting shared volumes when PX container is restarted. 
* Add Linux immutable (CAP_LINUX_IMMUTABLE) when PX is running as Docker V2 Plugin
* Set autocache parameter for shared volumes
* On volume mount, make the path read-only if an unmount comes in if the POD gets deleted or PX is restarted during POD
  creation. On unmount, the delete the mount path.
* Remove the volume quorum check during volume mounts so the mount can be retried until the quorum is achieved
* Allow snapshot volume source to be provided as another PX volume ID and Snapshot ID
* Allow inline snapshot creation in Portworx Kubernetes volume driver using the Portworx Kubernetes volume spec
* Post log messages indicating when logging URL is changed
* Handle volume delete requests gracefully when PX container is starting up
* Handle service account access when PX is running as a container instead of a daemonset when running under kubernetes
* Implement a global lock for kubernetes filter such that all cluster-wide Kubernetes filter operations are 
  coordinated through the lock
* Improvements in unmount/detach handling in kubernetes to handle different POD clean up behaviors for deployments 
  and statefulsets

### Errata

* If two containers using the same shared volume are run in the same node using docker, when one container exits, the container's connection to the volume will get disrupted as well. Workaround is to run containers using shared volume in two different portworx nodes

## 1.2.9 Release notes

>**Important:**<br/> If you are upgrading from an older version of PX (1.2.8 or older) and have PX volumes in attached state, you will need node reboot after upgrade in order for the new version to take effect properly.

### Key Features

* Provide ability to cancel a replication add or HA increase operation
* Automatically decommision a storageless node in the cluster if it has been offline for longer than 48 hours
* [Kubernetes snapshots driver for PX-Enterprise](/scheduler/kubernetes/snaps.html)
* Improve Kubernetes mount/unmount handling with POD failovers and moves


### Key Issues Addressed

* Correct mountpath retrieval for encrypted volumes
* Fix cleanup path maintenance mode exit issue and clean up alerts
* Fix S3 provider for compatibility issues with legacy object storage providers not supporting ListObjectsV2 API correctly.
* Add more cloudsnap related alerts to indicate cloudsnap status and any cloudsnap operation failures.
* Fix config.json for Docker Plugin installs
* Read topology parameters on PX restart so RACK topology information is read correctly on restarts
* Retain environment variables when PX is upgraded via `pxctl upgrade` command
* Improve handling for encrypted scale volumes

### Errata

* When PX-Enterprise is run on a large number of nodes, there is potential memory leak and a few nodes show high memory usage.
  This issue is resolved in 1.2.12.0 onwards. Workaround is to restart the PX-Enterprise container

## 1.2.8 Release notes

### Key Features

* License Tiers for PX-Enterprise

### Key Issues Addressed

NONE

## 1.2.5 Release notes

### Key Features

* Increase volume limit to 16K volumes

### Key Issues Addressed

* Fix issues with volume CLI hitting a panic when used the underlying devices are from LVM devices
* Fix px bootstrap issues with pre-existing snapshot schedules
* Remove alerts posted when volumes are mounted and unmounted
* Remove duplicate updates to kvdb


## 1.2.4 Release notes

### Key Features

* Support for --racks and --zones option when creating replicated volumes
* Improved replication node add speeds
* Node labels and scheduler convergence for docker swarm
* Linux Kernel 4.11 support
* Unique Cluster-specifc bucket for each cluster for cloudsnaps
* Load balanced cloudsnap backups for replicated PX volumes
* One-time backup schedules for Cloudsnap
* Removed the requirement to have /etc/pwx/kubernetes.yaml in all k8s nodes 


### Key Issues Addressed

* `pxctl cloudsnap credentials` command has been moved under `pxctl credentials`
* Docker inline volume creation support for setting volume aggregation level
* --nodes support for docker inline volume spec
* Volume attach issues after a node restart when container attaching to a volume failed
* PX Alert display issues in Prometheus
* Cloudsnap scheduler display issues where the existing schedules were not seen by some users.
* Removed snapshots from being counted into to total volume count
* Removed non-px related metrics being pushed to Prometheus
* Added CLI feedback and success/failure alerts for `pxctl volume update` command
* Fixed issues with Cloudsnap backup status updates for container restarts


## 1.2.3 Release notes

### Key Features

No new features in 1.2.3. This is a patch release.

### Key Issues Addressed

* Performance improvements for database workloads

## 1.2.2 Release notes

### Key Features

No new features in 1.2.2. This is a patch release.

### Key Issues Addressed

* Fix device detection in AWS autenticated instances

## 1.2.1 Release notes

### Key Features

No new features in 1.2.1. This is a patch release.

### Key Issues Addressed

* Fix issues with pod failovers with encrypted volumes
* Improve performance with remote volume mounts
* Add compatbility for Linux 4.10+ kernels


## 1.2 Release notes

### Key Features

* [AWS Auto-scaling integration with Portworx](/cloud/aws/asg.html) managing EBS volumes for EC2 instances in AWS ASG 
* [Multi-cloud Backup and Restore](/cloud/backups.html) of Portworx Volumes 
* [Encrypted Volumes](/manage/encrypted-volumes.html) with Data-at-rest and Data-in-flight encryption
* Docker V2 Plugin Support
* [Prometheus Integeration](/maintain/monitoring/prometheus/index.html)
* [Hashicorp Vault](/secrets/portworx-with-vault.html), [AWS KMS integration](/secrets/portworx-with-aws-kms.html) and 
  Docker Secrets Integration
* [Dynamically resize](/manage/volume-update.html#increase-volume-size) PX Volumes with no application downtime
* Security updates improve PX container security

### Key Issues Addressed

* Issues with volume auto-attach
* Improved network diagnostics on PX container start
* Added an alert when volume state transitions to read-only due to loss of quorum
* Display multiple attached hosts on shared volumes
* Improve shared volume container attach when volume is in resync state
* Allow pxctl to run as normal user
* Improved pxctl help text for commands like pxctl service

### Key Notes

## 1.1.6 Release notes

### Key Features

* Volume Aggregation across multiple nodes to provide scale-out performance
* Self Node Decommission provides ability to for node decommission operations from the node itself
* Automatic decomission of storage-less nodes when they join and leave the cluster as part of a auto-scaling group
* Volume auto-attach and detach for fine grained background processing of volume maintenance operations
* Support rack-aware replication to replicate across racks
* Volume aggregation within a rack

### Key Issues Addressed

* Support PX Volume snapshots via docker volume plugin
* Improved stability and tighter integration for Consul based environments
* Latest Amazon Linux and Debian support
* Rancher catalog support for CoreOS

### Key notes
* COS is now referenced as IO Priority


## 1.1.4 Release notes

### Key Changes

Improve node failure and resync handling

## 1.1.3 Release notes

### Key Features

* Shared volumes (or shared namespace support) [Shared Volumes](/manage/shared-volumes.html)
* Scale Volumes support - Create volumes in scale with single command
* Sticky Volumes support - Create volumes with sticky bit so only a pxctl volume delete can delete it
* Improvements in replication performance
* Debian Linux distro and kernel support

## 1.1.2 Release notes

### Key Features
* Support scaling up to 256 nodes
* Enhanced authentication support for etcd
* Support Kubernetes scheduler placement of containers
* Enhancements to Class of Service to improve better detection on different public clouds. 
* Enhanced drive replacement workflows

### Key Issues Addressed
* Prevent volume updates in maintenance mode from happening
* Fixed netstats calculation to resolve the network throughput display issues
* Improve etcd version check handling in cases where the etcd version is not recieved
* Add support for etcd versions between 2.0 to 2.3

### Key notes
* Note that the shared namespace feature is still in beta.

## 1.1.0 Release notes

### Key Features
* Class of Service Support. Refer to [CoS](/manage/class-of-service.html)
* Lighthouse on-prem for airgapped environments. Refer to [Lighthouse on-prem](/enterprise/lighthouse.html)
* Scale up to 125 nodes


### Key Issues Addressed

* Portworx Flexvolume compatibility fixes with latest Kubernetes
* Changes to improve Marathon and Mesos compatibility
* Fixes to improve maintenance mode entry and exit experience
* REST API improvements for Volume status
* REST API improvements for aggregated node status
* Alert message improvements for HA increase operations
* Fix for shared volume detach failures

### Key notes
* Note that the shared namespace feature is still in beta.


## 1.0.9 Release Notes

* Add Amazon ECS Support. Refer to [Portworx-on-ECS](/portworx-on-ecs.html)

## 1.0.8 Release Notes

* Incremental fixes to the pxctl upgrade that showed version mismatch between the CLI and px daemon after upgrades
* Add support for cloud providers like Packet

## 1.0.7 Release Notes

### Key Features
* Continual online drive health monitoring.

### Key Issues addressed
* Fix for Lighthouse reporting some nodes as online when the entire cluster is down.
* Shared volumes can occasionally cause high CPU spikes.  This has been fixed.
* Improvements to the shared volumes throughput.
* Lighthouse had a bug causing occasional incorrect volume to container mapping.  This has been fixed. 
* Password reset in Lighthouse has been fixed.

## 1.0.6 Release Notes

### Key Features 
* Support for Consul
* Ability to add storage to a head-only node
* Ability to import data from an external storage source
* Ability to bootstrap and deploy PX through external automated procedures.  PX takes command line parameters and does not need a config.json. 
* Support for Rancher

### Key Issues addressed 
* Fix for occasional PX node restart.  Occasionaly during heavy load, a PX node would get marked down by gossip, and asked to restart.  While this did not cause any noticable delay in IO, it would flood the logs with gossip error messages.  This bug has been fixed.
* Minor CLI enhancements around displaying IP addresses instead of node IDs (where possible).







