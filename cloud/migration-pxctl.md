---
layout: page
title: "Cloud Migration using pxctl"
keywords: cloud, backup, restore, snapshot, DR, migration
---

* TOC
{:toc}

## Overview
This method can be used to migrate volumes between two Portworx cluster. It will
not migrate any scheduler specific resources.

## Pre-requisites
* Requires PX-Enterprise v2.0+ 
* Make sure you have configured a [secret store](https://docs.portworx.com/secrets/) on both your clusters. This will be used to store the credentials for the 
objectstore.
* Make sure ports 9001 and 9010 on the destination cluster are reachable from the
source cluster.

## Pairing clusters

1. Install portworx on two clusters
2. To pair the cluster we need a token from the destination cluster to authorize the pairing from the source cluster. On the destination cluster, run 
   the following commands from one of the Portworx nodes (steps (a) and (b) will not be  required in the future)
   1. Create a volume for the objectstore: `/opt/pwx/bin/pxctl volume create --size 100 objectstore`
   2. Create an objectstore: `/opt/pwx/bin/pxctl objectstore create -v objectstore`
   3. Get the cluster token: `/opt/pwx/bin/pxctl cluster token show`
3. On the source cluster, run the following commands:
   1. Create the cluster pair: 
   ```
   $ /opt/pwx/bin/pxctl cluster pair create --ip <ip_of_destination_cluster_node> --token <token_from_2c>
   ```
4. If 3(a) is successful you should see the destination cluster in the list of pairs: 
   ```
   $ /opt/pwx/bin/pxctl cluster pair list
 
   CLUSTER-ID                                       NAME            ENDPOINT                     CREDENTIAL-ID
   2937523c-a8f6-4564-a683-e3b53b92a3b7 (default)   disrani-px2     http://192.168.56.106:9001   952e15df-ca3e-49df-8c20-92f862a44a78
   ```
5. You can pair multiple clusters with each other
6. You can delete the cluster pair by running the following command:
```
/opt/pwx/bin/pxctl cluster pair delete --id <cluster_id>
```
7. The first pair created will be listed as the default pair. 

## Migrating Volumes
Once you have created cluster pairs you can migrate volumes to it

1. Migration can be done at 2 granularities right now
   1. Migrate all volumes from the cluster: `/opt/pwx/bin/pxctl cloudmigrate start -a [ -c <cluster_id> ]`
   2. Migrate a particular volume from the cluster: `/opt/pwx/bin/pxctl cloudmigrate start -v <volumeId> [ -c <cluster_id> ]`
2. If no ClusterID is specified it'll pick up the default cluster pair
3. The status for the migration can be checked by running the following command: 

   ```
   $ /opt/pwx/bin/pxctl cloudmigrate status 

   CLUSTER UUID: 2937523c-a8f6-4564-a683-e3b53b92a3b7
   TASK-ID                                  VOLUME-ID           VOLUME-NAME  STAGE  STATUS      LAST-UPDATE
   107655ea-0f66-4ffe-99e2-1ef06434aa40     589129994411792979  testVolume   Done   Complete    Sat, 27 Oct 2018 01:12:40 UTC
   ```
4. The stages of migration will progress from Backup→ Restore→Done. If any stage fails the status will be marked as Failed.
5. If the migration is successful you should be able see the volume(s) with the same name created on the destination cluster.
