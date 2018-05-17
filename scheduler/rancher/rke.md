---
layout: page
title: "Run Portworx with Rancher Kubernetes Engine(RKE)"
keywords: portworx, PX-Developer, container, RKE, storage, RKE
sidebar: home_sidebar
redirect_from:
  - /run-with-rancher.html
  - /scheduler/rancher.html
  - /deploy_px_with_rancher.html
---

* TOC
{:toc}


## Step 1: Install RKE

Follow the instructions for installing [Rancher Kubernetes Engine(RKE)](https://github.com/rancher/rke).

## Step 2: Install Portworx in the RKE cluster

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