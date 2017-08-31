---
layout: page
title: "Tectonic"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, tectonic, coreos, azure, aws
sidebar: home_sidebar
---

* TOC
{:toc}

[Tectonic](https://coreos.com/tectonic/docs/latest/) is the new automated installer for Kubernetes from CoreOS.
While Tectonic provides a simple way to install Kubernetes, there are still a few requirements needed before
Portworx can run on a cluster installed with Tectonic --- 
specifically, ensuring that additional disks are created and attached for the workers,
and ensuring that the Portworx-required network ports are open.

To address these requirements in a uniform fashion, Portworx has offered the ["px-ptool"](https://github.com/portworx/px-ptool).
*px-ptool* has a facilities to create clusters from scratch that are "Portworx ready", 
or to take clusters that have already been deployed through Tectonic, and to make sure that they are "PX ready".

*"px-ptool"* assumes that the Tectonic cluster has been successfully deployed first, 
and that the corresponding environment variables set during the deployment are still active.

Please see the *"px-ptool"* [README](https://github.com/portworx/px-ptool/blob/master/README.md) for documentation and usage.

## On AWS

Ensure the following environment variables are properly set:

```
$AWS_ACCESS_KEY_ID       
$AWS_SECRET_ACCESS_KEY
$AWS_DEFAULT_REGION     
$AWS_CLUSTER
```

where $AWS_CLUSTER corresponds to the $CLUSTER variable set during the Tectonic deployment.

To post-process an AWS Tectonic deployment:

```
./px_provision.sh pxify aws --aws_access_key_id $AWS_ACCESS_KEY_ID         \
                          --aws_secret_access_key $AWS_SECRET_ACCESS_KEY \
                          --disks 3 --disk_size 100                      \
                          --region $AWS_DEFAULT_REGION                   \
                          --aws_cluster $AWS_CLUSTER
```                          

where *disks* and *disk_size* can be configured as desired.


## On Azure

Ensure the following environment variables are properly set:

```
$ARM_SUBSCRIPTION_ID
$ARM_CLIENT_SECRET
$ARM_TENANT_ID
$ARM_REGION 
$CLUSTER                    
```

To post-process an Azure Tectonic deployment:

```
./px_provision.sh pxify azure --arm_client_id $ARM_CLIENT_ID             \
                              --arm_subscription_id $ARM_SUBSCRIPTION_ID \
                              --arm_client_secret $ARM_CLIENT_SECRET     \
                              --arm_tenant_id $ARM_TENANT_ID             \
                              --region $ARM_REGION                       \
                              --arm_cluster $CLUSTER                     \
                              --disks 2                                  \
                              --disk_size 100

```

where *disks* and *disk_size* can be configured as desired.

