---
layout: page
title: "Upgrade Portworx on Kubernetes"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk
sidebar: home_sidebar
---

* TOC
{:toc}

This guide describes the procedure how to upgrade Portworx in Kubernetes environment as OCI container, which is the default and recommended method of running Portworx in Kubernetes.


>**IMPORTANT:**<br/>We do not recommend upgrading Portworx using [Kubernetes instructions](https://kubernetes.io/docs/tasks/manage-daemon/update-daemon-set/) (e.g. via `kubectl set image ds/portworx portworx=portworx/XXXX:### -n kube-system`).<br/>
>Instead, please follow the instructions below for best practice how to upgrade Portworx in Kubernetes environment.


## Upgrading Portworx

The Portworx Daemonset is using `RollingUpdate` update strategy, which greatly simplifies the upgrade process.

### Step 1) Apply updated YAML-spec

The upgrade Portworx, we will just have to re-apply the YAML spec-file generated from the [install.portworx.com](http://install.portworx.com) site, which is very similar to how we [installed Portworx](/scheduler/kubernetes/install.html#install).


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

<U>Rollout status</U>:<br/>
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

<U>Pods status</U>:<br/>
To get more information about the status of Portworx daemonset across the nodes, run:

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
* looking at AGE, we can tell that:
   - "minion4" and "minion5" have Portworx up for 16 days (likely still on old version, and to be upgraded), while the
   - "minion3" has Portworx up for only 5 minutes (likely just upgraded and restarted)
* if we keep on monitoring, we will observe that the upgrade will not switch to the "next" node until STATUS is "Running" and the READY is 1/1 (meaning, the "readynessProbe" reports Portworx service is fully up).

<U>Portworx cluster list</U>:<br/>
Finally, one can run the following command to inspect the Portworx cluster:

```
$ px_pod=$(kubectl get pods -n kube-system -l name=portworx -o jsonpath='{.items[0].metadata.name}')
$ kubectl exec -it $px_pod -n kube-system /opt/pwx/bin/pxctl status

[...]
Nodes in the cluster:
ID      DATA IP         CPU             MEM TOTAL       MEM FREE        CONTAINERS      VERSION                 STATUS
minion5 192.168.56.74   1.530612        4.0 GB          3.1 GB          N/A             1.2.11.4-3598f81        Online
minion4 192.168.56.73   3.836317        4.0 GB          3.0 GB          N/A             1.2.11.4-3598f81        Online
minion3 192.168.56.72   3.324808        4.1 GB          3.3 GB          N/A             1.2.11.9-8aa25b7        Online
minion2 192.168.56.71   3.316327        4.1 GB          3.2 GB          N/A             1.2.11.9-8aa25b7        Online
```
* from the output above, we can confirm that the:
   - "minion4" and "minion5" are still on the old Portworx version (1.2.11.4), while
   - "minion3" and "minion2" have already been upgraded to the latest version (in our case, v1.2.11.9).


## Migrating from Legacy Portworx

The legacy Portworx installations (v1.2.10 and older) have been deploying as PX-Containers Kubernetes daemonsets (i.e. Portworx running directly as Docker container), but since then we have changed the deployments as via [OCI runC](/runc/runc/index.html), which eliminates cyclical dependancies, speeds up service restarts, and brings other improvements.

There are no special instructions required to migrate your old PX-Container into the latest OCI runC Daemonset - please follow the instructions listed [above](#upgrading-portworx) to generate a new YAML spec-file, reapply it on your Kubernetes cluster, and this will automatically migrate Portworx to OCI containers deployment.


>**NOTE**:<br/>Since Portworx v1.2.11 installing PX-Containers as Kubernetes daemonset is no longer recommended.  If you are looking for legacy instructions how to manually upgrade and retain PX-Container deployment, you can find them [here](/scheduler/kubernetes/upgrade-legacy.html).
