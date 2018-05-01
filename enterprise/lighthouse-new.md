---
layout: page
title: "Lighthouse Setup"
keywords: portworx, px-developer, px-enterprise, install, configure, container, storage, lighthouse
meta-description: "Lighthouse monitors and manages your PX cluster and storage and can be run on-prem. Find out how today."
---

### Start Lighthouse Container

```
sudo docker run --restart=always                            \
       --name px-lighthouse -d                              \
       -p 80:80 -p 443:443                                  \
       -v /etc/pwxlh:/config -v /etc/pwxlh/certs:/certs     \
       portworx/px-lighthouse:1.4.0-rc1
```

Visit *http://{IP_ADDRESS}* in the browser and login with admin/Password1

### Add PX cluster to lighthouse

**NOTE:** Any cluster running Portworx 1.4.0 and above can be added to lighthouse.  
         At the time of the first login, lighthouse will ask to add a cluster.

* For the endpoint,  please provide the loadbalancer ip or a IP address of one of the nodes in the PX Cluster.

* Click "Verify" 

* If the cluster is reachable, lighthouse will auto populate the clustername.
   Once verified, click on attach. Lighthouse should now show you a cluster card.

![Lighthouse add new cluster](/images/lh-new-add-cluster.png){:width="1796px" height="600px"}

### Delete Cluster from lighthouse

![Lighthouse menu](/images/lh-new-menu.png){:width="1796px" height="600px"}

* Click on Manage Clusters. 
* In the cluster list that appears, click on the trashcan link next to the cluster name.
* This will remove the cluster card from lighthouse cluster landing page 

**NOTE:** This will not remove your cluster from your KVDB. Just the entry in lighthouse.

![Lighthouse add new cluster](/images/lh-new-delete-cluster.png){:width="1796px" height="600px"}
