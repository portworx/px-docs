---
layout: page
title: "Run Converged Kubernetes and Portworx"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk
sidebar: home_sidebar
---
>**Note:**<br/>**This is experimental!**

`px-kube` is a converged Portworx with Kubernetes container image.  You can use this to deploy a joint Kubernetes with Portworx cluster for stateful containers.  There are two modes in which this image runs:

1. Master mode - In this mode, the container comes up as a Kubernetes master node.  This is where the `etcd`, `kube api server`, `kube controller manager` and `kube scheduler` will run.
2. Agent mode - These are the minion nodes and these container instances will run the `kubelet`.  These nodes will join the Kubernetes master nodes.

Note that running these container images will automatically start both Kubernetes and the Portworx components.  The cluster will also automatically configure itself, so there are no extra steps that need to be taken to start using Kubernetes or Portworx.

## Deploy Kube Master

>**Note:**<br/>**ETCD must NOT be running on the host... px-kube will run etcd internally on port 2379 and this port must be open**

Run the following command on a server that you will designate as the Kubernetes master node.  Note the various `-v` options.  It is critical that the `/var/lib/etcd` is properly mapped to a persistent location.

```
# docker run --restart=always                                     \
      --name kube -d --net=host                                   \
      --privileged=true                                           \
      -v /run/docker/plugins:/run/docker/plugins                  \
      -v /var/lib/osd:/var/lib/osd:shared                         \
      -v /dev:/dev                                                \
      -v /etc/pwx:/etc/pwx                                        \
      -v /opt/pwx/bin:/export_bin:shared                          \
      -v /var/run:/var/run                                        \
      -v /var/cores:/var/cores                                    \
      -v /lib/modules:/lib/modules                                \
      -v /var/lib/etcd:/var/lib/etcd                              \
      -v /etc/kubernetes:/etc/kubernetes                          \
      -v /var/lib/docker:/var/lib/docker                          \
      -v /var/lib/docker:/var/lib/docker                          \
      -v /var/lib/kubelet:/var/lib/kubelet                        \
      -v /sys/fs/cgroup:/sys/fs/cgroup                            \
      portworx/px-kube --kube-master -c MY_CLUSTER_ID -z
```

Note the option `--kube-master`.  This instructs the px-kube container to start as a master node.  Chose a cluster ID for the `-c` option.  The first time this container is started, it will create a **new** cluster with the given cluster ID.  The `-z` option tells Portworx to not allocate any storage on the master node.  This is optional however, you can also request the master node to participate as a storage node by using the `-s /dev/sdb` option.

## Deploy Kube Agent
Run the following command on each server that you want to be a Kubernetes minion node:

```
# docker run --restart=always                                     \
      --name kube -d --net=host                                   \
      --privileged=true                                           \
      -v /run/docker/plugins:/run/docker/plugins                  \
      -v /var/lib/osd:/var/lib/osd:shared                         \
      -v /dev:/dev                                                \
      -v /etc/pwx:/etc/pwx                                        \
      -v /opt/pwx/bin:/export_bin:shared                          \
      -v /var/run:/var/run                                        \
      -v /var/cores:/var/cores                                    \
      -v /lib/modules:/lib/modules                                \
      -v /var/lib/etcd:/var/lib/etcd                              \
      -v /etc/kubernetes:/etc/kubernetes                          \
      -v /var/lib/docker:/var/lib/docker                          \
      -v /var/lib/docker:/var/lib/docker                          \
      -v /var/lib/kubelet:/var/lib/kubelet                        \
      -v /sys/fs/cgroup:/sys/fs/cgroup                            \
      portworx/px-kube --kube-agent -c MY_CLUSTER_ID -km 172.31.8.91 -s /dev/xvdb -s /dev/xvdc
```

Note the option `--kube-agent`.  This instructs the px-kube container to start as a minion node.  It joins the master at the IP specified in the `-km` option.  Specify the storage devices as you would to a regular PX container.
