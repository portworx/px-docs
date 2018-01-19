---
layout: page
title: "Alerting with Portworx"
keywords: portworx, prometheus, grafana, alertmanager, cluster, storage
sidebar: home_sidebar
redirect_from: "/alerting.html"
meta-description: "Learn how to configure Prometheus to enable you to visualize your Portworx cluster status within Grafana."
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

This file can be downloaded from [prometheus.yml](https://github.com/portworx/px-docs/blob/gh-pages/maintain/monitoring/prometheus.yml)

Note: 'alert-manager-ip' is the IP address of the node where AlertManager is running. It is configured in the later steps.

### Prometheus alerts rules file

Copy [px.rules](https://github.com/portworx/px-docs/blob/gh-pages/maintain/monitoring/px.rules) file, and save it as ${PROMETHEUS_CONF}/px.rules.
For Prometheus v2.0.0 and above, rules file is available [here](https://github.com/portworx/px-docs/blob/prometheus_update_rules_file/maintain/monitoring/px.rules.yml).

### Run Prometheus

In this example prometheus is running as docker container. Make sure to map the directory where your rules and config file is stored to '/etc/prometheus'.

```
docker run --restart=always --name prometheus -d -p 9090:9090 \
-v ${PROMETHEUS_CONF}:/etc/prometheus \
prom/prometheus
```
Prometheus UI is available at http://&lt;IP_ADDRESS&gt;:9090

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
Save it as ${ALERTMANAGER_CONF}/config.yml.

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

This file can be downloaded from [config.yml](https://github.com/portworx/px-docs/blob/gh-pages/maintain/monitoring/config.yml)

### Run AlertManager

In this example AlertManager is running as docker container. Make sure to map the directory where your config file is stored to '/etc/alertmanager'.

```
docker run -d -p 9093:9093 --restart=always --name alertmgr \
-v ${ALERTMANAGER_CONF}:/etc/alertmanager \
prom/alertmanager
```

