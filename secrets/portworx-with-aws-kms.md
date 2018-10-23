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

Following are the authentication details required by Portworx to use the AWS KMS service

- `AWS_ACCESS_KEY_ID` : [required] AWS Access Key ID
- `AWS_SECRET_ACCESS_KEY` : [required] AWS Secret Access Key
- `AWS_SECRET_TOKEN_KEY` : [optional] AWS Secret Token Key
- `AWS_CMK` : [required] AWS Customer Master Key.
   The CMK can be found out from AWS's resource ARN. Here is an example ARN for CMK:

   ```arn:aws:kms:us-east-1::key/<cmk-id>```

   It specifies that the ARN is for the `kms` service for `us-east-1` region. The trailing ID at the end of ARN is the actual CMK that needs to be provided to Portworx
   through the `AWS_CMK` field.

- `AWS_REGION` : [required] The AWS region to which the CMK is associated to. CMKs are region specific and cannot be used across regions.

### Using AWS environment variables

Portworx can authenticate with AWS using AWS SDK's EnvProvider.

Each of the above fields can be provided as is to Portworx through environment variables.

#### Kubernetes users


If you are installing Portworx on Kubernetes, when generating the Portworx Kubernetes spec file on https://install.portworx.com/ :
1. Pass in all the above variables as is in the Environment Variables section.
2. Specify the `Secret Store Type` in the Advanced Settings section as `aws`

More help on generating the Portworx spec for Kubernetes is available [here](/scheduler/kubernetes/install.html).

If you already have a running Portworx installation, [update `/etc/pwx/config.json` on each node](#adding-aws-kms-credentials-to-configjson).

#### Other users

During installation,
1. Use argument `-secret_type aws-kms` when starting Portworx to specify the secret type as AWS KMS.
2. Use `-e` argument to expose the AWS KMS environment variables

If you already have a running Portworx installation, [update `/etc/pwx/config.json` on each node](#adding-aws-kms-credentials-to-configjson).

#### Adding AWS KMS Credentials to config.json
>**Note:**<br/>This section is optional and is only needed if you intend to provide the PX configuration before installing PX.

If you are deploying PX with your PX configuration created before hand, then add the following `secrets` section to the `/etc/pwx/config.json`:

```
# cat /etc/pwx/config.json
{
    "clusterid": "<cluster-id>",
    "secret": {
        "secret_type": "aws-kms",
        "aws": {
               "AWS_ACCESS_KEY_ID": "your-access-key-id",
               "AWS_SECRET_ACCESS_KEY": "your-secret-access-key",
               "AWS_CMK": "your-customer-master-key-id",
               "AWS_REGION": "you-aws-region-to-which-this-cmk-belongs"
        },
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

Along with the EC2 role you will still need to provide `AWS_CMK` and `AWS_REGION` through config.json
```
# cat /etc/pwx/config.json
{
    "clusterid": "<cluster-id>",
    "secret": {
        "secret_type": "aws-kms",
        "aws": {
               "AWS_CMK": "your-customer-master-key-id",
               "AWS_REGION": "you-aws-region-to-which-this-cmk-belongs"
        },
    }
    ...
}
```


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

Portworx provides CLI commands to generate AWS KMS Data keys. Portworx associates each KMS Data Key with a unique name provided through the ```--secret_id``` argument.
To generate a new KMS Data Key run the following command:

```
/opt/pwx/bin/pxctl secrets aws generate-kms-data-key --secret_id portworx_secret
KMS Data Key successfully created.
```

The above command generates a KMS Data Key and associates it with the name ```portworx_secret```. For any subsequent operations that require a secret you can use this name ```portworx_secret```

Run the following command to create an encrypted volume using the newly generated KMS Data Key.

```
$ /opt/pwx/bin/pxctl volume create --secure --secret_key portworx_secret --size 20 encrypted_volume
```

## Setting cluster wide secret key
A cluster wide secret key is a common key that can be used to encrypt all your volumes. You can set the cluster secret key using the following command

```
# /opt/pwx/bin/pxctl secrets set-cluster-key --secret portworx_secret

```

You can provide any ```--secret_id``` that was used in the ```generate-kms-data-key``` command as the `--secret` argument to the above command.. From our example we can set the cluster secret key to ```portworx_secret```. This command needs to be run just once for the cluster.
