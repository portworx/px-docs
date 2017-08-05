---
layout: page
title: "Alerting with Portworx"
keywords: portworx, prometheus, grafana, alertmanager, cluster, storage
sidebar: home_sidebar
redirect_from: "/alerting.html"
---

This guide shows you how to configure prometheus to monitor your portworx node and visualize your cluster status and activities in Grafana.

## Configure Prometheus

Prometheus will require following two files: config file, alert rules file

### Prometheus config file

Modify this prometheus.yml (TBD: Insert link) to include your PX nodes' Ip address, and save it as /tmp/prometheus.yml.

### Prometheus alerts rules file

Copy this px.rules (TBD: Insert link) file, and save it as /tmp/px.rules.

### Run Prometheus

In this example prometheus is running as docker container. Make sure to map the directory where your rules and config file is stored to '/etc/prometheus'. This example uses /tmp.

```
docker run --restart=always --name prometheus -d -p 9090:9090 \
-v /tmp/prometheus.yml:/etc/prometheus/prometheus.yml \
-v /tmp:/etc/prometheus \
prom/prometheus
```

Prometheus UI can be visited at http://<IP_ADDRESS>:9090

## Configure Grafana

Start grafana with the follwing docker run command

```
docker run --restart=always --name grafana -d -p 3000:3000 grafana/grafana
```

Login to this grafana by visiting http://<IP_ADDRESS>:3000 in your browser. Default grafana login is admin/admin.

Here, it will ask you to configure your datastore. We are going to be using prometheus that we configured earlier. To use the templates that are provided later, name your datastore 'prometheus'.

In the below screen <TBD: Insert screenshot>
1) Choose 'Prometheus' from the 'Type' dropdown.
2) Name datastore 'prometheus'
3) Add URL of your prometheus UI under Http settings -> Url

Click on 'Save & Test'

Next step would be to import Portworx provided Cluster (TBD: Link to be inserted) and Volume (TBD: Link to be inserted) grafana templates.

From the dropdown on left in your grafana dashboard, go to Dashboards -> Import, and add cluster and volume template.

Your dashboard should look like the following. (TBD: Picture to be inserted)



