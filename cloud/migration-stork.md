---
layout: page
title: "Cloud Migration using stork"
keywords: cloud, backup, restore, snapshot, DR, migration
---

* TOC
{:toc}

## Overview
This method can be used to migrate volumes between two Kubernetes clusters
each running a Portworx cluster.

## Pre-requisites
* Requires PX-Enterprise v2.0+ and stork v1.3+
* Make sure you have configured a [secret store](https://docs.portworx.com/secrets/) on both your clusters. This will be used to store the credentials for the 
objectstore.
* Download storkctl to a system that has access to kubectl:
  * [Linux](http://openstorage-stork.s3-website-us-east-1.amazonaws.com/storkctl/latest/linux/storkctl)
  * [Mac](http://openstorage-stork.s3-website-us-east-1.amazonaws.com/storkctl/latest/darwin/storkctl)
  * [Windows](http://openstorage-stork.s3-website-us-east-1.amazonaws.com/storkctl/latest/windows/storkctl.exe)

## Pairing clusters
On Kubernetes the cluster pairs can be created using custom objects managed by stork. This creates a pairing with the storage
driver (Portworx) and well as the scheduler (Kubernetes) so that the volumes, as well as resources, can be migrated between 
clusters.

1. Install portworx and stork on 2 clusters using the above images
2. On the destination cluster, run the following commands from one of the Portworx nodes (steps (a) and (b) will not be 
required in the future)
   1. Create a volume for the objectstore: 
     ```/opt/pwx/bin/pxctl volume create --size 100 objectstore```
   2. Create an objectstore: ```/opt/pwx/bin/pxctl objectstore create -v objectstore```
   3. Get the cluster token: ```/opt/pwx/bin/pxctl cluster token show```
3. Get the ClusterPair spec from the destination cluster. This is required to migrate Kubernetes resources to the destination cluster.
You can generate the template for the spec using `storkctl generate clusterpair`
```yaml
$ storkctl generate clusterpair
apiVersion: stork.libopenstorage.org/v1alpha1
kind: ClusterPair
metadata:
    creationTimestamp: null
    name: <insert_name_here>
spec:
   config:
      clusters:
         kubernetes:
            LocationOfOrigin: /etc/kubernetes/admin.conf
            certificate-authority-data: <CA_DATA>
            server: https://192.168.56.74:6443
      contexts:
         kubernetes-admin@kubernetes:
            LocationOfOrigin: /etc/kubernetes/admin.conf
            cluster: kubernetes
            user: kubernetes-admin
      current-context: kubernetes-admin@kubernetes
      preferences: {}
      users:
         kubernetes-admin:
            LocationOfOrigin: /etc/kubernetes/admin.conf
            client-certificate-data: <CLIENT_CERT_DATA>
            client-key-data: <CLIENT_KEY_DATA>
    options:
       <insert_storage_options_here>: ""
status:
  remoteStorageId: ""
  schedulerStatus: ""
  storageStatus: ""
```
4. With the information from (2) update the spec generated in (3). You'll need to add the metadata.name for the cluster and 
add the Portworx clusterpair information under spec.options. The update ClusterPair should like this:
```yaml
apiVersion: stork.libopenstorage.org/v1alpha1
kind: ClusterPair
metadata:
  creationTimestamp: null
  name: remotecluster
spec:
  config:
      clusters:
        kubernetes:
          LocationOfOrigin: /etc/kubernetes/admin.conf
          certificate-authority-data: <CA_DATA> 
          server: https://192.168.56.74:6443
      contexts:
        kubernetes-admin@kubernetes:
          LocationOfOrigin: /etc/kubernetes/admin.conf
          cluster: kubernetes
          user: kubernetes-admin
      current-context: kubernetes-admin@kubernetes
      preferences: {}
      users:
        kubernetes-admin:
          LocationOfOrigin: /etc/kubernetes/admin.conf
          client-certificate-data: <CLIENT_CERT_DATA>
          client-key-data: <CLIENT_KEY_DATA>
  options:
      ip: <ip_of_remote_px_node>
      port: <port_of_remote_px_node_default_9001>
      token: <token_from_step_3>
status:
  remoteStorageId: ""
  schedulerStatus: ""
  storageStatus: ""
```
5. Once you apply the above spec you should be able to check the status of the pairing. On a successful pairing, you should 
see the "Storage Status" and "Scheduler Status" as "Ready" using storkctl
```
$ storkctl get clusterpair
NAME            STORAGE-STATUS   SCHEDULER-STATUS   CREATED
remotepair      Ready            Ready              26 Oct 18 03:11 UTC
```
6. If the status is in error state you can describe the clusterpair to get more information
```
$ kubectl describe clusterpair remotepair
```

## Migrating Volumes and Resources
Once you have the cluster pair set up you can migrate volumes and resources to the destination cluster

1. Migration through stork is also done through a CRD. Example migration spec:
```yaml
apiVersion: stork.libopenstorage.org/v1alpha1
kind: Migration
metadata:
  name: mysqlmigration
spec:
  # This should be the name of the cluster pair created above
  clusterPair: remotecluster
  # If set to false this will migrate only the Portworx volumes. No PVCs, apps, etc will be migrated
  includeResources: true
  # If set to false, the deployments and stateful set replicas will be set to 0 on the destination. There will be an annotation with "stork.openstorage.org/migrationReplicas" to store the replica count from the source
  startApplications: true
  # List of namespaces to migrate
  namespaces:
  - mysql
```

2. You can also start a migration using storkctl
```
$ storkctl create migration mysqlmigration --clusterPair remotecluster --namespaces mysql --includeResources --startApplications
Migration mysqlmigration created successfully
```

3. Once the migration has been started using the spec in (1) or using storkctl in (2), you can check the status of the migration using storkctl
```
$ storkctl get migration
NAME            CLUSTERPAIR     STAGE     STATUS       VOLUMES   RESOURCES   CREATED
mysqlmigration  remotecluster   Volumes   InProgress   0/1       0/0         26 Oct 18 20:04 UTC
```

4. The Stages of migration will go from Volumes→ Application→Final if successful.
```
$ storkctl get migration
NAME            CLUSTERPAIR     STAGE     STATUS       VOLUMES   RESOURCES   CREATED
mysqlmigration  remotecluster   Final     Successful   1/1       3/3         26 Oct 18 20:04 UTC
```

5. If you want more information about what resources were migrated you can describe the migration object using kubectl
```
$ kubectl describe migration mysqlmigration
Name:         mysqlmigration
Namespace:   
Labels:       <none>
Annotations:  <none>
API Version:  stork.libopenstorage.org/v1alpha1
Kind:         Migration
Metadata:
  Creation Timestamp:  2018-10-26T20:04:19Z
  Generation:          1
  Resource Version:    2148620
  Self Link:           /apis/stork.libopenstorage.org/v1alpha1/migrations/ctlmigration3
  UID:                 be63bf72-d95a-11e8-ba98-0214683e8447
Spec:
  Cluster Pair:       remotecluster
  Include Resources:  true
  Namespaces:
      mysql
  Selectors:           <nil>
  Start Applications:  true
Status:
  Resources:
    Group:      core
    Kind:       PersistentVolume
    Name:       pvc-34bacd62-d7ee-11e8-ba98-0214683e8447
    Namespace: 
    Reason:     Resource migrated successfully
    Status:     Successful
    Version:    v1
    Group:      core
    Kind:       PersistentVolumeClaim
    Name:       mysql-data
    Namespace:  mysql
    Reason:     Resource migrated successfully
    Status:     Successful
    Version:    v1
    Group:      apps
    Kind:       Deployment
    Name:       mysql
    Namespace:  mysql
    Reason:     Resource migrated successfully
    Status:     Successful
    Version:    v1
  Stage:        Final
  Status:       Successful
  Volumes:
    Namespace:                mysql
    Persistent Volume Claim:  mysql-data
    Reason:                   Migration successful for volume
    Status:                   Successful
    Volume:                   pvc-34bacd62-d7ee-11e8-ba98-0214683e8447
Events:
  Type    Reason      Age    From   Message
  ----    ------      ----   ----   -------
  Normal  Successful  2m42s  stork  Volume pvc-34bacd62-d7ee-11e8-ba98-0214683e8447 migrated successfully
  Normal  Successful  2m39s  stork  /v1, Kind=PersistentVolume /pvc-34bacd62-d7ee-11e8-ba98-0214683e8447: Resource migrated successfully
  Normal  Successful  2m39s  stork  /v1, Kind=PersistentVolumeClaim mysql/mysql-data: Resource migrated successfully
  Normal  Successful  2m39s  stork  apps/v1, Kind=Deployment mysql/mysql: Resource migrated successfully
```
