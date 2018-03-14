---
layout: page
title: "Dynamic Portworx Volume Creation by running Kubernetes on AWS Autoscaling groups (ASG)"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, pv, persistent disk, aws, EBS
sidebar: home_sidebar
meta-description: "This page describes how to setup a production ready Portworx cluster using Kubernetes on AWS Autoscaling groups (ASG).
You will learn how to dynamically provision persistent volumes using AWS Autoscaling groups to spin up EC2 instances."
---

![k8s porx Logo](/images/k8s-porx.png){:height="188px" width="188px"}

* TOC
{:toc}

This is a guide to setup a production ready Portworx cluster using Kubernetes on AWS Autoscaling groups (ASG). This allows you to dynamically provision persistent volumes.

## Portworx in an Auto Scaling Group

{% include asg/px-asg-intro.md %}

## Prerequisites

{% include px-k8s-prereqs.md firewall-custom-steps="

In AWS, this can be done through the security group of the VPC to which your instances belong.
"%}

## AWS Requirements

{% include asg/aws-prereqs.md %}


## EBS volume template

{% include asg/ebs-template.md ebs-vol-addendum="
We will supply the template(s), when we create the Portworx DaemonSet spec later in this guide.
"
%}

## Install

Portworx gets deployed as a [Kubernetes DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/). Following sections describe how to generate the spec files and apply them.

### Generate the Portworx Spec

When generating the spec, following parameters are important:
1. __Volume template__: In the drives option (_s_), specify the EBS volume template that you created in [previous step](#ebs-volume-template). Portworx will dynamically create EBS volumes based on this template.
2. __AWS environment variables__: If you are using instance privileges to provide AWS permissions you can ignore setting the environment variables. If you are using environment variables, in the environment variables option (_e_), specify _AWS\_ACCESS\_KEY\_ID_ and _AWS\_SECRET\_ACCESS\_KEY_ for the IAM user. Example: AWS_ACCESS_KEY_ID=\<id>,AWS_SECRET_ACCESS_KEY=\<key>. 

{% include k8s-spec-generate.md %}

### Apply the spec

Once you have generated the spec file, deploy Portworx.
```bash
kubect apply -f px-spec.yaml
```

{% include k8s-monitor-install.md %}

### Corelating EBS volumes with Portworx nodes

{% include asg/cli.md list="# kubectl exec -it $PX_POD /opt/pwx/bin/pxctl clouddrive list" inspect="# kubectl exec -it $PX_POD /opt/pwx/bin/pxctl clouddrive inspect --nodeid ip-172-20-53-168.ec2.internal" %}

## Deploy a sample application

Now that you have Portworx installed, checkout various examples of [applications using Portworx on Kubernetes](/scheduler/kubernetes/k8s-px-app-samples.html).
