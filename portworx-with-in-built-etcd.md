---
layout: page
title: "Portworx with in-built etcd"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, etcd, pv, persistent disk
sidebar: home_sidebar
meta-description: "Spin up a portworx cluster with in-built etcd"
---

* TOC
{:toc}

## Portworx with in-built etcd

>**Note:**<br/>This is a beta feature.

Portworx requires an externally configured key-value database like etcd/consul to store its metadata. With this new feature PX container will internally start etcd on a few nodes and use it to store the metadata.

To spin up PX with internal etcd you can run the following docker command:

```
if `uname -r | grep -i coreos > /dev/null`; \
then HDRS="/lib/modules"; \
else HDRS="/usr/src"; fi
sudo docker run --restart=always --name px -d --net=host       \
                 --privileged=true                             \
                 -v /run/docker/plugins:/run/docker/plugins    \
                 -v /var/lib/osd:/var/lib/osd:shared           \
                 -v /dev:/dev                                  \
                 -v /etc/pwx:/etc/pwx                          \
                 -v /opt/pwx/bin:/export_bin                   \
                 -v /var/run/docker.sock:/var/run/docker.sock  \
                 -v /var/cores:/var/cores                      \
                 -v ${HDRS}:${HDRS}                            \
                px-enterprise-private:1.3.0-beta -k etcd://myetc.company.com:2379 -c MY_CLUSTER_ID -s /dev/xvdb -s /dev/xvdc -b
```

The following arguments are provided to the PX daemon:

|  Argument | Description                                                                                                                                                                              |
|:---------:|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|     `-c`    | (Required) Specifies the cluster ID that this PX instance is to join. You can create any unique name for a cluster ID.                                                                   |
|     `-k`    | (Required) Points to an external key value database, such as an etcd cluster or a consul cluster used for bootstrap PX internal etcd.                                                    |
|     `-b`    | (Required) This flag indicates PX to spin up etcd internally.                                                    |
|     `-s`    | (Optional if -a is used) Specifies the various drives that PX should use for storing the data.                                                                                           |

For a complete list of options refer [here](/scheduler/docker/install-standalone.html)

PX uses an external etcd specified through the `-k` option to bootstrap internal etcd. Once PX cluster is up and the internal etcd is bootstrapped the dependency on external etcd is released. All PX metadata will now be stored in the internal etcd. As mentioned above the `-b` option is required to instruct PX to spin up internal etcd.

Portworx has a generally available etcd cluster which you can point to for the external bootstrap etcd, so that you do not have to spin up one.

```
http://etcdv3-01.portworx.com:2379
http://etcdv3-02.portworx.com:2379
http://etcdv3-03.portworx.com:2379
```

If you are using any scheduler for running PX you can refer to their respective docs and make sure you specify the `-b` option.

* [Kubernetes](scheduler/kubernetes/install.html)
* [Docker](/scheduler/docker/install-standalone.html)
* [DC-OS](scheduler/mesosphere-dcos/install.html)
* [Rancher](scheduler/rancher/install.html)