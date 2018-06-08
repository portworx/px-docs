---
layout: page
title: "How to run WordPress and MySQL on Kubernetes using Portworx"
keywords: portworx, Wordpress, application stack, kubernetes, Persistent Storage, Persistent Volume, Persistent Volume Claim. 
sidebar: home_sidebar
redirect_from:
meta-description: "This article describes how operate WordPress on Kubernetes. You will learn how to run a high performance MySQL database for WordPress as well as use shared volumes for file uploads."
redirect_from:
  - /applications/wp-k8s.html
---

* TOC
{:toc}

## Summary
 
This document explains about how to deploy a WordPress site and a MySQL database using Kubernetes. Portworx solves two critical issues for WordPress running in containers.  Running a high performance, HA MySQL database and using shared volumes for file uploads.

By combining these two features of Portworx with a Kubernetes cluster we get a WordPress instance with the following abilities:

* automatically replicate the MySQL data for HA
* horizontally scale the WordPress PHP container using multi-writer semantics for the file-uploads directory
* automatically repair itself in the event of a node failure

This document makes use of Kubernetes storage primitives PersistentVolumes (PV) and PersistentVolumeClaims (PVC).

A PersistentVolume (PV) is a piece of storage in the cluster that has been provisioned by an administrator, and a PersistentVolumeClaim (PVC) is a set amount of storage in a PV. PersistentVolumes and PersistentVolumeClaims are independent from Pod lifecycles and preserve data through restarting, rescheduling, and even deleting Pods in kubernetes.

`Note:` The spec files provided in this tutorial are using beta Deployment APIs and are specific to Kubernetes version 1.8 and above. If you wish to use this tutorial with an earlier version of Kubernetes, please update the beta API appropriately, or reference earlier versions of kubernetes.

### Create Portworx PersistentVolume

Kubernetes supports many different types of PersistentVolumes, this step covers Portworx volumes. Both WordPress and MySQL will use Portworx as PersistentVolumes and PersistentVolumeClaims to store data.

#### Create MySQL Portworx PersistentVolume(PV) and PersistentVolumeClaim(PVC)

 `kubectl -f apply mysql-vol.yaml`

```
apiVersion: storage.k8s.io/v1beta1
kind: StorageClass
metadata:
  name: portworx-sc-repl3
provisioner: kubernetes.io/portworx-volume
parameters:
  repl: "3"
  priority_io: "high"
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pvc-1
  annotations:
    volume.beta.kubernetes.io/storage-class: portworx-sc-repl3
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
```

#### Create WordPress Portworx PersistentVolume(PV) and PersistentVolumeClaim(PVC) 

`kubectl -f apply wordpress-vol.yaml`

```
apiVersion: storage.k8s.io/v1beta1
kind: StorageClass
metadata:
  name: portworx-sc-repl3-shared
provisioner: kubernetes.io/portworx-volume
parameters:
  repl: "3"
  priority_io: "high"
  shared: "true"
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: wp-pv-claim
  labels:
    app: wordpress
  annotations:
    volume.beta.kubernetes.io/storage-class: portworx-sc-repl3-shared
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
```

### Create a Secret for MySQL Password

A Secret is an object that stores a piece of sensitive data like a password or key. The manifest files are already configured to use a Secret, but you have to create your own Secret. Note: To protect the Secret from exposure, neither get nor describe show its contents.

#### Create the Secret object from the following command:

`kubectl create secret generic mysql-pass --from-file=password.txt`


#### Verify that the Secret exists by running the following command:

`kubectl get secrets`


### Deploy MySQL with Portworx

The following manifest describes a single-instance MySQL Deployment. The MySQL container mounts the Portworx PersistentVolume at /var/lib/mysql. The MYSQL_ROOT_PASSWORD environment variable sets the database password from the Secret.
The deployment uses stork as the scheduler to enable the pods to be placed closer to where their data is located.

#### Deploy MySQL from the mysql.yaml file:

`kubectl create -f mysql.yaml`

```
apiVersion: v1
kind: Service
metadata:
  name: wordpress-mysql
  labels:
    app: wordpress
spec:
  ports:
    - port: 3306
  selector:
    app: wordpress
    tier: mysql
  clusterIP: None
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: wordpress-mysql
  labels:
    app: wordpress
spec:
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: wordpress
        tier: mysql
    spec:
      # Use the stork scheduler to enable more efficient placement of the pods
      schedulerName: stork
      containers:
      - image: mysql:5.6
        imagePullPolicy: 
        name: mysql
        env:
          # $ kubectl create secret generic mysql-pass --from-file=password.txt
          # make sure password.txt does not have a trailing newline
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-pass
              key: password.txt
        ports:
        - containerPort: 3306
          name: mysql
        volumeMounts:
        - name: mysql-persistent-storage
          mountPath: /var/lib/mysql
      volumes:
      - name: mysql-persistent-storage
        persistentVolumeClaim:
          claimName: mysql-pvc-1
```


### Deploy WordPress

The following manifest describes a three-instance WordPress Deployment and Service. It uses many of the same features like a Portworx PVC for persistent storage and a Secret for the password. But it also uses a different setting: type: NodePort. This setting exposes WordPress to traffic from outside of the cluster
This deployment also uses stork as the scheduler to enable the pods to be placed closer to where their data is located.

#### Deploy WordPress from the wordpress.yaml file:

`kubectl create -f wordpress-deployment.yaml`

```
apiVersion: v1
kind: Service
metadata:
  name: wordpress
  labels:
    app: wordpress
spec:
  ports:
    - port: 80
      nodePort: 30303
  selector:
    app: wordpress
    tier: frontend
  type: NodePort
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: wordpress
  labels:
    app: wordpress
spec:
  replicas: 3
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: wordpress
        tier: frontend
    spec:
      # Use the stork scheduler to enable more efficient placement of the pods
      schedulerName: stork
      containers:
      - image: wordpress:4.8-apache
        name: wordpress
        imagePullPolicy: 
        env:
        - name: WORDPRESS_DB_HOST
          value: wordpress-mysql
        - name: WORDPRESS_DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-pass
              key: password.txt
        ports:
        - containerPort: 80
          name: wordpress
        volumeMounts:
        - name: wordpress-persistent-storage
          mountPath: /var/www/html
      volumes:
      - name: wordpress-persistent-storage
        persistentVolumeClaim:
          claimName: wp-pv-claim
```

#### Verify Pods and Get WordPress Service by running the following command:

`kubectl get pods`

`kubectl get services wordpress`

### Cleaning up

* Deleting secret for mysql

`kubectl delete secret mysql-pass`

* Deleting wordpress

`kubectl delete -f wordpress-deployment.yaml`

`kubectl delete -f wordpress-vol.yaml`

* Deleting mysql for wordpress

`kubectl delete -f mysql.yaml`

`kubectl delete -f mysql-vol.yaml`


`Note:` Portworx PersistentVolume would allow you to recreate the Deployments and Services at this point without losing data, but hostPath loses the data as soon as the Pod stops running...


