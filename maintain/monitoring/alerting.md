---
layout: page
title: "Alerting with Portworx"
keywords: portworx, prometheus, grafana, alertmanager, cluster, storage
sidebar: home_sidebar
redirect_from: "/alerting.html"
---

This guide shows you how to configure prometheus to monitor your portworx node and visualize your cluster status and activities in Grafana. We will also configure AlertManager to send email alerts.

## Configure Prometheus

Prometheus requires the following two files: config file, alert rules file. These files need to be bind mounted into Prometheus container. 
```
# This can be any directory on the host.
PROMETHEUS_CONF=/etc/prometheus
```

### Prometheus config file

Modify the below configuration to include your PX nodes' IP addresses, and save it as ${PROMETHEUS_CONF}/prometheus.yml.

```
global:
  scrape_interval: 1m
  scrape_timeout: 10s
  evaluation_interval: 1m
rule_files:
  - px.rules
scrape_configs:
  - job_name: 'PX'
    scrape_interval: 5s
    static_configs:
      - targets: ['px-node-01-IP:9001','px-node-02-IP:9001','px-node-03-IP:9001']
alerting:
  alertmanagers:
  - scheme: http
    static_configs:
    - targets:
      - "alert-manager-ip:9093"
```

This file can be downloaded from [prometheus.yml](https://gist.github.com/shailvipx/dc5094d3a853c4cdb2b54cd188f80460)

Note: 'alert-manager-ip' is the IP address of the node where AlertManager is running. It is confugured in the later steps.

### Prometheus alerts rules file

Copy [px.rules](https://gist.github.com/shailvipx/67882f83c7d50d1dfd5bd49fc93fa3de) file, and save it as ${PROMETHEUS_CONF}/px.rules.

### Run Prometheus

In this example prometheus is running as docker container. Make sure to map the directory where your rules and config file is stored to '/etc/prometheus'.

```
docker run --restart=always --name prometheus -d -p 9090:9090 \
-v ${PROMETHEUS_CONF}:/etc/prometheus \
prom/prometheus
```
Prometheus UI is available at http://&lt;IP_ADDRESS&gt;:9090

## Configure Grafana

Start grafana with the follwing docker run command

```
docker run --restart=always --name grafana -d -p 3000:3000 grafana/grafana
```

Login to this grafana at http://&lt;IP_ADDRESS&gt;:3000 in your browser. Default grafana login is admin/admin.

Here, it will ask you to configure your datastore. We are going to be using prometheus that we configured earlier. To use the templates that are provided later, name your datastore 'prometheus'.

In the screen below:
1) Choose 'Prometheus' from the 'Type' dropdown.
2) Name datastore 'prometheus'
3) Add URL of your prometheus UI under Http settings -&gt; Url

Click on 'Save & Test'

![Grafana data store File](/images/grafana_datastore.png "Grafana data store File"){:width="1234px" height="1252px"}

Next step would be to import Portworx provided [Cluster](https://gist.github.com/shailvipx/6da98daa4f5464f855482c1de6a138b2) and [Volume](https://gist.github.com/shailvipx/cccbf6a99d9bfc81a86ced1bebc7039a) grafana templates.

From the dropdown on left in your grafana dashboard, go to Dashboards -&gt; Import, and add cluster and volume template.

Your dashboard should look like the following. 

![Grafana Cluster Status File](/images/grafana_cluster_status.png "Grafana Cluster Status File"){:width="2554px" height="964px"}


![Grafana Volume Status File](/images/grafana_volume_status.png "Grafana Volume Status File"){:width="2556px" height="644px"}

## Configure AlertManager

The Alertmanager handles alerts sent by Prometheus server. It can be configured to send them to the correct receiver integrations such as email, PagerDuty, Slack etc.
This example shows how it can be configured to send email notifications using gmail as SMTP server.

AlertManager requires a config file, which needs to be bind mounted into AlertManager container. 

```
# This can be any directory on the host.
ALERTMANAGER_CONF=/etc/alertmanager
```

### AlertManager config file

Modify the below config file to use Google's SMTP server for your account. 
Save it as ${ALERTMANAGER_CONF}/alert.conf.

```
global:
  # The smarthost and SMTP sender used for mail notifications.
  smtp_smarthost: 'smtp.gmail.com:587'
  smtp_from: '<sender-email-address>'
  smtp_auth_username: "<sender-email-address>"
  smtp_auth_password: '<sender-email-password>'
route:
  group_by: [Alertname]
  # Send all notifications to me.
  receiver: email-me
receivers:
- name: email-me
  email_configs:
  - to: <receiver-email-address>
    from: <sender-email-address>
    smarthost: smtp.gmail.com:587
    auth_username: "<sender-email-address>"
    auth_identity: "<sender-email-address>"
    auth_password: "<sender-email-password>"
```

This file can be downloaded from [alert.conf](https://gist.github.com/shailvipx/7fa7ed5d722062d6151c15c2db9bc05c)

### Run AlertManager

In this example AlertManager is running as docker container. Make sure to map the directory where your config file is stored to '/etc/alertmanager'.

```
docker run -d -p 9093:9093 --restart=always --name alertmgr \
-v ${ALERTMANAGER_CONF}:/etc/alertmanager \
prom/alertmanager
```

