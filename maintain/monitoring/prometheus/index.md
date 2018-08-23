---
layout: page
title: "Portworx integration with prometheus"
keywords: prometheus, graph, stats
sidebar: home_sidebar
redirect_from:
  - /portworx-with-prometheus.html
  - /prometheus/index.html
  - /maintain/prometheus.html
meta-description: "Looking to integrate Portworx with Prometheus? Learn to integrate PX storage with Prometheus for monitoring today!"
---

* TOC
{:toc}

PX storage and network stats can easily be integrated with [**prometheus**](https://prometheus.io) or similar applications.
These stats are exported at port 9001; your application can poll http://&lt;IP_ADDRESS&gt;:9001/metrics to get their runtime values.

## Integration with Prometheus

### Step 1: Configuring Prometheus to watch px node
Add your px node as a target in Prometheus config file:

![Prometheus Config File](/images/prometheus-config.png "Prometheus Config File"){:width="1702px" height="970px"}

In the example above, our node has IP address of 54.173.138.1, so Prometheus is watching 54.173.138.1:9001 as its target. This can be any node in the PX cluster.

### Step 2: PX metrics to watch and building graphs with Prometheus

Once Prometheus starts watching px node, you will be able to see new portworx related metrics added to Prometheus. 

![PX Metrics in Prometheus](/images/px-metrics-in-prometheus.png "PX Metrics in Prometheus"){:width="1110px" height="618px"}

You can now build graphs:

![Building a Graph with Prometheus](/images/building-a-graph-with-prometheus.png "Building a Graph with Prometheus"){:width="2006px" height="1154px"}

**Note**

A curl request on port 9001 also shows the stats:

![Curl Request on 9001](/images/curl-request-on-9001.png "Curl Request on 9001"){:width="1856px" height="1372px"}

## Storage and Network stats

### Cluster stats:

```
px_cluster_cpu_percent: average CPU usage for the PX cluster nodes in percentage 
px_cluster_disk_available_bytes: available storage in px cluster in bytes
px_cluster_disk_utilized_bytes: used storage in px cluster in bytes
px_cluster_memory_utilized_percent: average memory usage for the px cluster nodes
px_cluster_pendingio: total bytes (read/write) being currently processed
px_cluster_status_cluster_size: total cluster size
px_cluster_status_nodes_offline: total offline nodes 
px_cluster_status_nodes_online: total online nodes 
px_cluster_status_nodes_storage_down: total storage down nodes 
px_cluster_status_cluster_quorum: cluster_quorum, 1 = in quorum, 0 = not in quorum
px_cluster_disk_total_bytes: total storage in px cluster in bytes
px_cluster_status_storage_nodes_online: number of nodes proving storage which are online (these participate in quorum)
px_cluster_status_storage_nodes_offline: number of nodes proving storage which are offline (these participate in quorum)
```

### Node stats

```
px_network_io_bytessent: bytes sent by this node to other nodes
px_network_io_received_bytes: bytes received by this node from other nodes
px_node_status_<node_id>_status: <node_id> status, 1 = online, 0 = offline
px_node_stats_cpu_percent_usage: last reported CPU usage
px_node_stats_free_mem: amount of inactive and idle memory (reported by /proc/vmstat)
px_node_stats_total_mem: the amount of idle memory (reported by /proc/vmstat)
px_node_stats_used_mem: total - free
```

### Volume stats

```
px_volume_capacity_bytes: volume size
px_volume_depth_io: number of i/o operations being served at once
px_volume_halevel: volume HA level
px_volume_iops: operations per second
px_volume_read_bytes: total bytes read from volume
px_volume_reads: number of read operations served by the volume
px_volume_readthroughput: bytes read per second
px_volume_writes: number of write operations served by the volume
px_volume_writethroughput: bytes written per second
px_volume_written_bytes: total bytes written to the volume
px_volume_dev_depth_io: I/Os currently in progress as reported by block device 
px_volume_dev_read_latency_secs: read latency for block device (total time spent reading/ number of reads)
px_volume_dev_readthroughput: read throughput for block device 
px_volume_dev_write_latency_secs: write latency for block device (total time spent writing/ number of writes)
px_volume_dev_write_throughput: write througput for block device
px_volume_iopriority: configured volume io_priority (0 = low, 1 = medium, 2 = high)
px_volume_fs_capacity_bytes_bytes: total size reported by filesystem
px_volume_fs_usage_bytes_bytes: used capacity reported by filesystem
```

### Disk stats: collected from /proc/diskstats

```
px_disk_stats_interval_seconds: interval seconds
px_disk_stats_io_seconds: time spent doing I/Os 
px_disk_stats_progress_io: I/Os currently in progress
px_disk_stats_read_bytes: read bytes
px_disk_stats_read_seconds: time spent reading 
px_disk_stats_reads: reads
px_disk_stats_used_bytes: used bytes
px_disk_stats_write_bytes: write bytes
px_disk_stats_write_seconds: write seconds
px_disk_stats_writes: writes
px_disk_stats_read_latency_seconds: read latency for disk  (read ms / number of reads)
px_disk_stats_write_latency_seconds: write latency for disk (write ms / number of writes)
```


