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
gcloud container clusters create [CLUSTER_NAME] --image-type=ubuntu --zone=[ZONE_NAME]
```

More information about the gcloud command for GKE can be found here: [https://cloud.google.com/kubernetes-engine/docs/clusters/operations](https://cloud.google.com/kubernetes-engine/docs/clusters/operations)

## Add disks to nodes

After your GKE cluster is up, you will need to add disks to each of the nodes. These disks will be used by Portworx to create a storage pool.

You can do this by using the `gcloud compute disks create` and `gcloud compute instances attach-disk` commands as described here [https://cloud.google.com/compute/docs/disks/add-persistent-disk#create_disk](https://cloud.google.com/compute/docs/disks/add-persistent-disk#create_disk)

For example, after you GKE cluster is up, find the compute instances
```
$ gcloud compute instances list
NAME                                   ZONE           MACHINE_TYPE   PREEMPTIBLE  INTERNAL_IP  EXTERNAL_IP      STATUS
gke-px-gke-default-pool-6a9f0154-gxfg  us-east1-b     n1-standard-1               10.142.0.4   104.196.156.231  RUNNING
gke-px-gke-default-pool-6a9f0154-tzj4  us-east1-b     n1-standard-1               10.142.0.3   35.196.233.64    RUNNING
gke-px-gke-default-pool-6a9f0154-vqpb  us-east1-b     n1-standard-1               10.142.0.2   35.196.124.54    RUNNING
```

Then for each instance [create a persistent disk](https://cloud.google.com/sdk/gcloud/reference/compute/disks/create)
```
gcloud compute disks create [DISK_NAME] --size [DISK_SIZE] --type [DISK_TYPE]
```

Once the persistent disks have been created, [attach a disk to each instance](https://cloud.google.com/sdk/gcloud/reference/compute/instances/attach-disk)
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

To overcome this, we can run the PV binder controller as a pod on one of the minions. This controller would be in charge of
listening for new PV claims and binding them. Since this controller would be running on one of the minions it will be able to
communicate with Portworx using the Service and dynamically provision volumes.

## Starting PV binder controller
The PV binder controller pod can be started by using the following spec:

```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: portworx-pvc-controller-account
  namespace: kube-system
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
   name: portworx-pvc-controller-role
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: portworx-pvc-controller-role-binding
subjects:
- kind: ServiceAccount
  name: portworx-pvc-controller-account
  namespace: kube-system
roleRef:
  kind: ClusterRole
  name: portworx-pvc-controller-role
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  annotations:
    scheduler.alpha.kubernetes.io/critical-pod: ""
  labels:
    tier: control-plane
  name: portworx-pvc-controller
  namespace: kube-system
spec:
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
    type: RollingUpdate
  template:
    metadata:
      annotations:
        scheduler.alpha.kubernetes.io/critical-pod: ""
      labels:
        name: portworx-pvc-controller
        tier: control-plane
    spec:
      containers:
      - command:
        - kube-controller-manager
        - --leader-elect=false
        - --address=0.0.0.0
        - --controllers=persistentvolume-binder
        - --use-service-account-credentials=true
        image: gcr.io/google_containers/kube-controller-manager-amd64:v1.7.8
        livenessProbe:
          failureThreshold: 8
          httpGet:
            host: 127.0.0.1
            path: /healthz
            port: 10252
            scheme: HTTP
          initialDelaySeconds: 15
          timeoutSeconds: 15
        name: portworx-pvc-controller-manager
        resources:
          requests:
            cpu: 200m
      hostNetwork: true
      serviceAccountName: portworx-pvc-controller-account
```


To deploy the above pod, save the spec to a file and then apply it using kubectl:
```
curl -o px-pvc-controller.yaml https://docs.portworx.com/scheduler/kubernetes/px-pvc-controller.yaml
# Update the kubernetes version in the image if required
kubectl apply -f px-pvc-controller.yaml
```

Once the spec has been applied, wait for the pod to go to "Running" state:
```
$ kubectl get pods -n kube-system
...
portworx-pvc-controller-2561368997-5s35p              1/1       Running   0          43s
...
```

### Notes
* This spec is for Kubernetes v1.7.8. If you are using another version of Kubernetes please update the tag in the image
     to match that version.

* If encounter cluster role permission issue (```clusterroles.rbac.authorization.k8s.io "portworx-pvc-controller-role" is forbidden```), create clusterrolebinding as below.

```
# get current google identity
$ gcloud info | grep Account
Account: [myname@example.org]
# grant cluster-admin to your current identity
$ kubectl create clusterrolebinding myname-cluster-admin-binding --clusterrole=cluster-admin --user=myname@example.org
Clusterrolebinding "myname-cluster-admin-binding" created
```

After the controller is in Running statue you can [use PV claims to dynamically provision Portworx volumes on GKE](/scheduler/kubernetes/dynamic-provisioning.html).
