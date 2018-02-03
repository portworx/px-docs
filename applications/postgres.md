---
layout: page
title: "How to deploy Postgres DB on Portworx using Kubernetes"
keywords: portworx, postgres, postgresql
sidebar: home_sidebar
redirect_from: "/postgres.html"
meta-description: "Use this guide to install and run PostgreSQL using Kubernetes"
---

* TOC
{:toc}


## What is PostgreSQL?

PostgreSQL is a powerful, open source Relational Database Management System. PostgreSQL is not controlled by any organization or any individual. Its source code is available free of charge. It is pronounced as "post-gress-Q-L". 

PostgreSQL has earned a strong reputation for its reliability, data integrity, and correctness. 

*	It runs on all major operating systems, including Linux, UNIX (AIX, BSD, HP-UX, SGI IRIX, MacOS, Solaris, Tru64), and Windows. 

*	It is fully ACID compliant, has full support for foreign keys, joins, views, triggers, and stored procedures (in multiple languages). 

*	It includes most SQL:2008 data types, including INTEGER, NUMERIC, BOOLEAN, CHAR, VARCHAR, DATE, INTERVAL, and TIMESTAMP. 
    
*	It has native programming interfaces for C/C++, Java, .Net, Perl, Python, Ruby, Tcl, ODBC, among others, and exceptional documentation.

PostgreSQL on Portworx and kubernetes helped to utilize resources even much better than virtual machines and also provide isolation from other apps which are deployed on the same machine.

### Prerequisites

*	3-node Portworx cluster running on Kubernetes.

### Step 1 - Create PostgreSQL Portworx StorageClass
Create a file name called `px-postgres-sc.yaml` for Portworx StorageClass for PostgreSQL.

```

##### Portworx storage class
kind: StorageClass
apiVersion: storage.k8s.io/v1beta1
metadata:
    name: px-postgres-sc
provisioner: kubernetes.io/portworx-volume
parameters:
   repl: "2"

```
`kubectl apply -f px-postgres-sc.yaml`

### Step 2 - Create PostgreSQL Portworx PersistentVolumeClaim
Create a file name called `px-postgres-vol.yaml` for Portworx PersistentVolumeClaim for PostgreSQL.

```

##### Portworx persistent volume claim
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
   name: postgres-data
   annotations:
     volume.beta.kubernetes.io/storage-class: px-postgres-sc
spec:
   accessModes:
     - ReadWriteOnce
   resources:
     requests:
       storage: 1Gi

```
`kubectl apply -f px-postgres-vol.yaml`

### Step 3 - Deploy PostgreSQL using Kubernetes Deployment


We are recommending to use ["Stork"](https://docs.portworx.com/scheduler/kubernetes/stork.html#using-stork-with-your-applications) for Postgres deployment as a scheduler.  Stork is an opensource project that helps achieve even tighter integration of Portworx with Kubernetes. It allows users to co-locate pods with their data, provides seamless migration of pods in case of storage errors and makes it easier to create and restore snapshots of Portworx volumes.  Stork consists of 2 components, the stork scheduler, and an extender. Both of these components run in HA mode with three replicas by default.

Note: You need to install the stork before deploying below Postgres spec file. It `px-postgres-app.yaml`
uses `schedulerName: stork` instead of  `schedulerName: default-scheduler`. 

Deploying PostgreSQL on Kubernetes have following prerequisites. 
 
We need to Define the Environment Variables for PostgreSQL

1. POSTGRES_USER (Super Username for PostgreSQL)

2. POSTGRES_PASSWORD (Super User password for PostgreSQL)

3. PGDATA (Data Directory for PostgreSQL Database)


```

apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: postgres
spec:
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
    type: RollingUpdate
  replicas: 1
  template:
    metadata:
      labels:
        app: postgres
    spec:
      schedulerName: stork    
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: px/enabled
                operator: NotIn
                values:
                - "false"
      containers:
      - name: postgres
        image: postgres:9.5
        imagePullPolicy: "IfNotPresent"
        ports:
        - containerPort: 5432
        env:
        - name: POSTGRES_USER
          value: pgbench
        - name: POSTGRES_PASSWORD
          value: superpostgres
        - name: PGBENCH_PASSWORD
          value: superpostgres
        - name: PGDATA
          value: /var/lib/postgresql/data/pgdata
        volumeMounts:
        - mountPath: /var/lib/postgresql/data
          name: postgredb
      volumes:
      - name: postgredb
        persistentVolumeClaim:
          claimName: postgres-data

``` 

 Now let's deploy PostgreSQL using following commands:

`kubectl apply -f px-postgres-app.yaml`

### Validate StorageClass, PersistentVolumeClaim and PostgreSQL Deployment

```
ubuntu@node1:~$ kubectl get sc
NAME             PROVISIONER                     AGE
px-postgres-sc   kubernetes.io/portworx-volume   1h
ubuntu@node1:~$ kubectl get pvc
NAME            STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS     AGE
postgres-data   Bound     pvc-60e43292-06e3-11e8-96b4-022185d04910   1Gi        RWO            px-postgres-sc   1h
ubuntu@node1:~$ kubectl get pod
NAME                        READY     STATUS    RESTARTS   AGE
postgres-86cb8587c4-l9r48   1/1       Running   0          1h
```

### Validate PostgreSQL DB Server
To access via docker exec:

```
ubuntu@node1:~$ kubectl get pod
NAME                              READY     STATUS    RESTARTS   AGE
postgres-5d8767bb94-wdp2d         1/1       Running   0          1m
ubuntu@node1:~$ kubectl exec -it postgres-5d8767bb94-wdp2d bash
root@postgres-86cb8587c4-l9r48:/#
root@postgres-86cb8587c4-l9r48:/# psql
psql (9.5.10)
Type "help" for help.

pgbench=# \d
              List of relations
 Schema |       Name       | Type  |  Owner
--------+------------------+-------+---------
 public | pgbench_accounts | table | pgbench
 public | pgbench_branches | table | pgbench
 public | pgbench_history  | table | pgbench
 public | pgbench_tellers  | table | pgbench
(4 rows)

pgbench=# \l
                                 List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges
-----------+----------+----------+------------+------------+-----------------------
 pgbench   | postgres | UTF8     | en_US.utf8 | en_US.utf8 |
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 |
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
(4 rows)

pgbench=# \q
```
