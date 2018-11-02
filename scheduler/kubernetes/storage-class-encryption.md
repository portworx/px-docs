---
layout: page
title: "Encryption using StorageClass"
keywords: portworx, container, kubernetes, storage, k8s, flexvol, pv, persistent disk, encryption, pvc
meta-description: "This guide is a step-by-step tutorial on how to provision encrypted volumes using Storage Class parameters."
---

Using a Storage Class parameter, you can tell Portworx to encrypt all PVCs created using that Storage Class. Portworx uses a cluster wide secret to encrypt all the volumes created using the secure Storage Class.

{% include_relative set-cluster-wide-secret.md %}

{% include secrets/k8s/storage-class-encryption.md %}