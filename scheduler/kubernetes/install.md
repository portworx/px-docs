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

meta-description: "Find out how to install PX within a Kubernetes cluster and have PX provide highly available volumes to any application deployed via Kubernetes."
---

* TOC
{:toc}

Portworx can run alongside Kubernetes and provide Persistent Volumes to other applications running on Kubernetes. This section describes how to deploy PX within a Kubernetes cluster and have PX provide highly available volumes to any application deployed via Kubernetes.

>**Note:**<br/>OpenShift and Kubernetes Pre 1.6 users, please follow [these instructions](flexvolume.html).

![k8s porx Logo](/images/k8s-porx.png){:height="188px" width="188px"}

## Deploy PX with Kubernetes
Since Kubernetes [v1.6 release](https://github.com/kubernetes/kubernetes/releases/tag/v1.6.0), Kubernetes includes the Portworx native driver support which allows Dynamic Volume Provisioning.

The native portworx driver in Kubernetes supports the following features:

1. Dynamic Volume Provisioning
2. Storage Classes
3. Persistent Volume Claims
4. Persistent Volumes


Portworx also comes with two install options for Kubernetes:

1. PX-OCI - runs Portworx as OCI (Open Container Initiative) container [**RECOMMENDED**]
2. PX-Container - runs Portworx as Docker container


## Prerequisites

* *VERSIONS*: Portworx recommends running with Kubernetes 1.7.5 or newer
    - If your Kubernetes cluster version is between 1.6.0 and 1.6.4, you will need to set `mas=true` when creating the spec (see [install section](#install) below), to allow Portworx to run on the Kubernetes master node.
    - If your Kubernetes cluster is older than 1.6, follow [these](flexvolume.html) instructions to run Kubernetes with flexvolume (not recommended and has limited features).
* *SHARED MOUNTS*: If you are running Docker v1.12, you *must* configure Docker to allow shared mounts propagation (see [instructions](/knowledgebase/shared-mount-propogation.html)), as otherwise Kubernetes will not be able to install Portworx.<br/> Newer versions of Docker have shared mounts propagation already enabled, so no additional actions are required.
* *FIREWALL*: Ensure ports 9001-9004 are open between the Kubernetes nodes that will run Portworx.<br/> Also ensure ports 9001-9015 are open for "localhost" (generally, this is a default firewalls setting, so in most cases no actions will be required to enable "localhost" ports).
* *NTP*: Ensure all nodes running PX are time-synchronized, and NTP service is configured and running.
* *KVDB*: Please have a clustered key-value database (etcd or consul) installed and ready. For etcd installation instructions refer this [doc](/maintain/etcd.html).
* *STORAGE*: At least one of the PX-nodes should have extra storage available, in a form of unformatted partition or a disk-drive.<br/> Also please note that storage devices explicitly given to Portworx (ie. `s=/dev/sdb,/dev/sdc3`) will be automatically formatted by PX.

## Install

PX can be deployed with a single command as a [Kubernetes DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/) with the following:

```bash
# Download the spec - substitute your parameters below.
VER=$(kubectl version --short | awk -Fv '/Server Version: /{print $3}')
curl -o px-spec.yaml "http://install.portworx.com?c=mycluster&type=oci&k=etcd://etc.company.net:2379&kbver=$VER"

# Verify that the contents of px-spec.yaml are correct.
vi px-spec.yaml

# Apply the spec.
kubectl apply -f px-spec.yaml

# Monitor the deployment
kubectl get pods -o wide -n kube-system -l name=portworx
```

>**IMPORTANT:**<br/> To simplify the installation and entering the parameters, please head on to [http://install.portworx.com](http://install.portworx.com) and use the prepared HTML form.

Below are all parameters that can be given in the query string  (see [install.portworx.com](http://install.portworx.com)).

| Value  | Description                                                                                                                           | Example                                                    |
|:-------|:--------------------------------------------------------------------------------------------------------------------------------------|:-----------------------------------------------------------|
|        | <center>REQUIRED PARAMETERS</center>                                                                                                  |                                                            |
| type   | Select Portworx deployment type (_oci_ for OCI container, _dock_ for Docker container)                                                | <var>type=oci</var>                                        |
| c      | Specifies the unique name for the Portworx cluster.                                                                                   | <var>c=test_cluster</var>                                  |
| k      | Your key value database, such as an etcd cluster or a consul cluster.                                                                 | <var>k=etcd:http://etcd.fake.net:2379</var>                |
|        | <center>OPTIONAL PARAMETERS</center>                                                                                                  |                                                            |
| s      | Specify comma-separated list of drives.                                                                                               | <var>s=/dev/sdb,/dev/sdc</var>                             |
| d      | Specify data network interface. This is useful if your instances have non-standard network interfaces.                                | <var>d=eth1</var>                                          |
| m      | Specify management network interface. This is useful if your instances have non-standard network interfaces.                          | <var>m=eth1</var>                                          |
| kbver  | Specify Kubernetes version (current default is 1.7)                                                                                   | <var>kbver=1.8.4</var>                                     |
| coreos | REQUIRED if target nodes are running coreos.                                                                                          | <var>coreos=true</var>                                     |
| mas    | Specify if PX should run on the Kubernetes master node. For Kubernetes 1.6.4 and prior, this needs to be true (default is false)      | <var>mas=true</var>                                        |
| z      | Instructs PX to run in zero storage mode on Kubernetes master.                                                                        | <var>z=true</var>                                          |
| f      | Instructs PX to use any available, unused and unmounted drives or partitions. PX will never use a drive or partition that is mounted. | <var>f=true</var>                                          |
| st     | Select the secrets type (_aws_, _kvdb_ or _vault_)                                                                                    | <var>st=vault</var>                                        |
|        | <center>KVDB CONFIGURATION PARAMETERS</center>                                                                                        |                                                            |
| pwd    | Username and password for ETCD authentication in the form user:password                                                               | <var>pwd=username:password</var>                           |
| ca     | Location of CA file for ETCD authentication.                                                                                          | <var>ca=/path/to/server.ca</var>                           |
| cert   | Location of certificate for ETCD authentication.                                                                                      | <var>cert=/path/to/server.crt</var>                        |
| key    | Location of certificate key for ETCD authentication.                                                                                  | <var>key=/path/to/server.key</var>                         |
| acl    | ACL token value used for Consul authentication.                                                                                       | <var>acl=398073a8-5091-4d9c-871a-bbbeb030d1f6</var>        |
|        | <center>LIGHTHOUSE CONFIGURATION PARAMETERS</center>                                                                                  |                                                            |
| t      | Portworx Lighthouse token for cluster.                                                                                                | <var>t=token-a980f3a8-5091-4d9c-871a-cbbeb030d1e6</var>    |
| e      | Comma-separated list of environment variables that will be exported to portworx.                                                      | <var>e=API_SERVER=http://lighthouse-new.portworx.com</var> |


>**Note:**<br/> If using secure etcd provide "https" in the URL and make sure all the certificates are in a directory which is bind mounted inside PX container. (ex.: /etc/pwx)

If you are still experiencing issues, please refer to [Troubleshooting PX on Kubernetes](support.html) and [General FAQs](/knowledgebase/faqs.html).



#### Restricting PX to certain nodes
To restrict Portworx to install on only a subset of nodes in the Kubernetes cluster, please set the `px/enabled=false` Kubernetes label on the minion nodes you _do not_ wish to install Portworx on.  For example, to prevent Portworx from installing and starting on _minion2_ and _minion5_ nodes, run the following:

```
$ kubectl label nodes minion2 "px/enabled=false" --overwrite
$ kubectl label nodes minion5 "px/enabled=false" --overwrite
```

>**Note:**<br/> If you are using the PX-OCI containers, and the PX-OCI has already been deployed on your nodes, please use the `px/enabled=remove` label instead. <br/>Note that with PX-OCI containers, the `px/enabled=false` removes only the Portworx "oci-monitor" component, while retaining PX-OCI service. Applying the `px/enabled=remove` label will uninstall both PX-OCI service, and the "oci-monitor".


#### Scaling
Portworx is deployed as a [DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/). Therefore it automatically scales as you grow your Kubernetes cluster.  There are no additional requirements to install Portworx on the new nodes in your Kubernetes cluster.

#### Installing behind the HTTP proxy
During the installation Portworx may require access to the Internet, to fetch kernel headers if they are not available locally on the host system.  If your cluster runs behind the HTTP proxy, you will need to expose `PX_HTTP_PROXY` and/or `PX_HTTPS_PROXY` environment variables to point to your HTTP proxy when starting the DaemonSet.

Use `e=PX_HTTP_PROXY=<http-proxy>,PX_HTTPS_PROXY=<https-proxy>` query param when generating the DaemonSet spec. For example:

```
$ curl -o px-spec.yaml \
  "http://install.portworx.com?c=mycluster&k=etcd://etcd.fake.net:2379&e=PX_HTTP_PROXY=<http-proxy>,PX_HTTPS_PROXY=<https-proxy>"
```

## Uninstall

Uninstalling or deleting the portworx daemonset only removes the portworx containers from the nodes. As the configurations files which PX use are persisted on the nodes the storage devices and the data volumes are still intact. These portworx volumes can be used again if the PX containers are started with the same configuration files.

>**IMPORTANT:**<br/> Please note that the PX-OCI service is running independently of Docker and Kubernetes services. If you deployed Portworx as PX-OCI Daemonset, you will first need to explicitly uninstall it using `px/enabled=remove` label (see below).

* You can uninstall **Portworx OCI** (`type=oci`) from the cluster using:

  ```bash
  # [PX-OCI] installations - step 1) remove PX-OCI service first
  kubectl label nodes --all px/enabled=remove --overwrite
  
  # [PX-OCI] installations - step 2) confirm PX service is uninstalled (may take a few minutes)
  kubectl get pods -o wide -n kube-system -l name=portworx   # repeat until all pods terminated
  
  # If you deployed using your custom px-spec.yaml file, we recommend you uninstall using the same spec-file:
  kubectl delete -f px-spec.yaml
  
  # Alternatively delete PX using the Web-form:
  kubectl delete -f 'http://install.portworx.com?type=oci'
  ```

* To uninstall **non-OCI Portworx** (`type=dock`) from the cluster, please use:

  ```bash
  # If you deployed using your custom px-spec.yaml file, we recommend you uninstall using the same spec-file:
  kubectl delete -f px-spec.yaml
  
  # Alternatively delete PX using the Web-form:
  kubectl delete -f 'http://install.portworx.com?type=dock'
  ```

>**Note:**<br/>During uninstall, the Portworx configuration files under `/etc/pwx/` directory are preserved, and will not be deleted.

## Service control (PX-OCI only)

One can control the PX-OCI service using the Kubernetes labels:

* stop / start / restart the PX-OCI service
  * note: this is the equivalent of running `systemctl stop portworx`, `systemctl start portworx` ... on the node

  ```
  kubectl label nodes minion2 px/service=start
  kubectl label nodes minion5 px/service=stop
  kubectl label nodes --all px/service=restart
  ```

* enable / disable the PX-OCI service
  * note: this is the equivalent of running `systemctl enable portworx`, `systemctl disable portworx` on the node

  ```
  kubectl label nodes minion2 px/service=enable
  kubectl label nodes minion5 px/service=disable
  ```
  

## Wipe off PX Cluster configuration
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

## Cloud Installation
Portworx-ready Kubernetes clusters can be deployed through Terraform, using the Terraporx repository, on Digital Ocean and Google Clould Platform

### Google Cloud Platform (GCP)
To deploy a Portworx-ready Kubernetes cluster on GCP, use [this Terraporx repository](https://github.com/portworx/terraporx/tree/master/gcp/kubernetes_ubuntu16)

### Digital Ocean
To deploy a Portworx-ready Kubernetes cluster on Digital Ocean, use [this Terraporx repository](https://github.com/portworx/terraporx/tree/master/digital_ocean/kubernetes_ubuntu16)


## TROUBLESHOOTING:

* Q: My Kubernetes labels are not working -- I labeled a node with `px/enabled=remove` (or `px/service=restart`), and Portworx is not uninstalling (or, restarting)!  How do I fix this?
	* A1: On a "busy cluster", Kubernetes can take some time until it processes the node-labels change, and notifies Portowrx service -- please allow a few minutes for labels to be processed.
	* A2: Sometimes it may happen that Kubernetes labels processing stops altogether - in this case please reinstall the "oci-monitor" component by applying and then deleting the `px/enabled=false` label:<br> `kubectl label nodes --all px/enabled=false; sleep 30; kubectl label nodes --all px/enabled-`
		* this should reinstall/redeploy the "oci-monitor" component without disturbing the PX-OCI service or disrupting the storage, and the Kubernetes labels should work afterwards
