---
layout: page
title: "Deploy Cassandra with Portworx on Kubernetes"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, pv, persistent disk, cassandra
sidebar: home_sidebar
meta-description: "See how Portworx can be used to deploy stateful Cassandra on top of Kubernetes. Try it today!"
---

* TOC
{:toc}

These below instructions will provide you with a step by step guide in deploying Cassandra with Portworx on Kubernetes.

Kubernetes provides management of stateful workloads using Statefulsets. Cassandra is a distributed database and in this guide we will deploy a containerized [Cassandra cluster with Portworx](/applications/cassandra.html#advantages-of-cassandra-with-portworx) for volume management at the backend.

## Prerequisites

-	A running Kubernetes cluster with v 1.6+
-	All the kubernetes nodes should allow [shared mount propagation](/knowledgebase/shared-mount-propogation.html). PX requires this since it provisions volumes in containers.  
-	[Deploy Portworx on your kubernetes cluster](/scheduler/kubernetes/install.html). PX runs on each node of your kubernetes cluster as a daemonset.

### Install

A statefulset in Kubernetes requires a headless service to provide network identity to the pods it creates.
The following command and the spec will help you create a headless service for your Cassandra installation.

Create a ```cassandra-headless-service.yml``` with the following content.
```
apiVersion: v1
kind: Service
metadata:
  labels:
    app: cassandra
  name: cassandra
spec:
  clusterIP: None
  ports:
    - port: 9042
  selector:
    app: cassandra
```
Apply the configuration.

```
kubectl apply -f cassandra-headless-service.yml
```

This example dynamically provisions Portworx volumes using StorageClass API resource. [PersistentVolumeClaims with Portworx Volume](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#portworx-volume)

Create a ```px-storageclass.yml``` with the following content.
```
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: px-storageclass
provisioner: kubernetes.io/portworx-volume
parameters:
  repl: "2"
  priority_io: "high"

```
Apply the configuration

```
kubectl apply -f px-storageclass.yml
```
Create the Statefulset for Cassandra with 3 replicas.
The PodSpec in the statefulset specifies the container image of Cassandra. Statefulsets ensures a sticky and unique identity to the pods. The ordinal index ensures this identity to the Pods.  

Create a ```cassandra-statefulset.yml``` with the following content
```
apiVersion: "apps/v1beta1"
kind: StatefulSet
metadata:
  name: cassandra
spec:
  serviceName: cassandra
  replicas: 2
  template:
    metadata:
      labels:
        app: cassandra
    spec:
      containers:
      - name: cassandra
        image: gcr.io/google-samples/cassandra:v11
        imagePullPolicy: Always
        ports:
        - containerPort: 7000
          name: intra-node
        - containerPort: 7001
          name: tls-intra-node
        - containerPort: 7199
          name: jmx
        - containerPort: 9042
          name: cql
        resources:
          limits:
            cpu: "500m"
            memory: 1Gi
          requests:
           cpu: "500m"
           memory: 1Gi
        securityContext:
          capabilities:
            add:
              - IPC_LOCK
        lifecycle:
          preStop:
            exec:
              command: ["/bin/sh", "-c", "PID=$(pidof java) && kill $PID && while ps -p $PID > /dev/null; do sleep 1; done"]
        env:
          - name: MAX_HEAP_SIZE
            value: 512M
          - name: HEAP_NEWSIZE
            value: 100M
          - name: CASSANDRA_SEEDS
            value: "cassandra-0.cassandra.default.svc.cluster.local"
          - name: CASSANDRA_CLUSTER_NAME
            value: "K8Demo"
          - name: CASSANDRA_DC
            value: "DC1-K8Demo"
          - name: CASSANDRA_RACK
            value: "Rack1-K8Demo"
          - name: CASSANDRA_AUTO_BOOTSTRAP
            value: "false"
          - name: POD_IP
            valueFrom:
              fieldRef:
                fieldPath: status.podIP
          - name: POD_NAMESPACE
            valueFrom:
              fieldRef:
                fieldPath: metadata.namespace
        readinessProbe:
          exec:
            command:
            - /bin/bash
            - -c
            - /ready-probe.sh
          initialDelaySeconds: 15
          timeoutSeconds: 5
        # These volume mounts are persistent. They are like inline claims,
        # but not exactly because the names need to match exactly one of
        # the stateful pod volumes.
        volumeMounts:
        - name: cassandra-data
          mountPath: /cassandra_data
  # These are converted to volume claims by the controller
  # and mounted at the paths mentioned above.
  volumeClaimTemplates:
  - metadata:
      name: cassandra-data
      annotations:
        volume.beta.kubernetes.io/storage-class: px-storageclass
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1Gi
```

Apply the configuration

```
kubectl apply -f cassandra-statefulset.yml
```

### Post Install status

Verify that the PVC is bound to a volume using the storage class.

```
kubectl get pvc
NAME                         STATUS    VOLUME                                     CAPACITY   ACCESSMODES   STORAGECLASS   AGE
cassandra-data-cassandra-0   Bound     pvc-e6924b73-72f9-11e7-9d23-42010a8e0002   1Gi        RWO           portworx-sc    2m
cassandra-data-cassandra-1   Bound     pvc-49e8caf6-735d-11e7-9d23-42010a8e0002   1Gi        RWO           portworx-sc    2m
cassandra-data-cassandra-2   Bound     pvc-603d4f95-735d-11e7-9d23-42010a8e0002   1Gi        RWO           portworx-sc    1m
```
Verify that the cassandra cluster is created

```
kubectl exec cassandra-0 -- nodetool status

Datacenter: DC1-K8Demo
======================
Status=Up/Down
|/ State=Normal/Leaving/Joining/Moving
--  Address     Load       Tokens       Owns (effective)  Host ID                               Rack
UN  10.0.160.2  164.39 KiB  32           62.3%             ce3b48b8-1655-48a2-b167-08d03ca6bc41  Rack1-K8Demo
UN  10.0.64.2   190.76 KiB  32           64.1%             ba31128d-49fa-4696-865e-656d4d45238e  Rack1-K8Demo
UN  10.0.192.3  104.55 KiB  32           73.6%             c778d78d-c6bc-4768-a3ec-0d51ba066dcb  Rack1-K8Demo
```

Verify that the storageclass is created.

```
kubectl get storageclass
NAME                 TYPE
portworx-sc          kubernetes.io/portworx-volume

kubectl get pods
NAME          READY     STATUS    RESTARTS   AGE
cassandra-0   1/1       Running   0          1m
cassandra-1   1/1       Running   0          1m
cassandra-2   0/1       Running   0          47s

/opt/pwx/bin/pxctl v l

ID                      NAME                                            SIZE    HA      SHARED  ENCRYPTED       IO_PRIORITY     SCALE   STATUS
651254593135168442      pvc-49e8caf6-735d-11e7-9d23-42010a8e0002        1 GiB   2       no      no              LOW             0       up - attached on 10.142.0.3
136016794033281980      pvc-603d4f95-735d-11e7-9d23-42010a8e0002        1 GiB   2       no      no              LOW             0       up - attached on 10.142.0.4
752567898197695962      pvc-e6924b73-72f9-11e7-9d23-42010a8e0002        1 GiB   2       no      no              LOW             0       up - attached on 10.142.0.5
```
Get the pods and the knowledge of the Hosts on which they are scheduled.

```
kubectl get pods -l app=cassandra -o json | jq '.items[] | {"name": .metadata.name,"hostname": .spec.nodeName, "hostIP": .status.hostIP, "PodIP": .status.podIP}'
{
  "name": "cassandra-0",
  "hostname": "k8s-2",
  "hostIP": "10.142.0.5",
  "PodIP": "10.0.160.2"
}  
{
  "name": "cassandra-1",
  "hostname": "k8s-0",
  "hostIP": "10.142.0.3",
  "PodIP": "10.0.64.2"
}  
{
  "name": "cassandra-2",
  "hostname": "k8s-1",
  "hostIP": "10.142.0.4",
  "PodIP": "10.0.192.3"
}
```
Verify that the portworx volume has 2 replicas created.

```
/opt/pwx/bin/pxctl v i 651254593135168442 (This volume is up and attached to k8s-0)
Volume  :  651254593135168442
        Name                     :  pvc-49e8caf6-735d-11e7-9d23-42010a8e0002
        Size                     :  1.0 GiB
        Format                   :  ext4
        HA                       :  2
        IO Priority              :  LOW
        Creation time            :  Jul 28 06:23:36 UTC 2017
        Shared                   :  no
        Status                   :  up
        State                    :  Attached: k8s-0
        Device Path              :  /dev/pxd/pxd651254593135168442
        Labels                   :  pvc=cassandra-data-cassandra-1
        Reads                    :  37
        Reads MS                 :  72
        Bytes Read               :  372736
        Writes                   :  1816
        Writes MS                :  17648
        Bytes Written            :  38424576
        IOs in progress          :  0
        Bytes used               :  33 MiB
        Replica sets on nodes:
                Set  0
                        Node     :  10.142.0.4
                        Node     :  10.142.0.3

```

### Scaling
Portworx runs as a Daemonset in Kubernetes. Hence when you add a node or a worker to your kuberentes cluster you do not need to explicitly run Portworx on it.

If you did use the [Terraform scripts](https://github.com/portworx/terraporx) to create a kubernetes cluster, you would need to update the minion count and apply the changes via Terraform to add a new Node. 

Observe the Portworx cluster once you add a new node.
Execute the command

```
kubectl get ds -n kube-system
NAME         DESIRED   CURRENT   READY     UP-TO-DATE   AVAILABLE   NODE-SELECTOR   AGE
kube-proxy   6         6         6         6            6           <none>          5h
portworx     6         5         5         5            5           <none>          4h
weave-net    6         6         6         6            6           <none>          5h

kubectl get pods -n kube-system
NAME                                 READY     STATUS    RESTARTS   AGE
etcd-k8s-master                      1/1       Running   0          5h
kube-apiserver-k8s-master            1/1       Running   0          5h
kube-controller-manager-k8s-master   1/1       Running   0          5h
kube-dns-2425271678-p8620            3/3       Running   0          5h
kube-proxy-3t2c9                     1/1       Running   0          5h
kube-proxy-94j40                     1/1       Running   0          5h
kube-proxy-h75gd                     1/1       Running   0          5h
kube-proxy-nvl7m                     1/1       Running   0          5h
kube-proxy-xh3gr                     1/1       Running   0          2m
kube-proxy-zlxmn                     1/1       Running   0          4h
kube-scheduler-k8s-master            1/1       Running   0          5h
portworx-14g3z                       1/1       Running   0          4h
portworx-ggzvz                       0/1       Running   0          2m
portworx-hhg0m                       1/1       Running   0          4h
portworx-rkdp6                       1/1       Running   0          4h
portworx-stvlt                       1/1       Running   0          4h
portworx-vxqxh                       1/1       Running   0          4h
weave-net-0cdb7                      2/2       Running   1          5h
weave-net-2d6hb                      2/2       Running   0          5h
weave-net-95l8z                      2/2       Running   0          5h
weave-net-tlvkz                      2/2       Running   1          4h
weave-net-tmbxh                      2/2       Running   0          2m
weave-net-w4xgw                      2/2       Running   0          5h
```

The portworx cluster automatically scales as you scale your kubernetes cluster.

```
/opt/pwx/bin/pxctl status

Status: PX is operational
License: Trial (expires in 30 days)
Node ID: k8s-master
        IP: 10.140.0.2
        Local Storage Pool: 1 pool
        POOL    IO_PRIORITY     RAID_LEVEL      USABLE  USED    STATUS  ZONE    REGION
        0       MEDIUM          raid0           10 GiB  471 MiB Online  default default
        Local Storage Devices: 1 device
        Device  Path            Media Type              Size            Last-Scan
        0:1     /dev/sdb        STORAGE_MEDIUM_SSD      10 GiB          31 Jul 17 12:59 UTC
        total                   -                       10 GiB
Cluster Summary
        Cluster ID: px-cluster
        Cluster UUID: d2ebd5cf-9652-47d7-ac95-d4ccbd416a6a
        IP              ID              Used    Capacity        Status
        10.140.0.7      k8s-4           266 MiB 10 GiB          Online
        10.140.0.2      k8s-master      471 MiB 10 GiB          Online (This node)
        10.140.0.4      k8s-2           471 MiB 10 GiB          Online
        10.140.0.3      k8s-0           461 MiB 10 GiB          Online
        10.140.0.5      k8s-1           369 MiB 10 GiB          Online
        10.140.0.6      k8s-3           369 MiB 10 GiB          Online
Global Storage Pool
        Total Used      :  2.3 GiB
        Total Capacity  :  60 GiB

```

Scale your cassandra statefulset

```
kubectl get sts cassandra
NAME        DESIRED   CURRENT   AGE
cassandra   4         4         4h

kubectl scale sts cassandra --replicas=5
statefulset "cassandra" scaled

kubectl get pods -l "app=cassandra" -w
NAME          READY     STATUS    RESTARTS   AGE
cassandra-0   1/1       Running   0          5h
cassandra-1   1/1       Running   0          4h
cassandra-2   1/1       Running   0          4h
cassandra-3   1/1       Running   0          3h
cassandra-4   1/1       Running   0          57s

kubectl exec -it cassandra-0 -- nodetool status
Datacenter: DC1-K8Demo
======================
Status=Up/Down
|/ State=Normal/Leaving/Joining/Moving
--  Address     Load       Tokens       Owns (effective)  Host ID                               Rack
UN  10.0.128.1  84.75 KiB   32           41.4%             1c14f7dc-44f7-4174-b43a-308370c9139e  Rack1-K8Demo
UN  10.0.240.1  130.81 KiB  32           45.2%             60ebbe70-f7bc-48b0-9374-710752e8876d  Rack1-K8Demo
UN  10.0.192.2  156.84 KiB  32           41.1%             915f33ff-d105-4501-997f-7d44fb007911  Rack1-K8Demo
UN  10.0.160.2  125.1 KiB   32           45.3%             a56a6f70-d2e3-449a-8a33-08b8efb25000  Rack1-K8Demo
UN  10.0.64.3   159.94 KiB  32           26.9%             ae7e3624-175b-4676-9ac3-6e3ad4edd461  Rack1-K8Demo
```

### Failover

#### Pod Failover

Verify that there is a 5 node Cassandra cluster running on your kubernetes cluster.
```
kubectl get pods -l "app=cassandra"
NAME          READY     STATUS    RESTARTS   AGE
cassandra-0   1/1       Running   0          1h
cassandra-1   1/1       Running   0          10m
cassandra-2   1/1       Running   0          18h
cassandra-3   1/1       Running   0          17h
cassandra-4   1/1       Running   0          13h
```

Create data in your Cassandra DB

```
kubectl exec -it cassandra-2 -- bash
root@cassandra-2:/# cqlsh

Connected to K8Demo at 127.0.0.1:9042.
[cqlsh 5.0.1 | Cassandra 3.9 | CQL spec 3.4.2 | Native protocol v4]
Use HELP for help.

cqlsh> CREATE KEYSPACE demodb WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 2 };
cqlsh> use demodb;
cqlsh:demodb> CREATE TABLE emp(emp_id int PRIMARY KEY, emp_name text, emp_city text, emp_sal varint,emp_phone varint);
cqlsh:demodb> INSERT INTO emp (emp_id, emp_name, emp_city, emp_phone, emp_sal) VALUES(123423445,'Steve', 'Denver', 5910234452, 50000);

```

Let us look at which nodes host the data in your cassandra ring based on its partition key

```
root@cassandra-2:/# nodetool getendpoints demodb emp 123423445
10.0.112.1
10.0.160.1
```

Cross reference the above PodIPs to the nodes (Node k8s-0 is the one which hosts one of the pods)

```
kubectl get pods -l app=cassandra -o json | jq '.items[] | {"name": .metadata.name,"hostname": .spec.nodeName, "hostIP": .status.hostIP, "PodIP": .status.podIP}'
{
  "name": "cassandra-0",
  "hostname": "k8s-5",
  "hostIP": "10.140.0.8",
  "PodIP": "10.0.112.1"
}
{
  "name": "cassandra-1",
  "hostname": "k8s-0",
  "hostIP": "10.140.0.3",
  "PodIP": "10.0.160.1"
}
{
  "name": "cassandra-2",
  "hostname": "k8s-1",
  "hostIP": "10.140.0.5",
  "PodIP": "10.0.64.3"
}
{
  "name": "cassandra-3",
  "hostname": "k8s-3",
  "hostIP": "10.140.0.6",
  "PodIP": "10.0.240.1"
}
{
  "name": "cassandra-4",
  "hostname": "k8s-4",
  "hostIP": "10.140.0.7",
  "PodIP": "10.0.128.1"
}
```

Cordon the node where one of the replicas of the dataset resides. This will force scheduling of the pod to another node.

```
kubectl cordon k8s-0
node "k8s-0" cordoned

kubectl delete pods cassandra-1
pod "cassandra-1" deleted
```

The statefulset schedules a new cassandra pod on another host. (The pod gets scheduled on the node k8s-2 this time.)

```
kubectl get pods -w
NAME          READY     STATUS              RESTARTS   AGE
cassandra-0   1/1       Running             0          1h
cassandra-1   0/1       ContainerCreating   0          1s
cassandra-2   1/1       Running             0          19h
cassandra-3   1/1       Running             0          17h
cassandra-4   1/1       Running             0          14h
cassandra-1   0/1       Running   0         4s
cassandra-1   1/1       Running   0         28s

kubectl get pods -l app=cassandra -o json | jq '.items[] | {"name": .metadata.name,"hostname": .spec.nodeName, "hostIP": .status.hostIP, "PodIP": status.podIP}'
{
  "name": "cassandra-0",
  "hostname": "k8s-5",
  "hostIP": "10.140.0.8",
  "PodIP": "10.0.112.1"
}
{
  "name": "cassandra-1",
  "hostname": "k8s-2",
  "hostIP": "10.140.0.4",
  "PodIP": "10.0.192.2"
}
{
  "name": "cassandra-2",
  "hostname": "k8s-1",
  "hostIP": "10.140.0.5",
  "PodIP": "10.0.64.3"
}
{
  "name": "cassandra-3",
  "hostname": "k8s-3",
  "hostIP": "10.140.0.6",
  "PodIP": "10.0.240.1"
}
{
  "name": "cassandra-4",
  "hostname": "k8s-4",
  "hostIP": "10.140.0.7",
  "PodIP": "10.0.128.1"
}
```

Query for the data that was inserted earlier.
```
kubectl exec cassandra-1 -- cqlsh -e 'select * from demodb.emp'
 emp_id    | emp_city | emp_name | emp_phone  | emp_sal
-----------+----------+----------+------------+---------
 123423445 |   Denver |    Steve | 5910234452 |   50000

(1 rows)
```

#### Node Failover

Decomissioning a kubernetes node deletes the node object form the APIServer.
Before that you would want to decomission your Portworx node from the cluster.
Follow the steps mentioned in [Decommision a Portworx node](/scheduler/kubernetes/k8s-node-decommission.html)
Once done, delete the kubernetes node if it requires to be deleted permanently.

```
kubectl delete node k8s-1
```
The kubernetes statefulset would schedule the pod which was running on the node to another node to fulfil the replicas definition.

Cluster State Before k8s-1 was deleted:
```
kubectl get pods -l app=cassandra -o json | jq '.items[] | {"name": .metadata.name,"hostname": .spec.nodeName, "hostIP": .status.hostIP, "PodIP": status.podIP}'
{
  "name": "cassandra-0",
  "hostname": "k8s-5",
  "hostIP": "10.140.0.8",
  "PodIP": "10.0.112.1"
}
{
  "name": "cassandra-1",
  "hostname": "k8s-2",
  "hostIP": "10.140.0.4",
  "PodIP": "10.0.192.2"
}
{
  "name": "cassandra-2",
  "hostname": "k8s-1",
  "hostIP": "10.140.0.5",
  "PodIP": "10.0.64.3"
}
{
  "name": "cassandra-3",
  "hostname": "k8s-3",
  "hostIP": "10.140.0.6",
  "PodIP": "10.0.240.1"
}
{
  "name": "cassandra-4",
  "hostname": "k8s-4",
  "hostIP": "10.140.0.7",
  "PodIP": "10.0.128.1"
}

kubectl get nodes --show-labels (Some of the tags and colums are removed for brevity)
k8s-0        Read          cassandra-data-cassandra-1=true,cassandra-data-cassandra-3=true
k8s-1        Ready         cassandra-data-cassandra-1=true,cassandra-data-cassandra-4=true
k8s-2        Ready         cassandra-data-cassandra-0=true,cassandra-data-cassandra-2=true
k8s-3        Ready         cassandra-data-cassandra-3=true
k8s-4        Ready         cassandra-data-cassandra-4=true
k8s-5        Ready         
k8s-master   Ready         cassandra-data-cassandra-0=true,cassandra-data-cassandra-2=true
```

Cluster State After k8s-1 was deleted:

```
kubectl get pods -l app=cassandra -o json | jq '.items[] | {"name": .metadata.name,"hostname": .spec.nodeName, "hostIP": .status.hostIP, "PodIP": .status.podIP}'
{
  "name": "cassandra-0",
  "hostname": "k8s-5",
  "hostIP": "10.140.0.8",
  "PodIP": "10.0.112.1"
}
{
  "name": "cassandra-1",
  "hostname": "k8s-2",
  "hostIP": "10.140.0.4",
  "PodIP": "10.0.192.2"
}
{
  "name": "cassandra-2",
  "hostname": "k8s-0",
  "hostIP": "10.140.0.3",
  "PodIP": "10.0.160.2"
}
{
  "name": "cassandra-3",
  "hostname": "k8s-3",
  "hostIP": "10.140.0.6",
  "PodIP": "10.0.240.1"
}
{
  "name": "cassandra-4",
  "hostname": "k8s-4",
  "hostIP": "10.140.0.7",
  "PodIP": "10.0.128.1"
}

kubectl get nodes --show-labels (Some of the tags and colums are removed for brevity)
k8s-0        Ready         cassandra-data-cassandra-1=true,cassandra-data-cassandra-3=true
k8s-2        Ready         cassandra-data-cassandra-0=true,cassandra-data-cassandra-2=true
k8s-3        Ready         cassandra-data-cassandra-3=true
k8s-4        Ready         cassandra-data-cassandra-4=true
k8s-5        Ready               
k8s-master   Ready         cassandra-data-cassandra-0=true,cassandra-data-cassandra-2=true
```

## See Also
For further reading on Cassandra:
* [Cassandra Docker](https://portworx.com/use-case/cassandra-docker-container/) How to run Cassandra in Docker containers
* [Run multiple Cassandra rings on the same hosts](https://portworx.com/run-multiple-cassandra-clusters-hosts/)
* [Cassandra stress test with Portworx](/applications/cassandra-px-perf-test.html)
