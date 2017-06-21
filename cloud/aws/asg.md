---
layout: page
title: "Portworx AWS Auto Scaling"
keywords: portworx, AWS, CloudFormation, ASG, Auto Scaling, Load Balancer, ECS, EC2
sidebar: home_sidebar
redirect_from:
  - /cloud/aws-ec2-asg.html
  - /portworx-on-aws-asg.html
---

* TOC
{:toc}

This document describes how you can easily scale a Portworx cluster up or down on AWS using [**Auto Scaling**](https://aws.amazon.com/autoscaling/)

## About Stateful Auto Scaling
In order to determine if stateful auto scaling is needed in your environment, read [this blog](https://portworx.com/auto-scaling-groups-ebs-docker/) to get an overview of what this feature does.

## Configure the Auto Scaling Group
Use [this](http://docs.aws.amazon.com/autoscaling/latest/userguide/GettingStartedTutorial.html) tutorial to set up an auto scaling group.

## Stateless Autoscaling
When your Portworx instances do not have any local storage, they are called `head-only` or `stateless` nodes.  They still participate in the PX cluster and can provide volumes to any client container on that node.  However, they strictly consume storage from other stateful PX instances.

Automatically scaling these PX instances up or down do not require any special care, since they do not have any local storage.  They can join and leave the cluster without any manual intervention or administrative action.

To have your stateless PX nodes join a cluster, you need to create a master AMI from which you autoscale your instances.

## Create a stateless AMI
You will need to create a master AMI that you will associate with your auto scaling group.  This AMI will be configured with Docker and for PX to start via `systemd`.

1. Select a base AMI from the AWS market place.
2. Launch an instance from this AMI.
3. Configure this instance to run PX.  Install Docker and follow [these](/scheduler/systemd.html) instructions to configure the image to run PX.  Please **do not start PX** while creating the master AMI.

This AMI will ensure that PX is able to launch on startup.  Change the `ExecStart` to look as follows:

```bash
ExecStart=/usr/bin/docker run --net=host --privileged=true \
      --cgroup-parent=/system.slice/px-enterprise.service \
      -v /run/docker/plugins:/run/docker/plugins     \
      -v /var/lib/osd:/var/lib/osd:shared            \
      -v /dev:/dev                                   \
      -v /etc/pwx:/etc/pwx                           \
      -v /opt/pwx/bin:/export_bin                    \
      -v /var/run/docker.sock:/var/run/docker.sock   \
      -v /var/cores:/var/cores                       \
      -v ${HOSTDIR}:${HOSTDIR}                       \
      --name=%n \
      portworx/px-enterprise -c MY_CLUSTER_ID -k etcd://myetc.company.com:2379  -z
```

>**Note:**The `-z` option instructs PX to come up as a stateless node.

At this point, these nodes will be able to join and leave the cluster dynamically.

## Stateful Autoscaling
When your Portworx instances have storage associated with them, they are called `stateful` nodes and extra care must be taken when using `Auto Scaling`.  As instances get allocated, new EBS volumes may need to be allocated.  Similarly as instances as scaled down, care must be taken so that the EBS volumes are not deleted.

This section explains specific functionality that Portworx provides to easily integrate your auto scaling environment with your stateful PX nodes and optimally manage stateful applications across a variable number of nodes in the cluster.

## Create EBS volume templates
Create various EBS volume templates for PX to use.  PX will use these templates as a reference when creating new EBS volumes while scaling up.

For example, create two volumes as:
```
vol-0743df7bf5657dad8: 1000 GiB provisioned IOPS
vol-0055e5913b79fb49d: 1000 GiB GP2
```

Ensure that these EBS volumes are created in the same region as the auto scaling group.

## Create a stateful AMI
Now you will need to create a master AMI that you will associate with your auto scaling group.  This AMI will be configured with Docker and for PX to start via `systemd`.

The `stateful` PX instances need some additional information to properly operate in an autoscale environment:

1. AWS access credentials
2. EBS template information created above

The PX instance that is launching will use the above information to either allocate an existing EBS volume to the instance, or create a new one based on the template.  The exact procedure for how the PX instance assignes itself an EBS volume is described further below.

1. Select a base AMI from the AWS market place.
2. Launch an instance from this AMI.
3. Configure this instance to run PX.  Install Docker and follow [these](/scheduler/systemd.html) instructions to configure the image to run PX.  Please **do not start PX** while creating the master AMI.

This AMI will ensure that PX is able to launch on startup.  Change the `ExecStart` to look as follows:

```bash
ExecStart=/usr/bin/docker run --net=host --privileged=true \
      --cgroup-parent=/system.slice/px-enterprise.service \
      -v /run/docker/plugins:/run/docker/plugins     \
      -v /var/lib/osd:/var/lib/osd:shared            \
      -v /dev:/dev                                   \
      -v /etc/pwx:/etc/pwx                           \
      -e AWS_ACCESS_KEY_ID=XXX-YYY-ZZZ               \
      -e AWS_SECRET_ACCESS_KEY=XXX-YYY-ZZZ           \
      -v /opt/pwx/bin:/export_bin:shared             \
      -v /var/run/docker.sock:/var/run/docker.sock   \
      -v /var/cores:/var/cores                       \
      -v ${HOSTDIR}:${HOSTDIR}                       \
      --name=%n \
      portworx/px-enterprise -c MY_CLUSTER_ID -k etcd://myetc.company.com:2379 -s vol-0743df7bf5657dad8 -s vol-0055e5913b79fb49d   
```

>**Note:**There are 2 new env variables passed into the ExecStart.  These are AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY used for authentication.

>**Note:** -s vol-0743df7bf5657dad8 and -s vol-0055e5913b79fb49d - you can pass multiple EBS volumes to use as templates. If these volumes are unavailable, then volumes identical to these will be automatically created.

### Cloud-Init
Optionally, EBS template information can be provided by the `user-data` in [cloud-init](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html).

Specify the following information in the `user-data` section of your instance while creating the launch configuration for your auto scaling group:

```bash
#cloud-config
portworx:
  config:
    storage:
      devices:
      - vol-0743df7bf5657dad8
      - vol-0055e5913b79fb49d
```

PX will use the EBS volume IDs as volume template specs.  Each PX instance that is launched will either grab a free EBS volume that matches the template, or create a new one. 

Note that even though each instance is launched with the same `user-data` and hence the same EBS volume template, during runtime, each PX instance will figure out which actual EBS volume to use.

### Instance Privileges

A final option is to create each instance such that it has the authority to create EBS volumes without the access keys.  With this method (in conjunction with starting PX via `systemd`), the AWS_ACCESS_KEY_ID and the AWS_SECRET_ACCESS_KEY do not need to be provided. Instead you can associate an AWS IAM role with the ec2 instances that are spun in your ASG. More details about creating such an EC2 IAM role and corresponding AWS policy can be found [here](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html)

Following is an example policy that has all the required permissions
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "<stmt-id>",
            "Effect": "Allow",
            "Action": [
                "ec2:AttachVolume",
                "ec2:DetachVolume",
                "ec2:CreateTags",
                "ec2:CreateVolume",
                "ec2:DeleteTags",
                "ec2:DeleteVolume",
                "ec2:DescribeTags",
                "ec2:DescribeVolumeAttribute",
                "ec2:DescribeVolumesModifications",
                "ec2:DescribeVolumeStatus",
                "ec2:DescribeVolumes",
                "ec2:DescribeInstances"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
```

## Scaling the Cluster Up
For each instance in the auto scale group, the following process takes place on the first boot (Note that the `user-data` is made available only during the first boot of an instance):

1. When a PX node starts for the first time, it inspects it's config information (passed in via `user-data` or env variables).
2. PX will also use the AWS credentials provided (or instance priviledges) to query the status of the EBS volumes:
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

If an instance is terminated by EC2 ASG, then the following happens:
1. The EBS volume associated with that instance gets detached.
2. A new EC2 instance from the AMI gets created by ASG and PX will be able to attach to the free EBS volumes and re-join the cluster with the existing information.

If the number of instances are scaled up, then the following happens:
1. PX on the new instance will detect that there are no free EBS volumes.
2. PX will create a new EBS volume.
3. PX will join the cluster as a new node.

## Scaling the Cluster Down
When you scale the cluster down, the EBS volume (if any) associated with this instance simply gets released back into the EBS pool.  Any other PX instance can optionally be instructed to use this volume on another PX node using the [`pxctl service drive add`](/maintain/scale-up.html) command.

In the case of ASG, if you want to scale down your PX cluster, you will not be able to use methods mentioned in [Scale-Down Nodes](/maintain/scale-down.html#removing-a-functional-node-from-a-cluster). You can still reduce the size of your Auto Scaling Group, while making sure to maintain PX cluster quorum.

## Note

1. When starting a PX cluster with AWS Auto Scaling, you will not be able to use this cluster's configuraion on any other nodes which are not started by ASG.
2. If PX is unable to attach an ESB volume, it will retry, during which node index might get increased. This should be okay and should not affect any cluster, volume operations.

