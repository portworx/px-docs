---
layout: page
title: "Run Portworx with Kubernetes"
sidebar: home_sidebar
---
You can use Portworx to implement storage for Kubernetes pods. Portworx pools your servers' capacity and is deployed as a container. This section describes how to install PX-Developer on each server.

>**Note:**<br/>We are tracking when shared mounts will be allowed within Kubernetes (K8s), which will allow Kubernetes to deploy PX-Developer.

## Step 1: Run the PX-Developer container outside of Kubernetes

Run the PX-Developer container using Docker with following command:

```
$ docker run --restart=always --name px-dev -d --net=host
--privileged=true \
-v /run/docker/plugins:/run/docker/plugins \
-v /var/lib/osd:/var/lib/osd \
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

## Step 2: Install the Flexvolume Binary on all Kubernetes nodes

Flexvolume allows other volume drivers outside of Kubernetes to
attach, detach, mount, and unmount custom volumes to pods, daemonsets, and rcs.

When you run the PX-Developer container on a Kubernetes node, it automatically
installs the Flexvolume binary at the required path and is ready to use.

## Step 3: Include PX Flexvolume as a VolumeSpec in the Kubernetes spec file

Under the `spec` section of your spec yaml file, add a `volumes` section.

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
* Specify the unique ID for the volume created in the PX-Developer container as
the `volumeID` field.
* Always set `osdDriver` to `pxd`. It indicates that the Flexvolume
should use the px driver for managing volumes.

## Step 4: Include the Flexvolume as a VolumeMount spec in your container/application

After you specify Flexvolume as a volume type in your spec
file, you can mount it by including a `volumeMounts` section under the `spec` section. This example shows how you can use it in your container.

``` yaml
spec:
  containers:
  - name: nginx
    image: nginx
    securityContext:
      privileged: true
    volumeMounts:
    - name: test
      mountPath: /data
```

Be sure to use the same `name` field that you used when defining the volume.

## Step 5: Run the Kubernetes cluster in privileged mode

* To share the namespace between the host, PX-Developer container,
  and your Kubernetes pod instance, you must run the cluster with
  privileges. You can do that by setting the environment variable
  `ALLOW_PRIVILEGED` equal to `true`.
* Share the host path `/var/lib/kubelet` with the PX-Developer container and
  your pods. The Docker run command for PX-Developer shares this
  path. To share it within your pod, add a new `hostPath` type
  volume and a corresponding `volumeMount` in your spec file.

```yaml
spec:
  containers:
    volumeMounts:
    - name: lib
      mountPath: /var/lib/kubelet
  volumes:
    - name: lib
      hostPath:
        path: /var/lib/kubelet

```

## Summary of steps

1. Run the PX-Developer container using Docker with following command.

   ```
$ docker run --restart=always --name px-dev -d --net=host
--privileged=true \
-v /run/docker/plugins:/run/docker/plugins \
-v /var/lib/osd:/var/lib/osd \
-v /dev:/dev \
-v /etc/pwx:/etc/pwx \
-v /opt/pwx/bin:/export_bin \
-v /usr/libexec/kubernetes/kubelet-plugins/volume/exec/px~flexvolume:/export_flexvolume:shared \
-v /var/run/docker.sock:/var/run/docker.sock \
-v /var/cores:/var/cores \
-v /var/lib/kubelet:/var/lib/kubelet:shared \
--ipc=host \
-p 9001:9001 \
-p 9007:9007 \
-p 9008:9008 \
-p 2345:2345 \
portworx/px-dev:latest
```

2. Start your Kubernetes cluster in privileged mode.

    ```
$ cd kubernetes
$ ALLOW_PRIVILEGED=true hack/local-up-cluster.sh
```

3. Set your cluster details.

   ```
$ cluster/kubectl.sh config set-cluster local --server=http://127.0.0.1:8080 --insecure-skip-tls-verify=true
$ cluster/kubectl.sh config set-context local --cluster=local
$ cluster/kubectl.sh config use-context local
```

4. Run your pod.

    ```
$ ./kubectl create -f nginx-pxd.yaml
```
