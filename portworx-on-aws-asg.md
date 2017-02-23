---
layout: page
title: "Portworx AWS Auto Scaling"
keywords: portworx, AWS, CloudFormation, ASG, Auto Scaling, Load Balancer, ECS, EC2
sidebar: home_sidebar
---

These steps shows you how you can quickly and easily deploy Portworx on [**AWS Auto Scaling**](https://aws.amazon.com/autoscaling/)

Since Portworx instances are stateful, extra care must be taken when using `Auto Scaling`.  As instances get allocated, new EBS volumes may need to be allocated.  Similarly as instances as scaled down, care must be taken so that the EBS volumes are not deleted.

This document explains specific functionality that Portworx provides to easily integrate your auto scaling environment with your PX cluster and optimally manage stateful applications across a variable number of nodes in the cluster.

## Configure and Launch the Auto Scaling Group
Use [this](http://docs.aws.amazon.com/autoscaling/latest/userguide/GettingStartedTutorial.html) tutorial to set up an auto scaling group.

### Create an AMI 
First, you will need to create a master AMI that you will associate with your auto scaling group.  This AMI will be configured with Docker and for PX to start via `systemd`.

1. Select a base AMI from the AWS market place.
2. Launch an instance from this AMI.
3. Configure this instance to run PX.  Install Docker and follow [these](/run-with-systemd.html) instructions to configure the image to run PX.  Please **do not start PX** while creating the master AMI.://aws.amazon.com/cloudformation

This AMI will ensure that PX is able to launch on startup.  Subsequently, PX will receive it's runtime configuration via [`cloud-init`](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html).

### Create EBS volume templates
Create various EBS volume templates for PX to use.  PX will use these templates as a reference when creating new EBS volumes while scaling up.

For example, create two volumes as:
1. vol-0743df7bf5657dad8: 1000 GiB provisioned IOPS
2. vol-0055e5913b79fb49d: 1000 GiB GP2

Ensure that these EBS volumes are created in the same region as the auto scaling group.

### Pass PX Config via Cloud-Init
When instances are launched via the auto scaling group, they must use the AMI created above.  The PX instances will need to get cluster information when they launch.  This information will be provided by the [`cloud-init user data](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html)`.

Specify the following information in the user-data section of your instance while creating the auto scaling group:

```bash
#cloud-config
clusterid: my-px-asg-cluster
kvdb: etcd://myetc.company.com:2379
storage:
  - ebs vol-0055e5913b79fb49d
  - ebs vol-0743df7bf5657dad8
```

PX will use the EBS volume IDs as volume template specs.  Note that each instance will reference the same EBS volume.  PX will figure out which actual EBS volume to use during runtime.

## Scaling the Cluster Up

## Scaling the Cluster Down
