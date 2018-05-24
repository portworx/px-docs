---
layout: page
title: "Run pods on same host as a volume"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk, StatefulSets, stork
sidebar: home_sidebar
redirect_from:
  - /kubernetes-with-scheduler-convergence.html
meta-description: "Learn how to improve volume latency on Kubernetes by using convergence when using Portworx."
---

* TOC
{:toc}

### Hyper-convergence
When a pod runs on the same host as its volume, it is known as convergence or hyper-convergence.  Because this configuration reduces the network overhead of an application, performance is typically better.

### Using scheduler convergence
The recommended method to run your pods hyperconverged is to use [STORK](/scheduler/kubernetes/stork.html).

Once you have installed STORK, all you need to do is add `schedulerName: stork` in your application specs. STORK will then ensure that the nodes with data for a volume get prioritized when pods are being scheduled.

For example, this is how you would specify the scheduler name in a MySQL deployment:

```
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: mysql
spec:
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
    type: RollingUpdate
  replicas: 1
  template:
    metadata:
      labels:
        app: mysql
        version: "1"
    spec:
      schedulerName: stork
      containers:
      - image: mysql:5.6
        name: mysql
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: password
        ports:
        - containerPort: 3306
        volumeMounts:
        - name: mysql-persistent-storage
          mountPath: /var/lib/mysql
      volumes:
      - name: mysql-persistent-storage
        persistentVolumeClaim:
          claimName: mysql-data
```

### Initializer (Experimental feature in STORK v1.1)
If you are not able to update the schedulerName for you applications to use
stork, you can enable the app-initializer feature. This uses the Kubernetes
[AdmissionController Initializer](https://kubernetes.io/docs/admin/extensible-admission-controllers/#initializers)
feature to automatically update the scheduler to stork if your application
(deployment or statefulset) is using volumes backed by Portworx.

To enable the Initializer you need to:
* [Enable the Intializer feature in your Kubernetes cluster](https://kubernetes.io/docs/admin/extensible-admission-controllers/#enable-initializers-alpha-feature) since it is an alpha feature in Kubernetes.
* Add "--app-initializer=true" option in the stork deployment
* Add the [stork-initializer spec](https://raw.githubusercontent.com/libopenstorage/stork/master/specs/stork-initializer.yaml) to you Kubernetes cluster using `kubectl create -f stork-initializer.yaml`
