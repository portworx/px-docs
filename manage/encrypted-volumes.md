---
layout: page
title: "Portworx Encrypted Volumes"
keywords: portworx, px-developer, px-enterprise, plugin, install, configure, container, storage, encryption
sidebar: home_sidebar
redirect_from: "/encrypted-volumes.html"
---

* TOC
{:toc}

## Encrypted Volumes
This guide will give you an overview of how to use Encryption feature for Portworx volumes. Under the hood Portworx uses libgcrypt library to interface with the dm-crypt module for creating, accessing and managing encrypted devices. Portworx uses the LUKS format of dm-crypt and AES-256 as the cipher with xts-plain64 as the cipher mode.

All the encrypted volumes are protected by a key. Portworx uses a passphrase as a key to encrypt volumes. It is recommended to store these passphrases in a secure secret store. Currently Portworx integrates with following Secret endpoints

1. Vault
To setup Portworx to work with a Vault endpoint follow these [instructions](/secrets/portworx-with-vault.html)

2. AWS KMS
To setup Portworx to work with AWS KMS follow these [instructions](/secrets//portworx-with-aws-kms.html)

## Creating and using encrypted volumes

There are two ways in which Portworx volumes can be encrypted and are dependent on how a secret passphrase is provided to PX.

### Using cluster wide secret key
Cluster wide secret key is basically a key value pair where the value part is the secret that is used as a passphrase for encrypting volumes. A cluster wide secret key is a common key that can be used to encrypt all your volumes.

__Important: Make sure the cluster wide secret key is set when you are setting up Portworx with one of the supported secret endpoints__

```
# /opt/pwx/bin/pxctl volume create --secure --size 10 encrypted_volume
Volume successfully created: 822124500500459627
# /opt/pwx/bin/pxctl volume list
ID	      	     		NAME		SIZE	HA SHARED	ENCRYPTED	IO_PRIORITY	SCALE	STATUS
822124500500459627	 encrypted_volume	10 GiB	1    no yes		LOW		1	up - detached
```

You can attach and mount the encrypted volume

```
# /opt/pwx/bin/pxctl host attach encrypted_volume
Volume successfully attached at: /dev/mapper/pxd-enc822124500500459627
# /opt/pwx/bin/pxctl host mount encrypted_volume /mnt
Volume encrypted_volume successfully mounted at /mnt
```

We do not need to specify a secret key during create or attach of a volume as it will by default use the cluster wide secret key for encryption. However you can specify per volume keys which is explained in the next section.


### Using per volume secret keys

You can encrypt volumes using different keys instead of the cluster wide secret key. However you need to specify the key for every create
and attach commands.


```
# /opt/pwx/bin/pxctl volume create --secure --secret_key key1 enc_vol
Volume successfully created: 374663852714325215
# /opt/pwx/bin/pxctl host attach --secret key1 enc_vol
Volume successfully attached at: /dev/mapper/pxd-enc374663852714325215
```

__Important: Make sure secret `key1` exists in the secret endpoint__
