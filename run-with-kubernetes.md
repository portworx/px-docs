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

```
# sudo docker run --restart=always --name px -d --net=host \
    --privileged=true                             \
    -v /run/docker/plugins:/run/docker/plugins    \
    -v /var/lib/osd:/var/lib/osd:shared           \
    -v /dev:/dev                                  \
    -v /etc/pwx:/etc/pwx                          \
    -v /opt/pwx/bin:/export_bin                   \
    -v /usr/libexec/kubernetes/kubelet-plugins/volume/exec/px~flexvolume:/export_flexvolume:shared \
    -v /var/run/docker.sock:/var/run/docker.sock  \
    -v /var/cores:/var/cores                      \
    -v /var/lib/kubelet:/var/lib/kubelet:shared   \
    -v /usr/src:/usr/src                          \
    -v /lib/modules:/lib/modules                  \
    --ipc=host                                    \
    portworx/px-dev:latest -daemon -k etcd://myetc.company.com:2379 -c MY_CLUSTER_ID -s /dev/sdb -s /dev/sdc
```

Once this is run, PX will automatically deploy the K8s volume driver so that you can use PX volumes with any container deployed via K8s.

## Step 2: Deploy Kubernetes

* Start the K8s cluster. 

One way to start K8s for single node local setup is using the local-up-cluster.sh startup script in kubernetes source code.

```
# cd kubernetes
# hack/local-up-cluster.sh
```

### Set your cluster details.

```
# cluster/kubectl.sh config set-cluster local --server=http://127.0.0.1:8080 --insecure-skip-tls-verify=true
# cluster/kubectl.sh config set-context local --cluster=local
# cluster/kubectl.sh config use-context local
```

### Set the K8s volume plugin directory

By default the K8s volume plugin directory is "/usr/libexec/kubernetes/kubelet-plugins/volume/exec". If you are starting kubelet service by hand then make sure that you set the --volume-plugin-dir correctly. This is the directory where kubelet tries to search for portworx's volume driver. Example kubelet commands:

For CentOS

```
kubelet-wrapper \
  --api-servers=http://127.0.0.1:8080 \
  --network-plugin-dir=<network-plugin-dir> \
  --network-plugin=<network-plugin-name>\
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
  --network-plugin=<network-plugin-name>\
  --volume-plugin-dir=/etc/kubernetes/kubelet-plugins/volume/exec/ \
  --allow-privileged=true \
  --config=/etc/kubernetes/manifests \
  --hostname-override=<hostname> \
  --cluster-dns=<cluster-dns> \
  --cluster-domain=cluster.local
```
  
* Note that the volume-plugin-dir is provided as a shared mount option in the docker run command for PX container.

## Try it out with NGINX

To use PX with your applications deployed via Kubernetes, include PX as a volume spec in the K8s spec file.

Under the `spec` section of your spec yaml file, add a `volumes` section.  For example:

```yaml
spec:
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

* Set the driver name to `px/flexvolume`.
* Specify the unique ID for the volume created in the PX-Developer container as the `volumeID` field.
* Always set `osdDriver` to `pxd`. It indicates that the Flexvolume should use the px driver for managing volumes.

After you specify PX as a volume type in your spec file, you can mount it by including a `volumeMounts` section under the `spec` section. This example shows how you can use it with nginx.

Example pod spec file for NGINX

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

## Enabling scheduler convergence

You can configure PX to influence where Kubernetes schedules a container based on the container volume's data location.  When this mode is enabled, PX will communicate with Kubernetes and place host labels.  These labels will be used in influencing Kubernetes scheduling decisions.  To enable this mode, you must add a scheduler directive to the PX configuration as documented below.

### Provide access to kubernetes

A kubernetes.yaml file is needed for allowing PX to communicate with Kubernetes. This configuration file primarily consists of the kubernetes cluster information and the kubernetes master node's IP and port where the kube-apiserver is running. This file needs to be located at 

`/etc/pwx/kubernetes.yaml`

```
# cat /etc/pwx/kubernetes.yaml
```

``` yaml
apiVersion: v1
kind: Config
clusters:
- cluster:
    api-version: v1
    server: http://<master-node-ip>:<api-server-port>
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
    --ipc=host                                              \
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

Note the new section called nodeSelector

## PersistentVolumeClaims

A Kubernetes PersistentVolume is basically a PX volume provisioned by an administrator.  A PersistentVolumeClaim on the other hand is a request for storage which is bound to an available PersistentVolume based on matching the claim's specifications.

Here is an example of a PX volume and a corresponding PersistentVolume spec

```
$ /opt/pwx/bin/pxctl volume list
ID	    NAME		SIZE	HA	SHARED	ENCRYPTED	COS		        STATUS
41724	pv-pwx-vol	1 GiB	1	no	    no		    COS_TYPE_LOW	up - detached
```

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-pwx
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Recycle
  flexVolume:
    driver: "px/flexvolume"
    fsType: "ext4"
    options:
      volumeID: "pv-pwx-vol"
      size: "1G"
      osdDriver: "pxd"
```

You can create a PersistentVolume using the following kubernetes command

```
$ kubectl create -f pv.yaml
persistentvolume "pv-pwx" created

$ kubectl get pv
NAME       CAPACITY   ACCESSMODES   STATUS      CLAIM                   REASON    AGE
pv-pwx     1Gi        RWO           Available                                     7s
```

The status for the above PersistentVolume shows as Available and it can be bound to any matching PersistentVolumeClaim. Here is an example of a PersistentVolumeClaim spec

```yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: pv-claim
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

The above spec describes a volume claim with a request for storage of size 1Gi. You can create a PersistentVolumeClaim using the following command

```
$ kubectl create -f pv-claim.yaml
persistentvolumeclaim "pv-claim" created

$ kubectl get pvc
NAME            STATUS    VOLUME     CAPACITY   ACCESSMODES   AGE
pv-claim        Bound     pv-pwx     1Gi        RWO           5s

$ kubectl get pv
NAME       CAPACITY   ACCESSMODES   STATUS    CLAIM                   REASON    AGE
pv-pwx     1Gi        RWO           Bound     default/pv-claim                  4m
[root@osboxes kubernetes]#
```

The PersistentVolumeClaim for 1Gi gets matched with the existing PersistentVolume of size 1Gi. Both the Volume and the Claim are now "Bound" to each other. Now you can use this PersistentVolumeClaim in your pod spec file as a Volume. Here is an example of such a pod spec file

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pvc-pwx
spec:
  containers:
  - name: nginx
    image: nginx
    volumeMounts:
    - name: pwx-vol
      mountPath: /data
    ports:
    - containerPort: 80
  volumes:
  - name: pwx-vol
    persistentVolumeClaim:
      claimName: pv-claim
```

## Using PetSets

In Kubernetes pods are treated as stateless units, and if one of them is unhealthy or gets superseded by a newer version, the system just disposes it. Replication controllers provide some sort of a weak guarantee that 'N' set of pods will be kept running at a time.

In contrast a PetSet, is a group of stateful pods that are backed by a strong notion of identity. Kubernetes refers to such group of pods as 'clustered applications'. Traditionally clustered applications are deployed by leveraging the fact that nodes are stable and long-lived entities with persistent storage and static ips. The goal of PetSets is to decouple this dependency and assign identites to individual instances of applications irrespective of the underlying physical infrastructure.

To use PetSets backed with PersistentStorage you will need to create multiple PersistentVolumes depending on the number of replicas you intend to have in your petset. 

Following are the PersistentVolumes that are available:

```
$ kubectl get pv
NAME       CAPACITY   ACCESSMODES   STATUS      CLAIM                REASON    AGE
pv-pwx-0   1Gi        RWO           Available   default/pv-claim-0             15m
pv-pwx-1   1Gi        RWO           Available   default/pv-claim-1             13m
```

An example PetSet spec defined for an "nginx" service which uses PersistentVolumeClaims looks like this

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  ports:
  - port: 80
    name: petset-pwx
  # *.nginx.default.svc.cluster.local
  clusterIP: None
  selector:
    app: nginx
---
apiVersion: apps/v1alpha1
kind: PetSet
metadata:
  name: petset-pwx
spec:
  serviceName: "nginx"
  replicas: 2
  template:
    metadata:
      labels:
        app: nginx
      annotations:
        pod.alpha.kubernetes.io/initialized: "true"
    spec:
      terminationGracePeriodSeconds: 0
      containers:
      - name: nginx
        image: gcr.io/google_containers/nginx-slim:0.8
        ports:
        - containerPort: 80
          name: petset
        volumeMounts:
        - name: pv-claim
          mountPath: /data
  volumeClaimTemplates:
    - metadata:
        name: pv-claim
      spec:
        accessModes: [ "ReadWriteOnce" ]
        resources:
          requests:
            storage: 1Gi
```

For the nginx pods that will be a part of this PetSet we define a PersistentVolumeClaim which requests a storage of size 1Gi. The number of replicas defined in the PetSet spec is "2". Hence it is necessary that we have atleast two PersistentVolumes which can satisfy these claims. You can create a PetSet by running the following command

```
$ kubectl create -f petsets.yaml
service "nginx" created
petset "petset-pwx" created

$ kubectl get pvc
NAME                    STATUS    VOLUME     CAPACITY   ACCESSMODES   AGE
pv-claim-petset-pwx-0   Bound     pv-pwx-1   1Gi        RWO           3s
pv-claim-petset-pwx-1   Bound     pv-pwx-0   1Gi        RWO           3s

$ kubectl get pv
NAME       CAPACITY   ACCESSMODES   STATUS    CLAIM                           REASON    AGE
pv-pwx-0   1Gi        RWO           Bound     default/pv-claim-petset-pwx-1             6m
pv-pwx-1   1Gi        RWO           Bound     default/pv-claim-petset-pwx-0             6m

$ kubectl get pods
NAME           READY     STATUS    RESTARTS   AGE
petset-pwx-0   1/1       Running   0          6m
petset-pwx-1   1/1       Running   0          6m
```

Our PetSet definition creates two PersistentVolumeClaims, one for each nginx pod. These claims get Bound to the existing Volumes. Finally the PetSet looks like this

```
kubectl describe petsets petset-pwx
Name:			petset-pwx
Namespace:		default
Image(s):		gcr.io/google_containers/nginx-slim:0.8
Selector:		app=nginx
Labels:			app=nginx
Replicas:		2 current / 2 desired
Annotations:		<none>
CreationTimestamp:	Tue, 06 Dec 2016 02:36:48 +0000
Pods Status:		2 Running / 0 Waiting / 0 Succeeded / 0 Failed
No volumes.
Events:
  FirstSeen	LastSeen	Count	From	SubobjectPath	Type		Reason			Message
  ---------	--------	-----	----	-------------	--------	------			-------
  9m		9m		1	{petset }		Normal		SuccessfulCreate	pet: petset-pwx-0
  9m		9m		1	{petset }		Normal		SuccessfulCreate	pet: petset-pwx-1
```
