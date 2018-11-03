---
layout: page
title: "Encryption using PVC with IBM Key Protect"
keywords: portworx, container, kubernetes, storage, k8s, flexvol, pv, persistent disk, encryption, pvc
meta-description: "This guide is a step-by-step tutorial on how to provision encrypted volumes using PVC annotations."
---

* TOC
{:toc}

>**Note:**<br/>Supported from PX Enterprise 1.7 onwards

### Encryption using per volume secrets

In this method each volume will use its own unique passphrase to encrypt the volume. Portworx uses IBM Key Protect APIs to generate a unique 256 bit passphrase. This passphrase will be used during encryption and decryption.

#### Step 1: Create a Storage Class

{% include /secrets/k8s/enc-storage-class-spec.md %}

#### Step 2: Create a Persistent Volume Claim

```yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: mysql-data
  annotations:
    volume.beta.kubernetes.io/storage-class: px-secure-sc
spec:
  storageClassName: px-mysql-sc
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi

```

If you do not want to specify the `secure` flag in the storage class, but you want to encrypt the PVC using that Storage Class, then create the PVC as below

```yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: secure-pvc
  annotations:
    px/secure: "true"
spec:
  storageClassName: portworx-sc
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
```
Note the `px/secure: "true"` annotation on the PVC object.

### Encryption using cluster wide secret

In this method a default cluster wide secret will be set for the Portworx cluster. Such a secret will be referenced by the user and Portworx as **default** secret. Any PVC request referencing the secret name as `default` will use this cluster wide secret as a passphrase to encrypt the volume.

#### Step 1: Set the cluster wide secret key

{% include secrets/set-ibm-cluster-wide-secret.md %}

#### Step 2: Create a Storage Class

{% include /secrets/k8s/enc-storage-class-spec.md %}

#### Step 3: Create a Persistent Volume Claim

```yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: mysql-data
  annotations:
    px/secret-name: default
    volume.beta.kubernetes.io/storage-class: px-secure-sc
spec:
  storageClassName: px-mysql-sc
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi

```

Take a note of the annotation `px/secret-name: default`. This specific annotation indicates Portworx to use the default secret to encrypt the volume. In this case it will **NOT**  create a new passphrase for this volume and NOT use per volume encryption. If the annotation is not provided then Portworx will use the per volume encryption workflow as described in the previous section.

Again, if your Storage Class does not have the `secure` flag set, but you want to encrypt the PVC using the same Storage Class, then add the annotation `px/secure: "true"` to the above PVC.
