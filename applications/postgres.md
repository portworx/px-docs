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

PostgreSQL on portworx and kubernetes helped to utilize resources even much better than virtual machines and also provide isolation from other apps which are deployed on the same machine.

### Prerequisites
To follow this guide you need -

*	Kubernetes Cluster

*	3 node Portworx storage Cluster

### Step 1 - Create PostgreSQL Portworx StorageClass(sc)
Create a file name called `px-postgres-sc.yaml` for Portworx StorageClass(sc) for PostgreSQL.

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
`sudo kubectl apply -f px-postgres-sc.yaml`

### Step 2 - Create PostgreSQL Portworx PersistentVolumeClaim(pvc)
Create a file name called `px-postgres-vol.yaml` for Portworx PersistentVolumeClaim(pvc) for PostgreSQL.

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
`sudo kubectl apply -f px-postgres-vol.yaml`

### Step 3 - Deploy PostgreSQL using Kubernetes Deployment
 
Deploying PostgreSQL on Kubernetes have following prerequisites. 
Create a file name `px-postgres-app.yaml` for PostgreSQL. 
 
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
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: px/running
                operator: NotIn
                values:
                - "false"
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

`sudo kubectl apply -f px-postgres-app.yaml`

### Validate StorageClass(sc), PersistentVolumeClaim(pvc) and PostgreSQL Deployment.
```
ubuntu@node1:~$ sudo kubectl get sc
NAME             PROVISIONER                     AGE
px-postgres-sc   kubernetes.io/portworx-volume   1h
ubuntu@node1:~$ sudo kubectl get pvc
NAME            STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS     AGE
postgres-data   Bound     pvc-60e43292-06e3-11e8-96b4-022185d04910   1Gi        RWO            px-postgres-sc   1h
ubuntu@node1:~$ sudo kubectl get pod
NAME                        READY     STATUS    RESTARTS   AGE
postgres-86cb8587c4-l9r48   2/2       Running   0          1h
```
Note that you could run multiple instances of postgrSQL server on the same host, each with its own unique persistent volume mapped, and each with its own unique IP Address published.
 
### Access PostgreSQL DB Server and Validate 
 
To access via docker exec:

```
ubuntu@node2:~$ sudo docker ps -a | grep postgres
345d3d8e5739        harshpx/docker-pgbench@sha256:5688dc4647d387cd66484b9061ad50c9cb0ba351bef6c171caee52fee3c66d38                                           "/run.sh"                57 minutes ago      Up 57 minutes                                 k8s_pgbench_postgres-86cb8587c4-l9r48_default_7a8af36e-06e3-11e8-96b4-022185d04910_0
e7bb6aa3586f        postgres@sha256:2f4c2e4db86a1762de96a2331eb4791f91b6651d923792d66d0f4d53c8d67eed                                                         "docker-entrypoint..."   57 minutes ago      Up 57 minutes                                 k8s_postgres_postgres-86cb8587c4-l9r48_default_7a8af36e-06e3-11e8-96b4-022185d04910_0
f44e191530c7        gcr.io/google_containers/pause-amd64:3.0                                                                                                 "/pause"                 58 minutes ago      Up 58 minutes                                 k8s_POD_postgres-86cb8587c4-l9r48_default_7a8af36e-06e3-11e8-96b4-022185d04910_0
ubuntu@node2:~$ sudo docker exec -it e7bb6aa3586f bin/bash
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
root@postgres-86cb8587c4-l9r48:/# exit

```

### Database recoverability with Portworx snapshots

Use pxctl to create recoverable snapshots of your volume
To take a recoverable snapshot of the postgresql-server instance for a point in time, use the pxctl CLI:

```
ubuntu@node3:~$ /opt/pwx/bin/pxctl volume list
ID			NAME						SIZE	HA	SHARED	ENCRYPTED	IO_PRIORITY	SCALE	STATUS
174338855256084147	pvc-60e43292-06e3-11e8-96b4-022185d04910	1 GiB	1	no	no		LOW		0	up - attached on 192.168.56.62

ubuntu@node3:~$ pxctl snap create pvc-60e43292-06e3-11e8-96b4-022185d04910 --name postgresvol
Volume successfully snapped: 974380787902395280

ubuntu@node3:~$ pxctl snap list
ID			NAME		SIZE	HA	SHARED	ENCRYPTED	IO_PRIORITY	SCALE	STATUS
974380787902395280	postgresvol	1 GiB	1	no	no		LOW		0	up - detached

```
