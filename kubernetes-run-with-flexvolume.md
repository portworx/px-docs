---
layout: page
title: "Run Portworx with Kubernetes Flexvolume for k8s 1.5 and earlier"
keywords: portworx, PX-Developer, container, Kubernetes, storage
sidebar: home_sidebar
---

These instructions are recommended only if you are running a version of Kubernetes before 1.6.  Otherwise, see instructions [here](#insert-link)

You can use Portworx to provide storage for your Kubernetes pods. Portworx pools your servers capacity and turns your servers or cloud instances into converged, highly available compute and storage nodes. This section describes how to deploy PX within a Kubernetes cluster and have PX provide highly available volumes to any application deployed via Kubernetes.

>**Note:**<br/>We are tracking when shared mounts will be allowed within Kubernetes (K8s), which will allow Kubernetes to deploy PX.

## Step 1: Run the PX container

Portworx can be deployed via K8s directly, or run on each host via docker or systemd directly.

To run the PX container using Docker, run the following command:

For Redhat, Ubuntu and Debian distros:

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
    portworx/px-dev:latest -daemon -k etcd://myetc.company.com:2379 -c MY_CLUSTER_ID -s /dev/sdb -s /dev/sdc
```

For CoreOS and VMWare Photon	

```
# sudo docker run --restart=always --name px -d --net=host \		
   --privileged=true                             \
   -v /run/docker/plugins:/run/docker/plugins    \
   -v /var/lib/osd:/var/lib/osd:shared           \
   -v /dev:/dev                                  \
   -v /etc/pwx:/etc/pwx                          \
   -v /opt/pwx/bin:/export_bin:shared            \
   -v /var/run/docker.sock:/var/run/docker.sock  \
   -v /var/cores:/var/cores                      \
   -v /lib/modules:/lib/modules                  \
   -v /var/lib/kubelet:/var/lib/kubelet:shared   \
   -v /etc/kubernetes/kubelet-plugins/volume/exec/px~flexvolume/:/export_flexvolume:shared \
   portworx/px-dev:latest -daemon -k etcd://myetc.company.com:4001 -c MY_CLUSTER_ID -s /dev/sdb -s /dev/sdc
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

For Redhat, Ubuntu, Debian distros:

```bash
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

For CoreOS and VMWare Photon:

```bash
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
# kubectl create -f pv.yaml
persistentvolume "pv-pwx" created

# kubectl get pv
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
# kubectl create -f pv-claim.yaml
persistentvolumeclaim "pv-claim" created

# kubectl get pvc
NAME            STATUS    VOLUME     CAPACITY   ACCESSMODES   AGE
pv-claim        Bound     pv-pwx     1Gi        RWO           5s

# kubectl get pv
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
# kubectl get pv
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
# kubectl create -f petsets.yaml
service "nginx" created
petset "petset-pwx" created

# kubectl get pvc
NAME                    STATUS    VOLUME     CAPACITY   ACCESSMODES   AGE
pv-claim-petset-pwx-0   Bound     pv-pwx-1   1Gi        RWO           3s
pv-claim-petset-pwx-1   Bound     pv-pwx-0   1Gi        RWO           3s

# kubectl get pv
NAME       CAPACITY   ACCESSMODES   STATUS    CLAIM                           REASON    AGE
pv-pwx-0   1Gi        RWO           Bound     default/pv-claim-petset-pwx-1             6m
pv-pwx-1   1Gi        RWO           Bound     default/pv-claim-petset-pwx-0             6m

# kubectl get pods
NAME           READY     STATUS    RESTARTS   AGE
petset-pwx-0   1/1       Running   0          6m
petset-pwx-1   1/1       Running   0          6m
```

Our PetSet definition creates two PersistentVolumeClaims, one for each nginx pod. These claims get Bound to the existing Volumes. Finally the PetSet looks like this

```
# kubectl describe petsets petset-pwx
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
