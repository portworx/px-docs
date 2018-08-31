---
layout: page
title: "Configuring 3DSnaps"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk, snapshots, stork, clones
sidebar: home_sidebar
meta-description: "Learn to take a 3DSnaps of a volume."
---

* TOC
{:toc}


For each of the snapshot types, Portworx supports specifying pre and post rules that are run on the application pods using the volumes being snapshotted. This allows users to quiesce the applications before the snapshot is taken and resume I/O after the snapshot is taken.

The high level workflow for configuring 3DSnaps involves creating rules and later on referencing the rules when creating the snapshots.

#### 1. Create Rules

A Stork `Rule` is a Custom Resource Definition (CRD) that allows to define actions that get performed on pods matching selectors. Below are the supported fields:

* **podSelector**: The actions will get executed on pods that only match the label selectors given here. 
* **actions**: This contains a list of actions to be performed. Below are supported fields under actions:
    * **type**: The type of action to run. Only type _command_ is supported.
    * **background**: If _true_, the action will run in background and will be terminated by Stork after the snapshot has been initiated. If false, the action will first complete and then the snapshot will get initiated.
      * If background is set to _true_, add `${WAIT_CMD}` as shown in the examples below. This is a placeholder and Stork will replace it with an appropriate command to wait for the command is done.
    * **value**: This is the actual action content. For example, the command to run.
    * **runInSinglePod**: If _true_, the action will be run on a single pod that matches the selectors.

**Examples**

Below rule will flush tables on all mysql pods that match label app=mysql and take a read lock on the tables.
```
apiVersion: stork.libopenstorage.org/v1alpha1
kind: Rule
metadata:
  name: px-presnap-rule
spec:
  - podSelector:
      app: mysql
    actions:
    - type: command
      background: true
      # this command will flush tables with read lock
      value: mysql --user=root --password=$MYSQL_ROOT_PASSWORD -Bse 'flush tables with read lock;system ${WAIT_CMD};'
```

Below rule flushes the tables from the memtable on all cassandra pods.
```
apiVersion: stork.libopenstorage.org/v1alpha1
kind: Rule
metadata:
  name: px-cassandra-rule
spec:
  - podSelector:
      app: cassandra
    actions:
    - type: command
      value: nodetool flush
```


Below rule will run an echo command on a single pod that matches the label selector app=foo.
```
apiVersion: stork.libopenstorage.org/v1alpha1
kind: Rule
metadata:
  name: px-hello-world-rule
spec:
  - podSelector:
      app: foo
    actions:
    - type: command
      value: echo "hello world"
      runInSinglePod: true
```

#### 2. Create VolumeSnapshots that reference the rules

Once you have the rules applied in your cluster, you can reference them in the `VolumeSnapshot` using the following annotations.

* __stork.rule/pre-snapshot__: Stork will execute the rule which is given in the value of this annotation _before_ taking the snapshot.
* __stork.rule/post-snapshot__: Stork will execute the rule which is given in the value of this annotation _after_ taking the snapshot.

**Examples**

Follow is an example of a VolumeSnapshot which will do the following:

* Stork will run the _px-presnap-rule_ rule on all pods that are using PVCs that match labels _app=mysql_.
* Once the rule is executed, Stork will take a snapshot of all PVCs that match labels _app=mysql_. Hence this will be a group snapshot.
* After the snapshot has been triggered, Stork will terminate any background actions that may exist in the rule _px-presnap-rule_.

```
apiVersion: volumesnapshot.external-storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: mysql-3d-snapshot
  namespace: default
  annotations:
    portworx.selector/app: mysql
    stork.rule/pre-snapshot: px-presnap-rule
spec:
  persistentVolumeClaimName: mysql-data-1
```

To create PVCs from existing snapshots, read [Creating PVCs from snapshots](/scheduler/kubernetes/snaps-local.html#pvc-from-snap).