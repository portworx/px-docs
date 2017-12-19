---
layout: page
title: "Upgrade Portworx on Kubernetes"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk
sidebar: home_sidebar
---

* TOC
{:toc}

This guide describes the procedure how to upgrade Portworx in Kubernetes environment as OCI container, which is the default and recommended method of running Portworx in Kubernetes.

We assume you have deployed Portworx as [Kubernetes Daemonset](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/) using instructions provided at our [install page](/scheduler/kubernetes/install.html).


>**IMPORTANT:**<br/>We do not recommend upgrading Portworx using [Kubernetes instructions](https://kubernetes.io/docs/tasks/manage-daemon/update-daemon-set/) (e.g. via `kubectl set image ds/portworx portworx=portworx/XXXX:### -n kube-system`).<br/>
>Instead, whenever possible, we recommend using the [install.portworx.com](http://install.portworx.com) site to generate latest recommended YAML-spec, and re-apply the spec to upgrade Portworx.


>**NOTE**: This procedure will also automatically migrate all legacy PX-Container deployments into the OCI containers.  If you are looking for legacy instructions how to upgrade PX-Container deployments, you can find them [here](/scheduler/kubernetes/upgrade-legacy.html).


## Upgrading PX-OCI

The PX-OCI Daemonset is using `RollingUpdate` update strategy, which greatly simplifies the upgrade process.

### Step 1) Apply updated YAML-spec

The upgrade the PX-OCI, we will just have to re-apply the YAML spec-file generated from the [install.portworx.com](http://install.portworx.com) site.  The same applies if we want to migrate from the deprecated PX-Container to the recommended PX-OCI daemonset.


**OPTION a)**:<br/>
If you have the original URL that you used to generate your first YAML-spec, you can just download and reapply the updated YAML-spec from the same URL, e.g.:<br/>`kubectl apply -f '<original http://install.portworx.com/... url>'`.



**OPTION b)**:<br/>
If you did not preserve the original installation URL, not to worry, in most cases the configuration is very easy to reconstruct using your current Kubernetes configuration, like so:

```
$ kubectl get ds/portworx -n kube-system \
  -o jsonpath='{.spec.template.spec.containers[*].args}'

[-k etcd:http://etcd1.acme.net:2379,etcd:http://etcd2.acme.net:2379 \
 -c cluster123 -s /dev/sdb1 -s /dev/sdc -x kubernetes]
```
* you can ignore the '-x kubernetes' parameter (will be applied by default), also
* if you were using separate devices, you will need to collapse multiple "-s dev1 -s dev2 ..." into a single parameter "s=dev1,dev2"

You can re-enter the parameters on the YAML web-form at [install.portworx.com](http://install.portworx.com), or convert them manually.
The final YAML-spec from our example above would look similar to this:

```bash
VER=$(kubectl version --short | awk -Fv '/Server Version: /{print $3}')
curl -o oci-spec.yaml \
   'http://install.portworx.com?c=cluster123&k=etcd:http://etcd1.acme.net:2379,etcd:http://etcd2.acme.net:2379&s=/dev/sdb1,/dev/sdc&kbver=$VER'
kubectl apply -f oci-spec.yaml
```



Once you have applied the new YAML-spec, Kubernetes will start applying the Portworx upgrade in a "RollingUpdate" fashion, one node at a time.


### Step 2) Monitor the rolling upgrade

<U>ROLLOUT STATUS</U>:<br/>
One can monitor the upgrade process by running the "kubectl rollout status" command:

```
$ kubectl rollout status ds/portworx -n kube-system
Waiting for rollout to finish: 0 out of 4 new pods have been updated...
Waiting for rollout to finish: 1 out of 4 new pods have been updated...
Waiting for rollout to finish: 2 out of 4 new pods have been updated...
Waiting for rollout to finish: 3 out of 4 new pods have been updated...
Waiting for rollout to finish: 3 of 4 updated pods are available...
daemon set "portworx" successfully rolled out
```

Note that this command will inform us of general upgrade progress, but it will not point on which exact node is being upgraded and when.

<U>NODES PORTWORX PODS STATUS</U>:<br/>
To get more information about the status of Portworx daemonset across the nodes, we can run the following command:

```
$ kubectl get pods -o wide -n kube-system -l name=portworx
NAME             READY     STATUS              RESTARTS   AGE       IP              NODE
portworx-9njsl   1/1       Running             0          16d       192.168.56.73   minion4
portworx-fxjgw   1/1       Running             0          16d       192.168.56.74   minion5
portworx-fz2wf   1/1       Running             0          5m        192.168.56.72   minion3
portworx-x29h9   0/1       ContainerCreating   0          0s        192.168.56.71   minion2
```

As we can see in the example output above:

* looking at the STATUS/READY, we can tell that the rollout-upgrade is currently creating the container on the "minion2" node
* looking at AGE, we can tell that
	* "minion4" and "minion5" have Portworx up for 16 days (likely still on old version, and to be upgraded), while the
	* "minion3" has Portworx up for only 5 minutes (likely just upgraded and restarted)
* if we keep on monitoring, we will observe that the upgrade will not switch to the "next" node until STATUS is "Running" and the READY is 1/1 (meaning, the "readynessProbe" reports Portworx service is fully up).

<U>PORTWORX CLUSTER LIST</U>:<br/>
Finally, one can also run the following command to inspect the Portworx cluster:

```
minion1$ /opt/pwx/bin/pxctl cluster list
[...]
Nodes in the cluster:
ID      DATA IP         CPU             MEM TOTAL       MEM FREE        CONTAINERS      VERSION                 STATUS
minion5 192.168.56.74   1.530612        4.0 GB          3.1 GB          N/A             1.2.11.4-3598f81        Online
minion4 192.168.56.73   3.836317        4.0 GB          3.0 GB          N/A             1.2.11.4-3598f81        Online
minion3 192.168.56.72   3.324808        4.1 GB          3.3 GB          N/A             1.2.11.9-8aa25b7        Online
minion2 192.168.56.71   3.316327        4.1 GB          3.2 GB          N/A             1.2.11.9-8aa25b7        Online
```
* from the output above, we can confirm that the
	* "minion4" and "minion5" are still on the old Portworx version (1.2.11.4), while
	* "minion3" and "minion2" have already been upgraded to the latest version (in our case, v1.2.11.9).


## Migrating PX-Container to PX-OCI daemonset

There are no special instructions required to migrate your old PX-Container into the latest PX-OCI Daemonset - please follow the instructions listed at [Upgrading PX-OCI](#upgrading-px-oci) to generate a new YAML spec-file using [install.portworx.com](http://install.portworx.com).