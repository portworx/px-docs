---
layout: page
title: "Resize a Portworx PVC"
keywords: portworx, storage class, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk,StatefulSets
sidebar: home_sidebar
meta-description: "Looking to use a dynamically resize a provisioned volume with Kubernetes?  Follow this step-by-step tutorial on how to do it with Portworx."
---

* TOC
{:toc}

This document describes how to dynamically resize a volume (PVC) using Kubernetes and Portworx.

## Pre-requisites

* Resize support for PVC is in Kubernetes 1.11 and above. If you have an older version, use [pxctl volume update](/control/volume.html#pxctl-volume-update) to update the volume size.
* The StorageClass must have `allowVolumeExpansion: true`.
* The PVC must be in use by a Pod.

## Example

To resize a Portworx PVC, you can simply edit the PVC spec and update the size. Let's take an example of resizing a mysql PVC.

1. Download the [MySQL StorageClass spec](/k8s-samples/mssql/mssql_sc.yml?raw=true) and apply it. Note that the StorageClass has `allowVolumeExpansion: true`
2. Download the [MySQL PVC spec](/k8s-samples/mssql/mssql_pvc.yml?raw=true) and apply it. We will start with a 5GB volume.
3. Download the [MySQL Deployment spec](/k8s-samples/mssql/mssql_deployment.yml?raw=true) and apply it. Wail till the pod becomes 1/1 and then proceed to next step.
4. Run `kubectl edit pvc mssql-data` and change the size in the "spec" to 10Gi.

After you save the spec, `kubectl describe pvc mssql-data` should have an entry like below that confirms the volume resize.

```
Normal  VolumeResizeSuccessful  5s    volume_expand                ExpandVolume succeeded for volume default/mssql-data
```