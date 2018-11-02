---
layout: page
title: "Portworx Encrypted Volumes with AWS KMS"
keywords: portworx, px-developer, px-enterprise, plugin, install, configure, container, storage, encryption, aws, kms
meta-description: "This guide will give you an overview of how to use the Encryption feature for Portworx volumes with AWS KMS"
---

* TOC
{:toc}

## Creating and using encrypted volumes

There are two ways in which Portworx volumes can be encrypted and are dependent on how a secret passphrase is provided to PX.

### Using per volume secret keys

Follow [this](/secrets/portworx-with-aws-kms.html#key-generation-with-aws-kms) guide to create secrets in AWK KMS using pxctl.

{% include secrets/per-volume-secret.md %}

__Important: Make sure secret `key1` was generated using the pxctl aws kms helper commands__

### Using cluster wide secret key

Follow [this](/secrets/portworx-with-aws-kms.html#setting-cluster-wide-secret-key) guide to setup cluster wide secret key.

{% include secrets/volume-cluster-wide-secret.md %}

__Important: Make sure the cluster wide secret key is set when you are setting up Portworx with AWS KMS__