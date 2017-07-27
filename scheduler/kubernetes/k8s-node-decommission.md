---
layout: page
title: "Decommission a Portworx node in Kubernetes"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk
sidebar: home_sidebar
---

* TOC
{:toc}

This guide describes a recommended workflow for decommissioning a Portworx node in your Kubernetes cluster.

### 1. Migrate application pods using portworx volumes that are running on this node
If you plan to remove Portworx from a node, applications running on that node using Portworx need to be migrated. If Portworx is not running, existing application containers will end up with read-only volumes and new ones will fail to start.

You have 2 options for migrating applications.
##### Migrate all pods
* Drain the node using: `kubectl drain <node>`

##### Migrate selected pods
1. Cordon the node using: `kubectl cordon <node>`
2. Delete the application pods using portworx volumes using: `kubectl delete pod <pod-name>`
    * Since application pods are expected to be managed by a controller like `Deployement` or `StatefulSet`, Kubernetes will spin up a new replacement pod on another node.

### 2. Decommission Portworx
1. Follow [this guide](maintain/scale-down.html) to decommission the Portworx node from the cluster.
2. Set the `px/enabled` label to `false` on the node using: `kubectl label nodes <node> "px/enabled=false" --overwrite`
    * This will remove the Portworx container from this node since the Portworx DaemonSet spec file uses a node anti-affinity rule that causes it to _not_ run on nodes that have the label: `px/enabled=false`
    * If you have an older Portworx DaemonSet spec, ensure the spec has the following section.
    ```yaml
        spec:
          affinity:
            nodeAffinity:
              requiredDuringSchedulingIgnoredDuringExecution:
                nodeSelectorTerms:
                - matchExpressions:
                  - key: px/enabled
                    operator: NotIn
                    values:
                    - "false"
    ```
    * You can use `kubectl edit ds portworx -n kube-system` to update the spec or if you have a saved spec file, update the file and `kubectl apply` it. 

### 3. (Optional) Uncordon the node
If you need to continue using the Kubernetes node without Portworx, uncordon it using: `kubectl uncordon <node>`

### 4. Ensure application pods using Portworx don't run on this node
You will need to ensure your application pods using Porworx volumes don't get scheduled on the node where Portworx is decommissioned.

One way to achieve is this to use [labels](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) and [node anti-affinity](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity)
* We decommissioned the Portworx container from one of the nodes by applying the `px/enabled=false` label on the node.
* Now add a node anti-affinity section in your application pod specs to run only on nodes that do _not_ have this label. For e.g observe the `affinity` section in below spec.
```yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: postgres
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
        app: postgres
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: px/enabled
                operator: NotIn
                values:
                - "false"
      containers:
      - name: postgres
        image: postgres:9.5
        imagePullPolicy: "IfNotPresent"
        ports:
        - containerPort: 5432
        env:
        - name: POSTGRES_USER
          value: postgres
        - name: POSTGRES_PASSWORD
          value: superpostgres
        - name: PGDATA
          value: /var/lib/postgresql/data/pgdata
        volumeMounts:
        - mountPath: /var/lib/postgresql/data
          name: postgredb
      volumes:
      - name: postgredb
        persistentVolumeClaim:
          claimName: postgres-data
```