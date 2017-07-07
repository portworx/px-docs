---
layout: page
title: "NoSQL Performance"
keywords: portworx, cos, class of service, production, performance, overhead
sidebar: home_sidebar
---

* TOC
{:toc}

## Containerized NoSQL Workloads: Cassandra performance gains with running PX-Enterprise

In this example, we show how PX-Enterprise's network-optimized 3-way replication out-performs Cassandra's 3-way replication when running on a 3-node cluster. We compared the performance between the following two configuration and ran these tests on the same servers as the tests above.
 
 - PX-Enterprise replication factor set to 1 and Cassandra replication factor set to 3. (Legend: P1C3 in the diagram below)     
 - PX-Enterprise replication factor set to 3 and Cassandra replication factor set to 1. (Legend: P3C1 in the diagram below)

The results demonstrate that running with PX-Enterprise for Cassandra workloads provide significant gains. PX-Enterprise's breakthrough performance for containerized workloads along with the cloud-scale data protection and data services make it a compelling container data services infrastructure for Cassandra and other no-sql workloads

The Read OPS/sec and Write OPS/sec improvements graphs show how running with PX-Enterprise's three-node replication deliver a significantly better OPS/sec than running with Cassandra's three-node replication. This PX-Enterprise performance is also made possible because PX container software stack intelligently leverages NVMe SSDs to deliver high OPS/sec and low latencies.

### Cassandra with PX-Enterprise - Read OPS/sec improvements

![Cassandra Reads Ops](/images/Cassandra-PX Read OPS.png){:width="1056px" height="648px"}

### Cassandra with PX-Enterprise - Write OPS/sec improvements

![Cassandra Writes Ops](/images/Cassandra-PX Write Ops.png){:width="1056px" height="648px"}

The latency graphs below demonstrate the network-optimized replication performance of PX-Enterprise as it accelerates cassandra performance by delivering IO at very low latencies to the Cassandra Container

### Cassandra with PX-Enterprise - Read Latency improvements

![Cassandra Read Lats](/images/Cassandra-PX Read Latencies.png){:width="1066px" height="650px"}

### Cassandra with PX-Enterprise - Write Latency improvements

![Cassandra Write Lats](/images/Cassandra-PX Write latencies.png){:width="1054px" height="696px"}
