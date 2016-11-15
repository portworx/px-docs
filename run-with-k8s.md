---
layout: page
title: "Run Portworx with Kubernetes"
keywords: portworx, PX-Developer, container, Kubernetes, storage
sidebar: home_sidebar
---
You can use Portworx to implement storage for Kubernetes pods. Portworx pools your servers capacity and turns your servers or cloud instances into converged, highly available compute and storage nodes. This section describes how to deploy PX within a Kubernetes cluster and have PX provide highly available volumes to any application deployed via Kubernetes.

>**Note:**<br/>We are tracking when shared mounts will be allowed within Kubernetes (K8s), which will allow Kubernetes to deploy PX-Developer.

## Step 1: Run the PX container on the Kubernetes host machines.  Portworx can be deployed via K8s directly, or run on each host via docker or systemd directly.

To run the PX container using Docker, run the following command:

```
# sudo docker run --restart=always --name px -d --net=host
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

Once this is run, PX will automatically deploy the K8s volume driver so that you can use PX volumes with any container deployed via K8s.

## Step 2: Include PX as a VolumeSpec in the K8s spec file

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

## Step 3: Include the PX volume as a VolumeMount spec in your container/application

After you specify PX as a volume type in your spec file, you can mount it by including a `volumeMounts` section under the `spec` section. This example shows how you can use it in your container.

``` yaml
spec:
  containers:
  - name: nginx
    image: nginx
    volumeMounts:
    - name: test
      mountPath: /data
```

Be sure to use the same `name` field that you used when defining the volume.

## Summary of steps

1. Run the PX-Developer container using Docker with following command.

```
# sudo docker run --restart=always --name px -d --net=host
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

2. Start your Kubernetes cluster

    ```
$ cd kubernetes
$ hack/local-up-cluster.sh
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

Example pod spec file

```yaml
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

