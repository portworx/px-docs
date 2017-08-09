---
layout: page
title: "Deploy Apache Kafka and Zookeeper with Portworx on Kubernetes"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, pv, persistent disk, kafka, zookeeper
sidebar: home_sidebar
---

* TOC
{:toc}

These below instructions will provide you a step by step guide in deploying Apache Kafka and Zookeeper with Portworx on Kubernetes. 

Kubernetes provides management of stateful workloads using Statefulsets. Apache Kafka is a distributed streaming platform. [Apache kafka](https://kafka.apache.org/) is used in multiple cases where the need might be to provide realtime streaming of data to systems or in using it as an enterprise messaging system. 
Apache Kafka uses [Zookeeper](https://zookeeper.apache.org/) for maintaining configurations and distributed synchronization. 

## Prerequisites

-	A running Kubernetes cluster with v 1.6+ 
-	All the kubernetes nodes should allow [shared volume propagation](https://docs.portworx.com/knowledgebase/shared-mount-propogation.html). PX requires this since it provisions volumes in containers.  
-	[Deploy Portworx on your kubernetes cluster](https://docs.portworx.com/scheduler/kubernetes/install.html). PX runs on each node of your kubernetes cluster as a daemonset. 

## Install

### Portworx StorageClass for Volume Provisioning

Portworx provides volume(s) to Zookeeper as well as Kafka. 
Create ```portworx-sc.yml``` with Portworx as the provisioner and apply the configuration

```
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: portworx-sc
provisioner: kubernetes.io/portworx-volume
parameters:
  repl: "1"
  priority_io: "high"
---
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: portworx-sc-rep2
provisioner: kubernetes.io/portworx-volume
parameters:
  repl: "2"
  priority_io: "high"
---

kubectl apply -f portworx-sc.yml
	
```

### Install Zookeeper

A statefulset in Kubernetes requires a headless service to provide network identity to the pods it creates. 
This is also important for the later stages of the deployment of Kafka, since, we would need to access Zookeeper via the dns records that are created by this headless service. 

Create ```zookeeper-all.yaml``` with the below content. 

This spec a headless service, a config map, a PodDisruption budget and the Zookeeper Statefulset. 

```
apiVersion: v1
kind: Service
metadata:
  name: zk-headless
  labels:
    app: zk-headless
spec:
  ports:
  - port: 2888
    name: server
  - port: 3888
    name: leader-election
  clusterIP: None
  selector:
    app: zk
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: zk-config
data:
  ensemble: "zk-0;zk-1;zk-2"
  jvm.heap: "2G"
  tick: "2000"
  init: "10"
  sync: "5"
  client.cnxns: "60"
  snap.retain: "3"
  purge.interval: "1"
---
apiVersion: policy/v1beta1
kind: PodDisruptionBudget
metadata:
  name: zk-budget
spec:
  selector:
    matchLabels:
      app: zk
  minAvailable: 2
---
apiVersion: apps/v1beta1
kind: StatefulSet
metadata:
  name: zk
spec:
  serviceName: zk-headless
  replicas: 3
  template:
    metadata:
      labels:
        app: zk
      annotations:
        pod.alpha.kubernetes.io/initialized: "true"
    spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                matchExpressions:
                  - key: "app"
                    operator: In
                    values: 
                    - zk-headless
              topologyKey: "kubernetes.io/hostname"
      containers:
      - name: k8szk
        imagePullPolicy: Always
        image: gcr.io/google_samples/k8szk:v1
        ports:
        - containerPort: 2181
          name: client
        - containerPort: 2888
          name: server
        - containerPort: 3888
          name: leader-election
        env:
        - name : ZK_ENSEMBLE
          valueFrom:
            configMapKeyRef:
              name: zk-config
              key: ensemble
        - name : ZK_HEAP_SIZE
          valueFrom:
            configMapKeyRef:
                name: zk-config
                key: jvm.heap
        - name : ZK_TICK_TIME
          valueFrom:
            configMapKeyRef:
                name: zk-config
                key: tick
        - name : ZK_INIT_LIMIT
          valueFrom:
            configMapKeyRef:
                name: zk-config
                key: init
        - name : ZK_SYNC_LIMIT
          valueFrom:
            configMapKeyRef:
                name: zk-config
                key: tick
        - name : ZK_MAX_CLIENT_CNXNS
          valueFrom:
            configMapKeyRef:
                name: zk-config
                key: client.cnxns
        - name: ZK_SNAP_RETAIN_COUNT
          valueFrom:
            configMapKeyRef:
                name: zk-config
                key: snap.retain
        - name: ZK_PURGE_INTERVAL
          valueFrom:
            configMapKeyRef:
                name: zk-config
                key: purge.interval
        - name: ZK_CLIENT_PORT
          value: "2181"
        - name: ZK_SERVER_PORT
          value: "2888"
        - name: ZK_ELECTION_PORT
          value: "3888"
        command:
        - sh
        - -c
        - zkGenConfig.sh && zkServer.sh start-foreground
        readinessProbe:
          exec:
            command:
            - "zkOk.sh"
          initialDelaySeconds: 15
          timeoutSeconds: 5
        livenessProbe:
          exec:
            command:
            - "zkOk.sh"
          initialDelaySeconds: 15
          timeoutSeconds: 5
        volumeMounts:
        - name: datadir
          mountPath: /var/lib/zookeeper
      securityContext:
        runAsUser: 1000
        fsGroup: 1000
  volumeClaimTemplates:
  - metadata:
      name: datadir
    spec:
      storageClassName: portworx-sc
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 2Gi
```

Apply this configuration

```
kubectl apply -f zookeeper-all.yaml
```

### Post Install Status - Zookeeper

Verify that the zookeeper pods are running with provisioned Portworx volumes. 

```
kubectl get pods 
NAME      READY     STATUS    RESTARTS   AGE
zk-0      1/1       Running   0          23h
zk-1      1/1       Running   0          23h
zk-2      1/1       Running   0          23h

kubectl get pvc
NAME        STATUS    VOLUME                                     CAPACITY   ACCESSMODES   STORAGECLASS   AGE
data-zk-0   Bound     pvc-b79e96e9-7b79-11e7-a940-42010a8c0002   3Gi        RWO           portworx-sc    23h
data-zk-1   Bound     pvc-faaedef8-7b7a-11e7-a940-42010a8c0002   3Gi        RWO           portworx-sc    23h
data-zk-2   Bound     pvc-0e7a636d-7b7b-11e7-a940-42010a8c0002   3Gi        RWO           portworx-sc    23h

kubectl get sts
NAME      DESIRED   CURRENT   AGE
zk        3         3         1d

/opt/pwx/bin/pxctl v i pvc-b79e96e9-7b79-11e7-a940-42010a8c0002

Volume  :  816480848884203913
        Name                     :  pvc-b79e96e9-7b79-11e7-a940-42010a8c0002
        Size                     :  3.0 GiB
        Format                   :  ext4
        HA                       :  1
        IO Priority              :  LOW
        Creation time            :  Aug 7 14:07:16 UTC 2017
        Shared                   :  no
        Status                   :  up
        State                    :  Attached: k8s-0
        Device Path              :  /dev/pxd/pxd816480848884203913
        Labels                   :  pvc=data-zk-0
        Reads                    :  59
        Reads MS                 :  252
        Bytes Read               :  466944
        Writes                   :  816
        Writes MS                :  3608
        Bytes Written            :  53018624
        IOs in progress          :  0
        Bytes used               :  65 MiB
        Replica sets on nodes:
                Set  0
                        Node     :  10.140.0.5

```

Verify that the Zookeeper ensemble is working. 

```
kubectl exec zk-0 -- /opt/zookeeper/bin/zkCli.sh create /foo bar

WATCHER::
WatchedEvent state:SyncConnected type:None path:null
Created /foo

kubectl exec zk-2 -- /opt/zookeeper/bin/zkCli.sh get /foo

WATCHER::
WatchedEvent state:SyncConnected type:None path:null
cZxid = 0x10000004d
bar
ctime = Tue Aug 08 14:18:11 UTC 2017
mZxid = 0x10000004d
mtime = Tue Aug 08 14:18:11 UTC 2017
pZxid = 0x10000004d
cversion = 0
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 3
numChildren = 0

```

### Install Kafka

Obtain the Zookeeper node FQDN to be used in the configuration for Kafka.

```
for i in 0 1 2; do kubectl exec zk-$i -- hostname -f; done

zk-0.zk-headless.default.svc.cluster.local
zk-1.zk-headless.default.svc.cluster.local
zk-2.zk-headless.default.svc.cluster.local
```

Create ```kafka-all.yml``` with the following contents. Note the property ```zookeeper.connect```. This points to the zookeeper nodes' FQDN obtained earlier.  

```
---
apiVersion: v1
kind: Namespace
metadata:
  name: kafka
---
kind: ConfigMap
metadata:
  name: broker-config
  namespace: kafka
apiVersion: v1
data:
  init.sh: |-
    #!/bin/bash
    set -x

    KAFKA_BROKER_ID=${HOSTNAME##*-}
    sed -i "s/#init#broker.id=#init#/broker.id=$KAFKA_BROKER_ID/" /etc/kafka/server.properties

    hash kubectl 2>/dev/null || {
      sed -i "s/#init#broker.rack=#init#/#init#broker.rack=# kubectl not found in path/" /etc/kafka/server.properties
    } && {
      ZONE=$(kubectl get node "$NODE_NAME" -o=go-template='{{index .metadata.labels "failure-domain.beta.kubernetes.io/zone"}}')
      if [ $? -ne 0 ]; then
        sed -i "s/#init#broker.rack=#init#/#init#broker.rack=# zone lookup failed, see -c init-config logs/" /etc/kafka/server.properties
      elif [ "x$ZONE" == "x<no value>" ]; then
        sed -i "s/#init#broker.rack=#init#/#init#broker.rack=# zone label not found for node $NODE_NAME/" /etc/kafka/server.properties
      else
        sed -i "s/#init#broker.rack=#init#/broker.rack=$ZONE/" /etc/kafka/server.properties
      fi
    }

  server.properties: |-
    delete.topic.enable=true
    num.network.threads=3
    num.io.threads=8
    socket.send.buffer.bytes=102400
    socket.receive.buffer.bytes=102400
    socket.request.max.bytes=104857600
    log.dirs=/tmp/kafka-logs
    num.partitions=1
    num.recovery.threads.per.data.dir=1
    offsets.topic.replication.factor=1
    transaction.state.log.replication.factor=1
    transaction.state.log.min.isr=1
    log.retention.hours=168
    log.segment.bytes=1073741824
    log.retention.check.interval.ms=300000
    zookeeper.connect=zk-0.zk-headless.default.svc.cluster.local:2181,zk-1.zk-headless.default.svc.cluster.local:2181,zk-2.zk-headless.default.svc.cluster.local:2181
    zookeeper.connection.timeout.ms=6000
    group.initial.rebalance.delay.ms=0

  log4j.properties: |-
    log4j.rootLogger=INFO, stdout

    log4j.appender.stdout=org.apache.log4j.ConsoleAppender
    log4j.appender.stdout.layout=org.apache.log4j.PatternLayout
    log4j.appender.stdout.layout.ConversionPattern=[%d] %p %m (%c)%n

    log4j.appender.kafkaAppender=org.apache.log4j.DailyRollingFileAppender
    log4j.appender.kafkaAppender.DatePattern='.'yyyy-MM-dd-HH
    log4j.appender.kafkaAppender.File=${kafka.logs.dir}/server.log
    log4j.appender.kafkaAppender.layout=org.apache.log4j.PatternLayout
    log4j.appender.kafkaAppender.layout.ConversionPattern=[%d] %p %m (%c)%n

    log4j.appender.stateChangeAppender=org.apache.log4j.DailyRollingFileAppender
    log4j.appender.stateChangeAppender.DatePattern='.'yyyy-MM-dd-HH
    log4j.appender.stateChangeAppender.File=${kafka.logs.dir}/state-change.log
    log4j.appender.stateChangeAppender.layout=org.apache.log4j.PatternLayout
    log4j.appender.stateChangeAppender.layout.ConversionPattern=[%d] %p %m (%c)%n

    log4j.appender.requestAppender=org.apache.log4j.DailyRollingFileAppender
    log4j.appender.requestAppender.DatePattern='.'yyyy-MM-dd-HH
    log4j.appender.requestAppender.File=${kafka.logs.dir}/kafka-request.log
    log4j.appender.requestAppender.layout=org.apache.log4j.PatternLayout
    log4j.appender.requestAppender.layout.ConversionPattern=[%d] %p %m (%c)%n

    log4j.appender.cleanerAppender=org.apache.log4j.DailyRollingFileAppender
    log4j.appender.cleanerAppender.DatePattern='.'yyyy-MM-dd-HH
    log4j.appender.cleanerAppender.File=${kafka.logs.dir}/log-cleaner.log
    log4j.appender.cleanerAppender.layout=org.apache.log4j.PatternLayout
    log4j.appender.cleanerAppender.layout.ConversionPattern=[%d] %p %m (%c)%n

    log4j.appender.controllerAppender=org.apache.log4j.DailyRollingFileAppender
    log4j.appender.controllerAppender.DatePattern='.'yyyy-MM-dd-HH
    log4j.appender.controllerAppender.File=${kafka.logs.dir}/controller.log
    log4j.appender.controllerAppender.layout=org.apache.log4j.PatternLayout
    log4j.appender.controllerAppender.layout.ConversionPattern=[%d] %p %m (%c)%n

    log4j.appender.authorizerAppender=org.apache.log4j.DailyRollingFileAppender
    log4j.appender.authorizerAppender.DatePattern='.'yyyy-MM-dd-HH
    log4j.appender.authorizerAppender.File=${kafka.logs.dir}/kafka-authorizer.log
    log4j.appender.authorizerAppender.layout=org.apache.log4j.PatternLayout
    log4j.appender.authorizerAppender.layout.ConversionPattern=[%d] %p %m (%c)%n

    # Change the two lines below to adjust ZK client logging
    log4j.logger.org.I0Itec.zkclient.ZkClient=INFO
    log4j.logger.org.apache.zookeeper=INFO

    # Change the two lines below to adjust the general broker logging level (output to server.log and stdout)
    log4j.logger.kafka=INFO
    log4j.logger.org.apache.kafka=INFO

    # Change to DEBUG or TRACE to enable request logging
    log4j.logger.kafka.request.logger=WARN, requestAppender
    log4j.additivity.kafka.request.logger=false

    log4j.logger.kafka.network.RequestChannel$=WARN, requestAppender
    log4j.additivity.kafka.network.RequestChannel$=false

    log4j.logger.kafka.controller=TRACE, controllerAppender
    log4j.additivity.kafka.controller=false

    log4j.logger.kafka.log.LogCleaner=INFO, cleanerAppender
    log4j.additivity.kafka.log.LogCleaner=false

    log4j.logger.state.change.logger=TRACE, stateChangeAppender
    log4j.additivity.state.change.logger=false

    log4j.logger.kafka.authorizer.logger=WARN, authorizerAppender
    log4j.additivity.kafka.authorizer.logger=false

---
apiVersion: v1
kind: Service
metadata:
  name: broker
  namespace: kafka
spec:
  ports:
  - port: 9092
  # [podname].broker.kafka.svc.cluster.local
  clusterIP: None
  selector:
    app: kafka
---
apiVersion: apps/v1beta1
kind: StatefulSet
metadata:
  name: kafka
  namespace: kafka
spec:
  serviceName: "broker"
  replicas: 3
  template:
    metadata:
      labels:
        app: kafka
      annotations:
    spec:
      terminationGracePeriodSeconds: 30
      initContainers:
      - name: init-config
        image: solsson/kafka-initutils@sha256:c275d681019a0d8f01295dbd4a5bae3cfa945c8d0f7f685ae1f00f2579f08c7d
        env:
        - name: NODE_NAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        command: ['/bin/bash', '/etc/kafka/init.sh']
        volumeMounts:
        - name: config
          mountPath: /etc/kafka
      containers:
      - name: broker
        image: solsson/kafka:0.11.0.0@sha256:b27560de08d30ebf96d12e74f80afcaca503ad4ca3103e63b1fd43a2e4c976ce
        env:
        - name: KAFKA_LOG4J_OPTS
          value: -Dlog4j.configuration=file:/etc/kafka/log4j.properties
        ports:
        - containerPort: 9092
        command:
        - ./bin/kafka-server-start.sh
        - /etc/kafka/server.properties
        - --override
        -   zookeeper.connect=zk-0.zk-headless.default.svc.cluster.local:2181,zk-1.zk-headless.default.svc.cluster.local:2181,zk-2.zk-headless.default.svc.cluster.local:2181
        - --override
        -   log.retention.hours=-1
        - --override
        -   log.dirs=/var/lib/kafka/data/topics
        - --override
        -   auto.create.topics.enable=false
        resources:
          requests:
            cpu: 100m
            memory: 512Mi
        readinessProbe:
          exec:
            command:
            - /bin/sh
            - -c
            - 'echo "" | nc -w 1 127.0.0.1 9092'
        volumeMounts:
        - name: config
          mountPath: /etc/kafka
        - name: data
          mountPath: /var/lib/kafka/data
      volumes:
      - name: config
        configMap:
          name: broker-config
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      storageClassName: portworx-sc-rep2
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 3Gi
---
```
Apply the manifest
```
kubectl apply -f kafka-all.yml
```

### Post Install Status - Kafka

Verify Kafka resources created on the cluster. 

```
kubectl get pods -l "app=kafka" -n kafka -w
NAME      READY     STATUS     RESTARTS   AGE
kafka-0   1/1       Running    0          17s
kafka-1   0/1       Init:0/1   0          3s
kafka-1   0/1       Init:0/1   0         4s
kafka-1   0/1       PodInitializing   0         5s
kafka-1   0/1       Running   0         6s
kafka-1   1/1       Running   0         9s
kafka-2   0/1       Pending   0         0s
kafka-2   0/1       Pending   0         1s
kafka-2   0/1       Pending   0         3s
kafka-2   0/1       Init:0/1   0         4s
kafka-2   0/1       Init:0/1   0         6s
kafka-2   0/1       PodInitializing   0         8s
kafka-2   0/1       Running   0         9s
kafka-2   1/1       Running   0         15s

kubectl get pvc -n kafka
NAME           STATUS    VOLUME                                     CAPACITY   ACCESSMODES   STORAGECLASS       AGE
data-kafka-0   Bound     pvc-c405b033-7c4b-11e7-a940-42010a8c0002   3Gi        RWO           portworx-sc-rep2   1m
data-kafka-1   Bound     pvc-cc70447a-7c4b-11e7-a940-42010a8c0002   3Gi        RWO           portworx-sc-rep2   57s
data-kafka-2   Bound     pvc-d2388861-7c4b-11e7-a940-42010a8c0002   3Gi        RWO           portworx-sc-rep2   48s

/opt/pwx/bin/pxctl v l

ID                      NAME                                            SIZE    HA      SHARED  ENCRYPTED       IO_PRIORITY     SCALE   STATUS
523341158152507227      pvc-0e7a636d-7b7b-11e7-a940-42010a8c0002        3 GiB   1       no      no              LOW             0       up - attached on 10.140.0.4
816480848884203913      pvc-b79e96e9-7b79-11e7-a940-42010a8c0002        3 GiB   1       no      no              LOW             0       up - attached on 10.140.0.5
262949240358217536      pvc-c405b033-7c4b-11e7-a940-42010a8c0002        3 GiB   2       no      no              LOW             0       up - attached on 10.140.0.3
733731201475618092      pvc-cc70447a-7c4b-11e7-a940-42010a8c0002        3 GiB   2       no      no              LOW             0       up - attached on 10.140.0.5
360663112422496357      pvc-d2388861-7c4b-11e7-a940-42010a8c0002        3 GiB   2       no      no              LOW             0       up - attached on 10.140.0.4
168733173797215691      pvc-faaedef8-7b7a-11e7-a940-42010a8c0002        3 GiB   1       no      no              LOW             0       up - attached on 10.140.0.3

/opt/pwx/bin/pxctl v i pvc-c405b033-7c4b-11e7-a940-42010a8c0002

Volume  :  262949240358217536
        Name                     :  pvc-c405b033-7c4b-11e7-a940-42010a8c0002
        Size                     :  3.0 GiB
        Format                   :  ext4
        HA                       :  2
        IO Priority              :  LOW
        Creation time            :  Aug 8 15:10:51 UTC 2017
        Shared                   :  no
        Status                   :  up
        State                    :  Attached: k8s-2
        Device Path              :  /dev/pxd/pxd262949240358217536
        Labels                   :  pvc=data-kafka-0
        Reads                    :  37
        Reads MS                 :  8
        Bytes Read               :  372736
        Writes                   :  354
        Writes MS                :  3096
        Bytes Written            :  53641216
        IOs in progress          :  0
        Bytes used               :  65 MiB
        Replica sets on nodes:
                Set  0
                        Node     :  10.140.0.5
                        Node     :  10.140.0.3

```

Find the Kafka brokers 
```
for i in 0 1 2; do kubectl exec -n kafka kafka-$i -- hostname -f; done

kafka-0.broker.kafka.svc.cluster.local
kafka-1.broker.kafka.svc.cluster.local
kafka-2.broker.kafka.svc.cluster.local
```

Create a topic with 3 partitions and which has a replication factor of 3

```
kubectl exec -n kafka -it kafka-0 -- bash 

bin/kafka-topics.sh --zookeeper zk-headless.default.svc.cluster.local:2181 --create --if-not-exists --topic px-kafka-topic --partitions 3 --replication-factor 3

Created topic "px-kafka-topic".

bin/kafka-topics.sh --list --zookeeper zk-headless.default.svc.cluster.local:2181
px-kafka-topic

bin/kafka-topics.sh --describe --zookeeper zk-headless.default.svc.cluster.local:2181 --topic px-kafka-topic

Topic:px-kafka-topic    PartitionCount:3        ReplicationFactor:3     Configs:
Topic: px-kafka-topic   Partition: 0    Leader: 0       Replicas: 0,1,2 Isr: 0,1,2
Topic: px-kafka-topic   Partition: 1    Leader: 1       Replicas: 1,2,0 Isr: 1,2,0
Topic: px-kafka-topic   Partition: 2    Leader: 2       Replicas: 2,0,1 Isr: 2,0,1

```

Publish messages on the topic
```
bin/kafka-console-producer.sh --broker-list kafka-0.broker.kafka.svc.cluster.local:9092,kafka-1.broker.kafka.svc.cluster.local:9092,kafka-2.broker.kafka.svc.cluster.local:9092 --topic px-kafka-topic

>Hello Kubernetes!
>This is Portworx saying hello            
>Kafka says, I am just a messenger 

```

Consume messages from the topic
```
bin/kafka-console-consumer.sh --zookeeper zk-headless.default.svc.cluster.local:2181 —topic px-kafka-topic --from-beginning

This is Portworx saying hello
Hello Kubernetes!
Kafka says, I am just a messenger
```

## Scaling

Portworx runs as a Daemonset in Kubernetes. Hence when you add a new node to your kuberentes cluster you do not need to explicitly run Portworx on it.

If you did use the [Terraform scripts](https://github.com/portworx/terraporx) to create a kubernetes cluster, you would need to update the minion count and apply the changes via Terraform to add a new Node. 

```
kubectl get nodes -o wide
NAME         STATUS    AGE       VERSION   EXTERNAL-IP   OS-IMAGE       KERNEL-VERSION
k8s-0        Ready     2d        v1.7.0    <none>        Ubuntu 16.10   4.8.0-56-generic
k8s-1        Ready     2d        v1.7.0    <none>        Ubuntu 16.10   4.8.0-56-generic
k8s-2        Ready     2d        v1.7.0    <none>        Ubuntu 16.10   4.8.0-56-generic
k8s-3        Ready     19h       v1.7.0    <none>        Ubuntu 16.10   4.8.0-56-generic
k8s-master   Ready     2d        v1.7.0    <none>        Ubuntu 16.10   4.8.0-56-generic
```

Portworx scales along with your cluster. 

```
/opt/pwx/bin/pxctl status
Status: PX is operational
License: Trial (expires in 28 days)
Node ID: k8s-1
        IP: 10.140.0.4
        Local Storage Pool: 1 pool
        POOL    IO_PRIORITY     RAID_LEVEL      USABLE  USED    STATUS  ZONE    REGION
        0       MEDIUM          raid0           10 GiB  594 MiB Online  default default
        Local Storage Devices: 1 device
        Device  Path            Media Type              Size            Last-Scan
        0:1     /dev/sdb        STORAGE_MEDIUM_SSD      10 GiB          07 Aug 17 12:48 UTC
        total                   -                       10 GiB
Cluster Summary
        Cluster ID: px-kafka-cluster
        Cluster UUID: 819e722c-cb51-4f5f-9ac6-f99420435a90
        IP              ID      Used    Capacity        Status
        10.140.0.4      k8s-1   594 MiB 10 GiB          Online (This node)
        10.140.0.3      k8s-2   594 MiB 10 GiB          Online
        10.140.0.5      k8s-0   655 MiB 10 GiB          Online
        10.140.0.6      k8s-3   338 MiB 10 GiB          Online
Global Storage Pool
        Total Used      :  2.1 GiB
        Total Capacity  :  40 GiB
```

Scale the Kafka cluster. 

```
kubectl scale -n kafka sts kafka --replicas=4
statefulset "kafka" scaled

kubectl get pods -n kafka -l "app=kafka" -w
NAME      READY     STATUS            RESTARTS   AGE
kafka-0   1/1       Running           0          3h
kafka-1   1/1       Running           0          3h
kafka-2   1/1       Running           0          3h
kafka-3   0/1       PodInitializing   0          24s
kafka-3   0/1       Running           0          32s
kafka-3   1/1       Running           0          34s

kubectl get pvc -n kafka
NAME           STATUS    VOLUME                                     CAPACITY   ACCESSMODES   STORAGECLASS       AGE
data-kafka-0   Bound     pvc-c405b033-7c4b-11e7-a940-42010a8c0002   3Gi        RWO           portworx-sc-rep2   3h
data-kafka-1   Bound     pvc-cc70447a-7c4b-11e7-a940-42010a8c0002   3Gi        RWO           portworx-sc-rep2   3h
data-kafka-2   Bound     pvc-d2388861-7c4b-11e7-a940-42010a8c0002   3Gi        RWO           portworx-sc-rep2   3h
data-kafka-3   Bound     pvc-df82a9b0-7c68-11e7-a940-42010a8c0002   3Gi        RWO           portworx-sc-rep2   6m

```

Verify that the newly created kafka broker is part of the cluster. 

```
kubectl exec -n kafka -it kafka-0 -- bash

>zkCli.sh

[zk: localhost:2181(CONNECTED) 0] ls /brokers/ids

[0, 1, 2, 3]

[zk: localhost:2181(CONNECTED) 1] ls /brokers/topics

[px-kafka-topic]

[zk: localhost:2181(CONNECTED) 2] get /brokers/ids/3

{"listener_security_protocol_map":{"PLAINTEXT":"PLAINTEXT"},"endpoints":["PLAINTEXT://kafka-3.broker.kafka.svc.cluster.local:9092"],"jmx_port":-1,"host":"kafka-3.broker.kafka.svc.cluster.local","timestamp":"1502217586002","port":9092,"version":4}
cZxid = 0x1000000e9
ctime = Tue Aug 08 18:39:46 UTC 2017
mZxid = 0x1000000e9
mtime = Tue Aug 08 18:39:46 UTC 2017
pZxid = 0x1000000e9
cversion = 0
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x25dbd0e499e000b
dataLength = 246
numChildren = 0

```

## Failover

### Pod Failover for Zookeeper

Kill the zookeeper process which terminates the pod and get the earlier inserted vale from zookeeper.
Portworx alongwith the Statefulset provides durable storage to the Zookeeper pods. 

```
kubectl exec zk-0 -- pkill java

kubectl get pod -w -l "app=zk"
NAME      READY     STATUS    RESTARTS   AGE
zk-0      1/1       Running   0          1d
zk-1      1/1       Running   0          1d
zk-2      1/1       Running   0          1d
zk-0      0/1       Error     0          1d
zk-0      0/1       Running   1          1d
zk-0      1/1       Running   1          1d

kubectl exec zk-0 -- zkCli.sh get /foo

WATCHER::
WatchedEvent state:SyncConnected type:None path:null
bar
cZxid = 0x10000004d
ctime = Tue Aug 08 14:18:11 UTC 2017
mZxid = 0x10000004d
mtime = Tue Aug 08 14:18:11 UTC 2017
pZxid = 0x10000004d
cversion = 0
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 3
numChildren = 0


```
### Pod Failover for Kafka

Find the hosts of the running kafka cluster, cordon a node so that pods are scheduled on it. Kill a kafka pod and notice that it is scheduled on a newer node, joining the cluster back again with durable storage which is backed by the PX volume. 

```
kubectl get pods -n kafka -o wide
NAME      READY     STATUS    RESTARTS   AGE       IP           NODE
kafka-0   1/1       Running   0          21h       10.0.160.3   k8s-2
kafka-1   1/1       Running   0          21h       10.0.192.3   k8s-0
kafka-2   1/1       Running   0          21h       10.0.64.4    k8s-1
kafka-3   1/1       Running   0          18h       10.0.112.1   k8s-3

kubectl cordon k8s-0
node "k8s-0" cordoned

kubectl get nodes
NAME         STATUS                     AGE       VERSION
k8s-0        Ready,SchedulingDisabled   2d        v1.7.0
k8s-1        Ready                      2d        v1.7.0
k8s-2        Ready                      2d        v1.7.0
k8s-3        Ready                      19h       v1.7.0
k8s-master   Ready                      2d        v1.7.0

kubectl get pvc -n kafka | grep data-kafka-1
data-kafka-1   Bound     pvc-cc70447a-7c4b-11e7-a940-42010a8c0002   3Gi        RWO           portworx-sc-rep2   22h

/opt/pwx/bin/pxctl v l | grep pvc-cc70447a-7c4b-11e7-a940-42010a8c0002
733731201475618092      pvc-cc70447a-7c4b-11e7-a940-42010a8c0002        3 GiB   2       no      no              LOW             0       up - attached on 10.140.0.5


kubectl exec -n kafka -it kafka-0 -- bash 

bin/kafka-topics.sh --describe --zookeeper zk-headless.default.svc.cluster.local:2181 --topic px-kafka-topic

Topic:px-kafka-topic    PartitionCount:3        ReplicationFactor:3     Configs:
        Topic: px-kafka-topic   Partition: 0    Leader: 0       Replicas: 0,1,2 Isr: 0,1,2
        Topic: px-kafka-topic   Partition: 1    Leader: 1       Replicas: 1,2,0 Isr: 1,2,0
        Topic: px-kafka-topic   Partition: 2    Leader: 2       Replicas: 2,0,1 Isr: 2,0,1


kubectl delete po/kafka-1 -n kafka
pod "kafka-1" deleted

kubectl get pods -n kafka -w
NAME      READY     STATUS        RESTARTS   AGE
kafka-0   1/1       Running           0         22h
kafka-1   0/1       Terminating       0         22h
kafka-2   1/1       Running           0         22h
kafka-3   1/1       Running           0         18h
kafka-1   0/1       Terminating       0         22h
kafka-1   0/1       Terminating       0         22h
kafka-1   0/1       Pending           0         0s
kafka-1   0/1       Pending           0         0s
kafka-1   0/1       Init:0/1          0         0s
kafka-1   0/1       Init:0/1          0         2s
kafka-1   0/1       PodInitializing   0         3s
kafka-1   0/1       Running           0         5s
kafka-1   1/1       Running           0         11s

kubectl get pods -n kafka -o wide
NAME      READY     STATUS    RESTARTS   AGE       IP           NODE
kafka-0   1/1       Running   0          22h       10.0.160.3   k8s-2
kafka-1   1/1       Running   0          1m        10.0.112.2   k8s-3
kafka-2   1/1       Running   0          22h       10.0.64.4    k8s-1
kafka-3   1/1       Running   0          18h       10.0.112.1   k8s-3

bin/kafka-topics.sh --describe --zookeeper zk-headless.default.svc.cluster.local:2181 --topic px-kafka-topic

Topic:px-kafka-topic    PartitionCount:3        ReplicationFactor:3     Configs:
Topic: px-kafka-topic   Partition: 0    Leader: 0       Replicas: 0,1,2 Isr: 0,2,1
Topic: px-kafka-topic   Partition: 1    Leader: 1       Replicas: 1,2,0 Isr: 2,0,1
Topic: px-kafka-topic   Partition: 2    Leader: 2       Replicas: 2,0,1 Isr: 2,0,1

```

### Node Failover

In the case of a statefulset if the node is unreachable, which could happen in either of two cases
- The node is down for maintenance
- There has been a network partition. 

There is no way for kubernetes to know which of the case is it. Hence Kubernetes would not schedule the Statefulset and the pods running on those nodes would enter the ‘Terminating’ or ‘Unknown’ state after a timeout. For further information : [Statefulset Pod Deletion](https://kubernetes.io/docs/tasks/run-application/force-delete-stateful-set-pod/)

Decomissioning a kubernetes node deletes the node object form the APIServer. 
Before that you would want to decomission your Portworx node from the cluster. 
Follow the steps mentioned in [Decommision a Portworx node](https://docs.portworx.com/scheduler/kubernetes/k8s-node-decommission.html) 
Once done, delete the kubernetes node if it requires to be deleted permanently. 