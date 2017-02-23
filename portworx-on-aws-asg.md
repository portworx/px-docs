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

## Specify EBS volume specs to Portworx

## 
