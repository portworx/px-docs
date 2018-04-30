---
layout: page
title: "Deploying Portworx with CSI support"
keywords: csi, portworx, container, Kubernetes, storage, Docker, k8s, pv, persistent disk
sidebar: home_sidebar
---

* TOC
{:toc}

[CSI](https://kubernetes-csi.github.io/), or _Container Storage Interface_, is
the new model for integrating storage system service with Kubernetes and other
orchestration systems. Kubernetes has had support for CSI since 1.10 as beta.

With CSI, Kubernetes gives storage drivers the opportunity to release on their
schedule. This allows storage vendors to upgrade, update, and enhance their drivers
without the need to update Kubernetes, maintaining a consistent, dependable,
orchestration system.

## Status
Note, that currently this deployment mode is available only as a _Tech Preview_ for Release 1.4.

## Install

### Install using the Portworx spec generator
When installing Portworx through [install.portworx.com](https://install.portworx.com)
you can select CSI as the model to use for deployment.

If you are using [curl to fetch the Portworx
spec](https://docs.portworx.com/scheduler/kubernetes/px-k8s-spec-curl.html), you can add
`csi=true` to the parameter list to include CSI specs in the generated file.

## Impact on applications

The only affected object is the [_StorageClass_](https://kubernetes-csi.github.io/docs/Usage.html#dynamic-provisioning).
For any StorageClasses created, you will need to setup the value of `provisioner`
to `com.openstorage.pxd`. Here is an example:

```yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: portworx
provisioner: com.openstorage.pxd
parameters:
  repl: "3"
```

Your PersistentVolumes and PersistentVolumeClaims will all work the same as before.

## Upgrade

Currently upgrades are _not_ supported. You will need to deploy using CSI onto
a new Kubernetes cluster. The Kubernetes community is working very hard to make
this possible in the near future.

## Contribute

Portworx welcomes contributions to our CSI implemenation, which is open-source
and repository is at [OpenStorage](https://github.com/libopenstorage/openstorage).

