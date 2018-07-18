---
layout: page
title: "Deploy Portworx Developer edition on Kubernetes"
keywords: portworx, developer, free, container, kubernetes, storage, docker, k8s, pv, persistent disk
sidebar: home_sidebar
meta-description: "Find out how to deploy free Portworx Developer-edition on Kubernetes."
---

![k8s porx Logo](/images/k8s-porx.png){:height="188px" width="188px"}

* TOC
{:toc}

## What is PX-Developer

**PX-Developer** is a free version of Portworx software.
This version does not require explicit license, will never expire, but has a limited functionality and can run a cluster of up to 3 nodes.
For a full list of limitations please see our [licensing page](/getting-started/px-licensing.html#px-developer-license).

If you require full Portworx functionality or want to test the product for 30 days, you will need to install PX-Enterprise edition.
For more information about licensing, please refer to our [licensing page](/getting-started/px-licensing.html).


## Install

Portworx Kubernetes installations will by default install a PX-Enterprise edition, and automatically start a Trial period unless license has already been installed.
Starting with Portworx v1.4.1, we added a simple way how to install the PX-Developer -edition rather than default PX-Enterprise.

### Generate the spec

Start your deployment as usual, by following the Kubernetes installation guide for your specific variety of Kubernetes (e.g. [OpenShift](openshift-install.html)).
Once you entered your configuration data at https://install.portworx.com/1.4.1/, add the `&dev` at the end of the URL.

For example:

```bash
# appending &dev to YAML-spec URL will switch installation to PX-Developer edition
kubectl apply -f \
  'https://install.portworx.com/1.4.1/?c=myCluster&k=etcd:http://etcd-1.acme.net:2379&kbver=1.11.0&dev'
```

### Label the nodes

Since the PX-Developer edition can run only on upto 3 nodes, one will need to explicitly label the cluster nodes where Portworx should
install, by using the `px/dev=true` label.

Example:

```bash
# instruct Kubernetes to install Portworx on mynode1, mynode2 and mynode3 cluster nodes
kubectl label nodes mynode1 mynode2 mynode3 px/dev=true
```

