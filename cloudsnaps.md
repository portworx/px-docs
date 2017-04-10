---
layout: page
title: "Multi-Cloud Backup and Recovery of PX Volumes"
keywords: cloud, backup, restore, snapshot, disaster recovery
sidebar: home_sidebar
---
#WIP DOCUMENT
## Multi-Cloud Backup and Recovery of PX Volumes

This document outlines how PX volumes can be backed up to different cloud providers' object storage or any S3-compatible object storage. If the user wishes to restore any of the backups, they can restore the volume from that point in the timeline. This enables administrators running persistent container workloads on-prem or in the cloud to safely back their mission critical database volumes up to cloud storage and restore them on-demand, enabling a seamless DR integration for their important business application data.


### Supported Cloud Providers

Portworx PX-Enterprise supports the following cloud providerss
1. Amazon S3
2. Azure Blobstore
3. Google Cloud Storage
4. Any S3-compatible Object Storage

### Backing up a PX Volume to cloud storage

The first backup uploaded to the cloud is a full backup. After that, subsequent backups are incremental.
After 6 incremental backups, every 7th backup is a full backup. 

### Restoring a PX Volume from cloud storage

Any PX Volume backup can be restored to a PX Volume in the cluster. The restored volume inherits the attributes such as file system, size and block size from the backup. Replication level and aggregation level of the restored volume defaults to 1 irrespective of the replication and aggregation level of the backup volume. Users can increase replication or aggregation level level once the restore is complete on the restored volume.  

### Performing Cloud Backups of a PX Volume
 

#### Set the required cloud credentials

For this, we will use `pxctl cloudsnaps credentials create` command.

```
pxctl cloudsnap credentials create 

NAME:
   pxctl cloudsnap credentials create - Create a credential for cloud-snap

USAGE:
   pxctl cloudsnap credentials create [command options] [arguments...]

OPTIONS:
   --provider value                            Object store provider type [s3, azure, google]
   --s3-access-key value
   --s3-secret-key value
   --s3-region value
   --s3-endpoint value                         Endpoint of the S3 server, in host:port format
   --s3-disable-ssl
   --azure-account-name value
   --azure-account-key value
   --google-project-id value
   --google-json-key-file value
   --encryption-passphrase value, 
   --enc value  Passphrase to be used for encrypting data in the cloudsnaps
```

For Azure:

```
pxctl cloudsnaps credentials create --provider=azure --azure-account-name portworxtest --azure-account-key zbJSSpOOWENBGHSY12ZLERJJV 
```

For AWS:

```
pxctl cloudsnaps credentials create --provider=s3  --s3-access-key AKIAJ7CDD7XGRWVZ7A --s3-secret-key mbJKlOWER4512ONMlwSzXHYA --s3-region us-east-1 --s3-endpoint mybucket.s3-us-west-1.amazonaws.com:5555 
```

For Google Cloud:

```
TODO
```
`pxctl cloudsnaps credentials create' enables the user to configure the credentials for each supported cloud provider.

These credentials can also be enabled with encryption which makes each backup/restore to/from cloud to use the encryption passphrase given. These credentials can only be created once and cannot be modified. In order to maintain security, once configured, these secrets part of the credentials will not be displayed. 

### List the credentials to verify

Use 'pxctl cloudsnaps credentials list' to verify the credentials supplied. 

```
pxctl cloudsnaps credentials list

S3 Credentials
UUID                                         REGION            ENDPOINT                ACCESS KEY            SSL ENABLED        ENCRYPTION
5c69ca53-6d21-4086-85f0-fb423327b024        us-east-1        s3.amazonaws.com        AKIAJ7CDD7XGRWVZ7A        true           false

Azure Credentials
UUID                                        ACCOUNT NAME        ENCRYPTION
c0e559a7-8d96-4f28-9556-7d01b2e4df33        portworxtest        false
```


