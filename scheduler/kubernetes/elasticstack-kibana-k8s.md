---
layout: page
title: "Deploy Elastic Search and Kibana with Portworx on Kubernetes"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, pv, persistent disk, elastic, elastic stack, elastic search, kibana
sidebar: home_sidebar
meta-description: "Find out how to easily deploy Elasticsearch and Kibana on Kubernetes using Portworx to preserve state!"
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
    A node which only routes requests, handles the search reduce phase, and distributes bulk indexing. Consumers of the elastic search cluster interact with the coordinator nodes.

## Prerequisites
-    A running Kubernetes cluster with v 1.6+
-    [Deploy Portworx on your kubernetes cluster](https://docs.portworx.com/scheduler/kubernetes/install.html). PX runs on each node of your kubernetes cluster as a DaemonSet.

## Install

### Portworx StorageClass for Volume Provisioning

Portworx provides volume(s) to the elastic search data and master nodes.
Create ```portworx-sc.yaml``` with Portworx as the provisioner and apply the configuration. These storage classes create Portworx volumes with 2 replicas when referenced via a PersistentVolumeClaim.

```
kind: StorageClass
apiVersion: storage.k8s.io/v1beta1
metadata:
    name: px-es-data-sc
provisioner: kubernetes.io/portworx-volume
parameters:
   repl: "2"
   group: "elastic_data_vg"
   fg: "false"
---
kind: StorageClass
apiVersion: storage.k8s.io/v1beta1
metadata:
    name: px-es-master-sc
provisioner: kubernetes.io/portworx-volume
parameters:
   repl: "2"
   group: "elastic_master_vg"
   fg: "false"
---

$ kubectl apply -f portworx-sc.yaml
```

### Install Elasticsearch cluster
In this section we will create an ES cluster with the following:
-    3 master nodes using a Kubernetes `StatefulSet` backed by Portworx volumes
-    3 data nodes using a Kubernetes `StatefulSet` backed by Portworx volumes
-    2 coordinator nodes using a Kubernetes `Deployment`

All pods will use the stork scheduler to enable them to be placed closer to where their data is located.

Create ```es-master-svc.yaml``` with the following content

```
apiVersion: v1
kind: Service
metadata:
  name: elasticsearch-discovery
  labels:
    component: elasticsearch
    role: master
spec:
  selector:
    component: elasticsearch
    role: master
  ports:
  - name: transport
    port: 9300
    protocol: TCP
```

Create ```es-master-sts.yaml``` with the following content
```
apiVersion: apps/v1beta1
kind: StatefulSet
metadata:
  name: elasticsearch-master
  labels:
    component: elasticsearch
    role: master
spec:
  serviceName: elasticsearch-master
  replicas: 3
  template:
    metadata:
      labels:
        component: elasticsearch
        role: master
    spec:
      # Use the stork scheduler to enable more efficient placement of the pods
      schedulerName: stork
      initContainers:
      - name: init-sysctl
        image: busybox
        imagePullPolicy: IfNotPresent
        command: ["sysctl", "-w", "vm.max_map_count=262144"]
        securityContext:
          privileged: true
      containers:
      - name: elasticsearch-master-pod
        securityContext:
          privileged: true
          capabilities:
            add:
              - IPC_LOCK
              - SYS_RESOURCE
        image: quay.io/pires/docker-elasticsearch-kubernetes:6.3.2
        imagePullPolicy: Always
        env:
        - name: NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        - name: NODE_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: "CLUSTER_NAME"
          value: "escluster"
        - name: "NUMBER_OF_MASTERS"
          value: "2"
        - name: NODE_MASTER
          value: "true"
        - name: NODE_INGEST
          value: "false"
        - name: NODE_DATA
          value: "false"
        - name: HTTP_ENABLE
          value: "false"
        - name: "ES_JAVA_OPTS"
          value: "-Xms256m -Xmx256m"
        ports:
        - containerPort: 9300
          name: transport
          protocol: TCP
        volumeMounts:
        - name: px-storage
          mountPath: /data
  volumeClaimTemplates:
  - metadata:
      name: px-storage
      annotations:
        volume.beta.kubernetes.io/storage-class: px-es-master-sc
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 80Gi
```

Apply the specification for the Elastic search Master nodes and the service for the same.

```
$ kubectl apply -f es-master-svc.yaml
service "elasticsearch-discovery" created

$ kubectl apply -f es-master-sts.yaml
statefulset "es-master" created

$ kubectl get pods
NAME                         READY     STATUS            RESTARTS   AGE
elasticsearch-master-0       0/1       PodInitializing   0          22s
elasticsearch-master-1       0/1       PodInitializing   0          22s
elasticsearch-master-2       0/1       PodInitializing   0          22s
```

Verify that the master nodes have create and joined the cluster.
```
$ kubectl logs po/elasticsearch-master-0
```

Create ```es-coordinator-svc.yaml``` with the following content
```
apiVersion: v1
kind: Service
metadata:
  name: elasticsearch
  labels:
    component: elasticsearch
    role: coordinator
spec:
  selector:
    component: elasticsearch
    role: coordinator
  ports:
  - name: http
    port: 9200
    protocol: TCP
```

Create ```es-coordinator-deployment.yaml``` with the following content
```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: elasticsearch-coordinator
  labels:
    component: elasticsearch
    role: coordinator
spec:
  replicas: 2
  template:
    metadata:
      labels:
        component: elasticsearch
        role: coordinator
    spec:
      initContainers:
      - name: init-sysctl
        image: busybox
        imagePullPolicy: IfNotPresent
        command: ["sysctl", "-w", "vm.max_map_count=262144"]
        securityContext:
          privileged: true
      containers:
      - name: elasticsearch-coordinator
        securityContext:
          privileged: false
          capabilities:
            add:
              - IPC_LOCK
              - SYS_RESOURCE
        image: quay.io/pires/docker-elasticsearch-kubernetes:6.3.2
        imagePullPolicy: Always
        env:
        - name: NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        - name: NODE_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: "CLUSTER_NAME"
          value: "escluster"
        - name: NODE_MASTER
          value: "false"
        - name: NODE_DATA
          value: "false"
        - name: HTTP_ENABLE
          value: "true"
        - name: "ES_JAVA_OPTS"
          value: "-Xms256m -Xmx256m"
        ports:
        - containerPort: 9200
          name: http
          protocol: TCP
        - containerPort: 9300
          name: transport
          protocol: TCP
        volumeMounts:
        - name: storage
          mountPath: /data
      volumes:
          - emptyDir:
              medium: ""
            name: "storage"
```

Apply the specification for the coordinator `Deployment` and its service.
```
$ kubectl apply -f es-coordinator-deployment.yaml
deployment "elasticsearch-coordinator" created

$ kubectl apply -f es-coordinator-svc.yaml
service "elasticsearch" created

$ kubectl get pods -w
NAME                                            READY     STATUS    RESTARTS   AGE
po/elasticsearch-coordinator-2155074821-nxdkt   1/1       Running   0          1m
po/elasticsearch-coordinator-2155074821-v0w31   1/1       Running   0          1m
po/elasticsearch-master-0                       1/1       Running   0          4m
po/elasticsearch-master-1                       1/1       Running   0          4m
po/elasticsearch-master-2                       1/1       Running   0          4m
```

Verify that the coordinator nodes have joined the cluster.
```
$ kubectl logs po/elasticsearch-coordinator-2155074821-nxdkt
```

Create ```es-data-svc.yaml``` with the following content
```
apiVersion: v1
kind: Service
metadata:
  name: elasticsearch-data
  labels:
    component: elasticsearch
    role: data
spec:
  clusterIP: None
  selector:
    component: elasticsearch
    role: data
  ports:
  - name: transport
    port: 9300
    protocol: TCP
```

Create ```es-data-sts.yaml``` with the following content
```
apiVersion: apps/v1beta1
kind: StatefulSet
metadata:
  name: elasticsearch-data
  labels:
    component: elasticsearch
    role: data
spec:
  serviceName: elasticsearch-data
  replicas: 3
  template:
    metadata:
      labels:
        component: elasticsearch
        role: data
    spec:
      initContainers:
      - name: init-sysctl
        image: busybox
        imagePullPolicy: IfNotPresent
        command: ["sysctl", "-w", "vm.max_map_count=262144"]
        securityContext:
          privileged: true
      containers:
      - name: elasticsearch-data-pod
        securityContext:
          privileged: true
          capabilities:
            add:
              - IPC_LOCK
        image: quay.io/pires/docker-elasticsearch-kubernetes:6.3.2
        imagePullPolicy: Always
        env:
        - name: NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        - name: NODE_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: "CLUSTER_NAME"
          value: "escluster"
        - name: NODE_MASTER
          value: "false"
        - name: NODE_INGEST
          value: "false"
        - name: HTTP_ENABLE
          value: "false"
        - name: "ES_JAVA_OPTS"
          value: "-Xms256m -Xmx256m"
        ports:
        - containerPort: 9300
          name: transport
          protocol: TCP
        volumeMounts:
        - name: px-storage
          mountPath: /data
  volumeClaimTemplates:
  - metadata:
      name: px-storage
      annotations:
        volume.beta.kubernetes.io/storage-class: px-es-data-sc
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 80Gi
```

Apply the StatefulSet spec for the Elastic search data nodes along with the headless service.
```
$ kubectl apply -f es-data-svc.yaml
service "es-data-srv" created

$ kubectl apply -f es-data-sts.yaml
statefulset "elasticsearch-data" created

$ kubectl get pods -l "component=elasticsearch, role=data" -w
NAME                   READY     STATUS            RESTARTS   AGE
elasticsearch-data-0   0/1       PodInitializing   0          24s
elasticsearch-data-0   1/1       Running                0          26s
elasticsearch-data-1   0/1       Pending                0          0s
elasticsearch-data-1   0/1       Pending           0          0s
elasticsearch-data-1   0/1       Pending                0          3s
elasticsearch-data-1   0/1       Init:0/1            0          3s
elasticsearch-data-1   0/1       PodInitializing   0          5s
elasticsearch-data-1   1/1       Running                0          51s
elasticsearch-data-2   0/1       Pending                0          0s
elasticsearch-data-2   0/1       Pending                0          0s
elasticsearch-data-2   0/1       Pending                0          3s
elasticsearch-data-2   0/1       Init:0/1            0          3s
elasticsearch-data-2   0/1       PodInitializing   0          5s
elasticsearch-data-2   1/1       Running                0          18s
```
Cluster state
```
$ kubectl get all
NAME                                            READY     STATUS    RESTARTS   AGE
po/elasticsearch-data-0                         1/1       Running   0          18m
po/elasticsearch-data-1                         1/1       Running   0          18m
po/elasticsearch-data-2                         1/1       Running   0          17m
po/elasticsearch-coordinator-2193029848-5828s   1/1       Running   0          2m
po/elasticsearch-coordinator-2193029848-7xpss   1/1       Running   0          2m
po/elasticsearch-master-0                       1/1       Running   0          12m
po/elasticsearch-master-1                       1/1       Running   0          12m
po/elasticsearch-master-2                       1/1       Running   0          12m

NAME                          CLUSTER-IP     EXTERNAL-IP    PORT(S)          AGE
svc/elasticsearch             10.105.105.41   <pending>     9200:31989/TCP   2m
svc/elasticsearch-discovery   10.106.42.96    <none>        9300/TCP         12m
svc/es-data-srv               None            <none>        9300/TCP         14m
svc/kubernetes                10.96.0.1       <none>        443/TCP          20d

NAME                              DESIRED   CURRENT   AGE
statefulsets/elasticsearch-data   3         3         18m
statefulsets/elasticsearch-master 3         3         18m

NAME                               DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deploy/elasticsearch-coordinator   2         2         2            2           2m

NAME                                      DESIRED   CURRENT   READY     AGE
rs/elasticsearch-coordinator-2193029848   2         2         2         2m
```

### Verify Elastic Search installation.

- Verify that Portworx Volumes are used for the elasticsearch cluster.
- Verify the cluster state by inserting and querying indexes.

Portworx volumes are created with 2 replicas for storing Indexes and Documents for Elasticsearch. This is based on the Storageclass definition.

```
$ kubectl get pv
NAME                                       CAPACITY   ACCESSMODES   RECLAIMPOLICY     STATUS    CLAIM                                       STORAGECLASS     REASON    AGE
pvc-60acf83a-e6b6-11e8-ba45-000c29dcfd58   80Gi       RWO            Delete           Bound     default/px-storage-elasticsearch-data-0     px-es-data-sc               6m
pvc-77b53fcc-e6b6-11e8-ba45-000c29dcfd58   80Gi       RWO            Delete           Bound     default/px-storage-elasticsearch-master-0   px-es-master-sc             5m
pvc-8a9ae703-e6b6-11e8-ba45-000c29dcfd58   80Gi       RWO            Delete           Bound     default/px-storage-elasticsearch-master-1   px-es-master-sc             4m
pvc-a48b03bc-e6b6-11e8-ba45-000c29dcfd58   80Gi       RWO            Delete           Bound     default/px-storage-elasticsearch-data-1     px-es-data-sc               4m
pvc-aa10c4d6-e6b6-11e8-ba45-000c29dcfd58   80Gi       RWO            Delete           Bound     default/px-storage-elasticsearch-master-2   px-es-master-sc             3m
pvc-b5911226-e6b6-11e8-ba45-000c29dcfd58   80Gi       RWO            Delete           Bound     default/px-storage-elasticsearch-data-2     px-es-data-sc               3m

$ kubectl get pvc
NAME                                STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS      AGE
px-storage-elasticsearch-data-0     Bound     pvc-60acf83a-e6b6-11e8-ba45-000c29dcfd58   80Gi       RWO            px-es-data-sc     8m
px-storage-elasticsearch-data-1     Bound     pvc-a48b03bc-e6b6-11e8-ba45-000c29dcfd58   80Gi       RWO            px-es-data-sc     6m
px-storage-elasticsearch-data-2     Bound     pvc-b5911226-e6b6-11e8-ba45-000c29dcfd58   80Gi       RWO            px-es-data-sc     6m
px-storage-elasticsearch-master-0   Bound     pvc-77b53fcc-e6b6-11e8-ba45-000c29dcfd58   80Gi       RWO            px-es-master-sc   7m
px-storage-elasticsearch-master-1   Bound     pvc-8a9ae703-e6b6-11e8-ba45-000c29dcfd58   80Gi       RWO            px-es-master-sc   7m
px-storage-elasticsearch-master-2   Bound     pvc-aa10c4d6-e6b6-11e8-ba45-000c29dcfd58   80Gi       RWO            px-es-master-sc   6m

$ /opt/pwx/bin/pxctl volume list
ID                    NAME                                                SIZE      HA   SHARED    ENCRYPTED    IO_PRIORITY    STATUS                          HA-STATE
507832545683763135    pvc-60acf83a-e6b6-11e8-ba45-000c29dcfd58            80 GiB    2    no        no           LOW            up - attached on 70.0.83.216    Up
371131979294695563    pvc-77b53fcc-e6b6-11e8-ba45-000c29dcfd58            80 GiB    2    no        no           LOW            up - attached on 70.0.83.218    Up
87503122675290230     pvc-8a9ae703-e6b6-11e8-ba45-000c29dcfd58            80 GiB    2    no        no           LOW            up - attached on 70.0.83.216    Up
102878661305450280    pvc-a48b03bc-e6b6-11e8-ba45-000c29dcfd58            80 GiB    2    no        no           LOW            up - attached on 70.0.83.218    Up
476683850212083469    pvc-aa10c4d6-e6b6-11e8-ba45-000c29dcfd58            80 GiB    2    no        no           LOW            up - attached on 70.0.83.223    Up
923503818074837680    pvc-b5911226-e6b6-11e8-ba45-000c29dcfd58            80 GiB    2    no        no           LOW            up - attached on 70.0.83.223    Up

$ /opt/pwx/bin/pxctl volume list --label pvc=px-storage-elasticsearch-data-0
ID                    NAME                                        SIZE      HA   SHARED    ENCRYPTED     IO_PRIORITY    STATUS                          HA-STATE
507832545683763135    pvc-60acf83a-e6b6-11e8-ba45-000c29dcfd58    80 GiB    2    no        no            LOW            up - attached on 70.0.83.216    Up


$ /opt/pwx/bin/pxctl volume inspect 507832545683763135
Volume    :  507832545683763135
    Name                 :  pvc-60acf83a-e6b6-11e8-ba45-000c29dcfd58
    Group                 :  elastic_data_vg
    Size                 :  80 GiB
    Format               :  ext4
    HA                   :  2
    IO Priority          :  LOW
    Creation time        :  Nov 12 20:06:04 UTC 2018
    Shared               :  no
    Status               :  up
    State                :  Attached: disrani-noon-thunder-1 (70.0.83.216)
    Device Path          :  /dev/pxd/pxd507832545683763135
    Labels               :  pvc=px-storage-elasticsearch-data-0,namespace=default
    Reads                :  60
    Reads MS             :  284
    Bytes Read           :  1130496
    Writes               :  2879
    Writes MS            :  315432
    Bytes Written        :  1344454656
    IOs in progress      :  1
    Bytes used           :  1.4 GiB
    Replica sets on nodes:
        Set 0
          Node          : 70.0.83.223 (Pool 1)
          Node          : 70.0.83.216 (Pool 1)
    Replication Status     :  Up
    Volume consumers     : 
        - Name           : elasticsearch-data-0 (60adf461-e6b6-11e8-ba45-000c29dcfd58) (Pod)
          Namespace      : default
          Running on     : disrani-noon-thunder-1
          Controlled by  : elasticsearch-data (StatefulSet)
```

### Verify Elastic search cluster state.

Obtain the External IP address from the elasticsearch coordinator service.
```
kubectl describe svc elasticsearch
Name:            elasticsearch
Namespace:        default
Labels:            component=elasticsearch
            role=coordinator
Annotations:        kubectl.kubernetes.io/last-applied-configuration={"apiVersion":"v1","kind":"Service","metadata":{"annotations":{},"labels":{"component":"elasticsearch","role":"coordinator"},"name":"elasticsearch","namespa...
Selector:        component=elasticsearch,role=coordinator
Type:              LoadBalancer
IP:                10.105.105.41
Port:                  9200/TCP
NodePort:            32058/TCP
Endpoints:        10.36.0.1:9200,10.47.0.3:9200
Session Affinity:    None
Events:            <none>

$ kubectl exec -it elasticsearch-master-0  curl 'http://elasticsearch.default.svc:9200'
{
  "name" : "elasticsearch-coordinator-2155074821-nxdkt",
  "cluster_name" : "escluster",
  "cluster_uuid" : "zAYA9ERGQgCEclvYHCsOsA",
  "version" : {
    "number" : "5.5.0",
    "build_hash" : "260387d",
    "build_date" : "2017-06-30T23:16:05.735Z",
    "build_snapshot" : false,
    "lucene_version" : "6.6.0"
  },
  "tagline" : "You Know, for Search"
}

$ kubectl exec -it elasticsearch-master-0  curl 'http://elasticsearch.default.svc:9200/_cat/nodes?v'
ip        heap.percent ram.percent cpu load_1m load_5m load_15m node.role master name
10.44.0.2           41          41   0    0.00    0.03     0.08 m         -      elasticsearch-master-0
10.36.0.1           43          18   0    0.07    0.05     0.05 i         -      elasticsearch-coordinator-2155074821-v0w31
10.40.0.2           49          15   0    0.05    0.07     0.11 m         *      elasticsearch-master-1
10.47.0.3           43          20   0    0.13    0.11     0.13 i         -      elasticsearch-coordinator-2155074821-nxdkt
10.47.0.4           42          20   0    0.13    0.11     0.13 d         -      elasticsearch-data-2
10.47.0.2           39          20   0    0.13    0.11     0.13 m         -      elasticsearch-master-2
10.42.0.2           41          13   0    0.00    0.04     0.10 d         -      elasticsearch-data-1
10.40.0.3           42          15   0    0.05    0.07     0.11 d         -      elasticsearch-data-0

$ kubectl exec -it elasticsearch-master-0 curl -- -XPUT 'http://elasticsearch.default.svc:9200/customer?pretty&pretty'
{
  "acknowledged" : true,
  "shards_acknowledged" : true
}

$ kubectl exec -it elasticsearch-master-0 curl -- -XGET 'http://elasticsearch.default.svc:9200/_cat/indices?v&pretty'
health status index    uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   customer -Cort549Sn6q4gmbwicOMA   5   1          0            0      1.5kb           810b

$ kubectl exec -it elasticsearch-master-0 curl -- -XPUT 'http://elasticsearch.default.svc:9200/customer/external/1?pretty&pretty' -H 'Content-Type: application/json' -d'
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

$ kubectl exec -it elasticsearch-master-0 curl -- -XGET 'http://elasticsearch.default.svc:9200/customer/external/1?pretty&pretty'
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
### Install Kibana

Create ```kibana-svc.yaml``` with the following content:
```
apiVersion: v1
kind: Service
metadata:
  name: kibana
  namespace: default
  labels:
    component: kibana
spec:
  selector:
    component: kibana
  type: LoadBalancer
  ports:
  - name: http
    port: 80
    targetPort: 5601
    protocol: TCP
```

Create `kibana-deployment.yaml` with the following content:
```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: kibana
  namespace: default
  labels:
    component: kibana
spec:
  replicas: 1
  selector:
    matchLabels:
     component: kibana
  template:
    metadata:
      labels:
        component: kibana
    spec:
      containers:
      - name: kibana
        image: docker.elastic.co/kibana/kibana:6.3.2
        env:
        - name: "CLUSTER_NAME"
          value: "escluster"
        - name: XPACK_SECURITY_ENABLED
          value: 'false'
        - name: XPACK_GRAPH_ENABLED
          value: 'false'
        - name: XPACK_ML_ENABLED
          value: 'false'
        - name: XPACK_REPORTING_ENABLED
          value: 'false'
        - name: ELASTICSEARCH_URL
          value: 'http://elasticsearch.default.svc:9200'
        resources:
          limits:
            cpu: 1000m
          requests:
            cpu: 100m
        ports:
        - containerPort: 5601
          name: kibana
          protocol: TCP
```

Deploy the Kibana spec for the `Deployment` as well as the service.
```
$ kubectl apply -f kibana-svc.yaml
service "kibana" created

kubectl describe svc/kibana
Name:     kibana
Namespace:    default
Labels:     component=kibana
Annotations:    kubectl.kubernetes.io/last-applied-configuration={"apiVersion":"v1","kind":"Service","metadata":{"annotations":{},"labels":{"component":"kibana"},"name":"kibana","namespace":"default"},"spec":{"ports"...
Selector:   component=kibana
Type:     LoadBalancer
IP:         10.102.83.180
Port:       80/TCP
NodePort:        32645/TCP
Endpoints:        <none>
Session Affinity:    None
Events:            <none>

$ kubectl apply -f kibana-deployment.yaml
deployment "kibana" created

$ kubectl get pods -l "component=kibana" -w
NAME                      READY     STATUS    RESTARTS   AGE
kibana-2713637544-4wxsk   1/1       Running   0          12s


$ kubectl logs po/kibana-2713637544-4wxsk

{"type":"log","@timestamp":"2017-08-23T11:36:19Z","tags":["listening","info"],"pid":1,"message":"Server running at http://0:5601"}
```

### Verify Kibana Installation

Insert data into Elasticsearch and verify that Kibana is able to search for the data in Elastic Search.
This will help create dashboards and visualizations.

Save the data from the following location:
[Download accounts.json](/k8s-samples/efk/accounts.json?raw=true)
```
$ kubectl exec -it elasticsearch-master-0 curl -- -XGET 'https://docs.portworx.com/k8s-samples/efk/accounts.json?raw=true' -o accounts.json
```
```
$ kubectl exec -it elasticsearch-master-0 curl -- -H "Content-Type:application/json" -XPOST 'http://elasticsearch.default.svc:9200/bank/account/_bulk?pretty&refresh' --data-binary "@accounts.json"

$ kubectl exec -it elasticsearch-master-0 curl -- 'http://elasticsearch.default.svc:9200/_cat/indices?v
health status index    uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   bank     7Ll5S-NeSHK3subHKhA7Dg   5   1       1000            0      1.2mb        648.1kb
green  open   .kibana  uJnR9Dp5RdCvAEJ6bg-mEQ   1   1          2            0     10.8kb          5.4kb
green  open   customer -Cort549Sn6q4gmbwicOMA   5   1          1            0      8.2kb          4.1kb
```

Once you have run the above command you should see `bank` and `customer` indices in your elasticsearch cluster.
Search for them through your Kibana dashboard.

Bank Index with its documents

![bankIndex](/images/kibanaBank.png){:width="655px" height="200px"}

## Scaling

Portworx runs as a DaemonSet in Kubernetes. Hence when you add a new node to your kuberentes cluster you do not need to explicitly run Portworx on it.

If you did use the [Terraform scripts](https://github.com/portworx/terraporx) to create a kubernetes cluster, you would need to update the minion count and apply the changes via Terraform to add a new Node.

Scale your Elastic Search Cluster.
```
$ kubectl scale sts elasticsearch-data --replicas=5
statefulset "elasticsearch-data" scaled

$ kubectl get pods -l "component=elasticsearch, role=data" -w
NAME                   READY     STATUS            RESTARTS   AGE
elasticsearch-data-0   1/1       Running           0          21m
elasticsearch-data-1   1/1       Running           0          21m
elasticsearch-data-2   1/1       Running           0          20m
elasticsearch-data-3   0/1       PodInitializing   0          22s
elasticsearch-data-3   1/1       Running              0          1m
elasticsearch-data-4   0/1       Pending              0          0s
elasticsearch-data-4   0/1       Pending              0          0s
elasticsearch-data-4   0/1       Pending              0          3s
elasticsearch-data-4   0/1       Init:0/1          0          3s
elasticsearch-data-4   0/1       PodInitializing   0          6s
elasticsearch-data-4   1/1       Running              0          9s

$ kubectl exec -it elasticsearch-master-0 curl -- 'http://elasticsearch.default.svc:9200/_cat/nodes?v'
ip        heap.percent ram.percent cpu load_1m load_5m load_15m node.role master name
10.40.0.2           35          16   0    0.06    0.09     0.13 m         *      elasticsearch-master-0
10.44.0.2           47          42   0    0.00    0.12     0.17 m         -      elasticsearch-master-1
10.44.0.3           49          42   0    0.00    0.12     0.17 d         -      elasticsearch-data-4
10.47.0.4           36          21   0    0.29    0.11     0.12 d         -      elasticsearch-data-2
10.47.0.2           46          21   0    0.29    0.11     0.12 m         -      elasticsearch-master-2
10.42.0.2           41          15   0    0.01    0.15     0.16 d         -      elasticsearch-data-1
10.40.0.3           42          16   0    0.06    0.09     0.13 d         -      elasticsearch-data-0
10.36.0.2           48          20   0    0.01    0.07     0.08 d         -      elasticsearch-data-3
10.47.0.3           51          21   0    0.29    0.11     0.12 i         -      elasticsearch-coordinator-2155074821-nxdkt
10.36.0.1           51          20   0    0.01    0.07     0.08 i         -      elasticsearch-coordinator-2155074821-v0w31


$ kubectl get pvc
NAME                                STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS      AGE
px-storage-elasticsearch-data-0     Bound     pvc-60acf83a-e6b6-11e8-ba45-000c29dcfd58   80Gi       RWO            px-es-data-sc     18m
px-storage-elasticsearch-data-1     Bound     pvc-a48b03bc-e6b6-11e8-ba45-000c29dcfd58   80Gi       RWO            px-es-data-sc     16m
px-storage-elasticsearch-data-2     Bound     pvc-b5911226-e6b6-11e8-ba45-000c29dcfd58   80Gi       RWO            px-es-data-sc     15m
px-storage-elasticsearch-data-3     Bound     pvc-98b350a7-e6b8-11e8-ba45-000c29dcfd58   80Gi       RWO            px-es-data-sc     2m
px-storage-elasticsearch-data-4     Bound     pvc-b95c996d-e6b8-11e8-ba45-000c29dcfd58   80Gi       RWO            px-es-data-sc     1m
px-storage-elasticsearch-master-0   Bound     pvc-77b53fcc-e6b6-11e8-ba45-000c29dcfd58   80Gi       RWO            px-es-master-sc   17m
px-storage-elasticsearch-master-1   Bound     pvc-8a9ae703-e6b6-11e8-ba45-000c29dcfd58   80Gi       RWO            px-es-master-sc   16m
px-storage-elasticsearch-master-2   Bound     pvc-aa10c4d6-e6b6-11e8-ba45-000c29dcfd58   80Gi       RWO            px-es-master-sc   15m

$ /opt/pwx/bin/pxctl volume list
ID                    NAME                                        SIZE      HA   SHARED    ENCRYPTED     IO_PRIORITY    STATUS                          HA-STATE
507832545683763135    pvc-60acf83a-e6b6-11e8-ba45-000c29dcfd58    80 GiB    2    no        no            LOW            up - attached on 70.0.83.216    Up
371131979294695563    pvc-77b53fcc-e6b6-11e8-ba45-000c29dcfd58    80 GiB    2    no        no            LOW            up - attached on 70.0.83.218    Up
87503122675290230     pvc-8a9ae703-e6b6-11e8-ba45-000c29dcfd58    80 GiB    2    no        no            LOW            up - attached on 70.0.83.216    Up
1065394113641908183   pvc-98b350a7-e6b8-11e8-ba45-000c29dcfd58    80 GiB    2    no        no            LOW            up - attached on 70.0.83.223    Up
102878661305450280    pvc-a48b03bc-e6b6-11e8-ba45-000c29dcfd58    80 GiB    2    no        no            LOW            up - attached on 70.0.83.218    Up
476683850212083469    pvc-aa10c4d6-e6b6-11e8-ba45-000c29dcfd58    80 GiB    2    no        no            LOW            up - attached on 70.0.83.223    Up
923503818074837680    pvc-b5911226-e6b6-11e8-ba45-000c29dcfd58    80 GiB    2    no        no            LOW            up - attached on 70.0.83.223    Up
620487557616493514    pvc-b95c996d-e6b8-11e8-ba45-000c29dcfd58    80 GiB    2    no        no            LOW            up - attached on 70.0.83.216    Up
```

## Failover

### Pod Failover for Elastic search.
Portworx provides durable storage for the Elastic search pods.
Cordon a node so that pods do not get scheduled on it, delete a pod manually to simulate a failure scenario and watch the pod get scheduled on another node. However the StatefulSet with PX as the volume would reattach the

```
$ kubectl get pods -l "component=elasticsearch, role=data"  -o wide
NAME                   READY     STATUS    RESTARTS   AGE       IP          NODE
elasticsearch-data-0   1/1       Running   0          1h        10.40.0.3   pdc3-sm19
elasticsearch-data-1   1/1       Running   0          1h        10.42.0.2   pdc3-sm18
elasticsearch-data-2   1/1       Running   0          1h        10.47.0.4   pdc3-sm16
elasticsearch-data-3   1/1       Running   0          43m       10.39.0.1   70-0-5-129.pools.spcsdns.net
elasticsearch-data-4   1/1       Running   0          1h        10.44.0.3   pdc-dell14

$ kubectl cordon 70-0-5-129.pools.spcsdns.net
node "70-0-5-129.pools.spcsdns.net" cordoned

$ kubectl get nodes
NAME                           STATUS                     AGE       VERSION
70-0-5-129.pools.spcsdns.net   Ready,SchedulingDisabled   20d       v1.7.2
pdc-dell14                     Ready                      21d       v1.7.2
pdc-dell15                     Ready                      21d       v1.7.2
pdc-sm13.portcolo.com          Ready                      21d       v1.7.2
pdc3-sm16                      Ready                      21d       v1.7.2
pdc3-sm18                      Ready                      21d       v1.7.2
pdc3-sm19                      Ready                      21d       v1.7.2
```

Find the docs count on this data node.
```
$ kubectl exec -it elasticsearch-master-0 curl --'http://elasticsearch.default.svc:9200/_nodes/elasticsearch-data-3/stats/indices'

{"_nodes":{"total":1,"successful":1,"failed":0},"cluster_name":"escluster","nodes":{"Y53C7xqeS-Wi2UHDdE3hgg":{"timestamp":1503479282677,"name":"elasticsearch-data-3","transport_address":"10.39.0.1:9300","host":"10.39.0.1","ip":"10.39.0.1:9300","roles":["data"],"indices":{"docs":{"count":401,"deleted":0}.....

$ kubectl delete po/elasticsearch-data-3
pod "elasticsearch-data-3" deleted

$ kubectl get pods -l "component=elasticsearch, role=data"  -o wide -w
NAME                   READY     STATUS        RESTARTS       AGE       IP          NODE
elasticsearch-data-0   1/1       Running               0         1h        10.40.0.3   pdc3-sm19
elasticsearch-data-1   1/1       Running               0         1h        10.42.0.2   pdc3-sm18
elasticsearch-data-2   1/1       Running               0         1h        10.47.0.4   pdc3-sm16
elasticsearch-data-3   1/1       Terminating           0         46m       10.39.0.1   70-0-5-129.pools.spcsdns.net
elasticsearch-data-4   1/1       Running               0         1h        10.44.0.3   pdc-dell14
elasticsearch-data-3   0/1       Terminating           0         46m       <none>      70-0-5-129.pools.spcsdns.net
elasticsearch-data-3   0/1       Terminating           0         46m       <none>      70-0-5-129.pools.spcsdns.net
elasticsearch-data-3   0/1       Terminating           0         46m       <none>      70-0-5-129.pools.spcsdns.net
elasticsearch-data-3   0/1       Pending                  0         0s        <none>        <none>
elasticsearch-data-3   0/1       Pending                  0         0s        <none>        pdc-dell15
elasticsearch-data-3   0/1       Init:0/1              0         0s        <none>        pdc-dell15
elasticsearch-data-3   0/1       PodInitializing    0         3s        10.36.0.2   pdc-dell15
elasticsearch-data-3   1/1       Running               0         6s        10.36.0.2   pdc-dell15
```

Verify that the same volume has been attached back to the pod which was scheduled post failover.
```
$ kubectl exec -it elasticsearch-master-0 curl -- 'http://elasticsearch.default.svc:9200/_nodes/elasticsearch-data-3/stats/indices'

{"_nodes":{"total":1,"successful":1,"failed":0},"cluster_name":"escluster","nodes":{"Y53C7xqeS-Wi2UHDdE3hgg":{"timestamp":1503479456687,"name":"elasticsearch-data-3","transport_address":"10.36.0.2:9300","host":"10.36.0.2","ip":"10.36.0.2:9300","roles":["data"],"indices":{"docs":{"count":401,"deleted":0},
```

### Node Failover

In the case of a StatefulSet if the node is unreachable, which could happen in either of two cases
- The node is down for maintenance
- There has been a network partition.

There is no way for kubernetes to know which of the case is it. Hence Kubernetes would not schedule the StatefulSet and the pods running on those nodes would enter the ‘Terminating’ or ‘Unknown’ state after a timeout.
If there was a network partition and when the partition heals, kubernetes will complete the deletion of the Pod and remove it from the API server. It would subsequently schedule a new pod to honor the replication requirements mentioned in the Podspec.

For further information : [StatefulSet Pod Deletion](https://kubernetes.io/docs/tasks/run-application/force-delete-stateful-set-pod/)

Decomissioning a kubernetes node deletes the node object form the APIServer.
Before that you would want to decomission your Portworx node from the cluster.
Follow the steps mentioned in [Decommision a Portworx node](/scheduler/kubernetes/k8s-node-decommission.html)
Once done, delete the kubernetes node if it requires to be deleted permanently.
