---
layout: page
title: "Portworx on Kubernetes"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk
sidebar: home_sidebar
meta-description: "Find out how to install PX within a Kubernetes cluster and have PX provide highly available volumes to any application deployed via Kubernetes."
---

* TOC
{:toc}

Portworx can run alongside Kubernetes and provide Persistent Volumes to other applications running on Kubernetes. This section describes how to deploy PX within a Kubernetes cluster and have PX provide highly available volumes to any application deployed via Kubernetes.

Since [Kubernetes v1.6](https://github.com/kubernetes/kubernetes/releases/tag/v1.6.0) release, Kubernetes includes the Portworx native driver support which allows Dynamic Volume Provisioning.

Portworx supports the following features in Kubernetes:

1. Dynamic Volume Provisioning with Storage Classes, Persistent Volume Claims and Persistent Volumes
2. Volume Snapshots and Restores
3. Volume Encryption
4. Hyper-convergence
5. Scheduler extensions with Stork
5. [CSI](https://kubernetes-csi.github.io/) Support
6. Rolling upgrades


Based on your Kubernetes distro, proceed to one of the following pages:

* [Openshift](/scheduler/kubernetes/openshift-install.html)
* [Google Kubernetes Engine (GKE)](/cloud/gcp/gke.html)
* [Kubernetes Operations (KOPS) on AWS](/cloud/aws/kops-asg.html)
* [Azure Container Service Engine (ACS-Engine)](/cloud/azure/k8s-acs-engine.html)
* [Azure Managed Kubernetes Service (AKS-Engine)](/cloud/azure/aks.html)
* [IBM Kubernetes Service (IKS)](/cloud/ibm/ibm-cloud-iks.html)
* [All Other distros](/scheduler/kubernetes/install.html)
