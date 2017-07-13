---
layout: page
title: "Cassandra Stress Test with Portworx"
keywords: portworx, px-enterprise, cassandra, databases, performance
sidebar: home_sidebar
---

* TOC
{:toc}

# About this Guide
This guide is to measure the performance of running Cassandra with PX volumes.  We use Docker directly on EC2 instances.  You may chose to use a different way of starting Cassandra and creating Portworx volumes depending on your orchestration environment (Kubernetes, Mesosphere or Swarm). Running [Cassandra in Docker containers](https://portworx.com/use-case/cassandra-docker-container/) is one of the most common uses of Portworx.

# Testing Cassandra on PX
Below are the instructions to test and verify Cassandra's Performance with PX volumes in a Docker environment without a scheduler. We will create three Cassandra docker containers on three machines and each Cassandra container will expose its ports. The test is conducted in AWS, using three r4.2xlarge instance and each with 60GB Ram and 128GB disk for the PX cluster. 

## Setup for the test

In each of the AWS instance launch PX container and specify the etcd IP e.g. ``172.31.45.219`` and disk volume e.g.`` /dev/xvdb``

```
$ docker run --restart=always --name px -d --net=host      \
             --privileged=true                             \
             -v /run/docker/plugins:/run/docker/plugins    \
             -v /var/lib/osd:/var/lib/osd:shared           \
             -v /dev:/dev                                  \
             -v /etc/pwx:/etc/pwx                          \
             -v /opt/pwx/bin:/export_bin:shared            \
             -v /var/run/docker.sock:/var/run/docker.sock  \
             -v /var/cores:/var/cores                      \
             -v /usr/src:/usr/src                          \
             --ipc=host                                    \
             portworx/px-enterprise -daemon -k etcd://172.31.45.219:4001 -c PXCassTest001 -s /dev/xvdb
```
    
Once the PX cluster is created, create three PX volumes with `size=60GB` that is local to each node. On each of the AWS instance run the following `pxctl` command:
```
$ /opt/pwx/bin/pxctl volume create CVOL-`hostname` --size 60 --nodes LocalNode
```

Verify the created PX volumes:
```
$ /opt/pwx/bin/pxctl volume list
ID                      NAME                    SIZE    HA      SHARED  ENCRYPTED       IO_PRIORITY     SCALE   STATUS
999260470129557090      CVOL-ip-172-31-32-188   60 GiB  1       no      no              LOW             1       up - detached
973892635505817385      CVOL-ip-172-31-45-219   60 GiB  1       no      no              LOW             1       up - detached
446982770798983273      CVOL-ip-172-31-47-121   60 GiB  1       no      no              LOW             1       up - detached
```

Create Cassandra container(s) using the created PX volumes. In our test case; we have three AWS instances.

Set IP addresse variables of the three nodes on each instance:
```
$ NODE_1_IP=172.31.32.188
$ NODE_2_IP=172.31.45.219
$ NODE_3_IP=172.31.47.121
```

>**Note:**<br/>Download [the ``cassandra_conf.tar`` file](https://s3.amazonaws.com/rlui-dcos-hadoop/cassandra_conf.tar) which includes cassandra.yaml file which is using TCP port 17000 instead of 7000.  The reason to use custom cassandra.yaml file is because as of this writing, PX is occupying the port 7000, and the default Cassandra data and storage port is also on port 7000. Use this custom cassandra configuration to avoid this conflict.  Download the cassandra_conf.tar file and extract it on ``/etc`` folder.
>This step is not required if you are running with Kubernets or Mesosphere.

For each AWS instance do a docker run and launch the Cassandra latest version Docker container.

On Node 1:

```
$ docker run  --name cass-`hostname` -e CASSANDRA_BROADCAST_ADDRESS=`hostname -i`      \
              -p 17000:17000 -p 7001:7001 -p 9042:9042 -p 9160:9160 -p 7199:7199       \
              -v /etc/cassandra:/etc/cassandra                                         \
              -v CVOL-`hostname`:/var/lib/cassandra                                    \
              -d cassandra:latest
```

On Node 2:
```
$ docker run  --name cass-`hostname` -e CASSANDRA_BROADCAST_ADDRESS=`hostname -i`      \
              -e CASSANDRA_SEEDS=${NODE_1_IP}                                          \
              -p 17000:17000 -p 7001:7001 -p 9042:9042 -p 9160:9160 -p 7199:7199       \
              -v /etc/cassandra:/etc/cassandra                                         \ 
              -v CVOL-`hostname`:/var/lib/cassandra                                    \
              -d cassandra:latest
```

On Node 3:
```
$ docker run  --name cass-`hostname` -e CASSANDRA_BROADCAST_ADDRESS=`hostname -i`      \
              -e CASSANDRA_SEEDS=${NODE_1_IP},${NODE_2_IP}                             \
              -p 17000:17000 -p 7001:7001 -p 9042:9042 -p 9160:9160 -p 7199:7199       \
              -v /etc/cassandra:/etc/cassandra                                         \
              -v CVOL-`hostname`:/var/lib/cassandra                                    \
              -d cassandra:latest
```


After all three Cassandra containers started, verify the status from one of the nodes by running ``nodetool status``

```
$ docker exec -it cass-ip-172-31-32-188 sh -c 'nodetool status'
     Datacenter: datacenter1
     =======================
     Status=Up/Down
     |/ State=Normal/Leaving/Joining/Moving
     --  Address        Load       Tokens       Owns (effective)   Host ID                               Rack
     UN  172.31.32.188  108.65 KiB  256          65.7%             7aa8a83e-1378-4aa1-b9d2-3008b3550b69  rack1
     UN  172.31.45.219  84.33 KiB  256           66.0%             b455c82e-9649-4724-adf1-dae09ec2c616  rack1
     UN  172.31.47.121  108.29 KiB  256          68.3%             26ffac02-2975-4921-b5d0-54f3274bfe84  rack1
```

## Running the test

Run Cassandra stress ``write`` testing with 10K inserts into the target keyspace ``TestKEYSPACE`` and 4 threads ``-rate threads=4``. On each node, start the Cassandra stress test about the same time. Below each node's Cassandra container is inserting object into the same keyspace but at different sequence `` e.g. 1 .. 10000``.

On Node 1
```
$ docker exec -it cass-`hostname` cassandra-stress write n=10000                 \
  cl=quorum -mode native cql3 -rate threads=4 -schema keyspace="TestKEYSPACE01"  \
  "replication(factor=2)" -pop seq=1..10000 -log file=~/Test_10Kwrite_001.log    \
  -node ${NODE_1_IP},${NODE_2_IP},${NODE_3_IP}
```

On Node 2
```
$ docker exec -it cass-`hostname` cassandra-stress write n=10000                  \
  cl=quorum -mode native cql3 -rate threads=4 -schema keyspace="TestKEYSPACE01"   \
  "replication(factor=2)" -pop seq=10001..20000 -log file=~/Test_10Kwrite_002.log \ 
  -node ${NODE_1_IP},${NODE_2_IP},${NODE_3_IP}
```

On Node 3
```
$ docker exec -it cass-`hostname` cassandra-stress write n=10000                   \
  cl=quorum -mode native cql3 -rate threads\>=72 -schema keyspace="TestKEYSPACE01" \
  "replication(factor=2)" -pop seq=20001..30000 -log file=~/Test_10Kwrite_003.log  \
  -node ${NODE_1_IP},${NODE_2_IP},${NODE_3_IP}
```

The output of result on each node should be similar below:

```
$ docker exec -it cass-`hostname` cassandra-stress write n=10000 cl=quorum -mode native cql3 -rate threads=4 -schema keyspace="TestKEYSPACE" "replication(factor=2)" -pop seq=1..10000 -log file=~/Test_10Kwrite_001.log -node ${NODE_1_IP},${NODE_2_IP},${NODE_3_IP}
      ******************** Stress Settings ********************
      Command:
      Type: write
      Count: 10,000
      No Warmup: false
      Consistency Level: QUORUM
      Target Uncertainty: not applicable
      Key Size (bytes): 10
      Counter Increment Distibution: add=fixed(1)
      Rate:
        Auto: false
        Thread Count: 4
        OpsPer Sec: 0
      Population:
      Sequence: 1..10000
      Order: ARBITRARY
      Wrap: true
      Insert:
        Revisits: Uniform:  min=1,max=1000000
        Visits: Fixed:  key=1
        Row Population Ratio: Ratio: divisor=1.000000;delegate=Fixed:  key=1
        Batch Type: not batching
      Columns:
        Max Columns Per Key: 5
        Column Names: [C0, C1, C2, C3, C4]
        Comparator: AsciiType
        Timestamp: null
        Variable Column Count: false
        Slice: false
        Size Distribution: Fixed:  key=34
      Count Distribution: Fixed:  key=5
      Errors:
        Ignore: false
        Tries: 10
      Log:
        No Summary: false
        No Settings: false
        File: /root/Test_10Kwrite_001.log
        Interval Millis: 1000
     Level: NORMAL
     Mode:
        API: JAVA_DRIVER_NATIVE
        Connection Style: CQL_PREPARED
        CQL Version: CQL3
        Protocol Version: V4
        Username: null
        Password: null
        Auth Provide Class: null
        Max Pending Per Connection: 128
        Connections Per Host: 8
        Compression: NONE
     Node:
        Nodes: [172.31.32.188, 172.31.45.219, 172.31.47.121]
     Is White List: false
     Datacenter: null
     Schema:
        Keyspace: TestKEYSPACE
        Replication Strategy: org.apache.cassandra.locator.SimpleStrategy
        Replication Strategy Pptions: {replication_factor=2}
        Table Compression: null
        Table Compaction Strategy: null
        Table Compaction Strategy Options: {}
     Transport:
     factory=org.apache.cassandra.thrift.TFramedTransportFactory; truststore=null; truststore-password=null; keystore=null; keystore-password=null; ssl-protocol=TLS; ssl-alg=SunX509; store-type=JKS; ssl-ciphers=TLS_RSA_WITH_AES_128_CBC_SHA,TLS_RSA_WITH_AES_256_CBC_SHA;
     Port:
       Native Port: 9042
       Thrift Port: 9160
       JMX Port: 7199
    Send To Daemon:
      *not set*
    Graph:
      File: null
      Revision: unknown
      Title: null
      Operation: WRITE
      TokenRange:
      Wrap: false
      Split Factor: 1

    Connected to cluster: Test Cluster, max pending requests per connection 128, max connections per host 8
    Datatacenter: datacenter1; Host: /172.31.32.188; Rack: rack1
    Datatacenter: datacenter1; Host: /172.31.45.219; Rack: rack1
    Datatacenter: datacenter1; Host: /172.31.47.121; Rack: rack1
    Created keyspaces. Sleeping 3s for propagation.
    Sleeping 2s...
    Warming up WRITE with 7500 iterations...
    Failed to connect over JMX; not collecting these stats
    Running WRITE with 4 threads for 10000 iteration
    Failed to connect over JMX; not collecting these stats
    type       total ops,    op/s,    pk/s,   row/s,    mean,     med,     .95,     .99,    .999,     max,   time,   stderr, errors,  gc: #,  max ms,  sum ms,  sdv ms,      mb
    total,          1303,    1303,    1303,    1303,     1.8,     1.2,     4.9,    11.0,    17.0,    21.7,    1.0,  0.00000,      0,      0,       0,       0,       0,       0
    total,          4324,    3021,    3021,    3021,     1.3,     1.1,     2.3,     6.1,    12.8,    14.9,    2.0,  0.27888,      0,      0,       0,       0,       0,       0
    total,          7819,    3495,    3495,    3495,     1.1,     1.1,     1.3,     2.0,    11.0,    16.7,    3.0,  0.20770,      0,      0,       0,       0,       0,       0
    total,         10000,    2692,    2692,    2692,     1.5,     1.1,     3.3,     9.2,    12.1,    13.5,    3.8,  0.15468,      0,      0,       0,       0,       0,       0


    Results:
    Op rate                   :    2,624 op/s  [WRITE: 2,624 op/s]
    Partition rate            :    2,624 pk/s  [WRITE: 2,624 pk/s]
    Row rate                  :    2,624 row/s [WRITE: 2,624 row/s]
    Latency mean              :    1.3 ms [WRITE: 1.3 ms]
    Latency median            :    1.1 ms [WRITE: 1.1 ms]
    Latency 95th percentile   :    2.2 ms [WRITE: 2.2 ms]
    Latency 99th percentile   :    7.5 ms [WRITE: 7.5 ms]
    Latency 99.9th percentile :   12.9 ms [WRITE: 12.9 ms]
    Latency max               :   21.7 ms [WRITE: 21.7 ms]
    Total partitions          :     10,000 [WRITE: 10,000]
    Total errors              :          0 [WRITE: 0]
    Total GC count            : 0
    Total GC memory           : 0.000 KiB
    Total GC time             :    0.0 seconds
    Avg GC time               :    NaN ms
    StdDev GC time            :    0.0 ms
    Total operation time      : 00:00:03

    END
```

If the above Cassandra test is OK and completed without any issue, the number of inserted objects and threads can be adjusted in such way to produce more accurate result.

Below is an example to insert 10 million objects into the target keyspace with threads ``>= 72``. When using threads ``>=72``, Cassandra Stress will run several cycles in threads ``72, 108, 162, 243, 364, 546 and 819``

```
$ docker exec -it cass-`hostname` cassandra-stress write n=10000000                 \
  cl=quorum -mode native cql3 -rate threads\>=72 -schema keyspace="TestKEYSPACE01"  \
  "replication(factor=2)" -pop seq=1..10000000 -log file=~/Test_10Mwrite_001.log    \
  -node ${NODE_1_IP},${NODE_2_IP},${NODE_3_IP}
```

After a write test, you can do a mixed test which is write/read; however a write test must be done before any mixed test:

```
$ docker exec -it cass-`hostname` cassandra-stress mixed n=10000000                 \
  cl=quorum -mode native cql3 -rate threads\>=72 -schema keyspace="TestKEYSPACE01"  \
  "replication(factor=2)" -pop seq=1..10000000 -log file=~/Test_10Mmixed_001.log    \
  -node ${NODE_1_IP},${NODE_2_IP},${NODE_3_IP}
```

Generally Cassandra stress test should be run on every Cassandra containers about the same time to increase the load. And using the same keyspace on the same test run, requires to use different ``sequence`` to separate between each containers operation on the same keyspace ``(e.g.  1..10000 and 10001..20000 and so on)``.



