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

Creating EKS clusters can be found [here](https://aws.amazon.com/eks/).

The steps below will help you enable dynamic provisioning of Portworx volumes in your Amazon Elastic Container Service for Kubernetes (Amazon EKS) cluster.

##Disk template
Portworx takes in a disk spec which gets used to provision AWS persistent disks dynamically.

{% include asg/k8s-asg.md %}

##Generate the spec
{% include k8s-spec-generate.md env-addendum="Select the EKS check box option in the installation spec generator page" skip12="true"  %}

##Applying the spec
Once you have generated the spec file, deploy Portworx.

$ kubectl apply -f px-spec.yaml
{% include k8s-monitor-install.md %}

##Deploy a sample application
Now that you have Portworx installed, checkout various examples of applications using Portworx on Kubernetes.

