---
layout: page
title: "Kuberentes on Azure with Tectonic"
keywords: portworx, kubernetes, microsoft, azure
sidebar: home_sidebar
---

* TOC
{:toc}

[Tectonic](https://coreos.com/tectonic/docs/latest/install/azure/azure-terraform.html)
is one of the simpler ways to deploy Kubernetes on Azure.

In order for Portworx to be subsequently deployed, a small amount of post-processing must be done on the cluster,
to provide additional disk(s) to the worker nodes and enable certain communication ports.

To facilitate the needed post-processing, the ["px-ptool"](https://github.com/portworx/px-ptool) can be easily used.

Please refer to [these directions](https://github.com/portworx/px-ptool/blob/master/README.md#example--post-processing-for-an-azure-tectonic-cluster-to-be-ready-for-portworx-to-deploy)
for doing Tectonic post-processing needed, before [installing Portworx on Kubernetes](/scheduler/kubernetes/install.html)
