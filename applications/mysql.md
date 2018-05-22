---
layout: page
title: "Manage MySQL Database Volumes with Portworx"
keywords: portworx, container, mysql, storage
sidebar: home_sidebar
redirect_from: "/mysql.html"
meta-description: "Check out this three minute video illustrating how to set up a three-node cluster for mysql and add more capacity on the fly."
---

* TOC
{:toc}

## Watch the video
Here is a three-minute video that shows how to set up a three-node cluster for mysql and add more capacity on the fly:
{% include vimeoPlayer.html id='163637386' %}


## Step 1: Run `mysql` with storage on demand

The command below runs `mysql` and dynamically creates the `mysqlvol` volume, 
with a size of 3G, with 3 replicas (data protected on 3 separate nodes), and with an I/O profile of `db`:

```
docker run --name pxmysql --volume-driver=pxd  \
           -v name=mysqlvol,size=3,repl=3,io_profile=db:/var/lib/mysql \
           -e MYSQL_ROOT_PASSWORD=password -d mysql:5.7.22
```

Note the volume binding done via `-v mysqlvol:/var/lib/mysql`.  This causes the Portworx `mysqlvol` to get bind mounted at `/var/lib/mysql`, which is where the `mysql` Docker container stores it's data.

Also note the returned Container-ID

## Step 2: Use `pxctl` to create snaps of your mysql volume

To demonstrate the capabilities of the SAN-like functionality offered by Portworx, create a snapshot of a mysql volume.

1. Create a database and a demo table in your mysql container.

```
docker exec -it <Container-ID> mysql -uroot -ppassword
[...]
mysql> create database pxdemo;
Query OK, 1 row affected (0.00 sec)
mysql> use pxdemo;
Database changed
mysql> create table grapevine (counter int unsigned);
Query OK, 0 rows affected (0.04 sec)
mysql> quit;
Bye
```

2. Create a snapshot/clone of this database using `pxctl`.

```
[root@test1 ~]# /opt/pwx/bin/pxctl volume clone --name mysql_clone mysqlvol
Volume clone successful: 858723406642053867
[root@test1 ~]# /opt/pwx/bin/pxctl volume list
ID            NAME        SIZE    HA    SHARED    ENCRYPTED    COMPRESSED    IO_PRIORITY    SCALE    STATUS
858723406642053867    mysql_clone    3 GiB    3    no    no        no        LOW        1    up - detached
972935509867294516    mysqlvol    3 GiB    3    no    no        no        LOW        0    up - attached on 70.0.164.113
```

3. Start another instance of `mysql` using the volume clone just taken.  

```
docker run --volume-driver=pxd                  \
            --name pxmysqlclone                              \
            -e MYSQL_ROOT_PASSWORD=password                  \
            -v mysql_clone:/var/lib/mysql -d mysql:5.7.22
```

Note the returned Container-ID

4. Verify that the database shows the cloned tables in the new mysql instance.

```
[root@test1 ~]# docker exec -it <Container-ID> mysql -uroot -ppassword
[...]
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| pxdemo             |
| sys                |
+--------------------+
5 rows in set (0.01 sec)

mysql> use pxdemo;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> show tables;
+------------------+
| Tables_in_pxdemo |
+------------------+
| grapevine        |
+------------------+
1 row in set (0.00 sec)

mysql>
```
