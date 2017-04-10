---
layout: page
title: "Multi-Cloud Backup and Recovery of PX Volumes"
keywords: cloud, backup, restore, snapshot, disaster recovery
sidebar: home_sidebar
---
#WIP DOCUMENT
## Multi-Cloud Backup and Recovery of PX Volumes

This document outlines how PX volumes can be backed up to different cloud provider's object storage or any S3-compatible object storage. If user wishes to restore any of the backups, he/she can restore the volume from that point in the timeline. This enables administrators running persistent container workloads on-prem or in the cloud to safely back their mission critical database volumes up to cloud storage and restore them on-demand, enabling a seamless DR integration for their important business application data.


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

Performing cloud backups of a PX Volume is available via `pxctl cloudsnap` command. This command has the following operations available for the full lifecycle management of cloud backups.

```
pxctl cloudsnap
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
pxctl cloudsnap credentials create --provider=azure --azure-account-name portworxtest --azure-account-key zbJSSpOOWENBGHSY12ZLERJJV 
```

For AWS:

```
pxctl cloudsnap credentials create --provider=s3  --s3-access-key AKIAJ7CDD7XGRWVZ7A --s3-secret-key mbJKlOWER4512ONMlwSzXHYA --s3-region us-east-1 --s3-endpoint mybucket.s3-us-west-1.amazonaws.com:5555 
```

For Google Cloud:

```
TODO
```
`pxctl cloudsnap credentials create` enables the user to configure the credentials for each supported cloud provider.

These credentials can also be enabled with encryption which makes each backup/restore to/from cloud to use the encryption passphrase given. These credentials can only be created once and cannot be modified. In order to maintain security, once configured, these secrets part of the credentials will not be displayed. 

#### List the credentials to verify ####

Use `pxctl cloudsnap credentials list` to verify the credentials supplied. 

```
pxctl cloudsnap credentials list

S3 Credentials
UUID                                         REGION            ENDPOINT                ACCESS KEY            SSL ENABLED        ENCRYPTION
5c69ca53-6d21-4086-85f0-fb423327b024        us-east-1        s3.amazonaws.com        AKIAJ7CDD7XGRWVZ7A        true           false

Azure Credentials
UUID                                        ACCOUNT NAME        ENCRYPTION
c0e559a7-8d96-4f28-9556-7d01b2e4df33        portworxtest        false
```

`pxctl cloudsnap credentials list`  only displays non-secret values part of the credentials.Secrets are neither stored locally nor displayed.  These credentials will be stored as part of the secret endpoint given for PX for persisting authentication across reboots. Please refer `pxctl secrets` help for more information.

#### Perform Cloud Backup ####

The actual backup of the PX Volume is done via the `pxctl cloudsnap backup` command

```
pxctl cloudsnap backup 

NAME:
   pxctl cloudsnap backup - Backup a snapshot to cloud

USAGE:
   pxctl cloudsnap backup [command options] [arguments...]

OPTIONS:
   --volume value, -v value       source volume
   --full, -f                     force a full backup
   --cred-uuid value, --cr value  Cloud credentials ID to be used for the backup

```

This command is used to backup a single volume to the configured cloud provider through credential command line. 
This command decides to take full or incremental backup depending on the existing backups for the volume. 
If it is the first backup for the volume it takes full backup of the volume. If its not the first backup, it takes incremental backup from the previous full/incremental backup.

```
pxctl cloudnsap backup volume1 --cred-uuid 82998914-5245-4739-a218-3b0b06160332
```

User can force the full backup any time by giving option --full.
If only one credential is configured, then it may be skipped on command line.

Here are a few steps to perform cloud backups successfully

* List the available volumes to choose the volume to backup

```
pxctl volume list
ID			NAME	SIZE	HA	SHARED	ENCRYPTED	IO_PRIORITY	SCALE	STATUS
538316104266867971	NewVol	4 GiB	1	no	no		LOW		1	up - attached on 70.0.9.73
980081626967128253	evol	2 GiB	1	no	no		LOW		1	up - detached
```

* List the configured credentials

```
pxctl cloudsnap credentials list

Azure Credentials
UUID						ACCOUNT NAME		ENCRYPTION
ef092623-f9ba-4697-aeb5-0d5d6d9b5742		portworxtest		false
```

Authenticate the nodes where the storage for volume to be backed up is provisioned.

* Login to the secrets database to use encryption in-flight

```
pxctl secrets kvdb login
Successful Login to Secrets Endpoint!
```

* Now issue the backup command 

Note that in this particular example,  since only one credential is configured, no need to specify the credentials on the command line

```
pxctl cloudsnap backup NewVol
Cloudsnap backup started successfully
```

* Watch the status

```
pxctl cloudsnap status
SOURCEVOLUME		STATE		BYTES-PROCESSED	TIME-ELAPSED	COMPLETED			ERROR
538316104266867971	Backup-Active	62914560	20.620429615s
980081626967128253	Backup-Done	68383234	4.522017785s	Sat, 08 Apr 2017 05:09:54 UTC
```

Once te volume is backed up to the cloud successfully,  lisitng the remote cloudsnap will display the backup that just completed.

* List the backups in cloud

# bin/pxctl cs l
SOURCEVOLUME 		CLOUD-SNAP-ID						CREATED-TIME				STATUS
evol			pqr9-cl1/980081626967128253-941778877687318172		Sat, 08 Apr 2017 05:09:49 UTC		Done
NewVol		pqr9-cl1/538316104266867971-807625803401928868		Sat, 08 Apr 2017 05:17:21 UTC		Done

#### Restore from a Cloud Backup

Use `pxctl cloudsnap restore` to restore from a cloud backup. 

Here is the command syntax.

```
pxctl cloudsnap restore

NAME:
   pxctl cloudsnap restore - Restore volume to a cloud snapshot

USAGE:
   pxctl cloudsnap restore [command options] [arguments...]

OPTIONS:
   --snap value, -s value         Cloud-snap id
   --node value, -n value         Optional node ID for provisioning restore volume storage
   --cred-uuid value, --cr value  Cloud credentials ID to be used for the restore
   
```

This command is used to restore a successful backup from cloud. It requires cloudsnap Id which can be used to restore and credentials for the cloud storage provider or the object storage. Restore happens on any node where storage can be provisioned. In this release restored volume will be of replication factor 1. This volume can be updated to different repl factors using volume ha-update command.

The command usage is as follows.
```
pxctl cloudsnap restore --snap cs30/669945798649540757-864783518531595119 --cr 82998914-5245-4739-a218-3b0b06160332​
```

Upon successful start of the command it returns the volume id created to restore the cloud snap
If the command fails to succeed, it shows the failure reason.

The restored volume will not be attached or mounted automatically.


* Use `pxctl cloudsnap list` to list the available backups.

`pxctl cloudsnap list` helps enumerate the list of available backups in the cloud. This command assumes that you have all the credentials setup properly. If the credentials are not setup, then the backups available in those clouds won't be listed by this command.

```
pxctl cloudsnap list
SOURCEVOLUME 		CLOUD-SNAP-ID						CREATED-TIME				STATUS
dvol			pqr9-cl1/520877607140844016-50466873928636534		Fri, 07 Apr 2017 20:22:43 UTC		Done
NewVol		pqr9-cl1/538316104266867971-807625803401928868		Sat, 08 Apr 2017 05:17:21 UTC		Done
```

* Choose one of them to restore

```
pxctl cloudsnap restore -s pqr9-cl1/538316104266867971-807625803401928868
Cloudsnap restore started successfully: 622390253290820715
```
`pxctl cloudsnap status` gives the status of the restore processes as well.

```
pxctl cloudsnap status
SOURCEVOLUME		STATE		BYTES-PROCESSED	TIME-ELAPSED	COMPLETED			ERROR
622390253290820715	Restore-Active	99614720	10.144539084s
980081626967128253	Backup-Done	68383234	4.522017785s	Sat, 08 Apr 2017 05:09:54 UTC
538316104266867971	Backup-Done	1979809411	2m39.761333366s	Sat, 08 Apr 2017 05:20:01 UTC
```
