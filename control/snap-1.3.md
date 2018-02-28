---
layout: page
title: "CLI Reference–Snapshots"
keywords: portworx, pxctl, command-line tool, cli, reference
sidebar: home_sidebar
redirect_from: "/cli-reference.html"
meta-description: "Explore the CLI reference guide for taking snapshots of container data volumes using Portworx. Try it today!"
---

* TOC
{:toc}

### Snapshot Operations
```
# pxctl volume snapshot -h
NAME:
   pxctl volume snapshot - Manage volume snapshots

USAGE:
   pxctl volume snapshot command [command options] [arguments...]

COMMANDS:
     create, c  Create a volume snapshot

OPTIONS:
   --help, -h  show help
```

#### pxctl volume snaphot create

`pxctl volume snapshot create` creates a snapshot of a volume.
```
# pxctl volume snapshot create --name mysnap --label color=blue,fabric=wool myvol
Volume snap successful: 234835613696329810
```
The label values allow you to tag the snapshot. You can use them to filter the output of the `pxctl volume list` command

#### pxctl volume list

User created snapshots can be listed using one of the following ways
```
# pxctl volume list --all
ID          NAME                                    SIZE    HA  SHARED  ENCRYPTED   COMPRESSED  IO_PRIORITY SCALE   STATUS
234835613696329810  mysnap                                  1 GiB   1   no  no      no      LOW     1   up - detached
1125771388930868153 myvol                                   1 GiB   1   no  no      no      LOW     1   up - detached
```
(or)
```
# pxctl volume list --snapshot
ID          NAME                                    SIZE    HA  SHARED  ENCRYPTED   COMPRESSED  IO_PRIORITY SCALE   STATUS
234835613696329810  mysnap                                  1 GiB   1   no  no      no      LOW     1   up - detached
```

All scheduled snapshots can be listed using  --snapshot-schedule option.
```
# pxctl volume list --snapshot-schedule
ID          NAME                                    SIZE    HA  SHARED  ENCRYPTED   COMPRESSED  IO_PRIORITYSCALE    STATUS
423119103642927058  myvol_periodic_2018_Feb_26_21_12                    1 GiB   1   no  no      no      LOW     1up - detached
```

You can filter the results with the --parent and --label options. For instance, --parent myvol will show only snapshots whose parent is myvol, i.e., mysnap in this example.
Giving labels restricts the list to snapshots that have all of the specified labels. For instance, --label fabric=wool would again show mysnap but --label fabric=cotton would produce an empty list.
```
# pxctl volume list --parent myvol --snapshot
ID          NAME    SIZE    HA  SHARED  ENCRYPTED   COMPRESSED  IO_PRIORITY SCALE   STATUS
234835613696329810  mysnap  1 GiB   1   no  no      no      LOW     1   up - detached

# pxctl volume list --parent myvol --snapshot --label fabric=wool
ID          NAME    SIZE    HA  SHARED  ENCRYPTED   COMPRESSED  IO_PRIORITY SCALE   STATUS
234835613696329810  mysnap  1 GiB   1   no  no      no      LOW     1   up - detached
```

#### pxctl volume delete

`pxctl volume delete` deletes snapshots. The argument is the name or ID of the snapshot that you wish to delete. The snapshot must be detached in order to delete it.
```
# pxctl volume delete mysnap
Delete volume 'mysnap', proceed ? (Y/N): y
Volume mysnap successfully deleted.
```
