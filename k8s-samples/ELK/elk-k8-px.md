
# Elasticsearch setup on Kubernetes with Portworx
---
layout: page
title: "Deploy Apache Kafka and Zookeeper with Portworx on Kubernetes"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, pv, persistent disk, kafka, zookeeper
sidebar: home_sidebar
---

* TOC
{:toc}

layout: page
title: "Deploy Elasticsearch with Portworx on Kubernetes"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, pv, persistent disk, ELK, elasticsearch,
sidebar: home_sidebar
---

* TOC
{:toc}

These below instructions will provide you a step by step guide in deploying Elasticsearch with Portworx on Kubernetes. 

Kubernetes provides management of stateful workloads using Statefulsets. Elasticsearch is a distributed, JSON-based search and analytics engine designed for horizontal scalability, maximum reliability, and easy management. [Elasticsearch](https://www.elastic.co/)  

## Prerequisites

-	A running Kubernetes cluster with v 1.6+ 
-	All the kubernetes nodes should allow [shared volume propagation](https://docs.portworx.com/knowledgebase/shared-mount-propogation.html). PX requires this since it provisions volumes in containers.  
-	[Deploy Portworx on your kubernetes cluster](https://docs.portworx.com/scheduler/kubernetes/install.html). PX runs on each node of your kubernetes cluster as a daemonset. 

## Install


This guide demonstrate setup of stateful ELK (Elasticsearch) cluster on K8 1.6.X . 
For K8 setup, please refer official Kubernetes setup guide using kubeadm.

The ELK cluster consists of three major components

3 - master nodes
2 - client nodes
3 -data   nodes

  - Data nodes are those indexed document stored and require stateful volumes 


### Setup ELK cluster 
```
kubectl create -f https://raw.githubusercontent.com/portworx/px-docs/gh-pages/k8s-samples/ELK/es-discovery-svc.yaml
kubectl create -f https://raw.githubusercontent.com/portworx/px-docs/gh-pages/k8s-samples/ELK/es-svc.yaml
kubectl create -f https://raw.githubusercontent.com/portworx/px-docs/gh-pages/k8s-samples/ELK/es-svc.yaml
```

** Wait until es-master all pods are completed then run

```
TODO kubectl describe ?????
```

kubectl create -f https://raw.githubusercontent.com/portworx/px-docs/gh-pages/k8s-samples/ELK/es-client.yaml
kubectl create -f https://raw.githubusercontent.com/portworx/px-docs/gh-pages/k8s-samples/ELK/es-data-sc.yaml
kubectl create -f https://raw.githubusercontent.com/portworx/px-docs/gh-pages/k8s-samples/ELK/es-data-stateful.yaml

### Verify all pods,deployment for ELK are successfully created

```
        kubectl get deployment,pods
        NAME               DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
        deploy/es-client   2         2         2            2           5m
        deploy/es-data01   1         1         1            1           2m
        deploy/es-data02   1         1         1            1           2m
        deploy/es-data03   1         1         1            1           2m
        deploy/es-master   3         3         3            3           5m

        NAME                            READY     STATUS    RESTARTS   AGE
        po/es-client-3170561982-8mtt8   1/1       Running   0          5m
        po/es-client-3170561982-qsb4w   1/1       Running   0          5m
        po/es-data01-583774158-pjfs3    1/1       Running   0          2m
        po/es-data02-3053483828-g7zfv   1/1       Running   0          2m
        po/es-data03-3620239159-10ncw   1/1       Running   0          2m
        po/es-master-2212299741-bc4nw   1/1       Running   0          5m
        po/es-master-2212299741-mgwvw   1/1       Running   0          5m
        po/es-master-2212299741-nvd0x   1/1       Running   0          5m
```

### Verify PX volumes are attached
``` 
        /opt/pwx/bin/pxctl v l
        ID                      NAME    SIZE    HA      SHARED  ENCRYPTED       IO_PRIORITY     SCALE   STATUS
        807852748764534732      evol01  100 GiB 1       no      no              LOW             1       up - attached on 172.31.42.35
        109602500435512894      evol02  100 GiB 1       no      no              LOW             1       up - attached on 172.31.38.57
        549945525761724000      evol03  100 GiB 1       no      no              LOW             1       up - attached on 172.31.35.102
```

### Verify Elasticsearch service access
```
      kubectl describe svc elasticsearch
        Name:                   elasticsearch
        Namespace:              default
        Labels:                 component=elasticsearch
                                role=client
        Annotations:            <none>
        Selector:               component=elasticsearch,role=client
        Type:                   LoadBalancer
        IP:                     10.111.107.223
        Port:                   http    9200/TCP
        NodePort:               http    31999/TCP
        Endpoints:              10.36.0.2:9200,10.39.0.2:9200
        Session Affinity:       None
        Events:                 <none>
```
### Access to ELK cluster-ip ``10.111.107.223:9200``
```
      curl http://10.111.107.223:9200
        {
          "name" : "es-client-3170561982-8mtt8",
          "cluster_name" : "myesdb",
          "cluster_uuid" : "btII8ujbRbibaqRgWQUxAA",
          "version" : {
            "number" : "5.4.0",
            "build_hash" : "780f8c4",
            "build_date" : "2017-04-28T17:43:27.229Z",
            "build_snapshot" : false,
            "lucene_version" : "6.5.0"
         },
         "tagline" : "You Know, for Search"
        }
```
### Verify ELK CLuster heath with following command
```
curl http://10.100.75.158:9200/_cluster/health?pretty
[root@PDC-SM13 ~]# curl http://10.111.107.223:9200/_cluster/health?pretty
{
  "cluster_name" : "myesdb",
  "status" : “green",
  "timed_out" : false,
  "number_of_nodes" : 92,
  "number_of_data_nodes" : 87,
  "active_primary_shards" : 37,
  "active_shards" : 37,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 5,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 88.09523809523809
}
```


