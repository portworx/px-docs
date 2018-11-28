---
layout: page
title: "Portworx on IBM Kubernetes Service (IKS)"
keywords: portworx, IBM, kubernetes, PaaS, IaaS, docker, converged, cloud
sidebar: home_sidebar
redirect_from: "/portworx-on-softlayer.html"
meta-description: "Deploy Portworx on IBM IKS. See for yourself how easy it is!"
---

![IBM CLoud Logo](/images/ibm-cloud.png){:height="188px" width="188px"}

* TOC
{:toc}

This guide shows you how you can easily deploy Portworx on [**IBM Cloud Kubernetes Service**](https://www.ibm.com/cloud/container-service)

## Prerequisites
{: #prerequisites}

Befor you begin: 
- Sign up for an [IBM Cloud Pay-As-You-Go](https://console.bluemix.net/registration/) account. With an IBM Cloud Pay-As-You-Go account you can access the IBM Cloud Platform-as-a-Service and Infrastructure-as-a-Service portfolio. 
- Create a 
- Review the [Portworx licensing information](https://docs.portworx.com/getting-started/px-licensing.html). When you install Portworx with a Helm chart, you get the Portworx `px-enterprise` edition as a Trial version. The Trial version provides you with the full Portworx functionality that you can test out for 30 days. After the Trial version expires, you must purchase a Portworx license to continue to use your Portworx cluster.

## Step 1: Choosing the right worker node flavor for your IBM Cloud Kubernetes Service cluster to support Portworx
{: #worker-flavor}



**What worker node flavor in IBM Cloud Kubernetes Service is the right one for Portworx?** </br>
IBM Cloud Kubernetes Service provides [bare metal worker node flavors that are optimized for software-defined storage (SDS) usage](https://console.bluemix.net/docs/containers/cs_clusters_planning.html#sds) and that come with one or more raw, unformatted, and unmounted local disks that you can use for your Portworx storage layer. Portworx offers best performance when you use SDS worker node machines that come with 10Gbps network speed. 

**What if I want to run Portworx on non-SDS worker nodes?**</br>
You can install Portworx on non-SDS worker node flavors, but you might not get the performance benefits that your app requires. Non-SDS worker nodes can be virtual or bare metal. If you want to use [virtual machines](https://console.bluemix.net/docs/containers/cs_clusters_planning.html#vm), use a worker node flavor of `b2c.16x64` or better. Virtual machines with a flavor of `b2c.4x16` or `u2c.2x4` do not provide the required resources for Portworx to work properly. [Bare metal](https://console.bluemix.net/docs/containers/cs_clusters_planning.html#bm) machines come with sufficient compute resources and network speed for Portworx. For more information about the compute resources that are required by Portworx, see the [minimum requirements](https://docs.portworx.com/#minimum-requirements). 

To add non-SDS worker nodes to the Portworx storage layer, each worker node must have at least one tertiary raw, unformatted, and unmounted disk that is attached to the worker node. You can manually add these tertiary disks or use the [IBM Cloud Block Attacher plug-in](https://console.bluemix.net/docs/containers/cs_storage_utilities.html#block_storage_attacher) to automatically add the disks to your non-SDS worker nodes. For more information, see the [IBM Cloud Kubernetes Service documentation](https://console.bluemix.net/docs/containers/cs_storage_portworx.html#create_block_storage). 

**How can I make sure that my data is stored highly available?** </br>
You need at least 3 worker nodes in your Portworx cluster so that Portworx can replicate your data across nodes. By replicating your data across worker nodes, Portworx can ensure that your stateful app can be rescheduled to a different worker node in case of a failure without losing data. For even higher availability, use a [multizone cluster](https://console.bluemix.net/docs/containers/cs_clusters_planning.html#multizone) and replicate your volumes across SDS worker nodes in 3 or more zones.

## Step 2: Creating or preparing your cluster for Portworx

2. [Install the IBM Cloud CLI](https://console.bluemix.net/docs/cli/index.html#overview) to create and manage your Kubernetes clusters in IBM Cloud Kubernetes Service. The IBM Cloud CLI includes the latest version of Docker, Helm, Git, and the `kubectl` CLI so that you do not need to install these packages separately. 

3. If you want to create a [multizone cluster](https://console.bluemix.net/docs/containers/cs_clusters_planning.html#multizone) for high availability, enable [VLAN spanning](https://console.bluemix.net/docs/infrastructure/vlans/vlan-spanning.html#vlan-spanning) for your IBM Cloud account. 

4. [Create or use an existing cluster](https://console.bluemix.net/docs/containers/cs_clusters.html#clusters_ui) in IBM Cloud Kubernetes Service with a Kubernetes version of 1.10 or higher. To ensure high availability for your data, set up a [multizone cluster](https://console.bluemix.net/docs/containers/cs_clusters_planning.html#multizone) with at least 3 worker nodes and spread the worker nodes across zones. 

5. If you created your cluster with non-SDS worker nodes, [add raw, unformatted, and unmounted block storage](https://console.bluemix.net/docs/containers/cs_storage_portworx.html#attach_block_to_worker) to your worker nodes. The block storage devices are attached to your worker node and can be included into the Portworx storage layer. 



## Step 2: Setting up a key-value store for the Portworx metadata
{: #key-value-store}
Every Portworx cluster must be connected to a key-value store to store Portworx metadata. The Portworx key-value store serves as the single source of truth for your Portworx storage layer. If the key-value store is not available, then you cannot work with your Portworx cluster to access or store your data. Existing data is not changed or removed when the Portworx database is unavailable.

In order for your Portworx cluster to be highly available, you must ensure that the Portworx key-value store is set up highly available. By using an IBM Cloud Database-as-a-Service, such as [**IBM Compose for etcd for IBM Cloud**](https://console.bluemix.com/docs/services/ComposeForEtcd/getting_started.html#getting-started-tutorial) you can set up a highly available key-value store for your Portworx cluster. Each IBM Compose for etcd service instance contains three etcd data members that are added to a cluster. The etcd data members are spread across zones in an IBM Cloud region and data is replicated across all etcd data members. 

Follow the [IBM Cloud Kubernetes Service documentation](https://console.bluemix.net/docs/containers/cs_storage_portworx.html#portworx_database) to set up your IBM Compose for etcd key-value store for Portworx. 

## Step 3: Setting up encryption for your Portworx volumes
{: #volume-encryption}

By default, data that you store on a Portworx volume is not encrypted at rest or during transit. To protect your data from being accessed by unauthorized users, you can choose to protect your volumes with [IBM Key Protect](https://console.bluemix.net/docs/services/key-protect/about.html#about). IBM Key Protect helps you to provision encrypted keys that are secured by FIPS 140-2 Level 2 certified cloud-based hardware security modules (HSMs). 

Review the following information in the IBM Cloud Kubernetes Service documentation: 
- [IBM Key Protect volume encryption flow](https://console.bluemix.net/docs/containers/cs_storage_portworx.html#encryption)
- [IBM Key Protect volume decryption flow](https://console.bluemix.net/docs/containers/cs_storage_portworx.html#decryption)
- [Setting up IBM Key Protect encryption for your volumes](https://console.bluemix.net/docs/containers/cs_storage_portworx.html#setup_encryption)

## Step 4: Installing Portworx on IBM Cloud Kubernetes Service
{: #install}

Install Portworx with a Helm chart. The Helm chart deploys a trial version of the Portworx enterprise edition `px-enterprise` that you can use for 30 days. In addition, [Stork](https://docs.portworx.com/scheduler/kubernetes/stork.html) is installed on your Kubernetes cluster. Stork is the Portworx storage scheduler and allows you to co-locate pods with their data, and create and restore snapshots of Portworx volumes. 

To install Portworx: 

1. Make sure that you [set up your Portworx database](#key-value-store) to store your Portworx cluster metadata. 



6. 


## Step 3: Adding Portworx storage to your apps

## Step 4: Protecting your Portworx volumes with IBM Key Protect

placeholder for Key Protect integration

## What's next? 



## Kubernetes versions
Portworx is not yet supported on IKS 1.11.2.
All other versions are supported.





## Deploy Portworx via Helm Chart

Make sure you have installed `helm` and run `helm init`

Follow these instructions to [Deploy Portworx via Helm](https://github.com/portworx/helm/blob/master/charts/portworx/README.md)

Be sure to execute the pre-requisite commands here:
```
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
```

The following values must be defined, either through `helm install --set ...` or through `values.yaml`:
* clusterName      :   User defined
* etcd.credentials :   `root:PASSWORD` , where PASSWORD is taken from the above etcd URL
* etcdEndPoint     :   of the form:

```
     etcdEndPoint=etcd:https://portal-ssl294-1.bmix-wdc-yp-a7a89461-abcc-45e5-84d7-cde68723e30d.588786498.composedb.com:15832;etcd:https://portal-ssl275-2.bmix-wdc-yp-a7a89461-abcc-45e5-84d7-cde68723e30d.588786498.composedb.com:15832
                  
```
where the actual URLs correspond to your `etcd` URLs.

>**Note:** For baremetal instances, please specify `dataInterface=bond0` and `managementInterface=bond0`

>**Note:** For disks, the default is to use all unmounted/unformatted disks and partitions.  Disk resources can be added explicitly via `drives=/dev/dm-0;/dev/dm-1;...` 

```
helm install --debug --name portworx-ds 
```

## Verify Portworx has been deployed

Verify Portworx pods have started and are `Running`:   
```
$ kubectl get pods -n kube-system -l name=portworx
NAME             READY     STATUS    RESTARTS   AGE
portworx-c5tk6   1/1       Running   0          2d
portworx-g7dx4   1/1       Running   0          2d
portworx-j5lh2   1/1       Running   0          2d
```

Verify the Portworx cluster is operational.  Ex:
```
$ kubectl exec -it portworx-c5tk6 -n kube-system -- /opt/pwx/bin/pxctl status
Status: PX is operational
License: Trial (expires in 29 days)
Node ID: 10.190.195.146
    IP: 10.190.195.146
     Local Storage Pool: 1 pool
    POOL    IO_PRIORITY    RAID_LEVEL    USABLE    USED    STATUS    ZONE    REGION
    0    LOW        raid0        100 GiB    8.0 GiB    Online    default    default
    Local Storage Devices: 1 device
    Device    Path                        Media Type        Size        Last-Scan
    0:1    /dev/mapper/3600a098038303931313f4a6d53556930    STORAGE_MEDIUM_MAGNETIC    100 GiB        09 Jul 18 15:50 UTC
    total                            -            100 GiB
Cluster Summary
    Cluster ID: px-cluster-metal-9d371e76-e54e-4f0b-b929-234ed35335ea
    Cluster UUID: 52e76e3f-f39e-44b8-83eb-2cdf1496171f
    Scheduler: kubernetes
    Nodes: 3 node(s) with storage (3 online)
    IP        ID        StorageNode    Used    Capacity    Status    StorageStatus    Version        Kernel            OS
    10.190.195.165    10.190.195.165    Yes        8.0 GiB    100 GiB        Online    Up        1.4.0.0-0753ff9    4.4.0-127-generic    Ubuntu 16.04.4 LTS
    10.190.195.146    10.190.195.146    Yes        8.0 GiB    100 GiB        Online    Up (This node)    1.4.0.0-0753ff9    4.4.0-127-generic    Ubuntu 16.04.4 LTS
    10.190.195.131    10.190.195.131    Yes        8.0 GiB    100 GiB        Online    Up        1.4.0.0-0753ff9    4.4.0-127-generic    Ubuntu 16.04.4 LTS
Global Storage Pool
    Total Used        :  24 GiB
    Total Capacity    :  300 GiB
```

## Deleting a Portworx cluster

Since deleting a Portworx cluster implies the deletion of data, the cluster-delete operation is multi-step, to ensure operator intent.

### Ensure the desired context

Make certain your **KUBECONFIG** environment variable points to the Kubernetes cluster you intend to target.

### Wipe Portworx cluster

In order to cleanly re-install Portworx after a previous installation, the cluster will have to be **"wiped"**
Issue the following command:

```
     curl https://install.portworx.com/px-wipe | bash
```

### Helm Delete the Portworx cluster

After the above `wipe` command, then perform `helm delete chart-name` for the corresponding `helm` chart

If a `wipe/delete` is being done as the result of a failed installation, 
then a best practice is to use a different `clusterName` when creating a new cluster.

## Troubleshooting

### 'helm install' hangs

This happens when helm/tiller is not provided with the correct RBAC permissions as [documented here](https://github.com/portworx/helm/tree/master/charts/portworx#pre-requisites)

If trying to install Portworx on a new cluster and `helm install` hangs or timeouts, please Cntrl-C and try:

```
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
```


### Retrying a previously failed installation

One use case for the Portworx cluster being deleted is the result of a previously failed installation.
If that's the case, then once the `wipe` and `helm delete` have been done,
then a `helm install` can be re-issued.

When retrying, please note the following for the `helm install`
* Pick a different value for `clusterName`.  This ensures no collision in `etcd` with the previous clusterName.
* Set `usefileSystemDrive=true`.  This forces the re-use of a raw device that may have previously been formatted for Portworx.
