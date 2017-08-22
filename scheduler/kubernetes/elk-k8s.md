---
layout: page
title: "Deploy Elastic Stack with Portworx on Kubernetes"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, pv, persistent disk, elastic, elastic stack, elastic search, logstash, kibana
sidebar: home_sidebar
---

* TOC
{:toc}

These below instructions will provide you with a step by step guide in deploying the Elasticstack (Elastic Search, Logstash, Kibana) with Portworx on Kubernetes.

Elasticsearch creates a cluster based on the cluster name property specified in the configuration. Each node within the cluster can forward client requests to the appropriate node and also knows about every other node in the cluster. 

An Elasticsearch cluster node can have one or more purposes. 
- Master-eligible node
	A node that has node.master set to true (default), which makes it eligible to be elected as the master node, which controls the cluster.
- Data node
	A node that has node.data set to true (default). Data nodes hold data and perform data related operations such as CRUD, search, and aggregations.
- Coordinating node
	A node which only routes requests, handles the search reduce phase, and distributes bulk indexing. 

In the document we will create an ES cluster with 
-	3 master nodes
-	3 data nodes and
-	2 coordinating nodes. 

## Prerequisites

-	A running Kubernetes cluster with v 1.6+
-	All the kubernetes nodes should allow [shared volume propagation](https://docs.portworx.com/knowledgebase/shared-mount-propogation.html). PX requires this since it provisions volumes in containers.  
-	[Deploy Portworx on your kubernetes cluster](https://docs.portworx.com/scheduler/kubernetes/install.html). PX runs on each node of your kubernetes cluster as a daemonset.

## Install

### Portworx StorageClass for Volume Provisioning

Portworx provides volume(s) to the elastic search data nodes. 
Create ```portworx-sc.yaml``` with Portworx as the provisioner and apply the configuration

```
kind: StorageClass
apiVersion: storage.k8s.io/v1beta1
metadata:
    name: px-data-sc
provisioner: kubernetes.io/portworx-volume
parameters:
   repl: "2"
---

kubectl apply -f portworx-sc.yaml
	
```

### Install Elasticsearch cluster


Apply the Statefulset spec for the Elastic search data nodes alongwith the headless service. 

```
 kubectl apply -f es-data-sts.yaml 
statefulset "elasticsearch-data" created

 kubectl get pods -w
NAME                   READY     STATUS            RESTARTS   AGE
elasticsearch-data-0   1/1       Running           0          21s
elasticsearch-data-1   0/1       PodInitializing   0          7s
elasticsearch-data-1   1/1       Running   		   0          14s
elasticsearch-data-2   0/1       Pending   		   0          0s
elasticsearch-data-2   0/1       Pending           0          0s
elasticsearch-data-2   0/1       Pending           0          3s
elasticsearch-data-2   0/1       Init:0/1          0          3s
elasticsearch-data-2   0/1       PodInitializing   0          6s
elasticsearch-data-2   1/1       Running           0          16s

 kubectl apply -f es-data-svc.yaml 
service "es-data-srv" created

```

Apply the specification for the Replication controller and its service for the Elastic search master nodes. 

```
 kubectl apply -f es-master-rc.yaml 
deployment "es-master" created

 kubectl apply -f es-master-svc.yaml 
service "elasticsearch-discovery" created

 kubectl get pods -w
NAME                         READY     STATUS            RESTARTS   AGE
elasticsearch-data-0         1/1       Running           0          6m
elasticsearch-data-1         1/1       Running           0          6m
elasticsearch-data-2         1/1       Running           0          5m
es-master-1371619260-0lg4h   1/1       Running           0          24s
es-master-1371619260-f0hl8   1/1       Running           0          24s
es-master-1371619260-z1mv7   0/1       PodInitializing   0          24s
es-master-1371619260-z1mv7   1/1       Running           0          26s

Verify that the master nodes have joined the cluster. 

kubectl logs po/es-master-1371619260-z1mv7

```

Apply the specification for the Replication controller and its service for the co-ordinator only nodes.

```
 kubectl apply -f es-client-rc.yaml 
deployment "es-client" created

 kubectl apply -f es-client-svc.yaml 
service "elasticsearch" created

kubectl get pods -w
NAME                         READY     STATUS    RESTARTS   AGE
elasticsearch-data-0         1/1       Running   0          15m
elasticsearch-data-1         1/1       Running   0          15m
elasticsearch-data-2         1/1       Running   0          15m
es-client-2193029848-5828s   1/1       Running   0          12s
es-client-2193029848-7xpss   1/1       Running   0          12s
es-master-1371619260-0lg4h   1/1       Running   0          10m
es-master-1371619260-f0hl8   1/1       Running   0          10m
es-master-1371619260-z1mv7   1/1       Running   0          10m

Verify that the client nodes have joined the cluster. 

kubectl logs po/es-client-2193029848-5828s


``` 

Cluster state
```
kubectl get all
NAME                            READY     STATUS    RESTARTS   AGE
po/elasticsearch-data-0         1/1       Running   0          18m
po/elasticsearch-data-1         1/1       Running   0          18m
po/elasticsearch-data-2         1/1       Running   0          17m
po/es-client-2193029848-5828s   1/1       Running   0          2m
po/es-client-2193029848-7xpss   1/1       Running   0          2m
po/es-master-1371619260-0lg4h   1/1       Running   0          12m
po/es-master-1371619260-f0hl8   1/1       Running   0          12m
po/es-master-1371619260-z1mv7   1/1       Running   0          12m

NAME                          CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
svc/elasticsearch             10.103.92.60   <pending>     9200:31989/TCP   2m
svc/elasticsearch-discovery   10.106.42.96   <none>        9300/TCP         12m
svc/es-data-srv               None           <none>        9300/TCP         14m
svc/kubernetes                10.96.0.1      <none>        443/TCP          20d

NAME                              DESIRED   CURRENT   AGE
statefulsets/elasticsearch-data   3         3         18m

NAME               DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deploy/es-client   2         2         2            2           2m
deploy/es-master   3         3         3            3           12m

NAME                      DESIRED   CURRENT   READY     AGE
rs/es-client-2193029848   2         2         2         2m
rs/es-master-1371619260   3         3         3         12m

```

### Verify the installation. 

```
/opt/pwx/bin/pxctl v l --label pvc=px-storage-elasticsearch-data-0
ID			NAME						SIZE	HA	SHARED	ENCRYPTED	IO_PRIORITY	SCALE	STATUS
517283802325048021	pvc-d59cb883-86ce-11e7-8556-ac1f6b2024cc	200 GiB	2	no	no		LOW		0	up - attached on 70.0.0.83

/opt/pwx/bin/pxctl v i 517283802325048021
Volume	:  517283802325048021
	Name            	 :  pvc-d59cb883-86ce-11e7-8556-ac1f6b2024cc
	Size            	 :  200 GiB
	Format          	 :  ext4
	HA              	 :  2
	IO Priority     	 :  LOW
	Creation time   	 :  Aug 22 07:13:52 UTC 2017
	Shared          	 :  no
	Status          	 :  up
	State           	 :  Attached: pdc-dell15
	Device Path     	 :  /dev/pxd/pxd517283802325048021
	Labels          	 :  pvc=px-storage-elasticsearch-data-0
	Reads           	 :  79
	Reads MS        	 :  157
	Bytes Read      	 :  512000
	Writes          	 :  6801
	Writes MS       	 :  89763
	Bytes Written   	 :  3358715904
	IOs in progress 	 :  0
	Bytes used      	 :  3.3 GiB
	Replica sets on nodes:
		Set  0
			Node 	 :  70.0.0.83
			Node 	 :  70.0.0.84
```

Obtain the External IP address from the elasticsearch client service.  
```
kubectl describe svc elasticsearch
Name:			elasticsearch
Namespace:		default
Labels:			component=elasticsearch
			role=client
Annotations:		kubectl.kubernetes.io/last-applied-configuration={"apiVersion":"v1","kind":"Service","metadata":{"annotations":{},"labels":{"component":"elasticsearch","role":"client"},"name":"elasticsearch","namespa...
Selector:		component=elasticsearch,role=client
Type:			LoadBalancer
IP:			10.103.92.60
Port:			http	9200/TCP
NodePort:		http	31989/TCP
Endpoints:		10.36.0.3:9200,10.44.0.2:9200
Session Affinity:	None
Events:			<none>

curl http://10.103.92.60:9200
{
  "name" : "es-client-2193029848-7xpss",
  "cluster_name" : "escluster",
  "cluster_uuid" : "tDHo-ioCShqF8SSSzHnF8Q",
  "version" : {
    "number" : "5.4.0",
    "build_hash" : "780f8c4",
    "build_date" : "2017-04-28T17:43:27.229Z",
    "build_snapshot" : false,
    "lucene_version" : "6.5.0"
  },
  "tagline" : "You Know, for Search"
}

curl http://10.103.92.60:9200/_cat/nodes?v
ip        heap.percent ram.percent cpu load_1m load_5m load_15m node.role master name
10.42.0.2           37          12   0    0.08    0.05     0.11 d         -      elasticsearch-data-1
10.36.0.2           46          27   0    0.08    0.10     0.14 m         *      es-master-1371619260-f0hl8
10.36.0.3           36          27   0    0.08    0.10     0.14 i         -      es-client-2193029848-7xpss
10.47.0.2           37          22   0    0.05    0.10     0.13 d         -      elasticsearch-data-2
10.40.0.2           40          14   0    0.03    0.12     0.17 m         -      es-master-1371619260-0lg4h
10.36.0.1           38          27   0    0.08    0.10     0.14 d         -      elasticsearch-data-0
10.44.0.2           39          47   0    0.02    0.07     0.10 i         -      es-client-2193029848-5828s
10.42.0.3           39          12   0    0.08    0.05     0.11 m         -      es-master-1371619260-z1mv7

curl -XPUT 'http://10.103.92.60:9200/customer?pretty&pretty'
{
  "acknowledged" : true,
  "shards_acknowledged" : true
}

curl -XGET 'http://10.103.92.60:9200/_cat/indices?v&pretty'
health status index    uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   customer py6RhNDKRfa7_PgEL7oqzw   5   1          0            0      1.2kb           650b

curl -XPUT 'http://10.103.92.60:9200/customer/external/1?pretty&pretty' -H 'Content-Type: application/json' -d'
{
"name": "Daenerys Targaryen"
}
'
{
  "_index" : "customer",
  "_type" : "external",
  "_id" : "1",
  "_version" : 1,
  "result" : "created",
  "_shards" : {
    "total" : 2,
    "successful" : 2,
    "failed" : 0
  },
  "created" : true
}

curl 'http://10.103.92.60:9200/customer/external/1?pretty&pretty'
{
  "_index" : "customer",
  "_type" : "external",
  "_id" : "1",
  "_version" : 1,
  "found" : true,
  "_source" : {
    "name" : "Daenerys Targaryen"
  }
}

```

## Scaling

```
kubectl scale sts elasticsearch-data --replicas=5
statefulset "elasticsearch-data" scaled

kubectl get pods -l "component=elasticsearch, role=data"
NAME                   READY     STATUS    RESTARTS   AGE
elasticsearch-data-0   1/1       Running   0          1h
elasticsearch-data-1   1/1       Running   0          1h
elasticsearch-data-2   1/1       Running   0          1h
elasticsearch-data-3   1/1       Running   0          2m
elasticsearch-data-4   1/1       Running   0          2m

curl http://10.103.92.60:9200/_cat/nodes?v
ip        heap.percent ram.percent cpu load_1m load_5m load_15m node.role master name
10.47.0.2           36          24   0    0.12    0.09     0.06 d         -      elasticsearch-data-2
10.40.0.2           40          15   0    0.07    0.12     0.13 m         -      es-master-1371619260-0lg4h
10.44.0.2           43          48   0    0.11    0.15     0.10 i         -      es-client-2193029848-5828s
10.40.0.3           37          15   0    0.07    0.12     0.13 d         -      elasticsearch-data-3
10.36.0.3           42          29   0    0.11    0.09     0.06 i         -      es-client-2193029848-7xpss
10.42.0.3           40          12   0    0.06    0.06     0.05 m         -      es-master-1371619260-z1mv7
10.42.0.2           44          12   0    0.06    0.06     0.05 d         -      elasticsearch-data-1
10.44.0.3           38          48   0    0.11    0.15     0.10 d         -      elasticsearch-data-4
10.36.0.1           40          29   0    0.11    0.09     0.06 d         -      elasticsearch-data-0
10.36.0.2           53          29   0    0.11    0.09     0.06 m         *      es-master-1371619260-f0hl8

```