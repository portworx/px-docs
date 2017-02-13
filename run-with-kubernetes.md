---
layout: page
title: "Run Portworx with Kubernetes"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk
sidebar: home_sidebar
---
You can use Portworx to provide storage for your Kubernetes pods. Portworx pools your servers capacity and turns your servers or cloud instances into converged, highly available compute and storage nodes. This section describes how to deploy PX within a Kubernetes cluster and have PX provide highly available volumes to any application deployed via Kubernetes.

>**Note:**<br/>You can run PX with Kubernetes using the PX native driver (preferred) or FlexVol.

## Kubernetes with the PX native driver
Use [these](run-with-kubernetes-flexvolume.html) instructions to run Kubernetes with the PX native driver.

## Kubernetes with FlexVol
Use [these](run-with-kubernetes-native-driver.html) instructions to run Kubernetes with FlexVol.
