---
layout: page
title: "Portworx AWS Auto Scaling"
keywords: portworx, AWS, CloudFormation, ASG, Auto Scaling, Load Balancer, ECS, EC2
sidebar: home_sidebar
---

These steps shows you how you can quickly and easily deploy Portworx on [**AWS Auto Scaling**](https://aws.amazon.com/autoscaling/)

Since Portworx instances are stateful, extra care must be taken when using `Auto Scaling`.  As instances get allocated, new EBS volumes may need to be allocated.  Similarly as instances as scaled down, care must be taken so that the EBS volumes are not deleted.

This document explains specific functionality that Portworx provides to easily integrate your auto scaling environment with your PX cluster and optimally manage stateful applications across a variable number of nodes in the cluster.

## Configure the Auto Scaling Group
Use [this](http://docs.aws.amazon.com/autoscaling/latest/userguide/GettingStartedTutorial.html) tutorial to set up an auto scaling group.

### Create an AMI 
First, you will need to create a master AMI that you will associate with your auto scaling group.  This AMI will be configured with Docker and for PX to start via `systemd`.

1. Select a base AMI from the AWS market place.
2. Launch an instance from this AMI.
3. Configure this instance to run PX.  Install Docker and follow [these](/run-with-systemd.html) instructions to configure the image to run PX.  Please **do not start PX** while creating the master AMI.

This AMI will ensure that PX is able to launch on startup.  Subsequently, PX will receive it's runtime configuration via [`cloud-init`](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html) or via environment variables.

### Create EBS volume templates
Create various EBS volume templates for PX to use.  PX will use these templates as a reference when creating new EBS volumes while scaling up.

For example, create two volumes as:
1. vol-0743df7bf5657dad8: 1000 GiB provisioned IOPS
2. vol-0055e5913b79fb49d: 1000 GiB GP2

Ensure that these EBS volumes are created in the same region as the auto scaling group.

### PX Config Data
When instances are launched via the auto scaling group, they must use the AMI created above.  The PX instances will need to get cluster information when they launch.  

There are three ways that PX can receive it's configuration (cluster ID, kvdb URL) information:

#### Option 1: Cloud-Init
This information can be provided by the `user-data` in [cloud-init](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html).

Specify the following information in the `user-data` section of your instance while creating the auto scaling group:

```bash
#cloud-config
px-cluster:
  clusterid: my-px-asg-cluster
  kvdb: etcd://myetc.company.com:2379
storage:
  ebs:
    template: vol-0055e5913b79fb49d
	max-count: 128
  ebs:
    template: vol-0743df7bf5657dad8
	max-count: 32
aws-credentialsi:
  AWS_ACCESS_KEY_ID: XXX-YYY-ZZZ
  AWS_SECRET_ACCESS_KEY: XXX-YYY-ZZZ
```

PX will use the EBS volume IDs as volume template specs.  Each PX instance that is launched will either grab a free EBS volume that matches the template, or create a new one as long as the number of existing EBS volumes for this auto scale group is less than the `max` value specified in the `user-data`.  If the maximum number of EBS volumes have been reached, then PX will startup as a storage-consumer (storage-less) node.

Note that even though each instance is launched with the same `user-data` and hence the same EBS volume template, during runtime, each PX instance will figure out which actual EBS volume to use.

#### Option 2: Environment Variables
This information can alternatively be provided by way of environment variables encoded into the `systemd` unit file.  While launching PX via the `docker run` command in the `systemd` unit file, specify the following additional options:

```bash
  -e AWS_ACCESS_KEY_ID=XXX-YYY-ZZZ
  -e AWS_SECRET_ACCESS_KEY=XXX-YYY-ZZZ
```

This, along with the usual cluster ID and KVDB will ensure that PX has the needed credentials to join the cluster and allocate EBS volumes on behalf of the scaling group.

#### Option 3: Instance Priviledges
A final option is to create each instance such that it has the authority to create EBS volumes without the access keys.  With this method, the AWS_ACCESS_KEY_ID and the AWS_SECRET_ACCESS_KEY do not need to be provided.

## Scaling the Cluster Up
For each instance in the auto scale group, the following process takes place on the first boot (Note that the `user-data` is made available only during the first boot of an instance):

1. When a PX node starts for the first time, it inspects it's `user-data`.
2. PX will also use the AWS credentials provided to query the status of the EBS volumes:
   - If there exists an unattached EBS volume that matches the template in the `storage` section of the `user-data`, PX will assign that volume to this instance.
   - If there does not exist an unattached EBS volume, then PX will create one that matches the template, as long as the total number of volumes in this scale group is less than the `max-count` parameter.
   - If there are more than `max-count` EBS volumes, this PX instance will initialize itself as a `storage-less` node.
3. PX will now join the cluster using the following scheme:
   - If PX **created a new** EBS volume, then PX will then use the information provided in the `px-cluster` section of the `user-data` to join the cluster.  PX creates the `/etc/pwx/config.json` cluster config information **directly inside the EBS volume** for subsequent boots.
   - On the other hand, if this PX instance was able to get an **existing** EBS volume, it will look for the PX cluster configuration information and use that to join the cluster as an existing node.

When PX creates an EBS volume, it adds labels on the volume so that the volume is associated with this cluster.  This is how multiple volumes from different clusters are kept seperate.  The labels will look like:
```bash
PWX_CLUSTER_ID=my-px-asg-cluster
PWX_EBS_VOLUME_TEMPLATE=vol-0055e5913b79fb49d
```

If an instance is terminated, then the following happens:
1. The EBS volume associated with that instance gets detached.
2. A new EC2 instance from the AMI gets created and PX will be able to attach to the free EBS volumes and re-join the cluster with the existing information.

If the number of instances are scaled up, then the following happens:
1. PX on the new instance will detect that there are no free EBS volumes.
2. PX will create a new EBS volume if it is within the `max-count` capacity limit.
3. PX will join the cluster as a new node.

## Scaling the Cluster Down
When you scale the cluster down, the EBS volume (if any) associated with this instance simply gets released back into the EBS pool.  Any other PX instance can optionally be instructed to use this volume on another PX node using the [`pxctl service drive add`](/scale-up.html) command.
