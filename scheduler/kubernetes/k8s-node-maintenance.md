---
layout: page
title: "Enter Portworx maintenance mode in Kubernetes"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk
sidebar: home_sidebar
---

* TOC
{:toc}

This guide describes a recommended workflow for putting a Portworx node in maintenance mode in your Kubernetes cluster.

### 1. Migrate application pods using portworx volumes that are running on this node
Before putting Portworx in maintenance mode on a node, applications running on that node using Portworx need to be migrated. 
If Portworx is in maintenance mode, existing application pods will end up with read-only volumes and new pods will fail to start.

You have 2 options for migrating applications.
##### Migrate all pods
* Drain the node using: `kubectl drain <node>`

##### Migrate selected pods
1. Cordon the node using: `kubectl cordon <node>`
2. Delete the application pods using portworx volumes using: `kubectl delete pod <pod-name>`
    * Since application pods are expected to be managed by a controller like `Deployement` or `StatefulSet`, Kubernetes will spin up a new replacement pod on another node.

### 2. Enter Portworx maintenance mode
Run **"pxctl service maintenance --enter"**.
This takes Portworx out of an "Operational" state for a given node.  Perform whatever maintenance tasks are needed.

### 3. Exit Portworx maintenance mode
Once you are done with maintenance tasks, run **"pxctl service maintenance --exit"**.
This puts Portworx back in to "Operational" state for a given node.

### 4. Uncordon the node
You can now uncordon the node using: `kubectl uncordon <node>`
