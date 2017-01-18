---
layout: page
title: "Manage MySQL Database Volumes with Portworx"
keywords: portworx, container, mysql, storage
sidebar: home_sidebar
---
## Watch the video
Here is a three-minute video that shows how to set up a three-node cluster for mysql and add more capacity on the fly:
<iframe src="https://player.vimeo.com/video/163637386" width="500" height="281" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>

## Step 1: Create a storage volume for mysql

To create a storage volume for mysql, run the following command and note the returned volume ID. You will need the volume ID when you start the mysql container in the next step.

```
# docker volume create -d pxd --name mysql_volume --opt \
        size=4 --opt block_size=64 --opt repl=1 --opt fs=ext4
```

That command creates a volume to attach to the mysql_volume container, which stores its data in the /var/lib/mysql directory. Use the Docker `-v` option to attach the Portworx volume to this directory.

## Step 2: Start the mysql container

To start the mysql container, run the following command. 

```
# docker run -p 3306:3306 --volume-driver=pxd               \
        --name pxmysql  --host                      \
        -e MYSQL_ROOT_PASSWORD=password     \
        -v mysql_volume:/var/lib/mysql -d mysql
```

Your mysql container is now available for use at port 3306.

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
