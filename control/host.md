---
layout: page
title: "CLI Reference–Host"
keywords: portworx, pxctl, command-line tool, cli, reference
sidebar: home_sidebar
redirect_from: "/cli-reference.html"
---

* TOC
{:toc}

### Host related operations
```
sudo /opt/pwx/bin/pxctl host --help   
NAME:
   pxctl host - Attach volumes to the host

USAGE:
   pxctl host command [command options] [arguments...]

COMMANDS:
     attach   Attach a volume to the host at a specified path
     detach   Detach a specified volume from the host
     mount    Mount a volume on the host
     unmount  Unmount a volume from the host

OPTIONS:
   --help, -h  show help
```
For the sake of these examples, let us use a volume by name "demovolume" that has just been created using a "volume create" CLI.
```
sudo /opt/pwx/bin/pxctl volume list
ID                      NAME            SIZE    HA      SHARED  ENCRYPTED       IO_PRIORITY     SCALE   STATUS
772733390943400581      demovolume      5 GiB   2       no      no              LOW             1       up - detached
```
#### pxctl host attach
`pxctl host attach` command is used to attach a volume to a host
```
sudo /opt/pwx/bin/pxctl host attach demovolume
Volume successfully attached at: /dev/pxd/pxd772733390943400581
```
Running "volume list" will now show something like:
```
sudo /opt/pwx/bin/pxctl volume list
ID                      NAME            SIZE    HA      SHARED  ENCRYPTED       IO_PRIORITY     SCALE   STATUS
772733390943400581      demovolume      5 GiB   2       no      no              LOW             1       up - attached on 172.31.46.119 *
* Data is not local to the node on which volume is attached.
```
Note: The volume resides on 2 different nodes than the one where it was attached in the above example. Hence the warning.

For an encrypted volume, if you are not using the cluster secret pass in '--secret_key &lt;key&gt;'. Otherwise the cluster secret key will be used.
```
sudo /opt/pwx/bin/pxctl host attach cliencr
Volume successfully attached at: /dev/mapper/pxd-enc1013237432577873530
```

If you are trying to attach an encrypted volume and if the node in which the encrypted volume is being attached to is not authenticated with the secrets endpoint, then you will get the following error message

```
sudo /opt/pwx/bin/pxctl host attach  vol3
attach: Not authenticated with the secrets endpoint
```
Ensure that the node is authenticated with the secretes endpoint. Refer to the Encrypted Volumes section.

#### pxctl host detach
`pxctl host detach` command is used to detach a volume from a host
```
sudo /opt/pwx/bin/pxctl host detach demovolume
Volume successfully detached
```
Running "volume list" will now show something like:
```
sudo /opt/pwx/bin/pxctl volume list
ID                      NAME            SIZE    HA      SHARED  ENCRYPTED       IO_PRIORITY     SCALE   STATUS
772733390943400581      demovolume      5 GiB   2       no      no              LOW             1       up - detached
```
#### pxctl host mount
`pxctl host mount` mounts a volume locally on a node at a path, say /mnt/demodir
```
sudo /opt/pwx/bin/pxctl host mount demovolume /mnt/demodir
Volume demovolume successfully mounted at /mnt/demodir
```
Running "volume list" will now show something like:
```
sudo /opt/pwx/bin/pxctl volume list
ID                      NAME            SIZE    HA      SHARED  ENCRYPTED       IO_PRIORITY     SCALE   STATUS
772733390943400581      demovolume      5 GiB   2       no      no              LOW             1       up - attached on 172.31.46.119 *
* Data is not local to the node on which volume is attached.
```
and running "volume inspect" on this volume will show something like:
```
sudo /opt/pwx/bin/pxctl volume inspect demovolume
Volume  :  772733390943400581
        Name                     :  demovolume
        Size                     :  5.0 GiB
        Format                   :  ext4
        HA                       :  2
        IO Priority              :  LOW
        Creation time            :  Feb 27 22:27:36 UTC 2017
        Shared                   :  no
        Status                   :  up
        State                    :  Attached: 5f8b8417-af2b-4ea7-930e-0027f6bbcbd1
        Device Path              :  /dev/pxd/pxd772733390943400581
        Reads                    :  65
        Reads MS                 :  57
        Bytes Read               :  487424
        Writes                   :  1
        Writes MS                :  1
        Bytes Written            :  4096
        IOs in progress          :  0
        Bytes used               :  211 MiB
        Replica sets on nodes:
                Set  0
                        Node     :  172.31.35.130
                        Node     :  172.31.39.201
```
#### pxctl host unmount
`pxctl host unmount` unmounts a volume from a host
```
sudo /opt/pwx/bin/pxctl host unmount demovolume /mnt/demodir
Volume demovolume successfully unmounted at /mnt/demodir
```
