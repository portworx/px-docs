---
layout: page
title: "Portworx on Amazon ECS"
keywords: portworx, amazon, docker, aws, ecs, cloud
sidebar: home_sidebar
---

This guide shows you how you can easily deploy Portworx on Amazon Elastic Container Service [**ECS**](https://aws.amazon.com/ecs/)

### Step 1: Create an ECS cluster
Create an ECS cluster using the Amazon ECS and AWS CLI.

1. Download and install the AWS CLI by following [these instructions](http://docs.aws.amazon.com/cli/latest/userguide/installing.html)
2. Download and install the ECS CLI by following [these instructions](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_CLI_installation.html)
3. Obtain your AWS access key ID and secret access key.  Export these environment variables.

    ```
    # export AWS_ACCESS_KEY_ID=XXXXXXXXXXXXXXX
    # export AWS_SECRET_ACCESS_KEY=XXXXXXXXXXXXXX
    ```
4. Create a keypair to use with the cluster that we will create.  Generate SSH keys using `ssh-keygen` and create a AWS keypair.  We will use `id_rsa` as your private key and `portworx` as the keypair for this tutorial.

    ```
    # ssh-keygen
    # aws ec2 import-key-pair --key-name portworx --public-key-material file://~/.ssh/id_rsa
    ```
5. Create an ECS cluster.  In this example, we create a 2 node cluster called `ecs-demo` in the US-WEST-2 region.

    ```
    # ecs-cli configure --region us-west-2 --cluster ecs-demo
    # ecs-cli up --keypair portworx --capability-iam --size 2 --instance-type t2.medium
    ```

Note that Portworx recommends a minimum cluster size of 3 nodes.

### Step 2: Add storage to the ECS instances

### Step 3: Configure Docker to allow shared mounts

### Step 4: Deploy Portworx on the ECS instances

### Step 5: Deploy containers to use PWX storage
