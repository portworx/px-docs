---
layout: page
title: "Lighthouse New"
keywords: portworx, px-developer, px-enterprise, install, configure, container, storage, lighthouse
meta-description: "Lighthouse monitors and manages your PX cluster and storage and can be run on-prem. Find out how today."
---

## Start Lighthouse Container


```
sudo docker run --restart=always                            \
       --name px-lighthouse -d                              \
       -p 80:80 -p 443:443                                  \
       -v /etc/pwxlh:/config -v /etc/pwxlh/certs:/certs     \
       portworx/lh-php:0188f24
```

Visit *http://{IP_ADDRESS}:login* in the browser and login with admin/Password1

## Add PX cluster to lighthouse

Any cluster running master code can be added to new lighthouse. It will use IP of one of the nodes of the cluster, as endpoint. 
After you login, click on 'click here to add a Cluster to Light House' -> Add cluster endpoint -> Click on Verify. This should automatically fill Cluster name and UUID. Once verified, you can click on attach.

![Lighthouse add new cluster](images/lh-new-add-cluster.png){:width="1796px" height="600px"}




