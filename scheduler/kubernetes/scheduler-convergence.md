---
layout: page
title: "Run pods on same host as a volume"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk, StatefulSets
sidebar: home_sidebar
---

## Using scheduler convergence
When a pod runs on the same host as its volume, it is known as convergence or hyper-convergence.  Because this configuration reduces the network overhead of an application, performance is typically better.

By modifying your pod spec files you can influence kubernetes to schedule pods on nodes where the volume is located.

### Using pre-provisioned volumes
If you have already created Portworx volumes out of band without using Kubernetes you can still influence the scheduler to schedule a pod on specific set of nodes.

Lets say you created two volumes viz. `vol1` and `vol2`

At this point, when you create a volume, PX will communicate with Kubernetes to place host labels on the nodes that contain a volume's data blocks.
For example:

```
[root@localhost porx]# kubectl --kubeconfig="/root/kube-config.json" get nodes --show-labels

NAME         STATUS    AGE       LABELS
10.0.7.181   Ready     13d       kubernetes.io/hostname=10.0.7.181,vol2=true,vol3=true
10.0.8.108   Ready     12d       kubernetes.io/hostname=10.0.8.108,vol1=true,vol2=true
```

The label `vol1=true` implies that the node hosts volume vol1's data.

### Using PersistentVolumeClaims
If you used Kubernetes's dynamic volume provisioning with Persistent Volume claims, then instead of the volume names, the claim names would
be used as the node labels. Here is a sample PVC

```
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: pvc-high-01
  annotations:
    volume.beta.kubernetes.io/storage-class: portworx-io-high
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 512Gi
```

Once the PVC gets Bound by kubernetes, you will see the following
labels on the node

```
[root@localhost porx]# kubectl --kubeconfig="/root/kube-config.json" get nodes --show-labels

NAME         STATUS    AGE       LABELS
10.0.7.181   Ready     13d       kubernetes.io/hostname=10.0.7.181,pvc-high-01=true
10.0.8.108   Ready     12d       kubernetes.io/hostname=10.0.8.108,
```

### Scheduling Pods and enabling hyperconvergence

You can now use these labels in the `nodeAffinity` section in your Kubernetes pod spec as explained [here](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity)

For example, your pod may look like:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    env: test
spec:
  affinity:
    nodeAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: "pvc-high-01"
            operator: In
            values:
              - "true"
  containers:
  - name: nginx
    image: nginx
    volumeMounts:
    - name: portworx-volume
      mountPath: /data
  volumes:
  - name: portworx-volume
    persistentVolumeClaim:
      claimName: pvc-high-01
```

In the nodeAffinity section we specify the `required` constraint implies that the specified rules must be met for a pod to schedule onto a node.
The key value in the above spec is set to the claim name as the volume being mounted at `/data` is a persistentVolumeClaim. If you are using
a pre-provisioned volume and not a PVC you will replace the key with PV name like `vol1`
