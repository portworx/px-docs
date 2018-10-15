---
layout: page
title: "Portworx on IBM Cloud Private (ICP)"
keywords: portworx, IBM, kubernetes, PaaS, IaaS, docker, converged, cloud
sidebar: home_sidebar
meta-description: "Deploy Portworx on IBM Cloud Private. See for yourself how easy it is!"
---

* TOC
{:toc}

This guide shows you how you can easily deploy Portworx on [**IBM Cloud Private and IBM Cloud Private for Data**](https://www.ibm.com/cloud/private)

# Install Portworx on IBM Cloud Private (ICP) and Cloud Private for Data (ICPD)

[Portworx is a technology ecosystem partner for IBM Cloud Private and Cloud Private for Data.](https://www.ibm.com/products/cloud-private-for-data/partners)

## Installation pre-requisites

All worker nodes must have some unmounted disk or partition to contribute.   Ideally this is raw/unformatted, but must be unmounted regardless.


## Installation
### ICP 3.1 and Above
For ICP 3.1 and above, Portworx is installed by Helm:  [https://github.com/IBM/charts/tree/master/community/portworx](https://github.com/IBM/charts/tree/master/community/portworx)
```
       Ex:
           helm install --name portworx-icpd --set "clusterName=px-icpd,usedrivesAndPartitions=true,usefileSystemDrive=true,internalKVDB=true,imageVersion=1.6.1" ./community/portworx
```

For the definitions, please refer to :
[https://github.com/IBM/charts/blob/master/community/portworx/values.yaml](https://github.com/IBM/charts/blob/master/community/portworx/values.yaml)

>**Important:**<br/>Please note that `usefileSystemDrive` will make use of any drives/partitions that have formatted filesystems, but which are not mounted.

### ICP 2.1.0.3
For ICP 2.1.0.3, Portworx should be installed via the Portworx installer at [https://install.portworx.com/](https://install.portworx.com)

Fill in the appropriate K8s version.  Choose the following:

* `Built-in etcd`
* Select `On-prem storage`  
* Select `Automatically Scan disks`
* Check `use umounted disks` as per above advisory on `usefileSystemDrive` 

If running in an air-gapped environment, click `Download spec` and copy the spec file into your K8s environment.

## Caveats 
### Network interfaces
Network interfaces may vary between environments and might not get properly detected automatically.   If there are multiple host interfaces, please specify explicity in the installer (install.portworx.com) or the Helm chart values (network.dataInterface, network.managementInterface)

### Retrying failed installations
If there are errors on installation:
-  For Helm based installation, run 'helm delete portworx-icpd' (for example)
-  For installation based on install.portworx.com, run :
```
     curl -fsL https://install.portworx.com/px-wipe | bash
```

## Licensing and Support
Portworx comes with a Free 30-day Trial license by default.

For any problems, please email support@portworx.com
