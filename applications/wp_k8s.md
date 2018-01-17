---
layout: page
title: "Deploying WordPress and MySQL with Portworx Persistent Volumes by Kubernetes"
keywords: portworx, Wordpress, application stack, kubernetes, Persistent Storage, Persistent Volume, Persistent Volume Claim. 
sidebar: home_sidebar
redirect_from:
meta-description: "Wordpress solution with Kubernetes. Use PX volume driver to create new volumes or reuse existing ones."
---

Deploying WordPress and MySQL with Portworx Persistent Volumes by Kubernetes
This documentation explains about how to deploy a WordPress site and a MySQL database using kubernetes. 

A PersistentVolume (PV) is a piece of storage in the cluster that has been provisioned by an administrator, and a PersistentVolumeClaim (PVC) is a set amount of storage in a PV. PersistentVolumes and PersistentVolumeClaims are independent from Pod lifecycles and preserve data through restarting, rescheduling, and even deleting Pods in kubernetes.

Note: The files provided in this tutorial are using beta Deployment APIs and are specific to kubernetes version 1.8 and above. If you wish to use this tutorial with an earlier version of Kubernetes, please update the beta API appropriately, or reference earlier versions of kubernetes tutorial.

## A.	 Create Porworx PersistentVolume
Kubernetes supports many different types of PersistentVolumes, this step covers portworx volume. Both applications WordPress and MySQL uses portworx as PersistentVolumes and PersistentVolumeClaims to store data.

## 1.	Create MySQL Portworx PersistentVolume(PV) and PersistanctVolumeClaim(PVC)- mysql-vol.yaml
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


## 2.	Create WordPress Portworx PersistentVolume(PV) and PersistanctVolumeClaim(PVC)- wordpress-vol.yaml
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

## B.	 Create a Secret for MySQL Password
A Secret is an object that stores a piece of sensitive data like a password or key. The manifest files are already configured to use a Secret, but you have to create your own Secret. Note: To protect the Secret from exposure, neither get nor describe show its contents.

## 3.	Create the Secret object from the following command:

`kubectl create secret generic mysql-pass --from-file=password.txt`

or 

`kubectl create secret generic mysql-pass --from-literal=password=YOUR_PASSWORD`


## 4.	Verify that the Secret exists by running the following command:

`kubectl get secrets`


C.	 Deploy MySQL with portworx
The following manifest describes a single-instance MySQL Deployment. The MySQL container mounts the Portworx PersistentVolume at /var/lib/mysql. The MYSQL_ROOT_PASSWORD environment variable sets the database password from the Secret.

## 5.	Deploy MySQL from the mysql.yaml file:

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


## D.	 Deploy WordPress
The following manifest describes a three-instance WordPress Deployment and Service. It uses many of the same features like a portworx PVC for persistent storage and a Secret for the password. But it also uses a different setting: type: NodePort. This setting exposes WordPress to traffic from outside of the cluster

## 6.	Deploy wordpress from the wordpress.yaml file:

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


## 7.	Verify Pods and Get WordPress Service by running the following command:


`kubectl get pods`

`kubectl get services wordpress`

E.	 Cleaning up
"Deleting secret for mysql”
`kubectl delete secret mysql-pass`

"Deleting wordpress..."
`kubectl delete -f wordpress.yaml`
`kubectl delete -f wordpress-vol.yaml`

"Deleting mysql for wordpress"
`kubectl delete -f mysql.yaml`
`kubectl delete -f mysql-vol.yaml`


Note: Portworx PersistentVolume would allow you to recreate the Deployments and Services at this point without losing data, but hostPath loses the data as soon as the Pod stops running.


