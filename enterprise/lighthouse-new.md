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
       portworx/lh-php:b95a88e
```

Visit *http://{IP_ADDRESS}:login* in the browser and login with admin/Password1

## Add PX cluster to lighthouse





