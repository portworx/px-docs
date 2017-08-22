---
layout: page
title: "Run Portworx with Kubernetes Flexvolume"
keywords: portworx, PX-Developer, container, Kubernetes, storage
sidebar: home_sidebar
redirect_from:
  - /run-with-kubernetes.html
  - /run-with-kubernetes-native-driver.html
  - /run-with-kubernetes-flexvolume.html
  - /run-with-k8s.html
---
You can use Portworx to provide storage for your Kubernetes pods. Portworx pools your servers capacity and turns your servers or cloud instances into converged, highly available compute and storage nodes. This section describes how to deploy PX within a Kubernetes cluster and have PX provide highly available volumes to any application deployed via Kubernetes.

This guide is for Kubernetes 1.5. If you are using Kubernetes 1.6 (recommended), please use [this page](/scheduler/kubernetes/install.html).
Portworx has limited support for Kubernetes 1.5. The recommended release is 1.6.

## Prerequisites
* You *must* configure Docker to allow shared mounts propogation. Please follow [these](/knowledgebase/shared-mount-propogation.html) instructions to enable shared mount propogation.  This is needed because PX runs as a container and it will be provisioning storage to other containers.
* If Kubernetes is deployed using Openshift, add the service account `px-account` to the privileged security context
 ```
 $ oc adm policy add-scc-to-user privileged -z px-account --namespace kube-system
 ```

## Step 1: Deploy Portworx
The following kubectl command deploys Portworx in the cluster as a `daemon set`:

```
$ kubectl apply -f "http://install.portworx.com/kube1.5?cluster=mycluster&kvdb=etcd://etc.company.net:4001"
```
Make sure you change the custom parameters (_cluster_ and _kvdb_) to match your environment.

>**Openshift users:**<br/> If kubernetes is deployed using Openshift, set `openshift=true` in the above URL. Check examples below.

You can also generate the spec using `curl` and supply that to kubectl. This is useful if:
* Your cluster doesn't have access to http://install.portworx.com, so the spec can be generated on a different machine.
* You want to save the spec file for future reference.

For example:
```
$ curl -o px-spec.yaml "http://install.portworx.com/kube1.5?cluster=mycluster&kvdb=etcd://etc.company.net:4001"
$ kubectl apply -f px-spec.yaml
```

Below are all parameters that can be given in the query string:

| Key         	| Description                                                                                                                                                                              	| Example                                           	|
|-------------	|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	|---------------------------------------------------	|
| cluster     	| (Required) Specifies the unique name for the Portworx cluster.                                                                                                                           	| cluster=test_cluster                              	|
| kvdb        	| (Required) Points to your key value database, such as an etcd cluster or a consul cluster.                                                                                               	| kvdb=etcd://etcd.fake.net:4001                    	|
| drives      	| (Optional) Specify comma-separated list of drives.                                                                                                                                       	| drives=/dev/sdb,/dev/sdc                          	|
| diface      	| (Optional) Specifies the data interface. This is useful if your instances have non-standard network interfaces.                                                                          	| diface=eth1                                       	|
| miface      	| (Optional) Specifies the management interface. This is useful if your instances have non-standard network interfaces.                                                                    	| miface=eth1                                       	|
| zeroStorage 	| (Optional) Instructs PX to run in zero storage mode on kubernetes master.                                                                                                                	| zeroStorage=true                                  	|
| force       	| (Optional) Instructs PX to use any available, unused and unmounted drives or partitions.,PX will never use a drive or partition that is mounted.                                         	| force=true                                        	|
| etcdPasswd  	| (Optional) Username and password for ETCD authentication in the form user:password                                                                                                       	| etcdPasswd=username:password                      	|
| etcdCa      	| (Optional) Location of CA file for ETCD authentication.                                                                                                                                  	| etcdCa=/path/to/server.ca                         	|
| etcdCert    	| (Optional) Location of certificate for ETCD authentication.                                                                                                                              	| etcdCert=/path/to/server.crt                      	|
| etcdKey     	| (Optional) Location of certificate key for ETCD authentication.                                                                                                                          	| etcdKey=/path/to/server.key                       	|
| acltoken    	| (Optional) ACL token value used for Consul authentication.                                                                                                                               	| acltoken=398073a8-5091-4d9c-871a-bbbeb030d1f6     	|
| token       	| (Optional) Portworx lighthouse token for cluster.                                                                                                                                        	| token=a980f3a8-5091-4d9c-871a-cbbeb030d1e6        	|
| env         	| (Optional) Comma-separated list of environment variables that will be exported to portworx.                                                                                              	| env=API_SERVER=http://lighthouse-new.portworx.com 	|
| coreos       	| (Optional) Specifies that target nodes are coreos.                                                                                                                                      	| coreos=true                                           |
| openshift    	| (Optional) Specifies that kubernetes is deployed using Openshift                                                                                                                          | openshift=true                                        |


#### Scaling
Portworx is deployed as a `Daemon Set`.  Therefore it automatically scales as you grow your Kubernetes cluster.  There are no additional requirements to install Portworx on the new nodes in your Kubernetes cluster.

#### Examples
```
# To specify drives
$ kubectl apply -f "http://install.portworx.com/kube1.5?cluster=mycluster&kvdb=etcd://etcd.fake.net:4001&drives=/dev/sdb,/dev/sdc"

# To run on openshift
$ kubectl apply -f "http://install.portworx.com/kube1.5?cluster=mycluster&kvdb=etcd://etcd.fake.net:4001&openshift=true"

# To run in master in zero storage mode and use a specific drive for other nodes
$ kubectl apply -f "http://install.portworx.com/kube1.5?cluster=mycluster&kvdb=etcd://etcd.fake.net:4001&zeroStorage=true&drives=/dev/sdb"
```

## Step 2: Restart Kubernetes
For Kubernetes to discover the newly deployed Portworx plugin, it's control plane components need to be restarted.

* If using openshift, run `systemctl restart atomic-openshift-node.service` on all nodes
* For other deployments, restart the `kubelet` service on all nodes

## Try it out with NGINX

First create a volume using pxctl
```
/opt/pwx/bin/pxctl volume create test-vol
```

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

## Using PetSets (Pre StatefulSets)
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

## Upgrade
To upgrade Portworx, use the same `kubectl apply` command used to install it. This will repull the image used for Portworx (portworx/px-enterprise:latest) and perform a rolling upgrade.

You can check the upgrade status with following command.
```
$ kubectl rollout status ds portworx --namespace kube-system
```

## Uninstall
Following kubectl command uninstalls Portworx from the cluster.

```
$ kubectl delete -f "http://install.portworx.com/kube1.5?cluster=mycluster&kvdb=etcd://etcd.fake.net:4001"
```

>**Note:**<br/>During uninstall, the configuration files (/etc/pwx/config.json and /etc/pwx/.private.json) are not deleted. If you delete /etc/pwx/.private.json, Portworx will lose access to data volumes.
