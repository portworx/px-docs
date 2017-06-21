---
layout: page
title: "CLI Reference–Snapshots"
keywords: portworx, pxctl, command-line tool, cli, reference
sidebar: home_sidebar
redirect_from: "/cli-reference.html"
---

* TOC
{:toc}

### Snapshot Operations
```
sudo /opt/pwx/bin/pxctl snap --help
NAME:
   pxctl snap - Manage volume snapshots

USAGE:
   pxctl snap command [command options] [arguments...]

COMMANDS:
     create, c  Create a volume snapshot
     list, l    List volume snapshots in the cluster
     delete, d  Delete a volume snapshot

OPTIONS:
   --help, -h  show help
```
#### pxctl snapshot create
`pxctl snapshot create` creates a snapshot of a volume. The different options and ways to use are shown below:
```
sudo /opt/pwx/bin/pxctl snap create vQuorum1 --name Snap1_on_vQuorum1 --label temp=true,cluster=devops
Volume successfully snapped: 376113877104406866
sudo /opt/pwx/bin/pxctl snap create vQuorum1 --name Snap2_on_vQuorum1 --label temp=true,cluster=production
Volume successfully snapped: 1097649911014990908
sudo /opt/pwx/bin/pxctl snap create vQuorum1 --name Snap3_on_vQuorum1 --label temp=false,cluster=production --readonly
Volume successfully snapped: 118252956373660375
```
* Examples 1, 2 show how could you use labels which can then be used to filter your snapshot list in the display
* Example 3 shows how to make a snapshot readonly

#### pxctl snapshot list
`pxctl snapshot list` lists all snapshots:
```
sudo /opt/pwx/bin/pxctl snap list
ID                      NAME                    SIZE    HA      SHARED  ENCRYPTED       IO_PRIORITY     SCALE   STATUS
376113877104406866      Snap1_on_vQuorum1       50 GiB  2       no      no              LOW             1       up - detached
1097649911014990908     Snap2_on_vQuorum1       50 GiB  2       no      no              LOW             1       up - detached
118252956373660375      Snap3_on_vQuorum1       50 GiB  2       no      no              LOW             1       up - detached
```
To list snapshots based on filter values:
```
sudo /opt/pwx/bin/pxctl snap list --label temp=true
ID                      NAME                    SIZE    HA      SHARED  ENCRYPTED       IO_PRIORITY     SCALE   STATUS
376113877104406866      Snap1_on_vQuorum1       50 GiB  2       no      no              LOW             1       up - detached
1097649911014990908     Snap2_on_vQuorum1       50 GiB  2       no      no              LOW             1       up - detached
sudo /opt/pwx/bin/pxctl snap list --label cluster=devops
ID                      NAME                    SIZE    HA      SHARED  ENCRYPTED       IO_PRIORITY     SCALE   STATUS
376113877104406866      Snap1_on_vQuorum1       50 GiB  2       no      no              LOW             1       up - detached
```
#### pxctl snapshot delete
`pxctl snapshot delete` deletes snapshots (make sure they are detached through host commands):
```
sudo /opt/pwx/bin/pxctl snap delete Snap3_on_vQuorum1
Snapshot Snap3_on_vQuorum1 successfully deleted.
```
