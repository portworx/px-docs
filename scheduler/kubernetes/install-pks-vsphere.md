---
layout: page
title: "Portworx install on PKS on vSphere"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk

meta-description: "Find out how to install PX in a PKS Kubernetes cluster on vSphere and have PX provide highly available volumes to any application deployed via Kubernetes."
---

* TOC
{:toc}

## Pre-requisites

* vSphere 6.5u1 or above.
* PKS 1.1 or above.
* Portworx 1.6.0 and later.

## Installing Portworx

Based on your ESXi datastore type, proceed to one of the following pages.

If you have **shared** datastores, proceed to [Portworx install on PKS on vSphere using shared datastores](install-pks-vsphere-shared.html).

If you have **local** datastores, proceed to [Portworx install on PKS on vSphere using local datastores](install-pks-vsphere-local.html).