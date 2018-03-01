---
layout: page
title: "Dynamic Portworx Volume Creation by Kubernetes Operations(KOPS)"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, KOPS, pv, persistent disk, aws, EBS
sidebar: home_sidebar
redirect_from: "/cloud/aws/kops_asg.html"
meta-description: "This page describes how to setup a production ready Portworx cluster using Kubernetes Kops.
You will learn how to dynamically provision persistent volumes using AWS Autoscaling groups to spin up EC2 instances."
---

![k8s porx Logo](/images/k8s-porx.png){:height="188px" width="188px"}

* TOC
{:toc}

This is a guide to setup a production ready Portworx cluster using Kubernetes (KOPS+AWS) environment that allows you to dynamically provision persistent volumes. KOPS helps you create, destroy, upgrade and maintain production-grade, highly available, Kubernetes clusters. Under the hood KOPS uses AWS Autoscaling groups (ASG) to spin up EC2 instances.

## Portworx in an Auto Scaling Group

{% include asg/px-asg-intro.md %}

## Prerequisites

{% include k8s-prereqs.md %}

**KOPS cluster in AWS**

Detailed instructions on how to setup a KOPS cluster in AWS are documented [here](https://github.com/kubernetes/KOPS/blob/master/docs/aws.md).

## AWS Requirements

{% include asg/aws-prereqs.md %}

## EBS volume template

{% include asg/ebs-template.md %}

## Install

Portworx gets deployed as a [Kubernetes DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/). Following sections describe how to generate the spec files and apply them.

### Generate the Portworx Spec

When generating the spec, following parameters are important for KOPS:
1. __AWS environment variables__: In the environment variables option (_e_), specify _AWS\_ACCESS\_KEY\_ID_ and _AWS\_SECRET\_ACCESS\_KEY_ for the KOPS IAM user. Example: AWS_ACCESS_KEY_ID=\<id>,AWS_SECRET_ACCESS_KEY=\<key>. If you are using instance privileges you can ignore setting the environment variables.

2. __Volume template__: In the drives option (_s_), specific the EBS volume template that you created in previous step. Portworx will dynamically create EBS volumes based on this template.

{% include k8s-spec-generate.md %}

### Apply the spec

Once you have generated the spec file, deploy Portworx.
```bash
kubect apply -f px-spec.yaml
```

{% include k8s-monitor-install.md %}

### Co-relating EBS volumes with Portworx nodes

{% include asg/cli.md %}

## Deploy a sample application

Now that you have Portworx installed, checkout various examples of [applications using Portworx on Kubernetes](/scheduler/kubernetes/k8s-px-app-samples.html).