---
layout: page
title: "ACS-Engine with Kubernetes and Portworx"
keywords: portworx, acs-engine, azure, Kubernetes, microsoft, azure
sidebar: home_sidebar
---

* TOC
{:toc}

### Overview
The [Azure Container Service Engine](https://github.com/Azure/acs-engine) (acs-engine) generates ARM (Azure Resource Manager) templates for Docker enabled clusters on Microsoft Azure with your choice of DC/OS, Kubernetes, Swarm Mode, or Swarm orchestrators. The input to the tool is a cluster definition. The cluster definition is very similar to (in many cases the same as) the ARM template syntax used to deploy a Microsoft Azure Container Service cluster.

The cluster definition file enables the following customizations to your Docker enabled cluster:

* choice of DC/OS, Kubernetes, Swarm Mode, or Swarm orchestrators
* multiple agent pools where each agent pool can specify:
* standard or premium VM Sizes, 
* node count,
* Virtual Machine ScaleSets or Availability Sets,
* Storage Account Disks or Managed Disks (under private preview),
* Docker cluster sizes of 1200

The instructions below are presented only as a *template* for how to deploy Portworx on ACS-Engine for Kubernetes.

### Install `acs-engine` and `azure CLI`
Install the released version of the [`acs-engine` binary](https://github.com/Azure/acs-engine/releases)

From a Linux host:
* ```curl -L https://aka.ms/InstallAzureCli | bash```

### Login to Azure and Set Subscription

* az login
* az account set --subscription "Your-Azure-Subscription-UUID"

### Create Azure Resource Group and Location

Pick a name for the Azure Resource Group and choose a LOCATION value
among the following:  
`centralus,eastasia,southeastasia,eastus,eastus2,westus,westus2,northcentralus`
<br>`southcentralus,westcentralus,northeurope,westeurope,japaneast,japanwest`
<br>`brazilsouth,australiasoutheast,australiaeast,westindia,southindia,centralindia`
<br>`canadacentral,canadaeast,uksouth,ukwest,koreacentral,koreasouth`

* az group create --name "$RGNAME" --location "$LOCATION"

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

### Select and customize the deployment configuration

The example deployment here uses Kubernetes with pre-attached disks and VM scale sets.
A sample json file can be found in the acs-engine repository under [examples/disks-managed/kubernetes-preAttachedDisks-vmas.json](https://github.com/Azure/acs-engine/blob/master/examples/disks-managed/kubernetes-preAttachedDisks-vmas.json)

The most important consideration for Portworx is to ensure that the target nodes have at least one "local" attached disk
that can be used to contribute storage to the global storage pool.  The above sample json includes four, which you are free to customize.

For the `masterProfile`, specify an appropriate value for `dnsPrefix` which will be used for fully qualified domain name (FQDN) [ Ex: "myacsk8scluster"].
<br>Use the default `vmSize` or select an appropriate value for the machine type and size.
<br>Specify the number and size of disks that will be attached to each DCOS private agent
as per the template default:

```
[...]
"diskSizesGB": [128, 128, 128, 128]
[...]
```

Specify the appropriate admin username as `adminUsername` and public key data as `keyData`

Fill in the servicePrincipalProfile values.   `clientId` should correspond to the `appId` and `secret` should correspond to the `password`
from the above "Create a service principal in Azure AD" step.

### Generate the Azure Resource Management (ARM) templates

```
acs-engine generate my-k8s-preAttachedDisks-vmas.json
```

The template will get generated in the `_output/$NAME` directory where *$NAME* correspods 
to the name used for the `dnsPrefix`.   `acs-engine` will generate the appropriate files for 
`apimodel.json`, `azuredeploy.json`, and `azuredeploy.parameters.json`

### Deploy the generated ARM template

```
az group deployment create \
    --name "$NAME" \
    --resource-group "$RGNAME" \
    --template-file "./_output/$NAME/azuredeploy.json" \
    --parameters "./_output/$NAME/azuredeploy.parameters.json"
```

where $RGNAME corresponds to the resource group name created above, and $NAME corresonds to the above value used for `dnsPrefix`


### Install Portworx

Use the [standard Portworx doc guide](/scheduler/mesosphere-dcos/install.html) for 
installing the Portworx Frameworks on DCOS.

Once Portworx is installed, then the [Portworx Stateful Service Frameworks](/scheduler/mesosphere-dcos/frameworks.html) can be easily deployed
as per the reference documentation.












