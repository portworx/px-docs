---
layout: page
title: "Encrypting PVCs with Vault"
keywords: portworx, container, kubernetes, storage, k8s, flexvol, pv, persistent disk, encryption, pvc, vault
meta-description: "This guide is a step-by-step tutorial on how to provision encrypted PVCs with Portworx configured with Vault"
---

* TOC
{:toc}

>**Note:**<br/>Supported from PX Enterprise 1.4 onwards

There are two ways in which Portworx volumes can be encrypted and are dependent on how a secret passphrase is provided to PX.

### Encryption using Storage Class

In this method, PX will use the cluster wide secret key to encrypt PVCs.

#### Step 1: Set a cluster wide secret

Follow [this](/secrets/portworx-with-vault.html#setting-cluster-wide-secret-key) guide to setup cluster wide secret key if not already set.

{% include /secrets/k8s/storage-class-encryption.md %}

### Encryption using PVC annotations

In this method, each PVC can be encrypted with its own secret key.

#### Step 1: Create a Storage Class

{% include /secrets/k8s/enc-storage-class-spec.md %}

#### Step 2: Create a PVC with annotation

{% include /secrets/k8s/other-providers-pvc-encryption.md  %}

__Important: Make sure secret `your_secret_key` exists in Vault__
