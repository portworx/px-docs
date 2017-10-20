---
layout: page
title: "Grafana with Portworx"
keywords: portworx, prometheus, grafana, alertmanager, cluster, storage
sidebar: home_sidebar
redirect_from: "/grafana/index.html"
---

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

## Cluster Template for Grafana
Use [this template](Cluster_Template.json) to display Portworx cluster details in Grafana

## Volume Template for Grafana
Use [this template](Volume_Template.json) to display Portworx volume details in Grafana
