---
layout: page
title: "Portworx AWS CloudFormation"
keywords: portworx, AWS, CloudFormation
sidebar: home_sidebar
---

This guide shows you how you can easily deploy Portworx on the [**AWS CloudFormation**](https://aws.amazon.com/cloudformation/)

### Step 1: Load PX CloudFormation Template 

The [Portworx CloudFormation](/px_aws_coreos_cf.json) Template is based on the CoreOS Autoscaling cluster.
The defaults are:

+ cluster size = 3
+ instance type = m3.medium
+ single disk = 128GB

This template is based on the CoreOS "Stable" Channel and includes the following to enable Portworx deployments:

+ An additional non-root device called "/dev/xvdb" for the global shared storage pool
+ Opened ports for 'etcd', 'ssh', and 'portworx' management services (2379, 2380, 4001, 9001, 9002)

Load the template, select the number of nodes, type of instance and keys, as seen here:
![Cloud_formation_setup](/images/cf_px.png)

Pick a specific Name for the Stack.

Portworx recommends a minimum cluster size of 3 nodes.

Defaults such as instance type and volume size can be changed by modifying the CloudFormation json file.

Create the stack and wait for completion.

### Step 2: List Instance IP Addrs

Using the AWS CLI the particular region, list the IP Addresses for the instances, based on the CloudFormation Stack Name
Example:

```
aws --region us-east-1 ec2  describe-instances --filters "Name=tag:aws:cloudformation:stack-name,Values=Jeff-CoreOS" --query 'Reservations[*].Instances[*].{IP:PublicIpAddress,ID:InstanceId}'
```

### Step 3: Launch PX-Enterprise

If running PX-Enterprise, then [follow the instructions to launch PX-Enterprise](get-started-px-enterprise.html)

If running PX-Enterprise "air-gapped", then [follow the instructions to launch in "air-gapped" mode](/run-air-gap.html)

NB: Since this stack uses CoreOS, use “-v /lib/modules:/lib/modules” instead of “-v /usr/src:/usr/src” if launching through "docker run"



