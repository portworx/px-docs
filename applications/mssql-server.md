---
layout: page
title: "Microsoft SQL Server Database on Portworx"
keywords: portworx, container, microsoft, sqlserver, storage
sidebar: home_sidebar
youtubeId: G3Lp1RgWdKg
---

* TOC
{:toc}

## Watch the video
In this five-minute hands-on video, you’ll learn how simple it is to run Microsoft SQL Server 
in containers with Portworx. For the first time, you’ll get the availability, durability, 
and recoverability that enterprises expect when running containerized SQL.
{% include youtubePlayer.html id=page.youtubeId %}


## Step 1: Run SQL Server with Portworx storage on demand

To create a highly available storage volume for SQL Server, without having to provision storage in advance,
run the following command:

```
docker run -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=P@ssw0rd' \
      -p 1433:1433 --volume-driver=pxd \
      -v name=mssqlvol,size=10,repl=3:/var/opt/mssql \
      -d microsoft/mssql-server-linux
```

This command runs `mssql-server-linux` with a 10 GB volume created dynamically on the fly with 3-way replication, 
which guarantees that the data will be protected on 3 separate nodes. 

The mssql-server container is now accessible remotely at port 1433.

## Step 2: Access SQL Server



## Step 3: Use `pxctl` to create snaps of your mysql volume

To demonstrate the capabilities of the SAN-like functionality offered by Portworx, create a snapshot of a mysql volume.

1. Create a database and a demo table in your mysql container.

   ```
# mysql --user=root --password=password
MySQL [(none)]> create database pxdemo;
Query OK, 1 row affected (0.00 sec)
MySQL [(none)]> use pxdemo;
Database changed
MySQL [pxdemo]> create table grapevine (counter int unsigned);
Query OK, 0 rows affected (0.04 sec)
MySQL [pxdemo]> quit;
Bye
```

2. Create a snapshot of this database using `pxctl`.

   ```
# /opt/pwx/bin/pxctl snap create 8927336170128555
Volume successfully snapped:  1483421664452964115
```

3. Note the snapshot volume ID.  Use this to launch a new instance of mysql.  Since you already have mysql running, you can go to another node in your cluster, or stop the original mysql instance.

   ```
# docker run -p 3306:3306 --volume-driver=pxd 				\
                        --name pxmysqlclone                 \
                        -e MYSQL_ROOT_PASSWORD=password     \
                        -v 1483421664452964115:/var/lib/mysql -d mysql
```

4. Verify that the database shows the cloned tables in the new mysql instance.

```
# mysql --user=root --password=password
MySQL [(none)]> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| pxdemo             |
| sys                |
+--------------------+
5 rows in set (0.00 sec)
MySQL [(none)]> use pxdemo;

Database changed
MySQL [pxdemo]> show tables;
+------------------+
| Tables_in_pxdemo |
+------------------+
| grapevine        |
+------------------+
1 rows in set (0.00 sec)
```

## See Also
For futher reading on Microsoft SQL Server on Linux, 
please visit the [SQL Server on Docker](https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-setup-docker#a-idpersista-persist-your-data) documentation
