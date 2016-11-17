---
layout: page
title: "Run Portworx with Kubernetes"
keywords: portworx, PX-Developer, container, Kubernetes, storage
sidebar: home_sidebar
---
You can use Portworx to implement storage for Kubernetes pods. Portworx pools your servers capacity and turns your servers or cloud instances into converged, highly available compute and storage nodes. This section describes how to deploy PX within a Kubernetes cluster and have PX provide highly available volumes to any application deployed via Kubernetes.

>**Note:**<br/>We are tracking when shared mounts will be allowed within Kubernetes (K8s), which will allow Kubernetes to deploy PX-Developer.

## Step 1: Run the PX container

Portworx can be deployed via K8s directly, or run on each host via docker or systemd directly.

To run the PX container using Docker, run the following command:

For CentOS

```
# sudo docker run --restart=always --name px -d --net=host
    --privileged=true \
    -v /run/docker/plugins:/run/docker/plugins \
    -v /var/lib/osd:/var/lib/osd:shared \
    -v /dev:/dev \
    -v /etc/pwx:/etc/pwx \
    -v /opt/pwx/bin:/export_bin \
    -v /usr/libexec/kubernetes/kubelet-plugins/volume/exec/px~flexvolume:/export_flexvolume:shared \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /var/cores:/var/cores \
    -v /var/lib/kubelet:/var/lib/kubelet:shared \
    --ipc=host \
    portworx/px-dev:latest
```

For CoreOS

```
sudo docker run --restart=always --name px -d --net=host \
  --privileged=true                             \
  -v /run/docker/plugins:/run/docker/plugins    \
  -v /var/lib/osd:/var/lib/osd:shared           \
  -v /dev:/dev                                  \
  -v /etc/pwx:/etc/pwx                          \
  -v /opt/pwx/bin:/export_bin:shared            \
  -v /var/run/docker.sock:/var/run/docker.sock  \
  -v /var/cores:/var/cores                      \
  -v /lib/modules:/lib/modules                  \
  -v /etc/kubernetes/kubelet-plugins/volume/exec/px~flexvolume/:/export_flexvolume:shared \
  --ipc=host                                    \
  portworx/px-dev:latest
```

Once this is run, PX will automatically deploy the K8s volume driver so that you can use PX volumes with any container deployed via K8s.

## Step 2: Deploy Kubernetes

Start the K8s cluster. One way to start K8s for single node local setup is using the local-up-cluster.sh startup script in kubernetes source code.

```
# cd kubernetes
# hack/local-up-cluster.sh
```

Set your cluster details.

```
# cluster/kubectl.sh config set-cluster local --server=http://127.0.0.1:8080 --insecure-skip-tls-verify=true
# cluster/kubectl.sh config set-context local --cluster=local
# cluster/kubectl.sh config use-context local
```

Set the K8s volume plugin directory

By default the K8s volume plugin directory is "/usr/libexec/kubernetes/kubelet-plugins/volume/exec". If you are starting kubelet service by hand then make sure that you set the --volume-plugin-dir correctly. This is the directory where kubelet tries to search for portworx's volume driver. Example kubelet commands:

For CentOS

```
kubelet-wrapper \
  --api-servers=http://127.0.0.1:8080 \
  --network-plugin-dir=<network-plugin-dir> \
  --network-plugin= <network-plugin-name>\
  --volume-plugin-dir=/usr/libexec/kubernetes/kubelet-plugins/volume/exec \
  --allow-privileged=true \
  --config=/etc/kubernetes/manifests \
  --hostname-override=<hostname> \
  --cluster-dns=<cluster-dns> \
  --cluster-domain=cluster.local
```

For CoreOS

```
kubelet-wrapper \
  --api-servers=http://127.0.0.1:8080 \
  --network-plugin-dir=<network-plugin-dir> \
  --network-plugin= <network-plugin-name>\
  --volume-plugin-dir=/etc/kubernetes/kubelet-plugins/volume/exec/ \
  --allow-privileged=true \
  --config=/etc/kubernetes/manifests \
  --hostname-override=<hostname> \
  --cluster-dns=<cluster-dns> \
  --cluster-domain=cluster.local
```
  
* Note that the volume-plugin-dir is provided as a shared mount option in the docker run command for PX container.

## Step 3: Include PX as a VolumeSpec

Include PX as a volume spec in the K8s spec file.

Under the `spec` section of your spec yaml file, add a `volumes` section.  For example:

``` yaml
spec:
  volumes:
    - name: test
      flexVolume:
        driver: "px/flexvolume"
        fsType: "ext4"
        options:
          volumeID: "615055680017358399"
          size: "1G"
          osdDriver: "pxd"
```

* Set the driver name to `px/flexvolume`.
* Specify the unique ID for the volume created in the PX-Developer container as the `volumeID` field.
* Always set `osdDriver` to `pxd`. It indicates that the Flexvolume should use the px driver for managing volumes.

## Step 4: Try it with NGINX

After you specify PX as a volume type in your spec file, you can mount it by including a `volumeMounts` section under the `spec` section. This example shows how you can use it with nginx.

Example pod spec file

``` yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-px
spec:
  containers:
  - name: nginx
    image: nginx
    volumeMounts:
    - name: test
      mountPath: <vol-mount-path>
    ports:
    - containerPort: 80
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
Be sure to use the same `name` field that you used when defining the volume.

Now you can run the nginx pod:

```
# ./kubectl create -f nginx-pxd.yaml
```
