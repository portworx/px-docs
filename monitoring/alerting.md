---
layout: page
title: "Alerting with Portworx"
keywords: portworx, prometheus, grafana, alertmanager, cluster, storage
sidebar: home_sidebar
redirect_from: "/alerting.html"
---

This guide shows you how to configure prometheus to monitor your portworx node and visualize your cluster status and activities in Grafana.

## Configure Prometheus

Prometheus requires the following two files: config file, alert rules file. These files need to be bind mounted into Prometheus container. 
```
# This can be any directory on the host.
PROMETHEUS_CONF=/etc/prometheus
```

### Prometheus config file

Modify [prometheus.yml](https://gist.github.com/shailvipx/dc5094d3a853c4cdb2b54cd188f80460) to include your PX nodes' IP addresses, and save it as ${PROMETHEUS_CONF}/prometheus.yml.

### Prometheus alerts rules file

Copy [px.rules](https://gist.github.com/shailvipx/67882f83c7d50d1dfd5bd49fc93fa3de) file, and save it as ${PROMETHEUS_CONF}/px.rules.

### Run Prometheus

In this example prometheus is running as docker container. Make sure to map the directory where your rules and config file is stored to '/etc/prometheus'.

```
docker run --restart=always --name prometheus -d -p 9090:9090 \
-v ${PROMETHEUS_CONF}:/etc/prometheus \
prom/prometheus
```
Prometheus UI is available at http://<IP_ADDRESS>:9090

## Configure Grafana

Start grafana with the follwing docker run command

```
docker run --restart=always --name grafana -d -p 3000:3000 grafana/grafana
```

Login to this grafana at http://<IP_ADDRESS>:3000 in your browser. Default grafana login is admin/admin.

Here, it will ask you to configure your datastore. We are going to be using prometheus that we configured earlier. To use the templates that are provided later, name your datastore 'prometheus'.

In the screen below:
1) Choose 'Prometheus' from the 'Type' dropdown.
2) Name datastore 'prometheus'
3) Add URL of your prometheus UI under Http settings -> Url

Click on 'Save & Test'

![Grafana data store File](/images/grafana_datastore.png "Grafana data store File")

Next step would be to import Portworx provided [Cluster](https://gist.github.com/shailvipx/6da98daa4f5464f855482c1de6a138b2) and [Volume](https://gist.github.com/shailvipx/cccbf6a99d9bfc81a86ced1bebc7039a) grafana templates.

From the dropdown on left in your grafana dashboard, go to Dashboards -> Import, and add cluster and volume template.

Your dashboard should look like the following. 

![Grafana Cluster Status File](/images/grafana_cluster_status.png "Grafana Cluster Status File")


![Grafana Volume Status File](/images/grafana_volume_status.png "Grafana Volume Status File")



