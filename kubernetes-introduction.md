---
layout: page
title: "Intro to running Portworx with Kubernetes"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, flexvol, pv, pv claim, persistent disk
sidebar: home_sidebar
---
[Kubernetes](https://kubernetes.io/docs/home/), affectionately known as k8s, is one of the most popular and full-featured schedulers for containerized applications. Portworx can be used as a storage provider for your Kubernetes cluster so you can run stateful applications like Cassandra, Redis, ElasticSearch, Jenkins and other popular stateful applications on k8s. Portworx pools the bare metal or cloud server capacity of your Kubernetes cluster and turns it into a converged, highly available compute and storage cluster.   With Portworx, you get a single data management layer for all of your stateful services, no matter where they run.  

Portworx supports the core storage abstractions provided by Kubernetes:

Dynamic Volume Provisioning
Storage Classes
Persistent Volume Claims
Persistent Volumes
Stateful sets

Our docs provide detailed instructions on running stateful services on Kubernetes.  Once you make sure you satisfy the prerequisites below, explore what you can do with PX and k8s.

* [Install PX into an Kubernetes 1.6 cluster]()
* [Force Kubernetes to schedule pods on hosts with your data](/kubernetes-convergence.html)
* [Create Kubernetes Storage Class](/kubernetes-define-storage-class.html)
* [Using pre-provisioned volumes with Kubernetes](/kubernetes-preprovisioned-volumes.html)
* [Dynamically provision volumes with Kubernetes](/kubernetes-dynamically-provisioned-volumes.html)
* [Using Stateful sets](/kubernetes-stateful-sets.html)
* [Running a pod from a snapshot](/kubernetes-running-a-pod-from-snapshot.html)
* [Failover a database using Kubernetes](kubernetes-database-failover.html)
* [Install PX on Kubernetes < 1.6](/kubernetes-run-with-flexvolume.html)
* [Cost calculator for converged container cluster using Kubernetes and Portworx](kubernetes-infrastructure-cost-calculator.html)

## Prerequisites

1. Kubernetes Cluster
Start a  Kubernetes cluster started using the pre-compiled binaries with Portworx native driver

2. Portworx Cluster
Run a Portworx instance on all of your Kubernetes nodes (master and slave).

>**Note:**<br/>We recommend running a storage less node on Kubernetes master as no pods will be scheduled on that node.

You can use the following command:

For CentOS

```
# sudo docker run --restart=always --name px -d --net=host \
    --privileged=true                             \
    -v /run/docker/plugins:/run/docker/plugins    \
    -v /var/lib/osd:/var/lib/osd:shared           \
    -v /dev:/dev                                  \
    -v /etc/pwx:/etc/pwx                          \
    -v /opt/pwx/bin:/export_bin                   \
    -v /var/run/docker.sock:/var/run/docker.sock  \
    -v /var/cores:/var/cores                      \
    -v /var/lib/kubelet:/var/lib/kubelet:shared   \
    -v /usr/src:/usr/src                          \
    portworx/px-dev:latest -daemon -k etcd://myetc.company.com:2379 -c
    MY_CLUSTER_ID -s /dev/sdb -s /dev/sdc
```

For CoreOS and VMWare Photon

```
# sudo docker run --restart=always --name px -d --net=host \
   --privileged=true                             \
   -v /run/docker/plugins:/run/docker/plugins    \
   -v /var/lib/osd:/var/lib/osd:shared           \
   -v /dev:/dev                                  \
   -v /etc/pwx:/etc/pwx                          \
   -v /opt/pwx/bin:/export_bin:shared            \
   -v /var/run/docker.sock:/var/run/docker.sock  \
   -v /var/cores:/var/cores                      \
   -v /lib/modules:/lib/modules                  \
   -v /var/lib/kubelet:/var/lib/kubelet:shared   \
   portworx/px-dev:latest -daemon -k etcd://myetc.company.com:4001 -c
   -MY_CLUSTER_ID -s /dev/sdb -s /dev/sdc
```
