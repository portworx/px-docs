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

This guide shows you how you can easily deploy Portworx on [**IBM Cloud Kubernetes Service (IKS)**](https://www.ibm.com/cloud/container-service)

## Install Portworx on IBM IKS

Portworx has 2 pre-requisites for successful installation:
* Some unformatted/umounted raw devices (or partitions) must be presented to at least 3 hosts.
* An existing key-value store such as `etcd` must be accessible

**Please ensure these pre-requisites are fulfilled before attempting to install Portworx in IKS.**

## IKS Worker node pre-reqs
Ensure you have unmounted/unformatted raw block devices presented to 
the worker nodes.   Either make sure your "bring-your-own hardware" nodes have
available raw block devices.   Or follow the steps [here](https://github.com/akgunjal/block-volume-attacher)
to allocate remote block devices

## Kubernetes versions
Portworx is not yet supported on IKS 1.11.2.
All other versions are supported.

## Machine types
For Virtual instances, please use `b2c.16x64` or better.
Please do not use `b2c.4x16` nor `u2c.2x4`, which do not have sufficient resources.
All bare-metal types should work without problem.

## Multi-zone clusters
If you are configuring a `multi-zone` cluster, then ensure you have [enabled VLAN spanning](https://console.bluemix.net/docs/containers/cs_clusters.html#multizone)


## Provision a `Compose etcd` instance

Create and deploy an instance of [Compose for etcd](https://console.bluemix.net/catalog/services/compose-for-etcd)

Obtain the `etcd` username, passwd and endpoints

```
$ bx target bx target --cf
$ bx service list                        #  To find name of Compose etcd service
$ bx service show 'Compose for etcd-8n'  #  Use appropriate service name to retrieve the `dashboard` parameter for your corresponding `etcd-service`


$ ETCDCTL_API=3 etcdctl --endpoints=https://portal-ssl294-1.bmix-wdc-yp-a7a89461-abcc-45e5-84d7-cde68723e30d.588786498.composedb.com:15832,https://portal-ssl275-2.bmix-wdc-yp-a7a89461-abcc-45e5-84d7-cde68723e30d.588786498.composedb.com:15832 --user=root:XXXXXXXXXXXXXXX member list -w table
+------------------+---------+------------------------------------------+-------------------------+-------------------------+
|        ID        | STATUS  |                   NAME                   |       PEER ADDRS        |      CLIENT ADDRS       |
+------------------+---------+------------------------------------------+-------------------------+-------------------------+
|  418ef52006c5049 | started | etcd129.sl-us-wdc-1-memory.2.dblayer.com | http://10.96.146.3:2380 | http://10.96.146.3:2379 |
|  bc4aa29071d56be | started | etcd113.sl-us-wdc-1-memory.0.dblayer.com | http://10.96.146.4:2380 | http://10.96.146.4:2379 |
| a52c701de81e1e64 | started | etcd113.sl-us-wdc-1-memory.1.dblayer.com | http://10.96.146.2:2380 | http://10.96.146.2:2379 |
+------------------+---------+------------------------------------------+-------------------------+-------------------------+
```

Please make note of both of the `--etcd-endpoints` as well as the `--user=root:PASSWORD` string 

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
