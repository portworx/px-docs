---
layout: page
title: "Volume encryption"
keywords: portworx, container, kubernetes, storage, k8s, flexvol, pv, persistent disk, encryption, pvc
sidebar: home_sidebar
meta-description: "Looking to use a encrypted volume with Kubernetes? Follow this step-by-step tutorial on how to provision encrypted volumes with Kubernetes."
---

* TOC
{:toc}

{% include secrets/intro.md %}

Based on your configured secret provider select one of the following volume encryption guides:

### Kubernetes Secrets

1. [Encryption using StorageClass](/scheduler/kubernetes/storage-class-encryption.html)
2. [Encryption using PVC](/scheduler/kubernetes/pvc-encryption.html)

### Vault

[Encrypting PVCs with Vault](/scheduler/kubernetes/encrypted-pvc-vault.html)

### AWS KMS

[Encrypting PVCs with AWS KMS](/scheduler/kubernetes/encrypted-pvc-awskms.html)

### IBM Key Protect

[Encrypting PVCs with IBM Key Protect](/scheduler/kubernetes/encrypted-pvc-ibm-kp.html)
