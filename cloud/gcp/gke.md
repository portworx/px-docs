---
layout: page
title: "Dynamic Provisioning on Google Kubernetes Engine (GKE)"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, pv, persistent disk, gke, gce
sidebar: home_sidebar
---

* TOC
{:toc}

The steps below will help you enable dynamic provisioning of Portworx volumes in your Google Kurbenetes Engine (GKE) cluster.

## Create GKE cluster
Portworx is supported on GKE provisioned on [Ubuntu Node Images](https://cloud.google.com/kubernetes-engine/docs/node-images).

You can create a 3 node GKE cluster with the gcloud cli using the following command:
```
$ gcloud container clusters create [CLUSTER_NAME] --image-type=ubuntu --zone=[ZONE_NAME]
```

You can set the default cluster with the following command:
```
$ gcloud container clusters get-credentials [CLUSTER_NAME] --zone=[ZONE_NAME]
Fetching cluster endpoint and auth data.
kubeconfig entry generated for gke-cluster-01.
```

More information about the gcloud command for GKE can be found here: [https://cloud.google.com/kubernetes-engine/docs/clusters/operations](https://cloud.google.com/kubernetes-engine/docs/clusters/operations).

## Add disks to nodes

After your GKE cluster is up, you will need to add disks to each of the nodes. These disks will be used by Portworx to create a storage pool.

You can do this by using the `gcloud compute disks create` and `gcloud compute instances attach-disk` commands as described here [https://cloud.google.com/compute/docs/disks/add-persistent-disk#create_disk](https://cloud.google.com/compute/docs/disks/add-persistent-disk#create_disk).

For example, after you GKE cluster is up, find the compute instances:
```
$ gcloud compute instances list
NAME                                   ZONE           MACHINE_TYPE   PREEMPTIBLE  INTERNAL_IP  EXTERNAL_IP      STATUS
gke-px-gke-default-pool-6a9f0154-gxfg  us-east1-b     n1-standard-1               10.142.0.4   104.196.156.231  RUNNING
gke-px-gke-default-pool-6a9f0154-tzj4  us-east1-b     n1-standard-1               10.142.0.3   35.196.233.64    RUNNING
gke-px-gke-default-pool-6a9f0154-vqpb  us-east1-b     n1-standard-1               10.142.0.2   35.196.124.54    RUNNING
```

Then for each instance [create a persistent disk](https://cloud.google.com/sdk/gcloud/reference/compute/disks/create):
```
gcloud compute disks create [DISK_NAME] --size [DISK_SIZE] --type [DISK_TYPE]
```

Once the persistent disks have been created, [attach a disk to each instance](https://cloud.google.com/sdk/gcloud/reference/compute/instances/attach-disk):
```
gcloud compute instances attach-disk [INSTANCE_NAME] --disk [DISK_NAME]
```

## Install Portworx

Once your GKE cluster is online and you have attached persistent disks to your nodes, install Portworx using the [Kubernetes install guide](/scheduler/kubernetes/install.html).

## Dynamic provisioner on GKE
Dynamic provisioning of volumes in Kubernetes is done through the Persistent Volume (PV) binder controller running on the
master nodes. This controller communicates with Portworx running on minions using a Kubernetes Service. But these Services
are not accessible from the master nodes in GKE. Due to this the PV binder contoller can not communicate with Portworx
running on the minions.

To overcome this, we need to run the PV binder controller as a pod on one of the minions. This controller would
listen for new PV claims and bind them. Since this controller is running on one of the minions it is able to
communicate with Portworx using the Service and 
[dynamically provision volumes](/scheduler/kubernetes/dynamic-provisioning.html).

### Starting PV binder controller
If you used the Web HTML form at [https://install.portworx.com](https://install.portworx.com) to build your YAML spec, please make sure to specify the exact Kubernetes server version (ie. `kbver=1.8.4-gke.0`). You can get the Kubernetes server version from the GKE console as well as by running `kubectl version`.

In this case, the generated YAML will contain all the necessary configuration (including the [PV binder controller](https://docs.portworx.com/scheduler/kubernetes/px-pvc-controller.yaml)), and you will not need to deploy the PV binder controller manually.

#### Manual deployment of PV binder controller pod
To deploy the PV binder controller pod manually, save [the PV binder controller spec](https://docs.portworx.com/scheduler/kubernetes/px-pvc-controller.yaml) to a file and then apply it using kubectl:

```
$ curl -o px-pvc-controller.yaml \
    https://docs.portworx.com/scheduler/kubernetes/px-pvc-controller.yaml

# Update the kubernetes versions in the spec (if required)
$ vi px-pvc-controller.yaml

$ kubectl apply -f px-pvc-controller.yaml
```

Once the spec has been applied, please validate that the pod has reached "Running" state:

```
$ kubectl get pods -n kube-system
NAME                                      READY     STATUS    RESTARTS   AGE
...
portworx-pvc-controller-2561368997-5s35p  1/1       Running   0          43s
...
```

## Troubleshooting Notes

* The `kubectl apply ...` command fails with "forbidden" error:
   - If you encounter an error with the cluster role permission (```clusterroles.rbac.authorization.k8s.io "portworx-pvc-controller-role" is forbidden```), create a ClusterRoleBinding for your user using the following commands:

   ```
   # get current google identity
   $ gcloud info | grep Account
   Account: [myname@example.org]

   # grant cluster-admin to your current identity
   $ kubectl create clusterrolebinding myname-cluster-admin-binding \
      --clusterrole=cluster-admin --user=myname@example.org
   Clusterrolebinding "myname-cluster-admin-binding" created
   ```

* The `kubectl apply ...` command fails with "error validating":
   - This likely happened because of a version discrepancy between the "kubectl" client and Kubernetes backend server (ie. using "kubectl" v1.8.4 to apply spec to Kubernetes server v1.6.13-gke.0).
   - To fix this, you can either:
      1. Downgrade the "kubectl" version to match your server's version, or
      2. Reapply the spec with client-validation turned off,  e.g.:<br/>`kubectl apply --validate=false ...`

* GKE instances under certain scenarios do not automatically re-attach the persistent disks used by PX.
   - Under the following scenarios, GKE will spin up a new VM as a replacement for older VMs with the same node name: 
      * Halting a VM in GKE cluster
      * Upgrading GKE between different kubernetes version
      * Increasing the size of the node pool
   - However, in these cases the previously attached persistent disks will not be re-attached automatically.
   - Currently you will have to manually re-attach the persistent disk to the new VM and then restart portworx on that node.

If you face any issues with GKE, reach out to us on [slack](http://slack.portworx.com).
