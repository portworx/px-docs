---
layout: page
title: "Run pods converged with data volumes"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, flexvol, pv, pv claim, persistent disk
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
    -v /usr/libexec/kubernetes/kubelet-plugins/volume/exec/px~flexvolume:/export_flexvolume:shared \
    -v /var/run/docker.sock:/var/run/docker.sock            \
    -v /var/cores:/var/cores                                \
    -v /var/lib/kubelet:/var/lib/kubelet:shared             \
    -v /usr/src:/usr/src                                    \
    -v /lib/modules:/lib/modules                            \
    portworx/px-dev:latest -daemon -k etcd://myetc.company.com:4001 -c MY_CLUSTER_ID -s /dev/sdb -x kubernetes
```

Note the flag `-x kubernetes`

At this point, when you create a volume, PX will communicate with Kubernetes to place host labels on the nodes that contain a volume's data blocks.
For example:

```
[root@localhost porx]# kubectl --kubeconfig="/root/kube-config.json" get nodes --show-labels

NAME         STATUS    AGE       LABELS
10.0.7.181   Ready     13d       kubernetes.io/hostname=10.0.7.181,vol2=true,vol3=true
10.0.8.108   Ready     12d       kubernetes.io/hostname=10.0.8.108,vol1=true,vol2=true
```

The label `vol1=true` implies that the node hosts volume vol1's data.

You can now use these labels as `nodeSelector` fields in your Kubernetes pod spec as explained [here](http://kubernetes.io/docs/user-guide/node-selection/).

For example, your pod may look like:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    env: test
spec:
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent
  nodeSelector:
    <vol-id>: "true"
  volumes:
  - name: test
    flexVolume:
      driver: "px/flexvolume"
      fsType: "ext4"
      options:
        volumeID: "<vol-id>"
        size: "<vol-size>"
        osdDriver: "pxd"
```

Note the new section called nodeSelector.

Read on for detailed instructions on running stateful services on Kubernetes.

* [Install PX into an Kubernetes 1.6 cluster]()
* [Force Kubernetes to schedule pods on hosts with your data](/kubernetes-convergence.html)
* [Create Kubernetes Storage Class](/kubernetes-define-storage-class.html)
* [Using pre-provisioned volumes with Kubernetes](/kubernetes-preprovisioned-volumes.html)
* [Dynamically provision volumes with Kubernetes](/kubernetes-dynamically-provisioned-volumes.html)
* [Using Stateful sets](/kubernetes-stateful-sets.html)
* [Running a pod from a snapshot](/kubernetes-running-a-pod-from-snapshot.html)
* [Failover a database using Kubernetes](kubernetes-database-failover.html)
* [Install PX on Kubernetes < 1.6](/kubernetes-run-with-flexvolume.html)
* [Cost calculator for converged container cluster using Kubernetes and Portworx](kubernetes-infrastructure-cost-calculator.html)

