---
layout: page
title: "CLI Reference–Credentials"
keywords: portworx, pxctl, command-line tool, cli, reference
sidebar: home_sidebar
redirect_from: "/cli-reference.html"
meta-description: "Trying to create, list, validate or delete credentials for cloud providers? Follow this step-by-step tutorial from Portworx!"
---

* TOC
{:toc}

#### Prerequisite
The cloud provider credentials are stored in an external secret store. Before you use these commands you should [configure a secret provider of your choice with Portworx](/secrets).

#### pxctl credentials
This command is used to create/list/validate/delete the credentials for cloud providers. These credentials will be used, for example, for cloudsnap of volume to the cloud.

Note: It will create a bucket with the portworx cluster ID to use for the backups
```
$ /opt/pwx/bin/pxctl credentials
NAME:
   pxctl credentials - Manage credentials for cloud providers

USAGE:
   pxctl credentials command [command options] [arguments...]

COMMANDS:
     create, c    Create a credential for cloud providers
     list, l      List all credentials for cloud-snap
     delete, d    Delete a credential for cloud-snap
     validate, v  Validate a credential for cloud-snap

OPTIONS:
   --help, -h  show help
```

#### pxctl credentials list
`pxctl credentials list` is used to list all configured credential keys
```
$ /opt/pwx/bin/pxctl credentials list

S3 Credentials
UUID						REGION			ENDPOINT			ACCESS KEY			SSL ENABLED	ENCRYPTION
ffffffff-ffff-ffff-1111-ffffffffffff		us-east-1		s3.amazonaws.com		AAAAAAAAAAAAAAAAAAAA		false		false

Azure Credentials
UUID						ACCOUNT NAME		ENCRYPTION
ffffffff-ffff-ffff-ffff-ffffffffffff		portworxtest		false
```

#### pxctl credentials create
`pxctl credentials create` is used to create/configure credentials for various cloud providers
```
$ /opt/pwx/bin/pxctl cred create \
  --provider s3 \
  --s3-access-key ***** \
  --s3-secret-key ***** \
  --s3-region us-east-1 \
  --s3-endpoint s3.amazonaws.com
Credentials created successfully
```

#### pxctl credentials delete
`pxctl credentials delete` is used to delete the credentials from the cloud providers.
```
$ /opt/pwx/bin/pxctl cred delete --uuid ffffffff-ffff-ffff-1111-ffffffffffff
Credential deleted successfully
```

#### pxctl credentials validate
`pxctl credentials validate` validates the existing credentials
```
$ /opt/pwx/bin/pxctl cred validate --uuid ffffffff-ffff-ffff-1111-ffffffffffff
Credential validated successfully
```
