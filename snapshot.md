---
layout: page
title: "Snapshot Reference"
keywords: portworx, pxctl, snapshot, reference
sidebar: home_sidebar
---

Snapshots are efficient point-in-time copies of volumes that can
be either read-write or read-only.  Each snapshot is a volume in its
own right and can be used freely by applications.  They are implemented
using a copy-on-write technique, so that they only use space in places
where they differ from their parent volume.  Snapshots can be created
explicitly by `pxctl snap create` commands or through a schedule that
is set on the volume.

## `pxctl` snapshot commands

Snapshots are managed with the `pxctl snap` command.

```
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

### Snapshot creation
Use `pxctl snap create` to make a new snapshot of a volume.
A typical example looks like this:

```
# pxctl snap create --name mysnap --label color=blue,fabric=wool myvol
Volume successfully snapped: 1152602487227170184
```

The parent volume, `myvol`, must be attached for this command
to succeed.

The string of digits in the output is the volume ID of the new
snapshot.  You can use this ID or the name, `mysnap`, to refer
to the snapshot in subsequent `pxctl` commands.  The label values
allow you to tag the snapshot with descriptive information of
your choosing.  You can use them to filter the output of the
`pxctl snap list` command, as described below.

Here is the synopsis for `pxctl snap create`:

```
NAME:
   pxctl snap create - Create a volume snapshot

USAGE:
   pxctl snap create [command options] [arguments...]

OPTIONS:
   --name value             user friendly name
   --label value, -l value  Comma separated name=value pairs, e.g. name=sqlvolume,type=production
   --readonly               true if snapshot is readonly
```

The argument is the name or ID of the parent volume on which
the snapshot is based.  By default, the snapshot will be writable,
but you can make it read-only with the `--readonly` option.  If
you omit the `--name` option, a default name is assigned.  Its
format is `<parent-ID>.snap-<creation-time>`, for example,

```
593988376247244600.snap-2016-12-12T13:59:17.952372744-08:00
```

Each snapshot is a volume and can be used like any other volume.
For instance, you can attach it and can create snapshots of it:
```
# pxctl host attach mysnap
Volume successfully attached at: /dev/pxd/pxd1152602487227170184
# pxctl snap create --name mysnap_jr mysnap
Volume successfully snapped: 1312421116276761727
```
However, snapshots do not appear in the output of `pxctl volume list`.
To list them, use `pxctl snap list`. As with other volumes, you can
use `pxctl volume inspect` to see more detailed information.

There is an implementation limit of 64 snapshots per volume.

### Listing snapshots

```
NAME:
   pxctl snap list - List volume snapshots in the cluster

USAGE:
   pxctl snap list [command options] [arguments...]

OPTIONS:
   --parent value           parent volume ID
   --label value, -l value  Comma separated name=value pairs, e.g name=sqlvolume,type=production
```

If you run this command with no options, you get a list of all snapshots,
with information about their attributes:

```
# pxctl snap list
ID                   NAME       SIZE   HA  SHARED  STATUS
1152602487227170184  mysnap     1 GiB  1   no      up - attached on 10.0.2.15
1312421116276761727  mysnap_jr  1 GiB  1   no      up - detached
```

You can filter the results with the `--parent` and `--label`
options.  For instance, `--parent myvol` will show only snapshots
whose parent is `myvol`, i.e., `mysnap` in this example.  Giving
labels restricts the list to snapshots that have all of the
specified labels.  For instance, `--label fabric=wool` would
again show `mysnap` but `--label fabric=cotton` would produce
an empty list.

### Deleting snapshots

```
NAME:
   pxctl snap delete - Delete a volume snapshot

USAGE:
   pxctl snap delete [arguments...]
```

The argument is the name or ID of the snapshot that you wish to delete.
The snapshot must be detached in order to delete it.

### Snapshot schedules

In addtion to creating snapshots explicitly with the ``pxctl snap
create`` command, you can create them automatically according to a
per-volume schedule.  There are four scheduling options, which you
can combine as desired.  A daily snapshot is created every day at
a specified time, a weekly snapshot is created on a specified day
of the week, and a monthly snapshot is created on a specified day
of the month.  Finally, you can specify that snapshots should be
created at a fixed interval, say every 60 minutes.  The example below
sets a schedule of daily snapshots at 8:00 a.m. and 6:00 p.m., a
weekly snapshot on Friday at 11:30 p.m., and a monthly snapshot on
the 1st of the month at 6:00 a.m.

```
pxctl volume create --daily @08:00 --daily @18:00 --weekly Friday@23:30 --monthly 1@06:00 myvol
```

Interval-based snapshots are set with the `--snap_interval` option.
As a special case `--snap_interval 0` removes any current snapshot
schedule.

The snapshot schedule can be changed with the
`pxctl volume snap-interval-update` command.  It accepts the
same scheduling arguments as the create command:

```
# pxctl volume snap-interval-update --daily @15:00 myvol
```

If a schedule is set, `pxctl volume inspect` will display it:

```
# pxctl volume inspect tester
Volume    :  593988376247244600
    Name                 :  tester
    Size                 :  1.0 GiB
    Format               :  ext4
    HA                   :  1
    IO Priority          :  LOW
    Snapshot             :  daily @15:00
    Shared               :  no
    Status               :  up
    State                :  Attached: b9289d88-229b-4c49-b1d1-497a84a37acf
    Device Path          :  /dev/pxd/pxd593988376247244600
    Reads                :  60
    Reads MS             :  69
    Bytes Read           :  466944
    Writes               :  0
    Writes MS            :  0
    Bytes Written        :  0
    IOs in progress      :  0
    Bytes used           :  33 MiB
    Replica sets on nodes:
        Set  0
            Node      :  10.0.2.15
```

Scheduled snapshots have names of the form
`<parent-ID>_sched_<creation_time>`, for example

```
593988376247244600_sched_2016-12-12T18:00:53-08:00
```

There is an implementation limit of five scheduled snapshots per
volume.  When a new scheduled snapshot is created, the oldest
existing one will be deleted if necessary to keep the total
under five.
