---
layout: page
title: "Deploy Portworx on Kubernetes"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk
sidebar: home_sidebar
redirect_from:
  - /cloud/azure/k8s_tectonic.html

meta-description: "Find out how to install PX within a Kubernetes cluster and have PX provide highly available volumes to any application deployed via Kubernetes."
---

![k8s porx Logo](/images/k8s-porx.png){:height="188px" width="188px"}

* TOC
{:toc}

## Interactive Tutorials

If you wish to get an overview of using Portworx on Kubernetes, start with [these interactive tutorials](/scheduler/kubernetes/px-k8s-interactive.html). These serve as a playground for you to get an idea about the capabilities of Portworx without having to install it in your cluster.

## Prerequisites

{% include px-prereqs.md %}.

## Install

Portworx gets deployed as a [Kubernetes DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/). Following sections describe how to generate the spec files and apply them.

#### Generating the spec

{% include k8s-spec-generate.md %}

#### Internal Kvdb (beta)

Portworx can be configured to run with internal kvdb by enabling it in the above spec generator.

>**Note:** Internal Kvdb is in beta and available for PX version > 1.4

#### Applying the spec

Once you have generated the spec file, deploy Portworx.

```bash
$ kubectl apply -f px-spec.yaml
```

{% include k8s-monitor-install.md %}

## Deploy a sample application

Now that you have Portworx installed, checkout various examples of [applications using Portworx on Kubernetes](/scheduler/kubernetes/k8s-px-app-samples.html).
