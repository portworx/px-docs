---
layout: page
title: "Install Lighthouse"
keywords: portworx, px-developer, px-enterprise, install, configure, container, storage, lighthouse
meta-description: "Lighthouse monitors and manages your PX cluster and storage and can be run on-prem. Find out how today."
---

Lighthouse is a GUI dashboard that can be used to monitor multiple Portworx clusters.

Any cluster running Portworx 1.4 or above can be added to Lighthouse.  Lighthouse must have network access on ports 9001 - 9015 to the nodes in the Portworx cluster.

## Start Lighthouse

Lighthouse runs as a Docker container.

```
sudo docker run --restart=always                            \
       --name px-lighthouse -d                              \
       -p 80:80 -p 443:443                                  \
       -v /etc/pwxlh:/config -v /etc/pwxlh/certs:/certs     \
       portworx/lh-php:0188f24
```

Visit *http://{IP_ADDRESS}:login* in the browser and login with `admin/Password1`

## Adding a PX cluster

To add a PX cluster to Lighthouse, you will need the IP address (known as a `cluster endpoint`) of any one of the nodes in that cluster.  Lighthouse will connect to that node and configure itself to monitor that cluster.

After your first login, go to 'click here to add a Cluster to Light House' -> Add cluster endpoint -> Verify. This should automatically fill in the cluster name and UUID.  Once verified, click on attach.

![Lighthouse add new cluster](/images/lh-new-add-cluster.png){:width="1796px" height="600px"}
