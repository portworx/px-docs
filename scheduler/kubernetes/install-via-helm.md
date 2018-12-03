---
layout: page
title: "Portworx install on kubernetes via Helm"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk

meta-description: "Find out how to install PX on Kubernetes via the Portworx Helm chart"
---

* TOC
{:toc}

## Pre-requisites

* This page assumes you have a running Kubernetes cluster and a kvdb cluster such as etcd/consul.

- The helm chart (portworx) deploys Portworx and STork(https://docs.portworx.com/scheduler/kubernetes/stork.html) on your Kubernetes cluster. - The minimum requirements for deploying the helm chart are as follows: Helm has been installed on the client machine from where you would install the chart. (https://docs.helm.sh/using_helm/#installing-helm) 
- Tiller version 2.9.0 and above is running on the Kubernetes cluster where you wish to deploy Portworx. Tiller has been provided with the right RBAC permissions for the chart to be deployed correctly. Kubernetes 1.7+ All Pre-requisites. for Portworx fulfilled.


## Portworx installation

To install Portworx via the chart with the release name `my-release` run the following commands substituting relevant values for your setup:

`clusterName` should be a unique name identifying your Portworx cluster. The default value is `mycluster`, but it is suggested to update it with your naming scheme.

For eg:
```
git clone https://github.com/portworx/helm.git
helm install --debug --name my-release --set etcdEndPoint=etcd:http://192.168.70.90:2379,clusterName=$(uuidgen) ./helm/charts/portworx/
```
Refer to all the configuration options while deploying Portworx via the Helm chart:
[Configurable Options](https://github.com/portworx/helm/tree/master/charts/portworx#configuration)

## Wipe Portworx installation

Below are the steps to wipe your entire Portworx installation on PKS.

1. Run cluster-scoped wipe: ```curl -fsL https://install.portworx.com/px-wipe | bash ``` This has to be run from the client machine which has kubectl access.
2. helm delete <release name> (the previously deployed release)

## Troubleshooting helm installation failures

Refer to the common troubleshooting instructions for Portworx deployments via Helm [Troubleshooting portworx installation](https://github.com/portworx/helm/tree/master/charts/portworx#basic-troubleshooting)
