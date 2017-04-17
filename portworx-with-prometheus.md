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

![Prometheus Config File](images/prometheus-config.png "Prometheus Config File")

In the example above, our node has IP address of 54.173.138.1, so Prometheus is watching 54.173.138.1:9001 as its target. This can be any node in the PX cluster.

### Step 2: PX metrics to watch and building graphs with Prometheus

Once Prometheus starts watching px node, you will be able to see new portworx related metrics added to Prometheus. 

![PX Metrics in Prometheus](images/px-metrics-in-prometheus.png "PX Metrics in Prometheus")

You can now build graphs:

![Building a Graph with Prometheus](images/building-a-graph-with-prometheus.png "Building a Graph with Prometheus")

**Note**

A curl request on port 9001 also shows the stats:

![Curl Request on 9001](images/curl-request-on-9001.png "Curl Request on 9001")

### Storage and Network stats

```
px_cluster_cpu_percent: average CPU usage for the PX cluster nodes in percentage 
px_cluster_disk_available_bytes: available storage in px cluster in bytes
px_cluster_disk_utilized_bytes: used storage in px cluster in bytes
px_cluster_memory_utilized_percent: average memory usage for the px cluster nodes
px_cluster_pendingio: 
px_network_io_bytessent:
px_network_io_received_bytes:
px_volume_depth_io:
px_volume_iops:
px_volume_latency_seconds:
px_volume_read_bytes:
px_volume_reads:
px_volume_readthroughput:
px_volume_writes:
px_colume_writethroughput:
px_volume_written_bytes:

```




