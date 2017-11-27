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

## Deploy PX with Kubernetes 1.6+
Kubernetes-1.6 [release](https://github.com/kubernetes/kubernetes/releases/tag/v1.6.0) includes the Portworx native driver support which allows Dynamic Volume Provisioning.

The native portworx driver in Kubernetes supports the following features:
1. Dynamic Volume Provisioning
2. Storage Classes
3. Persistent Volume Claims
4. Persistent Volumes

## Prerequisites
* Portworx recommends running with Kubernetes 1.6.5+ Cluster.
    * If your Kubernetes cluster is between 1.6.0 and 1.6.4, set `master=true` when creating the spec in the Install section below.
    * If your Kubernetes cluster is older than 1.6, follow [these](flexvolume.html) instructions to run Kubernetes with flexvolume (not recommended and has limited features).
* You *must* configure Docker to allow shared mounts propogation. Please follow [these](/knowledgebase/shared-mount-propogation.html) instructions to enable shared mount propogation.  This is needed because PX runs as a container and it will be provisioning storage to other containers.
* Ensure ports 9001-9004 are open between the Kubernetes nodes that will run Portworx.
* Ensure all nodes running PX are synchronized in time and NTP is configured
* A clustered key-value database (etcd or consul). For etcd installation instructions refer this [doc](/maintain/etcd.html).

## Install

PX can be deployed with a single command in Kubernetes as a `DaemonSet` with the following:
```
# Download the spec - substitute your parameters below.
K8S_VERSION=`kubectl version --short | grep Server | awk '{print $3}'`
$ curl -o px-spec.yaml "http://install.portworx.com?cluster=mycluster&kvdb=etcd://etc.company.net:2379&k8sVersion=$K8S_VERSION"

# Verify that the contents of px-spec.yaml are correct.
$ vi px-spec.yaml

# Apply the spec.
$ kubectl apply -f px-spec.yaml
```
Before you apply this command, make sure you change the custom parameters (_cluster_ and _kvdb_) to match your environment.

Below are all parameters that can be given in the query string:

| Key         	| Description                                                                                                                                                                              	| Example                                           	|
|-------------	|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	|---------------------------------------------------	|
| cluster     	| (Required) Specifies the unique name for the Portworx cluster.                                                                                                                           	| cluster=test_cluster                              	|
| kvdb        	| (Required) Points to your key value database, such as an etcd cluster or a consul cluster. Specify comma-separated list of kvdb endpoints.                                               	| kvdb=etcd:http(s)://etcd.fake.net:2379              |
| k8sVersion   | (Optional) Specifies the Kubernetes version. (Use the server version in the `kubectl version` output.)                                                                                   	| k8sVersion=v1.8.0                           	      |
| drives      	| (Optional) Specify comma-separated list of drives.                                                                                                                                       	| drives=/dev/sdb,/dev/sdc                          	|
| diface      	| (Optional) Specifies the data interface. This is useful if your instances have non-standard network interfaces.                                                                          	| diface=eth1                                       	|
| miface      	| (Optional) Specifies the management interface. This is useful if your instances have non-standard network interfaces.                                                                    	| miface=eth1                                       	|
| coreos       	|  REQUIRED if target nodes are running coreos.                                                                                                                                         	| coreos=true                                         |
| master     	| (Optional) If true, PX will run on the master node. For Kubernetes 1.6.4 and prior, this needs to be true (default is false)                                                            	| master=true                                  	      |
| zeroStorage 	| (Optional) Instructs PX to run in zero storage mode on kubernetes master.                                                                                                                	| zeroStorage=true                                  	|
| force       	| (Optional) Instructs PX to use any available, unused and unmounted drives or partitions.,PX will never use a drive or partition that is mounted.                                         	| force=true                                        	|
| etcdPasswd  	| (Optional) Username and password for ETCD authentication in the form user:password                                                                                                       	| etcdPasswd=username:password                      	|
| etcdCa      	| (Optional) Location of CA file for ETCD authentication.                                                                                                                                  	| etcdCa=/path/to/server.ca                         	|
| etcdCert    	| (Optional) Location of certificate for ETCD authentication.                                                                                                                              	| etcdCert=/path/to/server.crt                      	|
| etcdKey     	| (Optional) Location of certificate key for ETCD authentication.                                                                                                                          	| etcdKey=/path/to/server.key                       	|
| acltoken    	| (Optional) ACL token value used for Consul authentication.                                                                                                                               	| acltoken=398073a8-5091-4d9c-871a-bbbeb030d1f6     	|
| token       	| (Optional) Portworx lighthouse token for cluster.                                                                                                                                        	| token=a980f3a8-5091-4d9c-871a-cbbeb030d1e6        	|
| env         	| (Optional) Comma-separated list of environment variables that will be exported to portworx.                                                                                              	| env=API_SERVER=http://lighthouse-new.portworx.com 	|
| secretType   	| (Optional) Instructs PX from which secrets endpoint to fetch secrets from. Supported: vault, aws and kvdb                                                                                	| secretType=vault                                   	|
| clusterSecretKey | (Required for vault secret type) Sets the cluster-wide secretID. This secret will be used to fetch the secret stored in Vault. The secret will be used as a passphrase for encrypting all the volumes 	| clusterSecretKey=mysecretkey        	|

#### Examples
```
# To specify drives
$ curl -o px-spec.yaml "http://install.portworx.com?cluster=mycluster&kvdb=etcd://etcd.fake.net:2379&drives=/dev/sdb,/dev/sdc"

# To specify multiple kvdb endpoints
$ curl -o px-spec.yaml "http:install.portworx.com?cluster=mycluster&kvdb=etcd://etcd1.fake.net:2379,etcd://etcd2.fake.net:2379&drives=/dev/sdb"

# To run on coreos
$ curl -o px-spec.yaml "http://install.portworx.com?cluster=mycluster&kvdb=etcd://etcd.fake.net:2379&coreos=true"

# To run in master in zero storage mode and use a specific drive for other nodes
$ curl -o px-spec.yaml "http://install.portworx.com?cluster=mycluster&kvdb=etcd://etcd.fake.net:2379&zeroStorage=true&drives=/dev/sdb"
```


If you are having issues, refer to [Troubleshooting PX on Kubernetes](support.html) and [General FAQs](/knowledgebase/faqs.html).

>**Note:** If using secure etcd provide "https" in the URL and make sure all the certificates are in a directory which is bind mounted inside PX container. (ex.: /etc/pwx)


#### Restricting PX to certain nodes
To restrict Portworx to only a subset of nodes in the Kubernetes cluster, you can label the minion nodes.  For example, to prevent Portworx from starting on minion-X:

```
$ kubectl label nodes minion-X "px/enabled=false" --overwrite
```

#### Scaling
Portworx is deployed as a [DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/). Therefore it automatically scales as you grow your Kubernetes cluster.  There are no additional requirements to install Portworx on the new nodes in your Kubernetes cluster.

#### Installing in environments behind a proxy
Portworx container needs to fetch the kernel headers to install the px kernel module. If your cluster runs behind a proxy, expose `PX_HTTP_PROXY` and/or `PX_HTTPS_PROXY` environment variables to point to your proxy when starting the DaemonSet.

Use `env=PX_HTTP_PROXY=<http-proxy>,PX_HTTPS_PROXY=<https-proxy>` query param when generating the DaemonSet spec. For example:
```
$ curl -o px-spec.yaml "http://install.portworx.com?cluster=mycluster&kvdb=etcd://etcd.fake.net:2379&env=PX_HTTP_PROXY=<http-proxy>,PX_HTTPS_PROXY=<https-proxy>"
```

## Uninstall
Uninstalling or deleting the portworx daemon set only removes the portworx containers from the nodes. As the configurations files which PX use are persisted on the nodes the storage devices and the data volumes are still intact. These portworx volumes can be used again if the PX containers are started with the same configuration files.

You can uninstall Portworx from the cluster using:
```
$ kubectl delete -f <px-spec.yaml>
```

Here px-spec.yaml is the spec file used to create the Portworx cluster. If you don't have access to this file any longer, you can use:
```
$ kubectl delete -f "http://install.portworx.com?cluster=mycluster&kvdb=etcd://etcd.fake.net:2379"
```

>**Note:**<br/>During uninstall, the configuration files (/etc/pwx/config.json and /etc/pwx/.private.json) are not deleted.

## Wipe off PX Cluster
The commands used in this section are DISRUPTIVE and will lead to loss of all your data volumes. Proceed with CAUTION.

You can completely wipe PX cluster by deleting the configuration files under `/etc/pwx` on all nodes. If the portworx pods are running you can run the following command:

```
for pod in $(kubectl get pods -n kube-system -l name=portworx | awk -F" " '{print $1}' | grep -v NAME); do  kubectl -n kube-system exec -it $pod rm -- -rf /etc/pwx/; done
```

If the portworx pods are not running you need to remove `/etc/pwx` from all the nodes.

>**Note**<br/>If you are wiping off the cluster to re-use the nodes for installing a brand new PX cluster, make sure you use a new clusterid in the daemonset spec file

## Cloud Installation
Portworx-ready Kubernetes clusters can be deployed through Terraform, using the Terraporx repository, on Digital Ocean and Google Clould Platform

### Google Cloud Platform (GCP)
To deploy a Portworx-ready Kubernetes cluster on GCP, use [this Terraporx repository](https://github.com/portworx/terraporx/tree/master/gcp/kubernetes_ubuntu16)

### Digital Ocean
To deploy a Portworx-ready Kubernetes cluster on Digital Ocean, use [this Terraporx repository](https://github.com/portworx/terraporx/tree/master/digital_ocean/kubernetes_ubuntu16)
