## TestDFSIO benchmark with Px
### Hardware for Hadoop-px on DCOS
These benchmark tests were based on 5 data nodes as following. 
Hadoop and DCOS cluster was on 1Gbps network. Portworx management communication was on 1Gbps network and data communication was on 10Gbps network.

| Roles        | # Vcpu          | Mem (GB)  |# network    | # Px disks | Manufactor |
| ------------- |:-------------:| ----------:|-------------|------------|------------|
| Datanode 1    | 72            | 125        | 1Gbps+10Gbps|10         | Intel S2600WTTR |
| Datanode 2    | 36            | 125        | 1Gbps+10Gbps|10         | Intel S2600WTTR |
| Datanode 3    | 72            | 125        | 1Gbps+10Gbps|10         | Intel S2600WTTR |
| Datanode 4    | 32            | 31         | 1Gbps+10Gbps|8          | Supermicro SSG-6028R-E1CR12L  |
| Datanode 5    | 32            | 31         | 1Gbps+10Gbps|10         | Supermicro SSG-6028R-E1CR12L  |
| Master        | 16            | 125        | 1Gbps       |NA         | Supermicro SYS-F618R2-RTPT+  |

### Results with Px on DCOS
TestDFSIO Write throughput was about +/- 8 percent variance from the average Write throughput as each test is repeated three times.

| HDFS replication| Px replication| Write 1 (MB/s) per node| Write 2 (MB/s) per node| Write 3 (MB/s) per node |Avg Write (MB/s) per node|
| -------------   |:-------------:| ----------------------:|------------------------|-------------------------|-------------------------|
|  1              | 1             | 179.93                 |	185.7                 |	180.17	                | 181.93   | 
|2	              |1	            | 53.36                  |	53.62                 |	52.06                   |	53.01 |
|3	              |1	            |31.37                   |	30.78                 |	31.3	                  |31.15  |
|1                |	2	            |126.04                  |	133.55                |	126.31                  |	128.63  |
|2	              |2	            |45.62                   |	45.31                 |	46.17	                  |45.70   |
|1	              |3	            |84.26                   |	94.01                 |	95.2                    |	91.16  |

TestDFSIO Read throughput was about +/- 20 percent from the average Read throughput as each test is repeated three times.

| HDFS replication| Px replication| Read 1 (MB/s) per node| Read 2 (MB/s) per node| Read 3 (MB/s) per node |Avg Read (MB/s) per node|
|-------------    |:-------------:|---------------------:|-----------------------|------------------------|-------------------------|
|1	              |1	            |256.74	                |259.36                 |	283.05                 |	266.38  |
|2	              |1	            |157.68                 |	80.05	                | 108.46                 |	115.40  |
|3	              |1              |	109.69                |	108.51                |	123.21                 |	113.80  |
|1	              |2	            |99.62                  |	147.68                |	141.48                 |	129.59  |
|2	              |2	            |82.66                  |	83.23                 |	75.98	                 |80.62            |
|1	              |3	            |102.78               	|124.3	                |153	                   |126.69  |

## TestDFSIO benchmark without Px
Used Cloudera Manager to setup Hadoop cluster on bare metal (CDH 5.12.1). By default, Cloudera Manager installed namenode and secondary name node on separated machines (this was consistent with the practice out there). So, it installed 1 namenode, 1 secondary name node and 3 data nodes.

For each node, configured all available disks (i.e. 10 or 8 disks) as RAID0 device (similar to Px configuration) and HDFS used this device. 

### Hardware for Hadoop
These benchmark tests were based on 3 data nodes, 1 name node and 1 standby name node as following. 
Hadoop cluster was on 1Gbps network. For each node, all available disks were used to create RAID0 device for usage by Hadoop cluster. 

| Roles        | # Vcpu          | Mem (GB)  |# network    | # Avail disks | Manufactor |
| ------------- |:-------------:| ----------:|-------------|------------|------------|
| Datanode 1    | 72            | 125        | 1Gbps|10         | Intel S2600WTTR |
| Datanode 2    | 36            | 125        | 1Gbps|10         | Intel S2600WTTR |
| Datanode 3    | 72            | 125        | 1Gbps|10         | Intel S2600WTTR |
| Namenode      | 32            | 31         | 1Gbps|8          | Supermicro SSG-6028R-E1CR12L  |
| Standby namenode    | 32      | 31         | 1Gbps|10         | Supermicro SSG-6028R-E1CR12L  |

### Results without Px (No DCOS)
TestDFSIO Write throughput was about +/- 4 percent variance from the average Write throughput as each test is repeated three times.

| HDFS replication| Write 1 (MB/s) per node| Write 2 (MB/s) per node| Write 3 (MB/s) per node |Avg Write (MB/s) per node|
| -------------   |-----------------------:|------------------------|-------------------------|-------------------------|
|1                |478.44	                 |454.89	                |479.74	                  |471.02   | 
|2	              | 37.44                  |	37.18	                |37.34	                  |37.32 |
|3	              | 36.63	                 |36.62                   |	36.72                   |	36.66|

TestDFSIO Read throughput was about +/- 5 percent from the average Read throughput as each test is repeated three times.

| HDFS replication| Read 1 (MB/s) per node | Read 2 (MB/s) per node | Read 3 (MB/s) per node  |Avg Read (MB/s) per node|
| -------------   |-----------------------:|------------------------|-------------------------|-------------------------|
|1                | 37.11	                 |37.46                   |	37.74                   |	37.44| 
|2	              | 65.07                  |	61.84                 |	64.23                   |	63.71 |
|3	              | 1712.85	               |1802.71                 |	1896.41                 |	1803.99|

## Comparison of Px vs. No Px
| HDFS replication| Avg Write (MB/s) per node with no Px|  Avg Write (MB/s) per node with Px | % Avg Diff  |
| -------------   |--------------------------------------|-----------------------------------|---------    |
|1                | 471.02                               | 181.93                            |-61.37       |
|2	              | 37.32                                | 53.01                             |42.05        |
|3	              | 36.66                                | 31.15                             |-15.02       |


| HDFS replication| Avg Read (MB/s) per node with no Px  |  Avg Read (MB/s) per node with Px | % Avg Diff  |
| -------------   |--------------------------------------|-----------------------------------|---------    |
|1                |  37.44                               |266.38                             |611.56       |
|2	              |  63.71                               | 115.40                            |81.12        |
|3	              |  1803.99                             | 113.80                            |-93.69       |

## Terasort benchmark with Px
It took about 4 mins 44 sec to sort 10GB of data.

# FIO benchmark
For each node, all available disks (i.e 10 or 8) were used to create a RAID0 device and formatted with Ext4.

|                 |Write 1 (MB/s) per node |	Read 1 (MB/s) per node |
|-----------------|------------------------|-------------------------|
|FIO without Px   |1660.5	                 |1690.2   |
|FIO with Px      |1211.3                  |	1051.2  |
|% Diff	          |-27.05	                 |-37.81    |


