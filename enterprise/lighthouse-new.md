---
layout: page
title: "Install Lighthouse"
keywords: portworx, px-developer, px-enterprise, install, configure, container, storage, lighthouse
meta-description: "Lighthouse monitors and manages your PX cluster and storage and can be run on-prem. Find out how today."
---

Lighthouse is a GUI dashboard that can be used to monitor multiple Portworx clusters.

Any cluster running Portworx 1.4 or above can be added to Lighthouse. Lighthouse must have network access on ports 9001 - 9015 to the nodes in the Portworx cluster.

## Start Lighthouse

Lighthouse runs as a Docker container.

```
sudo docker run --restart=always                            \
       --name px-lighthouse -d                              \
       -p 80:80 -p 443:443                                  \
       -v /etc/pwx:/config                                  \
       portworx/px-lighthouse:1.4.0-rc1
```

this will create an 'lh' folder under /etc/pwx/ and put all lighthouse content there.

Visit _http://{IP_ADDRESS}_ in the browser and login with `admin/Password1` the password can be changed once logged in.

## Adding a PX cluster

To add a PX cluster to Lighthouse, you will need the IP address of any one of the nodes in that cluster. Lighthouse will connect to that node and configure itself to monitor that cluster.

After your first login, go to 'click here to add a Cluster to Light House' -> Add cluster endpoint -> Verify. This should automatically fill in the cluster name and UUID. Once verified, click on attach.

**NOTE:** For the cluster endpoint, please provide the loadbalancer IP or the IP address of one of the nodes in the PX Cluster.

![Lighthouse add new cluster](/images/lh-new-add-cluster.png){:width="897px" height="513px"}

### Grafana, Prometheus, Kibana

In the menu above you can see you can provide url's for Grafana, Prometheus and Kibana.
These will then show up on the dashboard and link you to the specific apps.

![Grafana link](/images/lh-new-dashboard-grafana.png){:width="344px" height="123px"}

These can be added after creating the cluster by clicking

![Add Links](/images/lh-new-add-dashboard-links.png){:width="89px" height="25px"}

Or from the manage cluster page. which you can reach from the menu on the top right.

![Lighthouse menu](/images/lh-new-menu.png){:width="250px" height="200px"}

### Deleting a PX cluster

Under the settings icon, click on Manage Clusters.

![Lighthouse menu](/images/lh-new-menu.png){:width="250px" height="200px"}

Click on the trashcan link next to the cluster name in the cluster list. This will remove this cluster card from lighthouse cluster landing page

![Lighthouse delete cluster](/images/lh-new-delete-cluster.png){:width="1796px" height="600px"}

**NOTE:** This will not remove your cluster from your KVDB. This action just de-registers this cluster from Lighthouse.
