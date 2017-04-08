---
layout: page
title: "Portworx integration with prometheus"
keywords: prometheus, graph, stats
sidebar: home_sidebar
---

PX storage and network stats can easily be integrated with [**prometheus**](https://prometheus.io) or similar applications.
These stats are exported at port 9001, so if your application listens to http://<IP_ADDRESS>:9001/metrics or makes a curl request, you would be able to get their runtime values.

### Integration with prometheus

## Step 1: Configuring prometheus to watch px node
You can add your px node as a target in prometheus config file as the following:

![Prometheus Config File](images/prometheus-config.png "Prometheus Config File")

In the example above, our node has IP address of 54.173.138.1, so prometheus is watching 54.173.138.1:9001 as it's target.

## Step 2: PX metrics to watch and building graphs with prometheus

Once prometheus starts watching px node, you will be able to see new portworx related metrix being added to prometheus. 

![PX Metrics in Prometheus](images/px-metrics-in-prometheus.png "PX Metrics in Prometheus")

You can build graphs as the following:

![Building a Graph with Prometheus](images/building-a-graph-with-prometheus.png "Building a Graph with Prometheus")

**Note**

If you make a curl request on port 9001, then also you should be able to see these stats as the following.

![Curl Request on 9001](images/curl-request-on-9001.png "Curl Request on 9001")




