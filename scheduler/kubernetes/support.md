---
layout: page
title: "Troubleshooting PX on Kubernetes"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk, debug, troubleshoot
sidebar: home_sidebar
redirect_from:
  - /scheduler/kubernetes/knowledgebase/faqs.html
meta-description: "For troubleshooting PX on Kubernetes, Portworx can help. Read this article for details about how to resolve your issue today."
---

* TOC
{:toc}

Following sections will guide you in troubleshooting issues with your Portworx installation on Kubernetes.

### Etcd
* Px container will fail to come up if it cannot reach etcd. The etcd location specified when creating the Portworx cluster needs to be reachable from all nodes.
  * Run `curl <etcd_location>/version` from each node to ensure reachability. For e.g `curl http://192.168.33.10:2379/version`
* If you deployed etcd as a Kubernetes service, use the ClusterIP instead of the kube-dns name. Portworx nodes cannot resolve kube-dns entries since px containers are in the host network. 

### Portworx cluster
* If the px container is failing to start on each node, ensure you have shared mounts enable. Please follow [these](/knowledgebase/shared-mount-propogation.html) instructions to enable shared mount propogation.  This is needed because PX runs as a container and it will be provisioning storage to other containers.
* Ports 9001 - 9006 must be open for internal network traffic between nodes running PX. Without this, px cluster nodes will not be able to communicate and cluster will be down.
* If one of your nodes has a custom taint, the Portworx pod will not get scheduled on that node unless you add a toleration in the Portworx DaemonSet spec. Read [here](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#taints-and-tolerations-beta-feature) for more information about taints and tolerations.
* When the px container boots on a node for the first time, it attempts to download kernel headers to compile it's kernel module. This can fail if the host sits behind a proxy. To workaround this, install the kernel headers on the host. For example on centos, this will be `` `yum install kernel-headers-`uname -r` `` and  `` yum install kernel-devel-`uname -r` ``
* If one of the px nodes is in maintenance mode, this could be because one or more of the drives has failed. In this mode, you can replace up to one failed drive. If there are multiple drive failures, a node can be decommissioned from the cluster. Once the node is decommissioned, the drives can be replaced and recommissioned into the cluster.

### PVC creation
If the PVC creation is failing, this could be due the following reasons
* A firewall rule for port 9001 is present on the hosts running px containers. This prevents the create volume call to come to the Portworx API server.
* For Kubernetes versions 1.6.4 and before, Portworx may not running on the Kubernetes master/controller node.
* For Kubernetes versions 1.6.5 and above, if you don't have Portworx running on the master/controller node, ensure that
    * The `portworx-service` is running in the `kube-system` namespace.
    * You don't have any custom taints on the master node. Doing so will disallow kube-proxy to run on master and that will cause the `portworx-service` to fail to handle requests.
* The StorageClass name specified might be incorrect.
* Make sure you are running Kubernetes 1.6 and above. Kubernetes 1.5 does not have our native driver which is required for PVC creation.

### Application pods
* Ensure Portworx container is running on the node where the application pod is scheduled. This is required for Portworx to mount the volume into the pod.
* Ensure the PVC used by the application pod is in "Bound" state.
* Check if Portworx is in maintenance mode on the node where the pod is running. If so, that will cause existing pods to see a read-only filesystem after about 10 minutes. New pods using Portworx will fail to start on this node.
* If a pod is stuck in terminating state, observe `journalctl -lfu kubelet` on the node where the pod is trying to terminate for errors during the pod termination process. Reach out to us over slack with the specific errors.
* Ensure that [namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/) of pod and the PersistentVolumeClaim is the same.

### Useful commands
* List PX pods: `kubectl get pods -l name=portworx -n kube-system`
* Describe PX pods: `kubectl describe pods -l name=portworx -n kube-system`
* Logs of all PX pods: `kubectl logs -l name=portworx -n kube-system --tail=1000`
* Follow logs of a particular px pod: `kubectl logs -w <pod-name> -n kube-system`
* Monitor kubelet logs on a particular Kubernetes node: `journalctl -lfu kubelet`
    * This can be useful to understand why a particular pod is stuck in creating or terminating state on a node.

### Collecting Logs from PX
Please run the following commands on any one of the nodes running Portworx:
```
# uname -a
# docker version
# kubectl version
# kubectl logs -n kube-system -l name=portworx --tail=1000
# kubectl get pods -n kube-system -l name=portworx -o wide
# /opt/pwx/bin/pxctl status
```
Include above logs when contacting us.

### Get support

If you have an enterprise license, please contact us at support@portworx.com with your license key and logs.

We are always available on Slack. Join us! [![](/images/slack.png){:height="48px" width="48px" alt="Slack" .slack-icon}](http://slack.portworx.com)

### Known issues

##### Kubernetes on CoreOS deployed through Tectonic
* This issue is fixed in Tectonic 1.6.7. So if are using a version equal or higher, this does not apply to you.
* [Tectonic](https://coreos.com/tectonic/) is deploying the [Kubernetes controller manager](https://kubernetes.io/docs/admin/kube-controller-manager/) in the docker `none` network. As a result, when the controller manager invokes a call on http://localhost:9001 to portworx to create a new volume, this results in the connection refused error since controller manager is not in the host network.
This issue is observed when using dynamically provisioned Portworx volumes using a StorageClass. If you are using pre-provisioned volumes, you can ignore this issue.
* To workaround this, you need to set `hostNetwork: true` in the spec file `modules/bootkube/resources/manifests/kube-controller-manager.yaml` and then run the tectonic installer to deploy kubernetes.
* Here is a sample [kube-controller-manager.yaml](https://gist.github.com/harsh-px/106a23b702da5c86ac07d2d08fd44e8d) after the workaround.

