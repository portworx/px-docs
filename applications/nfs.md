---
layout: page
title: "Create PX volume for NFS share"
keywords: portworx, px-developer, px-enterprise, install, configure, nfs, storage, share, volume
sidebar: home_sidebar
redirect_from: "/share-vol-for-nfs.html"
meta-description: "Learn to create a shared docker volume using Portworx and share it via NFS. Access the same volume from multiple containers today!"
---

* TOC
{:toc}

This guide explains how to share a PX volume externally via NFS.
In this setup, PX containers are running on three nodes suse01, suse04, suse05.  The nfs clients are kabo1, kabo2. 

Step 1. Create a shared volume using pxctl. For example:

```
$ /opt/pwx/bin/pxctl volume create my_shared_vol --shared --size=5 --repl=3
```

Step 2. Attach the shared volume on any one of the PX nodes.

```
$ /opt/pwx/bin/pxctl host attach my_shared_vol

```

Step 3. Mount the shared volume locally using the `pxctl host mount` command on the PX nodes.
   
on the suse01 node

```
$ mkdir -p /var/lib/osd/mounts/my_shared_vol_suse01
$ /opt/pwx/bin/pxctl host mount  my_shared_vol /var/lib/osd/mounts/my_shared_vol_suse01

```    

>**Note**<br/>The target path must be a path that is shared with the PX container.  Typically this would be any path under `/var/lib/osd/`.

on the suse04 node

```
$ mkdir -p /var/lib/osd/mounts/my_shared_vol_suse04
$ /opt/pwx/bin/pxctl host mount  my_shared_vol /var/lib/osd/mounts/my_shared_vol_suse04

```
on the suse05 node

```   
$ mkdir -p /var/lib/osd/mounts/my_shared_vol_suse05
$ /opt/pwx/bin/pxctl host mount  my_shared_vol /var/lib/osd/mounts/my_shared_vol_suse05
```   

Use "df -kh" to check ensure that the volume has been mounted.

```   
$ df -kh
  Filesystem      Size  Used Avail Use% Mounted on
  pxfs            4.8G   20M  4.6G   1% /var/lib/osd/mounts/my_shared_vol_suse04
```   

Step 4. On nodes suse01,04,05 edit `/etc/exports` and restart the nfs server.

Below is an example of `/etc/exports`  on node "suse01"

```
 /var/lib/osd/mounts/my_shared_vol_suse01        *(rw,no_root_squash,sync,no_subtree_check,fsid=0)
```

Step 5. Verify that the nfs exports can be seen from the client node kabo1.

```
[root@kabo1 ~]# for h in suse01 suse04 suse05; do showmount -e $h ; done
   Export list for suse01:    /var/lib/osd/mounts/my_shared_vol_suse01 *
   Export list for suse04:    /var/lib/osd/mounts/my_shared_vol_suse04 *
   Export list for suse05:    /var/lib/osd/mounts/my_shared_vol_suse05 *

```

Step 6. Create the mount points on both kabo1, kabo2 and mount the nfs exports from the PX container hosts suse01, suse04, suse05.

```
[root@kabo1 ~]# for m in 1 4 5; do mkdir -p /mnt/testmount$m ; done
[root@kabo2 ~]# for m in 1 4 5; do mkdir -p /mnt/testmount$m ; done

[root@kabo1 ~]# for m in 1 4 5; do mount -t nfs suse0$m:/var/lib/osd/mounts/my_shared_vol_suse0$m /mnt/testmount$m ; done
[root@kabo2 ~]# for m in 1 4 5; do mount -t nfs suse0$m:/var/lib/osd/mounts/my_shared_vol_suse0$m /mnt/testmount$m ; done

[root@kabo1 ~]# df -kh
   Filesystem                                       Size  Used Avail Use% Mounted on
   suse01:/var/lib/osd/mounts/my_shared_vol_suse01  4.8G   20M  4.6G   1% /mnt/testmount1
   suse04:/var/lib/osd/mounts/my_shared_vol_suse04  4.8G   20M  4.6G   1% /mnt/testmount4
   suse05:/var/lib/osd/mounts/my_shared_vol_suse05  4.8G   20M  4.6G   1% /mnt/testmount5

[root@kabo2 ~]# df -kh    
   Filesystem                                       Size  Used  Avail Use% Mounted on
   suse01:/var/lib/osd/mounts/my_shared_vol_suse01  4.8G   20M  4.6G   1% /mnt/testmount1
   suse04:/var/lib/osd/mounts/my_shared_vol_suse04  4.8G   20M  4.6G   1% /mnt/testmount4
   suse05:/var/lib/osd/mounts/my_shared_vol_suse05  4.8G   20M  4.6G   1% /mnt/testmount5

```

Step 7. Test the NFS share

Write a file on each nfs mount

```
[root@kabo1 ~]# for h in 1 4 5 ; do echo "This is a test file 0$h" > /mnt/testmount$h/test-kabo1-file0$h ; done
   
[root@kabo2 ~]# for h in 1 4 5 ; do echo "This is another test file 0$h" > /mnt/testmount$h/test-kabo2-file0$h ; done

```

Verify the file contents on both kabo1, kabo2 

```  
[root@kabo1 ~]# for h in 1 4 5 ; do cat /mnt/testmount$h/test-kabo1-file0$h ; done
   This is a test file 01
   This is a test file 04
   This is a test file 05

[root@kabo1 ~]# for h in 1 4 5 ; do cat /mnt/testmount$h/test-kabo2-file0$h ; done
   This is another test file 01
   This is another test file 04
   This is another test file 05

[root@kabo2 ~]# for h in 1 4 5 ; do cat /mnt/testmount$h/test-kabo1-file0$h ; done
   This is a test file 01
   This is a test file 04
   This is a test file 05

[root@kabo2 ~]# for h in 1 4 5 ; do cat /mnt/testmount$h/test-kabo2-file0$h ; done
   This is another test file 01
   This is another test file 04
   This is another test file 05

```

Listing each NFS volume from both kabo1 and kabo2
   
```

    [root@kabo2 ~]# for h in 1 4 5 ; do ls -al /mnt/testmount$h ; done
    total 28   drwxr-xr-x. 2 root root 4096 Dec 22 15:22 .   
    drwxr-xr-x. 5 root root   57 Dec 22 15:00 ..   
    -rw-r--r--. 1 root root   23 Dec 22 15:10 test-kabo1-file01
    -rw-r--r--. 1 root root   23 Dec 22 15:10 test-kabo1-file04
    -rw-r--r--. 1 root root   23 Dec 22 15:10 test-kabo1-file05
    -rw-r--r--. 1 root root   29 Dec 22 15:14 test-kabo2-file01
    -rw-r--r--. 1 root root   29 Dec 22 15:14 test-kabo2-file04
    -rw-r--r--. 1 root root   29 Dec 22 15:14 test-kabo2-file05
 
    total 28    drwxr-xr-x. 2 root root 4096 Dec 22 15:22 .
    drwxr-xr-x. 5 root root   57 Dec 22 15:00 ..
    -rw-r--r--. 1 root root   23 Dec 22 15:10 test-kabo1-file01
    -rw-r--r--. 1 root root   23 Dec 22 15:10 test-kabo1-file04
    -rw-r--r--. 1 root root   23 Dec 22 15:10 test-kabo1-file05
    -rw-r--r--. 1 root root   29 Dec 22 15:14 test-kabo2-file01
    -rw-r--r--. 1 root root   29 Dec 22 15:14 test-kabo2-file04
    -rw-r--r--. 1 root root   29 Dec 22 15:14 test-kabo2-file05
 
    total 28   drwxr-xr-x. 2 root root 4096 Dec 22 15:22 .
    drwxr-xr-x. 5 root root   57 Dec 22 15:00 ..   
    -rw-r--r--. 1 root root   23 Dec 22 15:10 test-kabo1-file01
    -rw-r--r--. 1 root root   23 Dec 22 15:10 test-kabo1-file04
    -rw-r--r--. 1 root root   23 Dec 22 15:10 test-kabo1-file05
    -rw-r--r--. 1 root root   29 Dec 22 15:14 test-kabo2-file01
    -rw-r--r--. 1 root root   29 Dec 22 15:14 test-kabo2-file04
    -rw-r--r--. 1 root root   29 Dec 22 15:14 test-kabo2-file05 
```
