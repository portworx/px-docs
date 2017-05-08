---
layout: page
title: "Run Portworx with Kubernetes"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk
sidebar: home_sidebar
---

* TOC
{:toc}

Portworx can run alongside Kubernetes and provide Persistent Volumes to other applications running on Kubernetes. This section describes how to deploy PX within a Kubernetes cluster and have PX provide highly available volumes to any application deployed via Kubernetes.


## Deploy PX with Kubernetes 1.6+
Kubernetes-1.6 [release](https://github.com/kubernetes/kubernetes/releases/tag/v1.6.0) includes the Portworx native driver support which allows Dynamic Volume Provisioning. 

The native portworx driver in Kubernetes supports the following features:
1. Dynamic Volume Provisioning
2. Storage Classes
3. Persistent Volume Claims
4. Persistent Volumes

## Prerequisites
You must have a running Kubernetes 1.6+ Cluster.  If your Kubernetes cluster is older than 1.6, follow [these](/run-with-kubernetes-flexvolume.html) instructions to run Kubernetes with flexvolume.

### Optional
To enable Scheduler Convergence, you need to provide PX with the Kubernetes configuration and certificate files.

A `kubernetes.yaml` file is needed for allowing PX to communicate with Kubernetes. This configuration file primarily consists of the kubernetes cluster information and the kubernetes master node's IP and port where the kube-apiserver is running. This file, and any kubernetes certificates, need to be located at 

`/etc/pwx/`

```
# cat /etc/pwx/kubernetes.yaml
```

```yaml
apiVersion: v1
kind: Config
clusters:
- cluster:
    api-version: v1
    server: http://<master-node-ip>:<api-server-port>
    certificate-authority: /etc/pwx/my_cafile
preferences:
  colors: true
```

>**Note:**<br/>The above kubernetes.yaml file is exactly same as the kubelet config file usually named as admin.conf. You need to just copy that file into /etc/pwx/ and rename it to kubernetes.yaml

## Install
Portworx deploys as a Daemon Set.

>**Note:**<br/>Currently, Portworx needs to run on the kubernetes master node (_This requirement will be removed soon_). To allow that, run the following command: `kubectl taint nodes --all node-role.kubernetes.io/master-`

Deploy the Portworx: Daemon Set:
```
kubectl create -f "http://install.portworx.com?cluster=mycluster&etcd=etcd://etcd.fake.net:4001"
```

Above command fetches the YAML spec from the web service and gives it to kubectl to create a Portworx monitor DaemonSet.

* This monitor ensures Portworx is running and maintains it's lifecycle
* The YAML spec declares details of the px-mon (image, parameters etc)
* Note how we give custom parameters which are specific to each setup.

Examples including optional parameters:

### To specify drives
```
# kubectl create -f "http://install.portworx.com?cluster=mycluster&etcd=etcd://etcd.fake.net:4001&drive=/dev/sdb"
```

### To specify data and management interfaces
``` 
# kubectl create -f "http://install.portworx.com?cluster=mycluster&etcd=etcd://etcd.fake.net:4001&diface=enp0s8&miface=enp0s8"
```

### To Uninstall
To Uninstall the PX daemon set, just delete it as follows:

```
kubectl delete -f "http://install.portworx.com?cluster=mycluster&etcd=etcd://etcd.fake.net:4001"
```
