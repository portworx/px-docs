---
layout: page
title: "ACS-Engine with DCOS and Portworx"
keywords: portworx, acs-engine, azure, DCOS, Mesosphere, microsoft, azure
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

The instructions below are presented only as a *template* for how to deploy Portworx on ACS-Engine using DCOS.

### Install `acs-engine` and `azure CLI`
Install and build the [`acs-engine` binary](https://github.com/Azure/acs-engine/blob/master/docs/acsengine.md)

From a Linux host:
* git clone https://github.com/Azure/acs-engine.git
* cd acs-engine
* ./scripts/devenv.sh
* make prereqs && make build
* curl -L https://aka.ms/InstallAzureCli | bash

### Login to Azure and Set Subscription

* az login
* az account set --subscription "Your-Azure-Subscription-UUID"

### Create Azure Resource Group and Location

Pick a name for the Azure Resource Group and choose a LOCATION value
among the following:  `centralus,eastasia,southeastasia,eastus,eastus2,westus,westus2,northcentralus,southcentralus,westcentralus,northeurope,westeurope,japaneast,japanwest,brazilsouth,australiasoutheast,australiaeast,westindia,southindia,centralindia,canadacentral,canadaeast,uksouth,ukwest,koreacentral,koreasouth`

* az group create --name "$RGNAME" --location "$LOCATION"

### Select and customize the deployment configuration

The example deployment here uses DCOS with pre-attached disks and VM scale sets.
The sample json file can be found in the acs-engine repository under [examples/disks-managed/dcos-preAttachedDisks-vmss.json](examples/disks-managed/dcos-preAttachedDisks-vmss.json)

For the `masterProfile`, specify an appropriate value for `dnsPrefix` which will be used for fully qualified domain name (FQDN).
<br>Use the default `vmSize` or select an appropriate value for the machine type and size.
<br>Specify the number and size of disks that will be attached to each DCOS private agent
as per the template default:

```
[...]
"diskSizesGB": [128, 128, 128, 128]
[...]
```

Specify the appropriate admin username as `adminUsername' and public key data as `keyData`

### Generate the Azure Resource Management (ARM) templates

```
./acs-engine generate examples/disks-managed/my-dcos-preAttachedDisks-vmss.json
```

The template will get generated under the acs-engine `_output/$NAME` where *$NAME* correspods 
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

### Create an `ssh` tunnel to the DCOS GUI

Currently, ARM templates deployed through ACS-engine require that an 'ssh' tunnel be established
to connect to the instance specified as the FQDN.  As such for DCOS, the easiest way to manage the cluster is to establish
an ssh tunnel that can be used to access the DCOS GUI.  Full instructions for recommended approaches can be found [here](https://docs.microsoft.com/en-us/azure/container-service/container-service-connect)
)

A simple example for access might look like this:

```
sudo ssh -i your-private.key  -fNL 80:localhost:80 -p 2200  adminUsername@dnsPrefix.LOCATION.cloudapp.azure.com
```

where `your-private.key` is the private key that corresponds to `keyData` in the template
<br> `adminUsername` and `dnsPrefix` refer to the corresponding values in the template
<br> `LOCATION` corresponds to the location used for the resource group created.

Once the DCOS GUI is accessible, then install the DCOS CLI on your local machine

### Install Portworx

Use the [standard Portworx doc guide](https://docs.portworx.com/scheduler/mesosphere-dcos/install.html) for 
installing the Portworx Frameworks on DCOS.

Once Portworx is installed, then the [Portworx Stateful Service Frameworks](https://docs.portworx.com/scheduler/mesosphere-dcos/frameworks.html) can be easily deployed
as per the reference documentation.













