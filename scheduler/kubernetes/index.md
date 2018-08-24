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

Since Kubernetes [v1.6 release](https://github.com/kubernetes/kubernetes/releases/tag/v1.6.0), Kubernetes includes the Portworx native driver support which allows Dynamic Volume Provisioning.

Portworx supports the following features in Kubernetes:

1. Dynamic Volume Provisioning with Storage Classes, Persistent Volume Claims and Persistent Volumes
2. Snapshots and Restores
3. Encryption
4. Hyper-convergence
5. Scheduler extensions with Stork
5. [CSI](https://kubernetes-csi.github.io/) Support
6. Rolling upgrades


Based on your Kubernetes distro, proceed to one of the following pages:
* [Openshift](/scheduler/kubernetes/openshift-install.html)
* [GKE](/cloud/gcp/gke.html)
* [KOPS on AWS](/cloud/aws/kops-asg.html)
* [Azure Container Engine](/cloud/azure/k8s-acs-engine.html)
* [Azure Managed Kubernetes Service (AKS)](/cloud/azure/aks.html)
* [All Other distros](/scheduler/kubernetes/install.html)
