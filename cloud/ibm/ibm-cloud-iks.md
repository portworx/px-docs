---
layout: page
title: "Portworx on IBM Kubernetes Service"
keywords: portworx, IBM, kubernetes, PaaS, IaaS, docker, converged, cloud, IBM Cloud Kubernetes Service
sidebar: home_sidebar
redirect_from: "/portworx-on-softlayer.html"
meta-description: "Deploy Portworx on IBM Cloud Kubernetes Service. See for yourself how easy it is!"
---

![IBM CLoud Logo](/images/ibm-cloud.png){:height="188px" width="188px"}

* TOC
{:toc}

This guide shows how you can deploy Portworx on an [**IBM Cloud Kubernetes Service** Kubernetes cluster](https://www.ibm.com/cloud/container-service). 

## Prerequisites
{: #prerequisites}

Before you begin: 
- Sign up for an [IBM Cloud Pay-As-You-Go](https://console.bluemix.net/registration/) account. With an IBM Cloud Pay-As-You-Go account you can access the IBM Cloud Platform-as-a-Service and Infrastructure-as-a-Service portfolio.  
- Learn about [IBM Cloud Kubernetes Service and the service benefits](https://console.bluemix.net/docs/containers/cs_why.html#cs_ov). 

## Step 1: Choosing the right worker node flavor for your IBM Cloud Kubernetes Service cluster to support Portworx
{: #worker-flavor}

Portworx is a highly available software-defined storage solution that you can use to manage persistent storage for your containerized databases or other stateful apps in your IBM Cloud Kubernetes Service cluster across multiple zones. To make sure that your cluster is set up with the compute resources that are required for Portworx, review the FAQs in this step. 

**What worker node flavor in IBM Cloud Kubernetes Service is the right one for Portworx?** </br>
IBM Cloud Kubernetes Service provides [bare metal worker node flavors that are optimized for software-defined storage (SDS) usage](https://console.bluemix.net/docs/containers/cs_clusters_planning.html#sds) and that come with one or more raw, unformatted, and unmounted local disks that you can use for your Portworx storage layer. Portworx offers best performance when you use SDS worker node machines that come with 10Gbps network speed. 

**What if I want to run Portworx on non-SDS worker nodes?**</br>
You can install Portworx on non-SDS worker node flavors, but you might not get the performance benefits that your app requires. Non-SDS worker nodes can be virtual or bare metal. If you want to use [virtual machines](https://console.bluemix.net/docs/containers/cs_clusters_planning.html#vm), use a worker node flavor of `b2c.16x64` or better. Virtual machines with a flavor of `b2c.4x16` or `u2c.2x4` do not provide the required resources for Portworx to work properly. [Bare metal](https://console.bluemix.net/docs/containers/cs_clusters_planning.html#bm) machines come with sufficient compute resources and network speed for Portworx. For more information about the compute resources that are required by Portworx, see the [minimum requirements](https://docs.portworx.com/#minimum-requirements). 

To add non-SDS worker nodes to the Portworx storage layer, each worker node must have at least one tertiary raw, unformatted, and unmounted disk that is attached to the worker node. You can manually add these tertiary disks or use the [IBM Cloud Block Attacher plug-in](https://console.bluemix.net/docs/containers/cs_storage_utilities.html#block_storage_attacher) to automatically add the disks to your non-SDS worker nodes. For more information, see the [IBM Cloud Kubernetes Service documentation](https://console.bluemix.net/docs/containers/cs_storage_portworx.html#create_block_storage). 

**How can I make sure that my data is stored highly available?** </br>
You need at least 3 worker nodes in your Portworx cluster so that Portworx can replicate your data across nodes. By replicating your data across worker nodes, Portworx can ensure that your stateful app can be rescheduled to a different worker node in case of a failure without losing data. For even higher availability, use a [multizone cluster](https://console.bluemix.net/docs/containers/cs_clusters_planning.html#multizone) and replicate your volumes across SDS worker nodes in 3 or more zones.

## Step 2: Creating or preparing your cluster for Portworx
{: #cluster-create}

To install Portworx, you must have an IBM Cloud Kubernetes Service cluster that runs Kubernetes version 1.10 or higher. To make sure that your cluster is set up with worker nodes that offer best performance for you Portworx cluster, review [Step 1: Choosing the right worker node flavor for your IBM Cloud Kubernetes Service cluster to support Portworx](#worker-flavor). 

To create or prepare your cluster for Portworx: 

1. [Install the IBM Cloud CLI](https://console.bluemix.net/docs/cli/index.html#overview) to create and manage your Kubernetes clusters in IBM Cloud Kubernetes Service. The IBM Cloud CLI includes the latest version of Docker, Helm, Git, and the `kubectl` CLI so that you do not need to install these packages separately. 

2. If you want to create a [multizone cluster](https://console.bluemix.net/docs/containers/cs_clusters_planning.html#multizone) for high availability, enable [VLAN spanning](https://console.bluemix.net/docs/infrastructure/vlans/vlan-spanning.html#vlan-spanning) for your IBM Cloud account. 

3. [Create or use an existing cluster](https://console.bluemix.net/docs/containers/cs_clusters.html#clusters_ui) in IBM Cloud Kubernetes Service with a Kubernetes version of 1.10 or higher. To ensure high availability for your data, set up a [multizone cluster](https://console.bluemix.net/docs/containers/cs_clusters_planning.html#multizone) with at least 3 worker nodes and spread the worker nodes across zones. 

4. If you created or want to use a cluster with non-SDS worker nodes, [add raw, unformatted, and unmounted block storage](https://console.bluemix.net/docs/containers/cs_storage_portworx.html#create_block_storage) to your worker nodes. The block storage devices are attached to your worker node and can be included into the Portworx storage layer. 

## Step 3: Setting up a key-value store for the Portworx metadata
{: #key-value-store}

Every Portworx cluster must be connected to a key-value store to store Portworx metadata. The Portworx key-value store serves as the single source of truth for your Portworx storage layer. If the key-value store is not available, then you cannot work with your Portworx cluster to access or store your data. Existing data is not changed or removed when the Portworx database is unavailable.

In order for your Portworx cluster to be highly available, you must ensure that the Portworx key-value store is set up highly available. By using an IBM Cloud Database-as-a-Service, such as [**IBM Compose for etcd for IBM Cloud**](https://console.bluemix.com/docs/services/ComposeForEtcd/getting_started.html#getting-started-tutorial) you can set up a highly available key-value store for your Portworx cluster. Each IBM Compose for etcd service instance contains three etcd data members that are added to a cluster. The etcd data members are spread across zones in an IBM Cloud region and data is replicated across all etcd data members. 

Follow the [IBM Cloud Kubernetes Service documentation](https://console.bluemix.net/docs/containers/cs_storage_portworx.html#portworx_database) to set up your IBM Compose for etcd key-value store for Portworx. 

## Step 4: Setting up encryption for your Portworx volumes
{: #volume-encryption}

By default, data that you store on a Portworx volume is not encrypted at rest or during transit. To protect your data from being accessed by unauthorized users, you can choose to protect your volumes with [IBM Key Protect](https://console.bluemix.net/docs/services/key-protect/about.html#about). IBM Key Protect helps you to provision encrypted keys that are secured by FIPS 140-2 Level 2 certified cloud-based hardware security modules (HSMs). 

Review the following information in the IBM Cloud Kubernetes Service documentation: 
- [IBM Key Protect volume encryption flow](https://console.bluemix.net/docs/containers/cs_storage_portworx.html#encryption)
- [IBM Key Protect volume decryption flow](https://console.bluemix.net/docs/containers/cs_storage_portworx.html#decryption)
- [Setting up IBM Key Protect encryption for your volumes](https://console.bluemix.net/docs/containers/cs_storage_portworx.html#setup_encryption)

## Step 5: Installing Portworx on IBM Cloud Kubernetes Service
{: #install-portworx}

Install Portworx version 1.7 with a Helm chart. The Helm chart deploys a trial version of the Portworx enterprise edition `px-enterprise` that you can use for 30 days. After the trial version expires, you must [purchase a Portworx license](https://docs.portworx.com/getting-started/px-licensing.html) to continue to use your Portworx cluster. In addition, [Stork](https://docs.portworx.com/scheduler/kubernetes/stork.html) is installed on your Kubernetes cluster. Stork is the Portworx storage scheduler and allows you to co-locate pods with their data, and create and restore snapshots of Portworx volumes. 

Before you begin: 
- Make sure that you [set up your Portworx database](#key-value-store) to store your Portworx cluster metadata. 
- Decide if you want to enable [Portworx volume encryption](#volume-encryption). 
- If you use non-SDS worker nodes, [add raw, unformatted, and unmounted block storage](https://console.bluemix.net/docs/containers/cs_storage_portworx.html#create_block_storage) to your worker nodes. 

For more information about how to install the Portworx Helm chart, see the [IBM Cloud Kubernetes Service documentation](https://console.bluemix.net/docs/containers/cs_storage_portworx.html#install_portworx). 

## Step 6: Adding Portworx storage to your apps
{: #add-portworx-storage}

Now that your Portworx cluster is all set, you can start creating Portworx volumes by using [Kubernetes dynamic provisioning](https://kubernetes.io/docs/concepts/storage/dynamic-provisioning/). The Portworx Helm chart already set up a few default storage classes in your cluster that you can see by running the `kubectl get storageclasses | grep portworx` command. You can also create your own storage class to define settings, such as: 
- Encryption for a volume
- IO priority of the disk where you want to store the data
- Number of data copies that you want to store across worker nodes
- Sharing of volumes across pods 

For more information about how to create your own storage class and add Portworx storage to your app, see the [IBM Cloud Kubernetes Service documentation](https://console.test.cloud.ibm.com/docs/containers/cs_storage_portworx.html#add_portworx_storage). For an overview of supported configuration in a PVC, see [Using Dynamic Provisioning](https://docs.portworx.com/scheduler/kubernetes/dynamic-provisioning.html#using-dynamic-provisioning).

## What's next? 

Now that you set up Portworx on your IBM Cloud Kubernetes Service cluster, you can explore the following features: 
- **Use existing Portworx volumes:** If you have an existing Portworx volume that you created manually or that was not automatically deleted when you deleted the PVC, you can statically provision the corresponding PV and PVC and use this volume with your app. For more information, see [Using existing volumes](https://docs.portworx.com/scheduler/kubernetes/preprovisioned-volumes.html#using-the-portworx-volume).
- **Running stateful sets on Portworx:** If you have a stateful app that you want to deploy as a stateful set into your cluster, you can set up your stateful set to use storage from your Portworx cluster. For more information, see [Create a mysql StatefulSet](https://docs.portworx.com/scheduler/kubernetes/statefulsets.html#create-a-mysql-statefulset). 
- **Running your pods hyperconverged:** You can configure your Portworx cluster to schedule pods on the same worker node where the pod's volume resides. This setup is also referred to as hyperconverged and can improve the data storage performance. For more information, see [Run pods on same host as a volume](https://docs.portworx.com/scheduler/kubernetes/scheduler-convergence.html).
- **Creating snapshots of your Portworx volumes:** You can save the current state of a volume and its data by creating a Portworx snapshot. Snapshots can be stored on your local Portworx cluster or in the Cloud. For more information, see [Create and use local snapshots](https://docs.portworx.com/scheduler/kubernetes/snaps.html).


