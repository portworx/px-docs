---
layout: page
title: "Kubernetes Scheduler Convergence"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk
sidebar: home_sidebar
---

## Enabling scheduler convergence
You can configure PX to influence where Kubernetes schedules a container based on the container volume's data location.  When this mode is enabled, PX will communicate with Kubernetes and place host labels.  These labels will be used in influencing Kubernetes scheduling decisions.  To enable this mode, you must add a scheduler directive to the PX configuration as documented below.

### Provide access to kubernetes
A kubernetes.yaml file is needed for allowing PX to communicate with Kubernetes. This configuration file primarily consists of the kubernetes cluster information and the kubernetes master node's IP and port where the kube-apiserver is running. This file needs to be located at 

`/etc/pwx/kubernetes.yaml`

```
# cat /etc/pwx/kubernetes.yaml
```

```yaml
apiVersion: v1
kind: Config
clusters:
- cluster:
    api-version: v1
    server: http://<master-node-ip>:<api-server-port>
    certificate-authority: /etc/pwx/my_cafile
preferences:
  colors: true
```

>**Note: **<br/>The above kubernetes.yaml file is exactly same as the kubelet config file usually named as admin.conf. You need to just copy that file into /etc/pwx/ and rename it to kubernetes.yaml

>**Important:**<br/>You need to provide this kubernetes.yaml file to all the PX nodes.

### Configure PX
Instruct PX to enable the Kubernetes scheduler hooks.  To do this, the PX configuration file needs to specify Kubernetes in the scheduler hook section.  Here is a sample section of PX config.json that has this directive:

```
# cat /etc/pwx/config.json
```

```json
{
    "clusterid": "4420f99f-a068-11e6-8688-0242ac110004",
    "kvdb": [
        "etcd://etcd.mycompany.com:4001"
    ],
    "scheduler": "kubernetes",
    "storage": {
        "devices": [
            "/dev/sdb"
        ]
    }
}
``` 

Note the specific directive:  `"scheduler": "kubernetes"`

Alternatively, you can also pass in the scheduler directive via the PX command line as follows:

```
# sudo docker run --restart=always --name px -d --net=host  \
    --privileged=true                                       \
    -v /run/docker/plugins:/run/docker/plugins              \
    -v /var/lib/osd:/var/lib/osd:shared                     \
    -v /dev:/dev                                            \
    -v /etc/pwx:/etc/pwx                                    \
    -v /opt/pwx/bin:/export_bin                             \
    -v /var/run/docker.sock:/var/run/docker.sock            \
    -v /var/cores:/var/cores                                \
    -v /var/lib/kubelet:/var/lib/kubelet:shared             \
    -v /usr/src:/usr/src                                    \
    -v /lib/modules:/lib/modules                            \
    portworx/px-dev:latest -daemon -k etcd://myetc.company.com:4001 -c MY_CLUSTER_ID -s /dev/sdb -x kubernetes
```

Note the flag `-x kubernetes`

### Using pre-provsioned volumes
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
      requiredDuringSchedulingIgnoredDuringExecution:
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
