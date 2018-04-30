---
layout: page
title: "PX-Enterprise Release notes - for RC builds"
keywords: portworx, px-enterprise, release notes
sidebar: home_sidebar
redirect_from:
  - /px-enterprise-release-notes.html
  - /release-notes-1-0-4.html
meta-description: "Stay up to date with the new releases and updates from Portworx. See our latest key features and an explanation of them all!"
---

* TOC
{:toc}

## 1.4.0 (WIP)


### Key Features

* 3DSnaps - Ability to take [application-consistent](https://docs.portworx.com/scheduler/kubernetes/snaps.html)
  snapshots cluster wide (Available in 05/14 GA version)
  * Volume Group snapshots - Ability to take crash-consistent snapshots on group of volumes based on a user-defined label 
* GCP/GKE automated disk management based on disk templates
* Provide ability to do a license tranfer from one cluster to another cluster
* [Kubernetes per volume secret support](https://docs.portworx.com/scheduler/kubernetes/pvc-encryption.html) to enable 
  volume encryption keys per Kubernetes PVC and using the Kubernetes secrets for key storage
* DC/OS vault integration - Use Vault integrated with DC/OS
* Support port mapping used by PX from 9001-9015 to a customer port number range


### Key Fixes:

WIPa












