---
layout: page
title: "Snapshot Reference"
keywords: portworx, pxctl, snapshot, reference
sidebar: home_sidebar
---
Snapshots are efficient point-in-time copies of volumes.  They can
be either read-write or read-only.  Each snapshot is a volume in its
own right and can be used freely by applications.  They are implemented
using a copy-on-write technique that means that they only use space in
places where they differ from their parent volume.

Snapshots are managed through `pxctl` commands.  They can be created
by explicit commands or through a schedule that is set for the volume.

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
```
NAME:
   pxctl snap create - Create a volume snapshot

USAGE:
   pxctl snap create [command options] [arguments...]

OPTIONS:
   --name value             user friendly name
   --label value, -l value  Comma separated name=value pairs, e.g name=sqlvolume,type=production
   --readonly               true if snapshot is readonly
```

To create a snapshot, you must specify a parent volume from which
it is effectively copied.  The implementation shares data between
the parent and the snapshot until one or the other changes, so no 
actual copying occurs during creation.  The snapshot is writable
by default, but you can make it read-only.  You can give it a name,
which you can subsequently use in `pxctl volume` and `pxctl snap`
commands in place of the multi-digit volume ID.  If you omit the
name, a name of the form `<parent-ID>.snap-<creation-time>`
is assigned, e.g.,
```
593988376247244600.snap-2016-12-12T13:59:17.952372744-08:00
```
Labels allow you to tag the snapshot with descriptive attributes
of your choosing.  You can supply a list of labels to the
`pxctl snap list` command to filter the snapshots that are
displayed.

Each snapshot is a volume and can be used like any other volume.
For instance, you can attach it and can create snapshots of it.
However, snapshots do not appear in the output of `pxctl volume list`,
but only in `pxctl snap list`.  There is an implementation limit
of 64 snapshots per volume, and a volume must be attached in
order to create a snapshot of it.

### Snapshot schedules

In addtion to creating snapshots explicitly with the ``pxctl snap
create`` command, you can create them automatically according to a
per-volume schedule.  There are four scheduling options, which can
be combined as desired.  A daily snapshot is created every day at
a specified time, a weekly snapshot is created on a specified day
of the week, and a monthly snapshot is created on a specified day
of the month.  Finally, you can specify that snapshots should be
created at a fixed interval, say every 60 minutes.  The example below
sets a schedule of daily snapshots at 8:00 a.m. and 6:00 p.m., a
weekly snapshot on Friday at 11:30 p.m., and a monthly snapshot on
the 1st of the month at 6:00 a.m.
```
pxctl volume create --daily @08:00 --daily@18:00 --weekly Friday@23:30 --monthly 1@06:00 myvol
```
Interval-based snapshots are set with the `--snap_interval` option.
As a special case `--snap_interval 0` removes any current snapshot
schedule.

The snapshot schedule can be changed with the
`pxctl volume snap-interval-update` command.  It accepts the
same scheduling arguments as the create command.  If a schedule
is set, the `pxctl volume inspect` command will display it.
The scheduled snapshots have names of the form
`<parent-ID>_sched_<creation_time>`, for example
```
593988376247244600_sched_2016-12-12T18:00:53-08:00
```
There is an implementation limit of five scheduled snapshots per
volume.  When a new scheduled snapshot is created, the oldest
existing one will be deleted if necessary to keep the total
under five.
