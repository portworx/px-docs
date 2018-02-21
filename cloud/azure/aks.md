---
layout: page
title: "Azure Managed Kubernetes Service (AKS) "
keywords: portworx, container, Kubernetes, storage, Docker, k8s, pv, persistent disk, aks, Azure
sidebar: home_sidebar
---

* TOC
{:toc}

### Overview
The [Azure Managed Kubernetes Service](https://docs.microsoft.com/en-us/azure/aks/intro-kubernetes) (aks-engine) generates ARM (Azure Resource Manager) templates for Kubernetes enabled clusters in Microsoft Azure.

### Install `azure CLI`
Install the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest).

### Login to Azure and Set Subscription

* az login
* az account set --subscription "Your-Azure-Subscription-UUID"

### Create Azure Resource Group and Location

Pick a name for the Azure Resource Group and choose a LOCATION value
among the following: 

Get the Azure locations using azure CLI command:

* az account list-locations

example locations:
`centralus,eastasia,southeastasia,eastus,eastus2,westus,westus2,northcentralus`
<br>`southcentralus,westcentralus,northeurope,westeurope,japaneast,japanwest`
<br>`brazilsouth,australiasoutheast,australiaeast,westindia,southindia,centralindia`
<br>`canadacentral,canadaeast,uksouth,ukwest,koreacentral,koreasouth`


* az group create --name "region-name" --location "location"

### Create a service principal in Azure AD

```
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/72c299a4-xxxx-xxxx-xxxx-6855109979d9"
{
  "appId": "1311e5f6-xxxx-xxxx-xxxx-ede45a6b2bde",
  "displayName": "azure-cli-2017-10-27-07-37-41",
  "name": "http://azure-cli-2017-10-27-07-37-41",
  "password": "ac49a307-xxxx-xxxx-xxxx-fa551e221170",
  "tenant": "ca9700ce-xxxx-xxxx-xxxx-09c48f71d0ce"
}
```
Make note of the `appId` and `password`


### Create the AKS cluster
Create the AKS cluster using either by Azure CLI or Azure Portal as per [AKS docs page](https://docs.microsoft.com/en-us/azure/aks/). 

###  Attach Data Disk to Azure VM
Follow the instructions from Azure documentation [How to attach a data disk to a AKS nodes in the Azure portal
](https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-linux-attach-disk-portal/)

Your deployment will look something like following:

![Azure Add Disk](/images/azure-add-disk.png "Add Disk"){:width="1483px" height="477px"}


### Install Portworx

Once AKS cluster created and disk added, Please make sure and verify that you meet the [minimum requirements](/#minimum-requirements), Portworx recommends a minimum cluster size of 3 nodes.

Install PX by following the instructions found [here](/scheduler/kubernetes/install.html).

Refer to [Portworx Docs](/) for further information on:
* [Storage Classes and PVCs](/scheduler/kubernetes/dynamic-provisioning.html)
* [Scheduler Convergence](/scheduler/kubernetes/scheduler-convergence.html)
* [Troubleshooting](/scheduler/kubernetes/support.html)
