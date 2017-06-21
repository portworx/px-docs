---
layout: page
title: "Run PX with AWS KMS"
keywords: portworx, px-developer, px-enterprise, plugin, install, configure, container, storage, encryption
sidebar: home_sidebar
---

## Portworx with AWS KMS
This guide will get a Portworx cluster up which is connected to an AWS KMS endpoint. The Data Keys created in KMS will  be used to encrypt Portworx Volumes.

## Deploying Portworx

There are multiple ways in which you can setup Portworx so that it gets authenticated with AWS

### Using AWS environment variables
Portworx can authenticate with AWS using AWS SDK's EnvProvider.  You can start PX on a node via the Docker CLI as follows

```
if `uname -r | grep -i coreos > /dev/null`; \
then HDRS="/lib/modules"; \
else HDRS="/usr/src"; fi
sudo docker run --restart=always --name px -d --net=host       \
                 --privileged=true                             \
                 -v /run/docker/plugins:/run/docker/plugins    \
                 -v /var/lib/osd:/var/lib/osd:shared           \
                 -v /dev:/dev                                  \
                 -v /etc/pwx:/etc/pwx                          \
                 -v /opt/pwx/bin:/export_bin:shared            \
                 -v /var/run/docker.sock:/var/run/docker.sock  \
                 -v /var/cores:/var/cores                      \
                 -v ${HDRS}:${HDRS}                            \
                 -e "AWS_ACCESS_KEY_ID=<aws-access-key>" \
                 -e "AWS_SECRET_ACCESS_KEY=<aws-secret-key>" \
                 -e "AWS_SECRET_TOKEN_KEY=<aws-secret-token>" \
                 -e "AWS_CMK=<kms-customer-master-key>" \
                 -e "AWS_REGION=<aws-region>" \
                portworx/px-enterprise:latest -daemon -k etcd://myetc.company.com:2379 -c MY_CLUSTER_ID -s \
		/dev/sdb -s /dev/sdc -secret_type aws -cluster_secret_key <secret-id>
```
All the arguments to the docker run command are explained [here](/install/docker.html). The two new arguments related to KMS are:

```
- secret_type
    > Instructs PX to use AWS KMS as the secret endpoint to fetch secrets from

- cluster_secret_key
    > Sets the cluster-wide secret key. This kms data key associated with the secretID will be used as a passphrase for encrypting volumes.
```

You need to add the following extra Docker runtime commands

```
-e "AWS_ACCESS_KEY_ID=<aws-access-key>"
    > Sets the AWS_ACCESS_KEY_ID environment variable. It would be
    used to authenticate with AWS.

-e "AWS_SECRET_ACCESS_KEY=<aws-secret-key>"
    > Sets the AWS_SECRET_ACCESS_KEY environment variable. It would be
    used to authenticate with AWS.

-e "AWS_SECRET_TOKEN_KEY=<aws-secret-token>"
    > Sets the AWS_SECRET_TOKEN_KEY environment variable. It would be
    used to authenticate with AWS.

-e "AWS_CMK=<kms-customer-master-key>"
    > Sets the AWS_CMK environment variable. The customer master key
    is used while generating KMS Data keys for encrypting volumes.

-e "AWS_REGION=<aws-region>"
    > Sets the AWS_REGION environment variable. This is the AWS region
    where the customer master key was created.

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

## Creating AWS KMS keys
There are two ways in which you can create KMS Data keys.

### Using AWS CLI
You can follow the instructions [here](http://docs.aws.amazon.com/cli/latest/reference/kms/generate-data-key.html) to generate a data key.

```
$ aws-cli generate-data-key-without-plaintext --key-id <cmk> --key_spec <AES_256/AES_128>
```

The above command will return the following two outputs
- CiphertextBlob -> (blob): The encrypted data encryption key.
- KeyId -> (string): The identifier of the CMK under which the data encryption key was generated and encrypted

Store the ciphertext blob in a file on the host. Provide this file as an input secret key while creating encrypted volumes.

__Important: You need to write the ciphertext blob in a file which is accessible by the PX container. We recommend /var/lib/osd/secrets/__

Here is an example of creating an encrypted volume using such a file
```
$ pxctl volume create --secure --secret_key /var/lib/osd/secrets/aws_cipher_blob.txt --size 20 encrypted_volume
```


### Using PX
If you do not wish to pre-generate data keys using AWS CLI you can delegate this action to Portworx, and PX will generate the kms data keys for you.

PX associates each kms data key with a unique ```keyID``` that you provide while creating the encrypted volume. You can use this ```keyID``` for subsequent operations which require you to provide the secret_key.

Here is an example of creating an encrypted volume using a unique keyID

```
$ pxctl volume create --secure --secret_key my_secret_key --size 20 encrypted_volume
```

The above command generates a kms data key and associates it with the ```keyID``` my_secret_key. For subsequent operations you can use the same ```keyID```

```
$ pxctl host attach --secret_key my_secret_key encrypted_volume
```

## Setting cluster wide secret key
A cluster wide secret key is a common key that can be used to encrypt all your volumes. You can set the cluster secret key using the following command

```
# /opt/pwx/bin/pxctl secrets set-cluster-key
Enter cluster wide secret key: *****
Successfully set cluster secret key!
```
As an input to set-cluster-key command you have the following two options
1. Provide the path to the pre-generated kms data key. PX will not
generate a key if a valid path and a valid kms cipher blob text is
provided.

2. Provide a ```keyID```. If the ```keyID``` was previously used, the
already generated kms data key will be set as the cluster wide secret
key. If the ```keyID``` was never used before a new kms data key will
be generated and set as the cluster wide secret key.
