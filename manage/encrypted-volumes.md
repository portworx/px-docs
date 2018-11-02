---
layout: page
title: "Portworx Encrypted Volumes"
keywords: portworx, px-developer, px-enterprise, plugin, install, configure, container, storage, encryption
sidebar: home_sidebar
redirect_from:
  - /encrypted-volumes.html
meta-description: "This guide will give you an overview of how to use the Encryption feature for Portworx volumes. Read the full overview here!"
---

* TOC
{:toc}

## Encrypted Volumes
This guide will give you an overview of how to use Encryption feature for Portworx volumes. Under the hood Portworx uses libgcrypt library to interface with the dm-crypt module for creating, accessing and managing encrypted devices. Portworx uses the LUKS format of dm-crypt and AES-256 as the cipher with xts-plain64 as the cipher mode.

All the encrypted volumes are protected by a key. Portworx uses a passphrase as a key to encrypt volumes. It is recommended to store these passphrases in a secure secret store. To know more about the supported secret providers and how to configure them with Portworx, refer the [Setup Secrets Provider](/secrets) page.

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

# docker run --rm -it -v secret_key=key1,name=enc_vol:/mnt busybox
/ #

# docker run --rm -it --mount src=secret_key=key1?name=enc_vol,dst=/mnt busybox
/ #
```

__Important: Make sure secret `key1` exists in the secret endpoint__

## Encrypted Shared Volumes

Encrypted shared volume allows access from multiple nodes to the same
encrypted volume.

Shared flag can be set while creating the encrypted volume using `--shared`
It can also be enabled or disabled during run-time using `--shared on/off`.
Volume must be in detached state to toggle shared flag during run-time.

Portworx cluster must be authenticated to access secret store for
the encryption keys.
Both cluster wide and per volume secrets are supported. For example, using
cluster wide secret key:

```
# pxctl volume create --shared --secure --size 10 encrypted_volume
Encrypted Shared volume successfully created: 77957787758406722
# pxctl volume inspect encrypted_volume
Volume	:  77957787758406722
Name            	 :  encrypted_volume
Size            	 :  10 GiB
Format          	 :  ext4
HA              	 :  1
IO Priority     	 :  LOW
Creation time   	 :  Nov 1 17:22:59 UTC 2018
Shared          	 :  yes
Status          	 :  up
State           	 :  detached
Attributes      	 :  encrypted
Reads           	 :  0
Reads MS        	 :  0
Bytes Read      	 :  0
Writes          	 :  0
Writes MS       	 :  0
Bytes Written   	 :  0
IOs in progress 	 :  0
Bytes used      	 :  131 MiB
Replica sets on nodes:
	Set 0
		Node 		 : 70.0.18.11 (Pool 0)
Replication Status	 :  Detached
```
