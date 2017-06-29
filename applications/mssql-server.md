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
and recoverability that enterprises expect when running containerized SQL Server
<br>
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

`OR` [Download the `sqlcmd` utility](https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-setup-tools).
Then access the `mssql-server` via:

```
sqlcmd -S 10.3.2.4 -U SA -P "P@ssw0rd"
```
where 10.3.2.4 is the IP address of the host.

To access via other client framework, for example [SQL Server Management Studio](https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms), use the IP Address of the host
where `mssql-server` has been launched.  If needed, supply the port of the instance ("1433" in the above example).

Note that you could run multiple instances of `mssql-server` on the same host, each with its own unique persistent volume mapped,
and each with its own unique IP Address published.


## Step 3: Use `pxctl` to create recoverable snapshots of your volume

To take a recoverable snapshot of the `mssql-server` instance for a point in time, 
use the `pxctl` CLI:

```
jeff-coreos-1 core # pxctl snap create mssqlvol --name mssqlvol_snap_0628
Volume successfully snapped: 342580301989879504
jeff-coreos-1 core # pxctl snap list
ID			NAME			SIZE	HA	SHARED	ENCRYPTED	IO_PRIORITY	SCALE	STATUS
342580301989879504	mssqlvol_snap_0628	10 GiB	3	no	no		LOW		0	up - detached
```

## Step 4: Use the snapshot to recover to an earlier point in time

By default, a Portworx volume snapshot is read-writable.   The snapshot taken is visible globally throughout the cluster, 
and can be used to start another instance of `mssql-server` on a different node as below:

```
jeff-coreos-2 core # pxctl snap list
ID			NAME			SIZE	HA	SHARED	ENCRYPTED	IO_PRIORITY	SCALE	STATUS
342580301989879504	mssqlvol_snap_0628	10 GiB	3	no	no		LOW		0	up - detached
jeff-coreos-2 core # docker run -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=P@ssw0rd' \
>       -p 1433:1433 --volume-driver=pxd \
>       -v mssqlvol_snap_0628:/var/opt/mssql \
>       -d microsoft/mssql-server-linux
jeff-coreos-2 core # docker ps
CONTAINER ID        IMAGE                          COMMAND                  CREATED             STATUS              PORTS                    NAMES
46eff5a9cbd6        microsoft/mssql-server-linux   "/bin/sh -c /opt/mssq"   4 minutes ago       Up 4 minutes        0.0.0.0:1433->1433/tcp   compassionate_perlman
0636d98250c4        portworx/px-dev                "/docker-entry-point."   2 hours ago         Up 2 hours                                   portworx.service
jeff-coreos-2 core # docker inspect --format '{{ "{{ .Mounts " }}}}' 46eff5a9cbd6
[{mssqlvol_snap_0628 /var/lib/osd/mounts/mssqlvol_snap_0628 /var/opt/mssql pxd  true rprivate}]
```

## See Also
For futher reading on Microsoft SQL Server on Linux, 
please visit the [SQL Server on Docker](https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-setup-docker#a-idpersista-persist-your-data) documentation
