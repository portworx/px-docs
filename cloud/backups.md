---
layout: page
title: "Multi-Cloud Backup and Recovery of PX Volumes"
keywords: cloud, backup, restore, snapshot, DR
sidebar: home_sidebar
redirect_from: "/cloudsnaps.html"
meta-description: "Portworx can be used as a backup and recovery solution for container data volumes on AWS, Azure and Google Cloud.  Find out how today!"
---

* TOC
{:toc}

## Multi-Cloud Backup and Recovery of PX Volumes

This document outlines how PX volumes can be backed up to different cloud provider's object storage including any S3-compatible object storage. If a user wishes to restore any of the backups, they can restore the volume from that point in the timeline. This enables administrators running persistent container workloads on-prem or in the cloud to safely backup their mission critical database volumes to cloud storage and restore them on-demand, enabling a seamless DR integration for their important business application data.

### Supported Cloud Providers

Portworx PX-Enterprise supports the following cloud providerss
1. Amazon S3 and any S3-compatible Object Storage
2. Azure Blob Storage
3. Google Cloud Storage

### Backing up a PX Volume to cloud storage

The first backup uploaded to the cloud is a full backup. After that, subsequent backups are incremental.
After 6 incremental backups, every 7th backup is a full backup. 

### Restoring a PX Volume from cloud storage

Any PX Volume backup can be restored to a PX Volume in the cluster. The restored volume inherits the attributes such as file system, size and block size from the backup. Replication level and aggregation level of the restored volume defaults to 1 irrespective of the replication and aggregation level of the volume that was backed up. Users can increase replication or aggregation level level once the restore is complete on the restored volume.  

### Performing Cloud Backups of a PX Volume

Performing cloud backups of a PX Volume is available via `pxctl cloudsnap` command. This command has the following operations available for the full lifecycle management of cloud backups.

```
# pxctl cloudsnap
NAME:
   pxctl cloudsnap - Backup and restore snapshots to/from cloud

USAGE:
   pxctl cloudsnap command [command options] [arguments...]

COMMANDS:
     backup, b          Backup a snapshot to cloud
     restore, r         Restore volume to a cloud snapshot
     list, l            List snapshot in cloud
     status, s          Report status of active backups/restores
     schedule, sc       Update cloud-snap schedule
     catalog, t         Display catalog for the backup in cloud
     credentials, cred  Manage cloud-snap credentials

OPTIONS:
   --help, -h  show help
```

#### Set the required cloud credentials ####

For this, we will use `pxctl cloudsnap credentials create` command.

```
# pxctl cloudsnap credentials create 

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
# pxctl cloudsnap credentials create --provider azure --azure-account-name portworxtest --azure-account-key zbJSSpOOWENBGHSY12ZLERJJV 
```

For AWS:

```
# pxctl cloudsnap credentials create --provider s3  --s3-access-key AKIAJ7CDD7XGRWVZ7A --s3-secret-key mbJKlOWER4512ONMlwSzXHYA --s3-region us-east-1 --s3-endpoint s3.amazonaws.com 
```

For Google Cloud:

```
# pxctl cloudsnap credentials create --provider google --google-project-id px-test --google-json-key-file px-test.json
```
`pxctl cloudsnap credentials create` enables the user to configure the credentials for each supported cloud provider.

An additional encryption key can also be provided for each credential. If provided, all the data being backed up to the cloud will be encrypted using this key. The same key needs to be provided when configuring the credentials for restore to be able to decrypt the data succesfuly. 

These credentials can only be created once and cannot be modified. In order to maintain security, once configured, the secret parts of the credentials will not be displayed. 

#### List the credentials to verify ####

Use `pxctl cloudsnap credentials list` to verify the credentials supplied. 

```
# pxctl cloudsnap credentials list

S3 Credentials
UUID                                         REGION            ENDPOINT                ACCESS KEY            SSL ENABLED        ENCRYPTION
5c69ca53-6d21-4086-85f0-fb423327b024        us-east-1        s3.amazonaws.com        AKIAJ7CDD7XGRWVZ7A        true           false

Azure Credentials
UUID                                        ACCOUNT NAME        ENCRYPTION
c0e559a7-8d96-4f28-9556-7d01b2e4df33        portworxtest        false

Google Credentials
UUID						PROJECT ID     ENCRYPTION
8bd266b5-da9f-4114-84a2-309bbb3838c6		px-test        false

```

`pxctl cloudsnap credentials list`  only displays non-secret values of the credentials. Secrets are neither stored locally nor displayed.  These credentials will be stored as part of the secret endpoint given for PX for persisting authentication across reboots. Please refer to `pxctl secrets` help for more information.

#### Perform Cloud Backup ####

The actual backup of the PX Volume is done via the `pxctl cloudsnap backup` command

```
# pxctl cloudsnap backup 

NAME:
   pxctl cloudsnap backup - Backup a snapshot to cloud

USAGE:
   pxctl cloudsnap backup [command options] [arguments...]

OPTIONS:
   --volume value, -v value       source volume
   --full, -f                     force a full backup
   --cred-uuid value, --cr value  Cloud credentials ID to be used for the backup

```

This command is used to backup a single volume to the cloud provider using the specified credentials. 
This command decides whether to take a full or incremental backup depending on the existing backups for the volume. 
If it is the first backup for the volume it takes a full backup of the volume. If its not the first backup, it takes an incremental backup from the previous full/incremental backup.

```
# pxctl cloudnsap backup volume1 --cred-uuid 82998914-5245-4739-a218-3b0b06160332
```

Users can force the full backup any time by giving the --full option.
If only one credential is configured on the cluster, then the cred-uuid option may be skipped on the command line.

Here are a few steps to perform cloud backups successfully

* List all the available volumes to choose the volume to backup

```
# pxctl volume list
ID			NAME	SIZE	HA	SHARED	ENCRYPTED	IO_PRIORITY	SCALE	STATUS
538316104266867971	NewVol	4 GiB	1	no	no		LOW		1	up - attached on 70.0.9.73
980081626967128253	evol	2 GiB	1	no	no		LOW		1	up - detached
```

* List the configured credentials

```
# pxctl cloudsnap credentials list

Azure Credentials
UUID						ACCOUNT NAME		ENCRYPTION
ef092623-f9ba-4697-aeb5-0d5d6d9b5742		portworxtest		false
```

Authenticate the nodes where the storage for volume to be backed up is provisioned.

* Login to the secrets database to use encryption in-flight

```
# pxctl secrets kvdb login
Successful Login to Secrets Endpoint!
```

* Now issue the backup command 

Note that in this particular example,  since only one credential is configured, there is no need to specify the credentials on the command line

```
# pxctl cloudsnap backup NewVol
Cloudsnap backup started successfully
```

* Watch the status of the backup

```
# pxctl cloudsnap status
SOURCEVOLUME		STATE		BYTES-PROCESSED	TIME-ELAPSED	COMPLETED			ERROR
538316104266867971	Backup-Active	62914560	20.620429615s
980081626967128253	Backup-Done	68383234	4.522017785s	Sat, 08 Apr 2017 05:09:54 UTC
```

Once the volume is backed up to the cloud successfully, listing the remote cloudsnaps will display the backup that just completed.

* List the backups in cloud

```
# pxctl cloudsnap list
SOURCEVOLUME	CLOUD-SNAP-ID					CREATED-TIME			STATUS
evol		pqr9-cl1/980081626967128253-941778877687318172	Sat, 08 Apr 2017 05:09:49 UTC	Done
NewVol		pqr9-cl1/538316104266867971-807625803401928868	Sat, 08 Apr 2017 05:17:21 UTC	Done
```

#### Restore from a Cloud Backup ####

Use `pxctl cloudsnap restore` to restore from a cloud backup. 

Here is the command syntax.

```
# pxctl cloudsnap restore

NAME:
   pxctl cloudsnap restore - Restore volume to a cloud snapshot

USAGE:
   pxctl cloudsnap restore [command options] [arguments...]

OPTIONS:
   --snap value, -s value         Cloud-snap id
   --node value, -n value         Optional node ID for provisioning restore volume storage
   --cred-uuid value, --cr value  Cloud credentials ID to be used for the restore
   
```

This command is used to restore a successful backup from cloud. It requires the cloudsnap ID which can be used to restore and credentials for the cloud storage provider or the object storage. Restore happens on any node where storage can be provisioned. In this release restored volume will have a replication factor of 1. The restored volume can be updated to different replication factors using `pxctl volume ha-update` command.

The command usage is as follows.
```
# pxctl cloudsnap restore --snap cs30/669945798649540757-864783518531595119 --cr 82998914-5245-4739-a218-3b0b06160332​
```

Upon successful start of the command it returns the volume id created to restore the cloud snap
If the command fails to succeed, it shows the failure reason.

The restored volume will not be attached or mounted automatically.


* Use `pxctl cloudsnap list` to list the available backups.

`pxctl cloudsnap list` helps enumerate the list of available backups in the cloud. This command assumes that you have all the credentials setup properly. If the credentials are not setup, then the backups available in those clouds won't be listed by this command.

```
# pxctl cloudsnap list
SOURCEVOLUME 	CLOUD-SNAP-ID					CREATED-TIME			STATUS
dvol		pqr9-cl1/520877607140844016-50466873928636534	Fri, 07 Apr 2017 20:22:43 UTC	Done
NewVol		pqr9-cl1/538316104266867971-807625803401928868	Sat, 08 Apr 2017 05:17:21 UTC	Done
```

* Choose one of them to restore

```
# pxctl cloudsnap restore -s pqr9-cl1/538316104266867971-807625803401928868
Cloudsnap restore started successfully: 622390253290820715
```
`pxctl cloudsnap status` gives the status of the restore processes as well.

```
# pxctl cloudsnap status
SOURCEVOLUME		STATE		BYTES-PROCESSED	TIME-ELAPSED	COMPLETED			ERROR
622390253290820715	Restore-Active	99614720	10.144539084s
980081626967128253	Backup-Done	68383234	4.522017785s	Sat, 08 Apr 2017 05:09:54 UTC
538316104266867971	Backup-Done	1979809411	2m39.761333366s	Sat, 08 Apr 2017 05:20:01 UTC
```
