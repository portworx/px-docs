---
layout: page
title: "Cloud Migration using stork"
keywords: cloud, backup, restore, snapshot, DR, migration
---

* TOC
{:toc}

## Overview
This method can be used to migrate volumes between two Kubernetes clusters
each running a Portworx cluster.

## Pre-requisites
* Requires PX-Enterprise v2.0+ and stork v1.3+
* Make sure you have configured a [secret store](https://docs.portworx.com/secrets/) on both your clusters. This will be used to store the credentials for the 
objectstore.
* Make sure ports 9001 and 9010 on the destination cluster are reachable from the
source cluster.
* Download storkctl to a system that has access to kubectl:
  * Linux:
  ```bash
  curl http://openstorage-stork.s3-website-us-east-1.amazonaws.com/storkctl/latest/linux/storkctl -o storkctl &&
  sudo mv storkctl /usr/local/bin &&
  sudo chmod +x /usr/local/bin/storkctl
  ```
  * OS X:
  ```bash
  curl http://openstorage-stork.s3-website-us-east-1.amazonaws.com/storkctl/latest/darwin/storkctl -o storkctl &&
  sudo mv storkctl /usr/local/bin &&
  sudo chmod +x /usr/local/bin/storkctl
  ```
  * Windows:
    * Download [storkctl.exe](http://openstorage-stork.s3-website-us-east-1.amazonaws.com/storkctl/latest/windows/storkctl.exe)
    * Move `storkctl.exe` to a directory in your PATH

## Pairing clusters
On Kubernetes the cluster pairs can be created using custom objects managed by stork. This creates a pairing with the storage
driver (Portworx) and well as the scheduler (Kubernetes) so that the volumes, as well as resources, can be migrated between 
clusters.

1. Install portworx and stork on 2 clusters using the above images
2. On the destination cluster, run the following commands from one of the Portworx nodes (steps (a) and (b) will not be 
required in the future)
   1. Create a volume for the objectstore: 
     ```/opt/pwx/bin/pxctl volume create --size 100 objectstore```
   2. Create an objectstore: ```/opt/pwx/bin/pxctl objectstore create -v objectstore```
   3. Get the cluster token: ```/opt/pwx/bin/pxctl cluster token show```
3. Get the ClusterPair spec from the destination cluster. This is required to migrate Kubernetes resources to the destination cluster.
You can generate the template for the spec using `storkctl generate clusterpair`
```yaml
$ storkctl generate clusterpair
apiVersion: stork.libopenstorage.org/v1alpha1
kind: ClusterPair
metadata:
    creationTimestamp: null
    name: <insert_name_here>
spec:
   config:
      clusters:
         kubernetes:
            LocationOfOrigin: /etc/kubernetes/admin.conf
            certificate-authority-data: <CA_DATA>
            server: https://192.168.56.74:6443
      contexts:
         kubernetes-admin@kubernetes:
            LocationOfOrigin: /etc/kubernetes/admin.conf
            cluster: kubernetes
            user: kubernetes-admin
      current-context: kubernetes-admin@kubernetes
      preferences: {}
      users:
         kubernetes-admin:
            LocationOfOrigin: /etc/kubernetes/admin.conf
            client-certificate-data: <CLIENT_CERT_DATA>
            client-key-data: <CLIENT_KEY_DATA>
    options:
       <insert_storage_options_here>: ""
status:
  remoteStorageId: ""
  schedulerStatus: ""
  storageStatus: ""
```
4. With the information from (2) update the spec generated in (3). You'll need to add the metadata.name for the cluster and 
add the Portworx clusterpair information under spec.options. The update ClusterPair should like this:
```yaml
apiVersion: stork.libopenstorage.org/v1alpha1
kind: ClusterPair
metadata:
  creationTimestamp: null
  name: remotecluster
spec:
  config:
      clusters:
        kubernetes:
          LocationOfOrigin: /etc/kubernetes/admin.conf
          certificate-authority-data: <CA_DATA> 
          server: https://192.168.56.74:6443
      contexts:
        kubernetes-admin@kubernetes:
          LocationOfOrigin: /etc/kubernetes/admin.conf
          cluster: kubernetes
          user: kubernetes-admin
      current-context: kubernetes-admin@kubernetes
      preferences: {}
      users:
        kubernetes-admin:
          LocationOfOrigin: /etc/kubernetes/admin.conf
          client-certificate-data: <CLIENT_CERT_DATA>
          client-key-data: <CLIENT_KEY_DATA>
  options:
      ip: <ip_of_remote_px_node>
      port: <port_of_remote_px_node_default_9001>
      token: <token_from_step_3>
status:
  remoteStorageId: ""
  schedulerStatus: ""
  storageStatus: ""
```
5. (EKS Only) When pairing with an EKS cluster, you also need to pass in your
   AWS credentials which will be used to generate the IAM token. This can be
   achieved by performing one of the following steps:
   1. Create a secret and mount in the stork deployment (Secure)
       1. On the source cluster, create a secret in kube-system namespace with your aws credentials
       file:
       ```
       $ kubectl create secret generic --from-file=$HOME/.aws/credentials -n  kube-system aws-creds
       secret/aws-creds created
       ```
       2. Mount the secret created above in the stork deployment. Run `kubectl edit deployment -n kube-system stork` and make the following updates.
           1. Add the following under spec.template.spec: 
           ```yaml
           volumes:
           - name: aws-creds
             secret:
                  secretName: aws-creds
           ```
           2. Add the following under spec.template.spec.containers:
           ```yaml
           volumeMounts:
           - mountPath: /root/.aws/
             name: aws-creds
             readOnly: true
           ```
       3. Wait for all the stork pods to be in running state after applying the
          changes: `kubectl get pods -n kube-system -l name=stork`
   2. Add environment variable to the client authentication spec (Non-secure)

      If you are pairing to an EKS cluster, the generated clusterpair spec will have a section for
      performing client authentication using the `aws-iam-authenticator`. You can pass in your AWS
      credentials through environment variables in this spec.
      An updated spec would look like the following
      ```yaml
      exec:
        apiVersion: client.authentication.k8s.io/v1alpha1
        env:
        - name: "AWS_ACCESS_KEY"
          value: "<your_access_key>
        - name: "AWS_SECRET_ACCESS_KEY"
          value: "<your_secret_key>"
        args:
        - token
        - -i
        - demo-destination-cluster
        command: aws-iam-authenticator
      ```
6. (GKE Only) When pairing with an GKE cluster, you also need to pass in your
   Google Cloud credentials which will be used to generate the access tokens. This can be
   achieved by performing all of the following steps:
   1. Create a service account key using [the guide from Google Cloud](https://cloud.google.com/iam/docs/creating-managing-service-account-keys)
   and save it as gcs-key.json. You can also create this using the following command: 
   ```
   $ gcloud iam service-accounts keys create gcs-key.json \
         --iam-account <your_iam_account>
   ```
   2. Create a clusterrolebinding to give your account the cluster-admin role
   ```
   $ kubectl create clusterrolebinding stork-cluster-admin-binding \
        --clusterrole=cluster-admin                                \
        --user=<your_iam_account>                                  \
   ```     
   3. On the source cluster, create a secret in kube-system namespace with
      the service account json created in the previous step:
   ```
   $ kubectl create secret  generic --from-file=gcs-key.json -n kube-system gke-creds
   secret/gke-creds created
   ```
   4. Mount the secret created above in the stork deployment. Run `kubectl edit deployment -n kube-system stork` and make the following updates.
       1. Add the following under spec.template.spec:
       ```yaml
       volumes:
       - name: gke-creds
         secret:
              secretName: gke-creds
       ```
       2. Add the following under spec.template.spec.containers
       ```yaml
       volumeMounts:
       - mountPath: /root/.gke/
         name: gke-creds
         readOnly: true
       ```
       3. Add the following under spec.template.spec.containers
       ```yaml
       env:
       - name: CLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE
         value: /root/.gke/gcs-key.json
       ```     
   5. Wait for all the stork pods to be in running state after applying the
      changes: `kubectl get pods -n kube-system -l name=stork`
7. Once you apply the above spec on the source cluster you should be able to check the status of the pairing. On a successful pairing, you should
see the "Storage Status" and "Scheduler Status" as "Ready" using storkctl
```
$ storkctl get clusterpair
NAME            STORAGE-STATUS   SCHEDULER-STATUS   CREATED
remotepair      Ready            Ready              26 Oct 18 03:11 UTC
```
8. If the status is in error state you can describe the clusterpair to get more information
```
$ kubectl describe clusterpair remotepair
```

## Migrating Volumes and Resources
Once you have the cluster pair set up you can migrate volumes and resources to the destination cluster

1. Migration through stork is also done through a CRD. Example migration spec:
```yaml
apiVersion: stork.libopenstorage.org/v1alpha1
kind: Migration
metadata:
  name: mysqlmigration
spec:
  # This should be the name of the cluster pair created above
  clusterPair: remotecluster
  # If set to false this will migrate only the Portworx volumes. No PVCs, apps, etc will be migrated
  includeResources: true
  # If set to false, the deployments and stateful set replicas will be set to 0 on the destination. There will be an annotation with "stork.openstorage.org/migrationReplicas" to store the replica count from the source
  startApplications: true
  # List of namespaces to migrate
  namespaces:
  - mysql
```

2. You can also start a migration using storkctl
```
$ storkctl create migration mysqlmigration --clusterPair remotecluster --namespaces mysql --includeResources --startApplications
Migration mysqlmigration created successfully
```

3. Once the migration has been started using the spec in (1) or using storkctl in (2), you can check the status of the migration using storkctl
```
$ storkctl get migration
NAME            CLUSTERPAIR     STAGE     STATUS       VOLUMES   RESOURCES   CREATED
mysqlmigration  remotecluster   Volumes   InProgress   0/1       0/0         26 Oct 18 20:04 UTC
```

4. The Stages of migration will go from Volumes→ Application→Final if successful.
```
$ storkctl get migration
NAME            CLUSTERPAIR     STAGE     STATUS       VOLUMES   RESOURCES   CREATED
mysqlmigration  remotecluster   Final     Successful   1/1       3/3         26 Oct 18 20:04 UTC
```

5. If you want more information about what resources were migrated you can describe the migration object using kubectl
```
$ kubectl describe migration mysqlmigration
Name:         mysqlmigration
Namespace:   
Labels:       <none>
Annotations:  <none>
API Version:  stork.libopenstorage.org/v1alpha1
Kind:         Migration
Metadata:
  Creation Timestamp:  2018-10-26T20:04:19Z
  Generation:          1
  Resource Version:    2148620
  Self Link:           /apis/stork.libopenstorage.org/v1alpha1/migrations/ctlmigration3
  UID:                 be63bf72-d95a-11e8-ba98-0214683e8447
Spec:
  Cluster Pair:       remotecluster
  Include Resources:  true
  Namespaces:
      mysql
  Selectors:           <nil>
  Start Applications:  true
Status:
  Resources:
    Group:      core
    Kind:       PersistentVolume
    Name:       pvc-34bacd62-d7ee-11e8-ba98-0214683e8447
    Namespace: 
    Reason:     Resource migrated successfully
    Status:     Successful
    Version:    v1
    Group:      core
    Kind:       PersistentVolumeClaim
    Name:       mysql-data
    Namespace:  mysql
    Reason:     Resource migrated successfully
    Status:     Successful
    Version:    v1
    Group:      apps
    Kind:       Deployment
    Name:       mysql
    Namespace:  mysql
    Reason:     Resource migrated successfully
    Status:     Successful
    Version:    v1
  Stage:        Final
  Status:       Successful
  Volumes:
    Namespace:                mysql
    Persistent Volume Claim:  mysql-data
    Reason:                   Migration successful for volume
    Status:                   Successful
    Volume:                   pvc-34bacd62-d7ee-11e8-ba98-0214683e8447
Events:
  Type    Reason      Age    From   Message
  ----    ------      ----   ----   -------
  Normal  Successful  2m42s  stork  Volume pvc-34bacd62-d7ee-11e8-ba98-0214683e8447 migrated successfully
  Normal  Successful  2m39s  stork  /v1, Kind=PersistentVolume /pvc-34bacd62-d7ee-11e8-ba98-0214683e8447: Resource migrated successfully
  Normal  Successful  2m39s  stork  /v1, Kind=PersistentVolumeClaim mysql/mysql-data: Resource migrated successfully
  Normal  Successful  2m39s  stork  apps/v1, Kind=Deployment mysql/mysql: Resource migrated successfully
```
