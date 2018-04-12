---
layout: page
title: "Deploy Portworx on Openshift"
keywords: portworx, container, kubernetes, storage, docker, k8s, pv, persistent disk, openshift
sidebar: home_sidebar

meta-description: "Find out how to install PX within a Openshift cluster and have PX provide highly available volumes to any application deployed via Kubernetes."
---

![k8s porx Logo](/images/k8s-porx.png){:height="188px" width="188px"}

* TOC
{:toc}

## Prerequisites

{% include px-k8s-prereqs.md %}

**Version**

Portworx supports Openshift 3.7 and above.

## Install

Portworx gets deployed as a [Kubernetes DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/). Following sections describe how to generate the spec files and apply them.

### Add Portworx service accounts to the privileged security context

```bash
oc adm policy add-scc-to-user privileged system:serviceaccount:kube-system:px-account
oc adm policy add-scc-to-user privileged system:serviceaccount:kube-system:portworx-pvc-controller-account
oc adm policy add-scc-to-user anyuid system:serviceaccount:default:default
```

### Generate the spec

>**Note:**<br/> Make sure you give _osft=true_ as part of the parameters while generating the spec.

{% include k8s-spec-generate.md %}


### Apply the spec

Once you have generated the spec file, deploy Portworx.	
```bash
oc apply -f px-spec.yaml
```

{% include k8s-monitor-install.md %}

## Deploy a sample application

We will test if the installation was successful using a persistent mysql deployment.

* Create a Portworx StorageClass by applying following spec:

```
kind: StorageClass
apiVersion: storage.k8s.io/v1beta1
metadata:
    name: px-demo-sc
provisioner: kubernetes.io/portworx-volume
parameters:
   repl: "3"
```
* Log into Openshift console: https://MASTER-IP:8443/console

* Create a new project "hello-world".

* Import and deploy [this mysql application template](/k8s-samples/px-mysql-openshift.json?raw=true)
    * For _STORAGE\\_CLASS\\_NAME_, we use the storage class _px-demo-sc_ created in step before.

* Verify mysql deployment is active.

You can find other examples at [applications using Portworx on Kubernetes](/scheduler/kubernetes/k8s-px-app-samples.html).
