---
layout: page
title: "Run PX with Docker User Namespaces"
keywords: portworx, install, configure, container, user, namespaces, namespace, security
sidebar: home_sidebar
---
To install and configure PX with Docker user namespaces enabled, use the command-line steps in this section.

### Running Portworx with User Namespaces

You must enable the `--userns host` directive to Docker

```
# sudo docker run --restart=always --name px -d --net=host \
                 --privileged=true                             \
                 --userns=host                                 \
                 -v /run/docker/plugins:/run/docker/plugins    \
                 -v /var/lib/osd:/var/lib/osd:shared           \
                 -v /dev:/dev                                  \
                 -v /etc/pwx:/etc/pwx                          \
                 -v /opt/pwx/bin:/export_bin:shared            \
                 -v /var/run/docker.sock:/var/run/docker.sock  \
                 -v /var/cores:/var/cores                      \
                 -v /usr/src:/usr/src                          \
                 -v /lib/modules:/lib/modules                  \
                 --ipc=host                                    \
                portworx/px-dev -daemon -k etcd://myetc.company.com:4001 -c MY_CLUSTER_ID -s /dev/nbd1 -s /dev/nbd2
```
