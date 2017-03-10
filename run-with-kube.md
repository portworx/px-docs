---
layout: page
title: "Run Converged Kubernetes and Portworx"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk
sidebar: home_sidebar
---
>**Note:**<br/>**This is experimental!**

`px-kube` is a converged Portworx with Kubernetes container image.  You can use this to deploy a joint Kubernetes with Portworx cluster for stateful containers.  There are two modes in which this image runs:

1. Master mode - In this mode, the container comes up as a Kubernetes master node.  This is where the `etcd`, `kube api server`, `kube controller manager` and `kube scheduler` will run.
2. Agent mode - These are the minion nodes and these container instances will run the `kubelet`.  These nodes will join the Kubernetes master nodes.

Note that running these container images will automatically start both Kubernetes and the Portworx components.  The cluster will also automatically configure itself, so there are no extra steps that need to be taken to start using Kubernetes or Portworx.


## Open Ports
The following ports must be opened:

1. ETCD - Port 2379
2. Kubernetes - Port 8080
3. Portworx - Ports 9001 - 9004

## Deploy Kube Master

>**Note:**<br/>**ETCD must NOT be running on the host... px-kube will run etcd internally on port 2379 and this port must be open**

Run the following command on a server that you will designate as the Kubernetes master node.  Note the various `-v` options.  It is critical that the `/var/lib/etcd` is properly mapped to a persistent location.

```
# docker run --restart=always                                     \
      --name kube -d --net=host                                   \
      --privileged=true                                           \
      -v /run/docker/plugins:/run/docker/plugins                  \
      -v /var/lib/osd:/var/lib/osd:shared                         \
      -v /dev:/dev                                                \
      -v /etc/pwx:/etc/pwx                                        \
      -v /opt/pwx/bin:/export_bin:shared                          \
      -v /var/run:/var/run                                        \
      -v /var/cores:/var/cores                                    \
      -v /lib/modules:/lib/modules                                \
      -v /var/lib/etcd:/var/lib/etcd                              \
      -v /etc/kubernetes:/etc/kubernetes                          \
      -v /var/lib/docker:/var/lib/docker                          \
      -v /var/lib/docker:/var/lib/docker                          \
      -v /var/lib/kubelet:/var/lib/kubelet                        \
      -v /sys/fs/cgroup:/sys/fs/cgroup                            \
      portworx/px-kube --kube-master -c MY_CLUSTER_ID -z
```

Note the option `--kube-master`.  This instructs the px-kube container to start as a master node.  Chose a cluster ID for the `-c` option.  The first time this container is started, it will create a **new** cluster with the given cluster ID.  The `-z` option tells Portworx to not allocate any storage on the master node.  This is optional however; you can also request the master node to participate as a storage node by using the `-s /dev/sdb` option.

## Deploy Kube Agent
Run the following command on each server that you want to be a Kubernetes minion node:

```
# docker run --restart=always                                     \
      --name kube -d --net=host                                   \
      --privileged=true                                           \
      -v /run/docker/plugins:/run/docker/plugins                  \
      -v /var/lib/osd:/var/lib/osd:shared                         \
      -v /dev:/dev                                                \
      -v /etc/pwx:/etc/pwx                                        \
      -v /opt/pwx/bin:/export_bin:shared                          \
      -v /var/run:/var/run                                        \
      -v /var/cores:/var/cores                                    \
      -v /lib/modules:/lib/modules                                \
      -v /var/lib/etcd:/var/lib/etcd                              \
      -v /etc/kubernetes:/etc/kubernetes                          \
      -v /var/lib/docker:/var/lib/docker                          \
      -v /var/lib/docker:/var/lib/docker                          \
      -v /var/lib/kubelet:/var/lib/kubelet                        \
      -v /sys/fs/cgroup:/sys/fs/cgroup                            \
      portworx/px-kube --kube-agent -c MY_CLUSTER_ID -km 172.31.8.91 -s /dev/xvdb -s /dev/xvdc
```

Note the option `--kube-agent`.  This instructs the px-kube container to start as a minion node.  It joins the master at the IP specified in the `-km` option.  Specify the storage devices as you would to a regular PX container.

## Test it
To test it, we create a storage class, then create a Kubernetes PVC (persistent volume claim) from that storage class and finally launch a POD with that PVC.

### Create a storage class

Create a file `px-sc.yaml`:

```yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1beta1
metadata:
   name: portworx-io-priority-high
provisioner: kubernetes.io/portworx-volume
parameters:
  repl: "1"
  snap_interval:   "70"
  io_priority:  "high"
```

Now use `kubectl` from the master node to create this class:

```
# /etc/pwx/bin/kubectl create -f px-sc.yaml
```

### Create a PVC

Create a file called `px-pvc.yaml`:

```yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: pvcsc001
  annotations:
    volume.beta.kubernetes.io/storage-class: portworx-io-priority-high
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
```

Use `kubectl` from the master node to create this PVC

```
# /etc/pwx/bin/kubectl create -f px-pvc.yaml
```

### Create a POD

In this test, we will start `mariadb` with  this PVC.  Create a file called `mariadb.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pvpod
spec:
  containers:
  - name: test-db
    image: mariadb
    volumeMounts:
    - name: test-volume
      mountPath: /var/lib/mysql
    env:
      - name: MYSQL_ROOT_PASSWORD
        value: password
  volumes:
  - name: test-volume
    persistentVolumeClaim:
      claimName: pvcsc001
```

Use `kubectl` from the master node to create this POD

```
# /etc/pwx/bin/kubectl create -f mariadb.yaml
```
