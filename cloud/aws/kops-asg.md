---
layout: page
title: "Run Portworx with Kubernetes Operations(KOPS)"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, KOPS, pv, persistent disk, aws, EBS
sidebar: home_sidebar
redirect_from: "/cloud/aws/kops_asg.html"
meta-description: "This page describes how to setup a production ready Portworx cluster with Kubernetes KOPS."
---

* TOC
{:toc}

This is a guide to setup a production ready Portworx cluster using Kubernetes (KOPS+AWS) environment that allows you to dynamically provision persistent volumes. KOPS helps you create, destroy, upgrade and maintain production-grade, highly available, Kubernetes clusters. Under the hood KOPS uses AWS Autoscaling groups (ASG) to spin up EC2 instances.

{% include asg/k8s-asg.md %}