---
layout: page
title: "Amazon EC2 with Portworx"
keywords: portworx, amazon, docker, aws, ecs, cloud
sidebar: home_sidebar
redirect_from:
  - /cloud/aws.html
meta-description: "Portworx on Amazon EC2"
---

* TOC
{:toc}

This guide shows you how to configure your environment for a deployment of a Portworx cluster on AWS [**EC2**](https://aws.amazon.com/ec2/) with EBS volumes.

## EC2 Instance types
A PX cluster can be deployed with a heterogeneous makeup of EC2 instance types.  Some of your nodes can be used for converged compute and storage, some for compute only and some for storage only.

Follow this guide to select your appropriate [instance type](https://aws.amazon.com/ec2/instance-types/).  Once you create an AMI template for an instance type, you will create multiple instances from that AMI.  Make sure your AMIs are available in each region that you want to run the PX cluster in.

## EBS Volumes
At least some of the The EC2 instances in your AWS cluster need to have storage attached to them.  Chose any combination of these EBS drives to your [AMI instances](https://aws.amazon.com/ebs/details/)

>**Note:**<br/>Since PX is a replicated block device, you can also use instance local store volumes for maximum performance.  However you **must** have PX replication turned on.

## Multi Zone Availability
Since PX is a replicated storage solution, we recommend using multiple availability zones when creating your EC2 based clsueter.  Follow this site for more information on geographical availability of your instances: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.RegionsAndAvailabilityZones.html

## Dynamic Provisioning
You can have your PX cluster dynamically manage the allocation and detachment of your EBS volumes.  This is known as ASG (Auto Scale Group) mode.  Follow this guide to enable [ASG](/cloud/aws/asg.html)

## Install Portworx
Once you have your AWS EC2 infrastructure configured, follow one of these guides to install [Portworx](https://docs.portworx.com/#install)

## Performance Tuning

>**Note:**<br/>Please reference this guide for tuning your EC2 instances to leverage a journal device: [Performance Tuning](/maintain/performance/tuning.html)
