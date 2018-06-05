---
layout: page
title: "Dynamic Provisioning on Amazon Elastic Container Service for Kubernetes (Amazon EKS)"
keywords: Amazon, portworx, container, Kubernetes, storage, Docker, k8s, pv, persistent disk, eks
sidebar: home_sidebar
---

![k8s porx Logo](/images/k8s-porx.png){:height="188px" width="188px"}

* TOC
{:toc}


## Create a EKS cluster

Visit [the Amazon EKS page](https://aws.amazon.com/eks/) for details on signing up and install instructions.

The steps below will help you enable dynamic provisioning of Portworx volumes in your Amazon Elastic Container Service for Kubernetes (Amazon EKS) cluster.

## Disk template
Portworx takes in a disk spec which gets used to provision AWS persistent disks dynamically.

{% include asg/k8s-asg.md env-addendum="Note: For the EKS clusters, select the EKS checkbox option when you create the Portworx spec." skip12="true" skip13="true" %}
