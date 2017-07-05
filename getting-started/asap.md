---
layout: page
title: "Get Started ASAP"
keywords: portworx, AWS, CloudFormation
sidebar: home_sidebar
redirect_from: "/get-started-asap.html"
---

* TOC
{:toc}

These steps shows you how you can quickly and easily deploy Portworx on [**AWS CloudFormation**](https://aws.amazon.com/cloudformation/)

Portworx has provided a CloudFormation stack, based on CoreOS 1235.4.0 ("Stable") that will bring up a complete 3-node **px-dev** stack in **less than 10 minutes**.

This template includes the following to enable Portworx deployments:

+ An additional non-root device called "/dev/xvdb" for the global shared storage pool of configurable size
+ Opened ports for 'etcd', 'ssh', and 'portworx' management services (2379, 2380, 4001, 9001, 9002, 9003, 9004)

>**Important:**<br/>Your AWS account settings must allow you to create SecurityGroup resources, otherwise you will not be able to use this.

### Configure and Launch the Portworx stack


<p><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/new?stackName=PX-STACK&amp;templateURL=https://s3.amazonaws.com/cf-templates-1oefrvxk1p71o-us-east-1/Portworx_CoreOS_Stack_v1.2_Feb06_2017" rel="nofollow noreferrer" target="_blank"><img src="https://cdn.rawgit.com/buildkite/cloudformation-launch-stack-button-svg/master/launch-stack.svg" alt="Launch Stack" width="144px" height="27px" class="cf-stack"></a></p>

- Click the "Launch Stack" button above.  The Portworx Template is automatically loaded into CloudFormation.   Click **Next**

 * If you are not able/authorized to create security groups, then use the CloudFormation template below instead:
<p><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/new?stackName=PX-STACK&amp;templateURL=https://s3.amazonaws.com/px-quickstart/px-quickstart-sgfree.json" rel="nofollow noreferrer" target="_blank"><img src="https://cdn.rawgit.com/buildkite/cloudformation-launch-stack-button-svg/master/launch-stack.svg" alt="Launch Stack" width="144px" height="27px" class="cf-stack"></a></p>


- Pick a specific Name for the Stack.  (default = PX-STACK)

- Specify any restrictions on ssh access via "AllowSSHFrom" (default 0.0.0.0/0)

- Specify the Discovery URL.  Copy the entire **output string** that is returned from [https://discovery.etcd.io/new?size=3](https://discovery.etcd.io/new?size=3)

- Select the instance type from the list (default type is 'm3.medium')

- Select the volume size of the non-root volume, configurable from **8GB** to **4TB** (default size is 128 GB)

- Select the name of your available key-pairs (assumed to be existing)
You may see a message indicating AWS is "Unable to list IAM roles", which can be safely ignored.

- Create the stack and wait for completion.  After the stack status is "CREATE COMPLETE", it may still be 5 minutes before Portworx is available.   You can use [this script](https://gist.githubusercontent.com/jsilberm/4fad7ac0496c0a651d1a240ec8dcf5c8/raw/a8bcd1cbe934926ee70489b0352864881336b71e/PX%2520Stack%2520Query) to query the instances IP address, via `ssh -i pub.key core@IPaddr`, where `pub.key` is the key selected from the Template drop-down and `IPaddr` is one of the addresses returned from the above script.


### Next Steps

Go use containers that require data persistence, high-availability, snapshots and other container-granular services.

The Portworx CloudFormation Template is freely available and can be easily customized.  
