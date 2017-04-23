---
layout: page
title: "Portworx integration with prometheus"
keywords: prometheus, graph, stats
sidebar: home_sidebar
---

PX storage and network stats can easily be integrated with [**prometheus**](https://prometheus.io) or similar applications.
These stats are exported at port 9001; your application can poll http://<IP_ADDRESS>:9001/metrics to get their runtime values.

## Integration with Prometheus

### Step 1: Configuring Prometheus to watch px node
Add your px node as a target in Prometheus config file:

![Prometheus Config File](images/prometheus-config.png "Prometheus Config File"){:width="1702px" height="970px"}

In the example above, our node has IP address of 54.173.138.1, so Prometheus is watching 54.173.138.1:9001 as its target. This can be any node in the PX cluster.

### Step 2: PX metrics to watch and building graphs with Prometheus

Once Prometheus starts watching px node, you will be able to see new portworx related metrics added to Prometheus. 

![PX Metrics in Prometheus](images/px-metrics-in-prometheus.png "PX Metrics in Prometheus"){:width="1110px" height="618px"}

You can now build graphs:

![Building a Graph with Prometheus](images/building-a-graph-with-prometheus.png "Building a Graph with Prometheus"){:width="2006px" height="1154px"}

**Note**

A curl request on port 9001 also shows the stats:

![Curl Request on 9001](images/curl-request-on-9001.png "Curl Request on 9001"){:width="1856px" height="1372px"}

## Storage and Network stats

### Cluster stats:

```
px_cluster_cpu_percent: average CPU usage for the PX cluster nodes in percentage 
px_cluster_disk_available_bytes: available storage in px cluster in bytes
px_cluster_disk_utilized_bytes: used storage in px cluster in bytes
px_cluster_memory_utilized_percent: average memory usage for the px cluster nodes
px_cluster_pendingio: total bytes (read/write) being currently processed
```

### Node stats

```
px_network_io_bytessent: bytes sent by this node to other nodes
px_network_io_received_bytes: bytes received by this node from other nodes
```

### Volume stats

```
px_volume_depth_io:number of i/o operations being served at once
px_volume_iops: operations per second
px_volume_latency_seconds: time spent by
px_volume_read_bytes: total bytes read from volume
px_volume_reads: number of read operations served by the volume
px_volume_readthroughput: bytes read per second
px_volume_writes: number of write operations served by the volume
px_colume_writethroughput:bytes written per second
px_volume_written_bytes: total bytes written to the volume 
```




