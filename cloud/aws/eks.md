---
layout: page
title: "Amazon Elastic Container Service for Kubernetes (Amazon EKS)"
keywords: Amazon, portworx, container, Kubernetes, storage, Docker, k8s, pv, persistent disk, eks
sidebar: home_sidebar
---

![k8s porx Logo](/images/k8s-porx.png){:height="188px" width="188px"}

* TOC
{:toc}

The steps below will help you enable dynamic provisioning of Portworx volumes in your GAmazon Elastic Container Service for Kubernetes (Amazon EKS) cluster.

## Prerequisites

{% include px-k8s-prereqs.md %}

**PX Version**

Support for GKE is available only in portworx release version 1.4 and above.

## Create a EKS cluster

Creating EKS clusters can be found [here](https://aws.amazon.com/eks/).

## Install

Portworx gets deployed as a [Kubernetes DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/). Following sections describe how to generate the spec files and apply them.

### Generate the spec

{% include k8s-spec-generate.md  asg-addendum="We will supply the template(s) explained in previous section, when we create the Portworx spec." skip12="true" skip13="true" %}

### Applying the spec

Once you have generated the spec file, deploy Portworx.

```bash
$ kubectl apply -f px-spec.yaml
```

{% include k8s-monitor-install.md %}

## Deploy a sample application

Now that you have Portworx installed, checkout various examples of [applications using Portworx on Kubernetes](/scheduler/kubernetes/k8s-px-app-samples.html).
