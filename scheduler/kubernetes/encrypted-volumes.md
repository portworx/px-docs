---
layout: page
title: "Volume encryption"
keywords: portworx, container, kubernetes, storage, k8s, flexvol, pv, persistent disk, encryption, pvc
sidebar: home_sidebar
meta-description: "Looking to use a encrypted volume with Kubernetes? Follow this step-by-step tutorial on how to provision encrypted volumes with Kubernetes."
---

* TOC
{:toc}

This document describes how to provision an encrypted volume using Kubernetes and Portworx. For more information on encryption refer the [Encrypted Volumes page](/manage/encrypted-volumes.html).

Before you start using PVC encryption, you need to setup a secrets provider to store your secret keys and configure Portworx to use it. Refer the [Setup Secrets Provider](/secrets) page for more details on configuring various secret providers with Portworx.

There are a couple of ways you can create an encrypted Portworx volume in Kubernetes:
1. [Encryption using StorageClass](/scheduler/kubernetes/storage-class-encryption.html)
2. [Encryption using PVC](/scheduler/kubernetes/pvc-encryption.html)
