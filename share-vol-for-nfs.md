---
layout: page
title: "Create PX volume for NFS share"
keywords: portworx, px-developer, px-enterprise, install, configure, nfs, storage, share, volume
sidebar: home_sidebar
---

This guide demonstrate creating a shared docker volume from PX and share it via NFS.
In this setup, PX containers are running on three nodes (suse01, suse04, susue05).
And the nfs clients are kabo1, kabo21. 

#### Create a shared volume using pxctl (do this on one of PX containers node e.g.  suse01).

```
   /opt/pwx/bin/pxctl volume create my_shared_vol --shared --size=5 --repl=3

```

#### Attach the shared volume on one of the node running PX containers.

```
   /opt/pwx/bin/pxctl host attach my_shared_vol

```

#### Mount the shared volume locally using "pxctl host mount" on three of those nodes running PX containers.
   
on suse01 node

```
   mkdir -p /var/lib/osd/mounts/my_shared_vol_suse01
   /opt/pwx/bin/pxctl host mount  my_shared_vol /var/lib/osd/mounts/my_shared_vol_suse01

```    

on suse04 node

```
   mkdir -p /var/lib/osd/mounts/my_shared_vol_suse04
   /opt/pwx/bin/pxctl host mount  my_shared_vol /var/lib/osd/mounts/my_shared_vol_suse04

```
on suse05 node

```   
   mkdir -p /var/lib/osd/mounts/my_shared_vol_suse05
   /opt/pwx/bin/pxctl host mount  my_shared_vol /var/lib/osd/mounts/my_shared_vol_suse05

```   

Use "df -kh" to check if shared volume is mounted on your specified mount point.

```   
   df -kh
   Filesystem      Size  Used Avail Use% Mounted on
   pxfs            4.8G   20M  4.6G   1% /var/lib/osd/mounts/my_shared_vol_suse04

```   
   
#### Display the shared volume from pxctl volume list showing status is attached on.

```
   /opt/pwx/bin/pxctl volume list
   ID                      NAME            SIZE    HA      SHARED  ENCRYPTED       PRIORITY        STATUS
   689753078804469955      my_shared_vol   5 GiB   3       yes     no              LOW             up - attached on 10.201.100.155

```

#### On the nodes suse01,04,05 edit /etc/exports and restart nfs server.

Below is the example of  /etc/exports  on node "suse01"

```
   /var/lib/osd/mounts/my_shared_vol_suse01        *(rw,no_root_squash,sync,no_subtree_check,fsid=0)

```

#### Verify nfs exports are observed from client node kabo1.

```
   [root@kabo1 ~]# for h in suse01 suse04 suse05; do showmount -e $h ; done
   Export list for suse01:    /var/lib/osd/mounts/my_shared_vol_suse01 *
   Export list for suse04:    /var/lib/osd/mounts/my_shared_vol_suse04 *
   Export list for suse05:    /var/lib/osd/mounts/my_shared_vol_suse05 *

```

#### Create three mount points on both kabo1, kabo2 and mount the nfs exports from three PX container hosts suse01, suse04, suse05.

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

#### Write a file on each nfs mount on both kabo1 and kabo2

```

   [root@kabo1 ~]# for h in 1 4 5 ; do echo "This is a test file 0$h" > /mnt/testmount$h/test-kabo1-file0$h ; done
   [root@kabo2 ~]# for h in 1 4 5 ; do echo "This is another test file 0$h" > /mnt/testmount$h/test-kabo2-file0$h ; done

```

Verify files content on both kabo1, kabo2 

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
