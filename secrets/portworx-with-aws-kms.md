---
layout: page
title: "Portworx with AWS KMS"
sidebar: home_sidebar
redirect_from:
  - /enterprise/portworx-with-aws-kms.html
meta-description: "Learn how to utilize AWS KMS to manage your Portworx volume encryption."
---

* TOC
{:toc}

Portworx can integrate with AWS KMS to generate and use KMS Datakeys. This guide will get a Portworx cluster up which is connected to an AWS KMS endpoint. The Data Keys created in KMS can be used to encrypt Portworx Volumes.

>**NOTE:**<br/> Supported from PX Enterprise 1.4 onwards

## Deploying Portworx

There are multiple ways in which you can setup Portworx so that it gets authenticated with AWS

### Using AWS environment variables

Portworx can authenticate with AWS using AWS SDK's EnvProvider.

#### Kubernetes users

If you are installing Portworx on Kubernetes, when generating the Portworx Kubernetes spec file:
1. Use `secretType=aws` to specify the secret type as aws
2. Use `clusterSecretKey=<key>` to set the cluster-wide secret ID. This kms data key associated with the secretID will be used as a passphrase for encrypting volumes.
3. Use `env=KEY1=VALUE1,KEY2=VALUE2` to set [Portworx aws environment variables](#portworx-aws-kms-environment-variables) to identify AWS endpoint.

Instructions on generating the Portworx spec for Kubernetes are available [here](/scheduler/kubernetes/install.html).

If you already have a running Portworx installation, [update `/etc/pwx/config.json` on each node](#adding-aws-kms-credentials-to-configjson).

#### Other users

During installation,
1. Use argument `-secret_type aws -cluster_secret_key <secret-id>` when starting Portworx to specify the secret type as AWS and the cluster-wide secret ID. This kms data key associated with the secretID will be used as a passphrase for encrypting volumes.
2. Use `-e` docker option to expose the [Portworx AWS KMS environment variables](#portworx-aws-kms-environment-variables)

If you already have a running Portworx installation, [update `/etc/pwx/config.json` on each node](#adding-aws-kms-credentials-to-configjson).

#### Portworx AWS KMS environment variables
- `AWS_ACCESS_KEY_ID=<aws-access-key>` : Sets the AWS_ACCESS_KEY_ID environment variable. It would be used to authenticate with AWS.
- `AWS_SECRET_ACCESS_KEY=<aws-secret-key>` : Sets the AWS_SECRET_ACCESS_KEY environment variable. It would be used to authenticate with AWS.
- `AWS_SECRET_TOKEN_KEY=<aws-secret-token>` : Sets the AWS_SECRET_TOKEN_KEY environment variable. It would be used to authenticate with AWS.
- `AWS_CMK=<kms-customer-master-key>` : Sets the AWS_CMK environment variable. The customer master key is used while generating KMS Data keys for encrypting volumes.
- `AWS_REGION=<aws-region>` : Sets the AWS_REGION environment variable. This is the AWS region where the customer master key was created.

#### Adding AWS KMS Credentials to config.json
>**Note:**<br/>This section is optional and is only needed if you intend to provide the PX configuration before installing PX.

If you are deploying PX with your PX configuration created before hand, then add the following `secrets` section to the `/etc/pwx/config.json`:

```
# cat /etc/pwx/config.json
{
    "clusterid": "<cluster-id>",
    "secret": {
        "secret_type": "aws",
        "cluster_secret_key": "mysecret",
    }
    ...
}
```

### Using AWS EC2 Role Credentials
Portworx can authenticate with AWS using AWS SDK's EC2RoleCredentials Provider. Follow [these](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html) instructions to create an EC2 role.
Make sure you provide the following access to KMS in your policy associated with EC2 role.

Here is a sample AWS Policy that gives access to KMS

```
{
    "Version": "2012-10-17",
    "Statement": [
            {
	                "Sid": "Stmt1490047200000",
            "Effect": "Allow",
            "Action": [
	                    "kms:*"
            ],
            "Resource": [
                "arn:aws:kms:us-east-1:<aws-id>:key/<key-id>"
            ]
        }
    ]
}
```

Apply EC2 role to all the AWS instances where Portworx will be running.

You can start PX on all the EC2 nodes using the above docker run command and ignoring the environment variables.

### Using PX CLI to authenticate with AWS

If you do not wish to set AWS environment variables, you can authenticate PX with AWS using PX CLI. Run the following commands:

```
# pxctl secrets aws login
Enter AWS_ACCESS_KEY_ID [Hit Enter to ignore]: ********************
Enter AWS_SECRET_ACCESS_KEY [Hit Enter to ignore]: ****************************************
Enter AWS_SECRET_TOKEN_KEY [Hit Enter to ignore]:
Enter AWS_CMK [Hit Enter to ignore]: ***********************
Enter AWS_REGION [Hit Enter to ignore]: us-east-1
Successfully authenticated with AWS.
```

__Important: You need to run this command on all PX nodes, so that you could create and mount encrypted volumes on all nodes__

If the CLI is used to authenticate with AWS, for every restart of PX container it needs to be re-authenticated by running the `login` command.

## Key generation with AWS KMS

The following sections describe the key generation process with PX and AWS KMS. These keys can be used as passphrases for encrypted volumes. More info about encrypted
volumes [here](/manage/encrypted-volumes.html)

Portworx provides the following CLI command to generate AWS KMS Data keys.
```
/opt/pwx/bin/pxctl secrets aws generate-kms-data-key --help
NAME:
   pxctl secrets aws generate-kms-data-key - Generates a KMS Data Key and associates the given secret_id to it

USAGE:
   pxctl secrets aws generate-kms-data-key [command options]

OPTIONS:
   --secret_id value  Secret Id to associate with the KMS Data Key
```

PX associates each KMS Data Key with a unique ```secret_id``` that you provide while creating the encrypted volume. You can use this ```secret_id``` for subsequent operations which require you to provide the secret_key.

Here is an example of generating a KMS Data Key with ```portworx_secret``` as the secret_id.

```
/opt/pwx/bin/pxctl secrets aws generate-kms-data-key --secret_id portworx_secret
KMS Data Key successfully created.
```
The above command generates a KMS Data Key and associates it with the ```portworx_secret```. For subsequent operations you can use the same ```portworx_secret```

Run the following command to create an encrypted volume using the newly generated KMS Data Key.

```
$ /opt/pwx/bin/pxctl volume create --secure --secret_key portworx_secret --size 20 encrypted_volume
```

## Setting cluster wide secret key
A cluster wide secret key is a common key that can be used to encrypt all your volumes. You can set the cluster secret key using the following command

```
# /opt/pwx/bin/pxctl secrets set-cluster-key
Enter cluster wide secret key: *****
Successfully set cluster secret key!

```
As an input to the above command you can provide any ```secret_id``` that was used in the ```generate-kms-data-key``` command. From our example we can set the cluster secret key to ```portworx_secret```. This command needs to be run just once for the cluster. If you have added the [cluster secret key through the *config.json*](#adding-aws-kms-credentials-to-configjson), the above command will overwrite it. Even on subsequent Portworx restarts, the cluster secret key in *config.json* will be ignored for the one set through the CLI.
