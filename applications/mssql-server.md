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
which guarantees that persistent data will be fully replicated on 3 separate nodes for the highest availability. 

The mssql-server container is now accessible remotely at port 1433.

## Step 2: Access SQL Server

To access via `docker exec`:

```
docker exec -it <Container ID> /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "P@ssw0rd" '
```

[Download](https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-setup-tools) `sqlcmd` utility.
Then access the `mssql-server` via:

```
sqlcmd -S 10.3.2.4 -U SA -P "P@ssw0rd"
```
where 10.3.2.4 is the IP address of the host.


To access via other client frameworks:


## Step 3: Use `pxctl` to create recoverable snapshots of your volume



## See Also
For futher reading on Microsoft SQL Server on Linux, 
please visit the [SQL Server on Docker](https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-setup-docker#a-idpersista-persist-your-data) documentation
