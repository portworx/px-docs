---
layout: page
title: "Portworx install on PKS on vSphere"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk

meta-description: "Find out how to install PX in a PKS Kubernetes cluster on vSphere and have PX provide highly available volumes to any application deployed via Kubernetes."
---

* TOC
{:toc}

## Pre-requisites

* vSphere 6.5u1 or above.
* PKS 1.1 or above.
* Portworx 1.6.0-rc3 and later.

## Step 1: PKS preparation

Before installing Portworx, let's ensure the PKS environment is prepared correctly.

### Enable privileged containers and kubectl exec

Ensure that following options are enabled on all plans on the PKS tile.
  * Enable Privileged Containers
  * Disable DenyEscalatingExec

### Enable zero downtime upgrades for Portworx PKS clusters

Use the following steps to add a runtime addon to the [Bosh Director](https://bosh.io/docs/bosh-components/#director) to stop the Portworx service.

>**Why is this needed ?** When stopping and upgrading instances bosh attempts to unmount _/var/vcap/store_. Portworx has it's root filesystem for it's OCI container mounted on _/var/vcap/store/opt/pwx/oci_ and the runc container is running using it. So one needs to stop Portworx and unmount _/var/vcap/store/opt/pwx/oci_ in order to allow bosh to proceed with stopping the instances. The addon ensures this is done automatically and enables zero downtime upgrades.

Perform these steps on any machine where you have the bosh CLI.

1. Create and upload the release.

    Replace _director-environment_ below with the environment which points to the Bosh Director.
    ```
    git clone https://github.com/portworx/portworx-stop-bosh-release.git
    cd portworx-stop-bosh-release
    bosh -e director-environment upload-release
    ```

2. Add the addon to the Bosh Director.

    First let's fetch your current Bosh Director runtime config.
    ```
    bosh -e director-environment runtime-config
    ```

    If this is empty, you can simply use the runtime config at [runtime-configs/director-runtime.config.yaml](https://raw.githubusercontent.com/portworx/portworx-stop-bosh-release/master/runtime-configs/director-runtime-config.yaml).

    If you already have an existing runtime config, add the release and addon in [runtime-configs/director-runtime.config.yaml](https://raw.githubusercontent.com/portworx/portworx-stop-bosh-release/master/runtime-configs/director-runtime-config.yaml) to your existing runtime config.


    Once we have the runtime config file prepared, let's update it in the Director.
    ```
    bosh update-runtime-config runtime-configs/director-runtime.config.yaml
    ```

3. Apply the changes

    After the runtime config is updated, go to your Operations Manager Installation Dashboard and click "Apply Changes". This will ensure bosh will add the addon on all new vm instances.

    If you already have an existing PX cluster, you will need to recreate the VM instances using the bosh recreate command.

## Step 2: Installing Portworx

Based on your ESXi datastore type, proceed to one of the following pages.

If you have **shared** datastores, proceed to [Portworx install on PKS on vSphere using shared datastores](install-pks-vsphere-shared.html).

If you have **local** datastores, proceed to [Portworx install on PKS on vSphere using local datastores](install-pks-vsphere-local.html).