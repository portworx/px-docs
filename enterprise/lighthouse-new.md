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
       portworx/px-lighthouse:1.4.0-rc1
```

Visit *http://{IP_ADDRESS}* in the browser and login with admin/Password1

## Add PX cluster to lighthouse

Any cluster running Portworx 1.4+ can be added to lighthouse.  
After your first login, Lighthouse will ask you to add a cluster.

For the Endpoint you put in either a loadbalancer or a px node that lighthouse can talk to.

Click verify cluster. 

If the cluster is reachable lighthouse will auto populate the clustername
Once verified, click on attach. Lighthouse should now show you a cluster card.

![Lighthouse add new cluster](/images/lh-new-add-cluster.png){:width="1796px" height="600px"}

## Delete Cluster from lighthouse

![Lighthouse menu](/images/lh-new-menu.png){:width="1796px" height="600px"}

Click manage clusters. You should now see a list of clusters that have been added to Lighthouse.
Click the trashcan on the right to delete the cluster form Lighthouse.

This will not remove your cluster from your KVDB. Just entry in lighthouse.

![Lighthouse add new cluster](/images/lh-new-delete-cluster.png){:width="1796px" height="600px"}
