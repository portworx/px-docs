---
layout: page
title: "Spark on DCOS with Portworx"
keywords: portworx, container, Mesos, Mesosphere, DCOS, HBase, hbase, HBASE
---

* TOC
{:toc}


This guide describe how to use ``HBase`` from ``px-universe`` latest ``hadoop-px`` package on DCOS cluster. Assume you have successfully deployed DCOS and PX cluster.

## Adding the repository for the service:

For this step you will need to login to a node which has the dcos cli installed and is authenticated to your DCOS cluster. 

Run the following command to add the repository to your DCOS cluster:

```
 $ dcos package repo add --index=0 hadoop-px-aws https://disrani-dcos.s3.amazonaws.com/v1/hadoop-px/hadoop-px.zip
```

Once you have run the above command you should see the Hadoop-PX service available in your universe


## Installation

### Default Install
If you want to use the defaults, you can now run the dcos command to install the service
```
$ dcos package install --yes hadoop-px
```
You can also click on the  “Install” button on the WebUI next to the service and then click “Install Package”.

### Advanced Install
If you want to modify the default, click on the “Install” button next to the package on the DCOS UI and then click on
“Advanced Installation”

Here you have the option to change the service name, volume name, volume size, and provide any additional options that you
want to pass to the docker volume driver. You can also configure other Hadoop related parameters on this page including
the number of Data and Yarn nodes for the Hadoop clsuter.

![Hadoop-PX install options](/images/dcos-hadoop-px-install-options.png){:width="655px" height="200px"}

Click on “Review and Install” and then “Install” to start the installation of the service.

## Verifying Install
Once you have started the install you can go to the Services page to monitor the status of the installation from the DCOS service screen, one hbase master server task and three hbase region server tasks should be observed when installation of hadoop-px is completed.


![Hadoop-PX install status](/images/hbase-px-universe-001.PNG)


From the DCOS workstation; check hbase task containers

    $ dcos task | head -1 && dcos task  |grep hbase
    NAME                 HOST        USER  STATE  ID
    hbase-master-0-node  10.0.1.248  root    R    hbase-master-0-node__a59f83d5-8e3a-40c5-8766-2a0be11b24ea
    hbase-region-0-node  10.0.1.75   root    R    hbase-region-0-node__f1f9f437-f125-4a53-a1f1-6a11fbbcabf4
    hbase-region-1-node  10.0.3.240  root    R    hbase-region-1-node__dd04080f-7d49-4fff-b02e-596d10ad620a
    hbase-region-2-node  10.0.1.248  root    R    hbase-region-2-node__f0860d79-62c7-4441-b958-978924b3b9d5


From the DCOS workstation, install new dcos command for hdfs 

    $ dcos package install hdfs --cli

Use the dcos command and inspect the hbase-site.xml file and look for the property of ``hbase.master.info.port``.

    $ dcos hdfs endpoints hbase-site.xml

The section of ``hbase.master.info.port`` in hbase-site.xml

      <property>
        <name>hbase.master.info.port</name>
        <value>60010</value>
        <description>The port for the HBase Master web UI.
        Set to -1 if you do not want a UI instance run.</description>
      </property>


The default setup for master web UI access is master node IP at port ``60010``.

## Accessing to Hbase Master UI

Create a ssh tunnel from the DCOS/Mesos master node and access to hbase master node port 60010. The DCOS/Mesos master node = `ec2-52-91-237-197.compute-1.amazonaws.com` and the hbase master node is obtained previously from dcos task command and is ``10.0.1.248``

    ssh -i awskey -L 60010:10.0.1.248:60010 core@ec2-52-91-237-197.compute-1.amazonaws.com

From the browser; you can inspect the setup of this Hbase cluster. and default setup only has 1 Hbase master and three Hbase region servers, and no backup master node.

![HBase WebUI](/images/hbase-px-universe-002.PNG)


## Checking Hbase in CLI

From the Hbase master node, run ``hbase hbck`` command; before running any hbase command, set JAVA_HOME.
 
    $ export JAVA_HOME=/mnt/mesos/sandbox/jre1.8.0_112

    $ /mnt/mesos/sandbox/hbase-1.2.0-cdh5.9.1/bin/hbase hbck
    
The output of ``hbase hbck`` is length and Hbase cluster information is observed

     Version: 1.2.0-cdh5.9.1
     Number of live region servers: 3
     Number of dead region servers: 0
     Master: ip-10-0-1-153.ec2.internal,60000,1495666988221
     Number of backup masters: 0
     Average load: 1.3333333333333333
     Number of requests: 0
     Number of regions: 4
     Number of regions in transition: 0
    
And ``hbase hbck`` also check all table status

     Table hbase:meta is okay.
     Number of regions: 1
     Deployed on:  ip-10-0-1-248.ec2.internal,60020,1495656787125
     Table test is okay.
     Number of regions: 1
     Deployed on:  ip-10-0-1-248.ec2.internal,60020,1495656787125
     Table hbase:namespace is okay.
     Number of regions: 1
     Deployed on:  ip-10-0-3-240.ec2.internal,60020,1495656817031

## Using the Hbase Shell

Get into the Hbase master task container from your DCOS workstation

    $ dcos task exec -it hbase-master-0-node__a59f83d5-8e3a-40c5-8766-2a0be11b24ea bash

From the Hbase master container, export the JAVA_HOME and run hbase shell; the default JAVA_HOME is on ``/mnt/mesos/sandbox/jre1.8.0_112``

    $ export JAVA_HOME=/mnt/mesos/sandbox/jre1.8.0_112

    $ /mnt/mesos/sandbox/hbase-1.2.0-cdh5.9.1/bin/hbase shell

      HBase Shell; enter 'help<RETURN>' for list of supported commands.
      Type "exit<RETURN>" to leave the HBase Shell
      Version 1.2.0-cdh5.9.1, rUnknown, Wed Jan 11 13:57:35 PST 2017

    hbase(main):001:0>

From the hbase shell check the current cluster ``status``

     hbase(main):010:0> status
     1 active master, 0 backup masters, 3 servers, 0 dead, 1.0000 average load

Create a test table ``test``; specify the column family name as ``cf``
    
     > create 'test', 'cf'
     0 row(s) in 2.4460 seconds

     => Hbase::Table - test


List created table ``test``

    > list
      
      TABLE
      test
      1 row(s) in 0.0060 seconds

     => ["test"]


Populate the ``test`` table with some rows


    > put 'test', 'row1', 'cf:a', 'value1'
    0 row(s) in 0.3090 seconds

    > put 'test', 'row2', 'cf:b', 'value2'
    0 row(s) in 0.2000 seconds

    > put 'test', 'row3', 'cf:c', 'value3'
    0 row(s) in 0.0120 seconds

Describe the ``test``  table

   
     > desc 'test'
       Table test is ENABLED
       test
       COLUMN FAMILIES DESCRIPTION
       {NAME => 'cf', BLOOMFILTER => 'ROW', VERSIONS => '1', IN_MEMORY => 'false', KEEP_DELETED_CELLS => 'FALSE', DATA_BLOCK_ENCODING => 'NONE',
       TTL => 'FOREVER', COMPRESSION => 'NONE', MIN_VERSIONS => '0', BLOCKCACHE => 'true', BLOCKSIZE => '65536', REPLICATION_SCOPE => '0'}
       1 row(s) in 0.1160 seconds  


Get a single row from `test` table

       > get 'test', 'row1'
       COLUMN                              CELL
       cf:a                               timestamp=1495664662231, value=value1
       1 row(s) in 0.0390 seconds

Scan the table `test`

       hbase(main):022:0> scan 'test'
       ROW                                COLUMN+CELL
       row1                               column=cf:a, timestamp=1495664662231, value=value1
       row2                               column=cf:b, timestamp=1495664685630, value=value2
       row3                               column=cf:c, timestamp=1495664706231, value=value3
       3 row(s) in 0.0220 seconds

Other hbase shell commands include:  ``disable``, ``enable`` and ``drop`` table.

Create sample table span from row-aa to row-zz with total 676 rows.

     > create 'testtable', 'colfam1'
     > for i in 'a'..'z' do for j in 'a'..'z' do \
       put 'testtable', "row-#{i}#{j}", "colfam1:#{j}", "#{j}" end end

Scan table ``testtable`` output is length and the end should be similar like below

      row-zv                             column=colfam1:v, timestamp=1495668892646, value=v
      row-zw                             column=colfam1:w, timestamp=1495668892649, value=w
      row-zx                             column=colfam1:x, timestamp=1495668892652, value=x
      row-zy                             column=colfam1:y, timestamp=1495668892655, value=y
      row-zz                             column=colfam1:z, timestamp=1495668892658, value=z


And from the HBase Master UI, the ``test`` table is listed under User Tables

![HBase WebUI](/images/hbase-px-universe-003.PNG)

### HBase file system

The Hbase default file system is using hadoop-px HDFS, from a configured hadoop client use hdfs command to check the default Hbase folder ``hbase``

     $ hadoop fs -ls /
       Found 1 items
       drwxr-xr-x   - root supergroup          0 2017-05-24 21:56 /hbase
     $ hadoop fs -ls /hbase
       Found 8 items
       drwxr-xr-x   - root supergroup          0 2017-05-24 20:13 /hbase/.tmp
       drwxr-xr-x   - root supergroup          0 2017-05-24 22:26 /hbase/MasterProcWALs
       drwxr-xr-x   - root supergroup          0 2017-05-24 20:13 /hbase/WALs
       drwxr-xr-x   - root supergroup          0 2017-05-24 22:24 /hbase/archive
       drwxr-xr-x   - root supergroup          0 2017-05-24 20:13 /hbase/data
        -rw-r--r--  3 root supergroup        42 2017-05-24 20:12  /hbase/hbase.id
        -rw-r--r--  3 root supergroup         7 2017-05-24 20:12  /hbase/hbase.version
       drwxr-xr-x   - root supergroup          0 2017-05-24 22:23 /hbase/oldWALs

The files associate to the created table ``test`` are located at HDFS /hbase/data/default/


     $ hadoop fs -ls -R /hbase/data/default/test/
       drwxr-xr-x   - root supergroup          0 2017-05-24 22:21 /hbase/data/default/test/.tabledesc
       -rw-r--r--   3 root supergroup        282 2017-05-24 22:21 /hbase/data/default/test/.tabledesc/.tableinfo.0000000001
       drwxr-xr-x   - root supergroup          0 2017-05-24 22:21 /hbase/data/default/test/.tmp
       drwxr-xr-x   - root supergroup          0 2017-05-24 22:21 /hbase/data/default/test/3c371ba86dbe886839cc5eb38925fa25
       -rw-r--r--   3 root supergroup         39 2017-05-24 22:21 /hbase/data/default/test/3c371ba86dbe886839cc5eb38925fa25/.regioninfo
       drwxr-xr-x   - root supergroup          0 2017-05-24 22:21 /hbase/data/default/test/3c371ba86dbe886839cc5eb38925fa25/cf
       drwxr-xr-x   - root supergroup          0 2017-05-24 22:21 /hbase/data/default/test/3c371ba86dbe886839cc5eb38925fa25/recovered.edits
       -rw-r--r--   3 root supergroup          0 2017-05-24 22:21 /hbase/data/default/test/3c371ba86dbe886839cc5eb38925fa25/recovered.edits/2.seqid

