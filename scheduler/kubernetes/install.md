---
layout: page
title: "Deploy Portworx on Kubernetes"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk
sidebar: home_sidebar
redirect_from:
  - /gce-k8s-pwx.html
  - /scheduler/kubernetes.html
  - /scheduler/kubernetes/
  - /cloud/azure/k8s_tectonic.html
  - /run-with-kube.md
  - /scheduler/kubernetes/flexvolume.html
  - /run-with-kube.md
  - /scheduler/kubernetes/flexvolume.html

meta-description: "Find out how to install PX within a Kubernetes cluster and have PX provide highly available volumes to any application deployed via Kubernetes."
---

![k8s porx Logo](/images/k8s-porx.png){:height="188px" width="188px"}

* TOC
{:toc}

Portworx can run alongside Kubernetes and provide Persistent Volumes to other applications running on Kubernetes. This section describes how to deploy PX within a Kubernetes cluster and have PX provide highly available volumes to any application deployed via Kubernetes.

Since Kubernetes [v1.6 release](https://github.com/kubernetes/kubernetes/releases/tag/v1.6.0), Kubernetes includes the Portworx native driver support which allows Dynamic Volume Provisioning.

The native portworx driver in Kubernetes supports the following features:

1. Dynamic Volume Provisioning
2. Storage Classes
3. Persistent Volume Claims
4. Persistent Volumes

## Interactive Tutorial

Following are some interactive tutorials that give an overview about Portworx on Kubernetes.

* [Portworx on Kubernetes](https://www.katacoda.com/portworx/scenarios/deploy-px-k8s) gives a high level overview on installing Portworx on Kubernetes.
* [Persistent volumes on Kubernetes using Portworx](https://www.katacoda.com/portworx/scenarios/px-k8s-vol-basic) explains how to create persistent volumes using Portworx on Kubernetes.

<a name="prereqs-section"></a>
## Prerequisites

* *VERSIONS*: Portworx recommends running with Kubernetes 1.7.5 or newer
    - If your Kubernetes cluster version is between 1.6.0 and 1.6.4, you will need to set `mas=true` when creating the spec (see [install section](#install) below), to allow Portworx to run on the Kubernetes master node.
* *SHARED MOUNTS*: If you are running Docker v1.12, you *must* configure Docker to allow shared mounts propagation (see [instructions](/knowledgebase/shared-mount-propogation.html)), as otherwise Kubernetes will not be able to install Portworx.<br/> Newer versions of Docker have shared mounts propagation already enabled, so no additional actions are required.
* *FIREWALL*: Ensure ports 9001-9015 are open between the Kubernetes nodes that will run Portworx.
* *NTP*: Ensure all nodes running PX are time-synchronized, and NTP service is configured and running.
* *KVDB*: Please have a clustered key-value database (etcd or consul) installed and ready. For etcd installation instructions refer this [doc](/maintain/etcd.html).
* *STORAGE*: At least one of the PX-nodes should have extra storage available, in a form of unformatted partition or a disk-drive.<br/> Also please note that storage devices explicitly given to Portworx (ie. `s=/dev/sdb,/dev/sdc3`) will be automatically formatted by PX.

>**NOTE:**<br/>  This page describes the procedure of installing & managing Portworx as a OCI container, which is the default and recommended method of installation. If you are looking for legacy instructions of running Portworx as a docker container, you can find them [here](/scheduler/kubernetes/install-legacy.html).

<a name="install-section"></a>
## Install

If you are installing on [Openshift](https://www.openshift.com/), follow [these instructions](/scheduler/kubernetes/openshift-install.html).

Portworx gets deployed as a [Kubernetes DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/). Following sections describe how to generate the spec files and apply them.

#### Generating the spec

To generate the spec file, head on to [https://install.portworx.com](https://install.portworx.com) and fill in the parameters. When filing the `kbver` (Kubernetes version) on the page, use output of: 

```bash
kubectl version --short | awk -Fv '/Server Version: /{print $3}'
```

Alternately, you can use `curl` to generate the spec as described in [Generating Portworx Kubernetes spec using curl](/scheduler/kubernetes/px-k8s-spec-curl.html).

>**Secure ETCD:**<br/> If using secure etcd provide "https" in the URL and make sure all the certificates are in the `/etc/pwx/` directory on each host which is bind mounted inside PX container.

#### Applying the spec

Once you have generated the spec file, deploy Portworx.

```bash
$ kubectl apply -f px-spec.yaml
```

You can monitor the status using following commands.
```
# Monitor the portworx pods

$ kubectl get pods -o wide -n kube-system -l name=portworx


# Monitor Portworx cluster status

$ PX_POD=$(kubectl get pods -l name=portworx -n kube-system -o jsonpath='{.items[0].metadata.name}')
$ kubectl exec $PX_POD -n kube-system -- /opt/pwx/bin/pxctl status
```

If you are still experiencing issues, please refer to [Troubleshooting PX on Kubernetes](support.html) and [General FAQs](/knowledgebase/faqs.html).



#### Restricting PX to certain nodes
To restrict Portworx to run on only a subset of nodes in the Kubernetes cluster, we can use the `px/enabled` Kubernetes label on the minion nodes you _do not_ wish to install Portworx on.  Below are examples to prevent Portworx from installing and starting on _minion2_ and _minion5_ nodes.

If Portworx Daemonset is not yet deployed in your cluster:
  ```
  $ kubectl label nodes minion2 minion5 px/enabled=false --overwrite
  ```

If Portworx has already been deployed in your cluster:
  ```
  $ kubectl label nodes minion2 minion5 px/enabled=remove --overwrite
  ```
    
  Above label will remove the existing systemd Portworx service and also apply the `px/enabled=false` label to stop Portworx from running in future.

#### Scaling
Portworx is deployed as a [DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/). Therefore it automatically scales as you grow your Kubernetes cluster.  There are no additional requirements to install Portworx on the new nodes in your Kubernetes cluster.

#### Installing behind the HTTP proxy
During the installation Portworx may require access to the Internet, to fetch kernel headers if they are not available locally on the host system.  If your cluster runs behind the HTTP proxy, you will need to expose `PX_HTTP_PROXY` and/or `PX_HTTPS_PROXY` environment variables to point to your HTTP proxy when starting the DaemonSet. 

Use `e=PX_HTTP_PROXY=<http-proxy>,PX_HTTPS_PROXY=<https-proxy>` query param when generating the DaemonSet spec. For example:
 
  ```
  $ curl -o px-spec.yaml \
    "https://install.portworx.com?c=mycluster&k=etcd://etcd.fake.net:2379&e=PX_HTTP_PROXY=<http-proxy>,PX_HTTPS_PROXY=<https-proxy>"
  ```

To view a list of all Portworx environment variables, go to [passing environment variables](/runc/options.html#environment-variables).

## Upgrade

For information about upgrading Portworx inside Kubernetes, please refer to the dedicated [upgrade page](/scheduler/kubernetes/upgrade.html).

## Service control 

>**NOTE:** You should not stop the Portworx systemd service while applications are still using it. Doing so can cause docker and applications to hang on the system. Migrate all application pods using `kubectl drain` from the node before stopping the Portworx systemd service.

One can control the Portworx systemd service using the Kubernetes labels:

* stop / start / restart the PX-OCI service
  * note: this is the equivalent of running `systemctl stop portworx`, `systemctl start portworx` ... on the node

  ```bash
  kubectl label nodes minion2 px/service=start
  kubectl label nodes minion5 px/service=stop
  kubectl label nodes --all px/service=restart
  ```

* enable / disable the PX-OCI service
  * note: this is the equivalent of running `systemctl enable portworx`, `systemctl disable portworx` on the node

  ```bash
  kubectl label nodes minion2 minion5 px/service=enable
  ```

## Uninstall

Uninstalling or deleting the portworx daemonset only removes the portworx containers from the nodes. As the configurations files which PX use are persisted on the nodes the storage devices and the data volumes are still intact. These portworx volumes can be used again if the PX containers are started with the same configuration files.

You can uninstall Portworx from the cluster using:

1. Remove the Portworx systemd service and terminate pods by labelling nodes as below. On each node, Portworx monitors this label and will start removing itself when the label is applied.
```bash
kubectl label nodes --all px/enabled=remove --overwrite
```

2. Monitor the PX pods until all of them are terminated
```bash
kubectl get pods -o wide -n kube-system -l name=portworx
```
3. Remove all PX Kubernetes Objects

    a. If you have a copy of the spec file you used to install Portworx:
    ```bash
    kubectl delete -f px-spec.yaml
    ```

    b. If you don't, you can use the Web form:
    ```bash
    VER=$(kubectl version --short | awk -Fv '/Server Version: /{print $3}')
    kubectl delete -f 'https://install.portworx.com?kbver=$VER'
    ```

4. Remove the 'px/enabled' label from your nodes
```bash
kubectl label nodes --all px/enabled-
```

>**Note:**<br/>During uninstall, the Portworx configuration files under `/etc/pwx/` directory are preserved, and will not be deleted.

## Delete PX Cluster configuration
The commands used in this section are DISRUPTIVE and will lead to loss of all your data volumes. Proceed with CAUTION.

You can remove PX cluster configuration by deleting the configuration files under `/etc/pwx` directory on all nodes:

 * If the portworx pods are running, you can run the following command:

  ```bash
  PX_PODS=$(kubectl get pods -n kube-system -l name=portworx | awk '/^portworx/{print $1}')
  for pod in $PX_PODS; do
      kubectl -n kube-system exec -it $pod -- rm -rf /etc/pwx/
  done
  ```

* otherwise, if the portworx pods are not running, you can remove PX cluster configuration by manually removing the contents of `/etc/pwx` directory on all the nodes.

>**Note**<br/>If you are wiping off the cluster to re-use the nodes for installing a brand new PX cluster, make sure you use a different ClusterID in the DaemonSet spec file  (ie. `-c myUpdatedClusterID`).
