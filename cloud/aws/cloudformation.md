---
layout: page
title: "Portworx AWS CloudFormation"
keywords: portworx, AWS, CloudFormation
sidebar: home_sidebar
redirect_from: "/portworx-on-aws-cloudformation.html"
meta-description: "Find out how to quickly and easily deploy Portworx using Amazon Web Services CloudFormation. You'll be up and running in < 10 minutes!"
---

* TOC
{:toc}

These steps shows you how you can quickly and easily deploy Portworx on [**AWS CloudFormation**](https://aws.amazon.com/cloudformation/)

Portworx has provided a CloudFormation stack, based on CoreOS 1235.4.0 that will bring up a complete 3-node **px-dev** stack in **less than 10 minutes**.

This template is based on the CoreOS "Stable" Channel (version 1235.4.0) and includes the following to enable Portworx deployments:

+ An additional non-root device called "/dev/xvdb" for the global shared storage pool of configurable size
+ Opened ports for 'etcd', 'ssh', and 'portworx' management services (2379, 2380, 4001, 9001, 9002, 9003)

>**Important:**<br/>Your AWS account settings must allow you to create SecurityGroup resources, otherwise you will not be able to use this.

### Step 1: Configure and Launch the Portworx stack

<p><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/new?stackName=PX-STACK&amp;templateURL=https://s3.amazonaws.com/cf-templates-1oefrvxk1p71o-us-east-1/2017019oeI-Portworx_CoreOS_Stack_v36ky4q0o5aniv7nslr74f7mbo6r" rel="nofollow noreferrer"><img src="https://cdn.rawgit.com/buildkite/cloudformation-launch-stack-button-svg/master/launch-stack.svg" alt="Launch Stack" width="144px" height="27px" class="cf-stack"></a></p>

- Click the "Launch Stack" button above.  The Portworx Template is automatically loaded into CloudFormation.   Click **Next**

- Pick a specific Name for the Stack.  (default = PX-STACK)

- Specify any restrictions on ssh access via "AllowSSHFrom" (default 0.0.0.0/0)

- Specify the Discovery URL.  Copy the entire **output string** that is returned from [https://discovery.etcd.io/new?size=3](https://discovery.etcd.io/new?size=3)

- Select the instance type from the list (default type is 'm3.medium')

- Select the volume size of the non-root volume, configurable from **8GB** to **4TB** (default size is 128 GB)

- Select the name of your available key-pairs (assumed to be existing)
You may see a message indicating AWS is "Unable to list IAM roles", which can be safely ignored.

- Create the stack and wait for completion.  After the stack status is "CREATE COMPLETE", it may still be 5 minutes before Portworx is available.   

### Step 2: List Instance IP Addrs

Using the AWS CLI for a particular region, list the IP Addresses for the instances, based on the CloudFormation Stack Name
Example:

```bash
REGION=us-east-1
STACK_NAME="PX-STACK"
aws --region ${REGION} ec2  describe-instances --filters "Name=tag:aws:cloudformation:stack-name,Values=${STACK_NAME}" --query 'Reservations[*].Instances[*].{IP:PublicIpAddress,ID:InstanceId}' --output text
```

Similarly, you can find all EC2 Instances named "PX-STACK" or whichever name was provided, and look for the IP or DNS addresses.

Using the key provided for the template, you can now login to the nodes as the **"core"** user, and **"sudo root"** as needed.

### Next Steps

The Portworx CloudFormation Template is freely available and can be easily customized.  

