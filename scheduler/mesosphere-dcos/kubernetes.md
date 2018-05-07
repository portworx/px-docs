---
layout: page
title: "Run Portworx with Kubernetes on Mesosphere DC/OS"
keywords: portworx, PX-Developer, container, Mesos, Mesosphere, storage, kubernetes, DCOS, DC/OS
meta-description: "Find out how to deploy Portworx with Kubernetes on DC/OS."
---

* TOC
{:toc}

>**Note:**<br/> Kubernetes on DC/OS with Portworx is only supported from PX version 1.4 onwards

Please make sure you have installed [Portworx on DCOS](/scheduler/mesosphere-dcos/install.html) before proceeding further.

The latest framework starts Portworx with scheduler set to mesos (`-x mesos` option) to
allow Portworx to mount volumes for Kubernetes pods. If you are using an older
version of the framework please update `/etc/pwx/config.json` to set `scheduler`
to `mesos`.

## Install dependencies

When using Kubernetes on DC/OS you will be able to use Portworx from your DC/OS
cluster. You only need to create a Kubernetes Service for Portworx to allow the
in-tree Kubernetes volume plugin to dynamically create and use Portworx volumes.

You can create the Service by running the following command:
```
$ kubectl apply -f 'https://install.portworx.com/1.4/?dcos=true&stork=true'
```

## Provisioning volumes

After the above spec has been applied, you can create volumes and snapshots
using Kuberenetes.
Please use the following guides:

* [Dynamic Provisioning](/scheduler/kubernetes/dynamic-provisioning.html)
* [Using Pre-provisioned volumes](/scheduler/kubernetes/preprovisioned-volumes.html)
* [Creating and using snapshots](/scheduler/kubernetes/snaps.html)
* [Volume encryption](/scheduler/kubernetes/storage-class-encryption.html)
