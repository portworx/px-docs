---
layout: page
title: "Encryption using StorageClass"
keywords: portworx, container, kubernetes, storage, k8s, flexvol, pv, persistent disk, encryption, pvc
meta-description: "This guide is a step-by-step tutorial on how to provision encrypted volumes using Storage Class parameters."
---

Using a Storage Class parameter, you can tell Portworx to encrypt all PVCs created using that Storage Class. Portworx uses a cluster wide secret to encrypt all the volumes created using the secure Storage Class.

{% include_relative set-cluster-wide-secret.md %}

#### Step 2: Create a StorageClass
Create a storage class with `secure` parameter set to `true`.
```yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: px-secure-sc
provisioner: kubernetes.io/portworx-volume
parameters:
  secure: "true"
  repl: "3"
```

#### Step 3: Create Persistent Volume Claim
Create a PVC that uses the above `px-secure-sc` storage class.
```yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: secure-pvc
spec:
  storageClassName: px-secure-sc
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
```

#### Step 4: Verify the volume
Once the PVC has been created, verify the volume created in Portworx is encrypted.
```
# PX_POD=$(kubectl get pods -l name=portworx -n kube-system -o jsonpath='{.items[0].metadata.name}')
# kubectl exec $PX_POD -n kube-system -- /opt/pwx/bin/pxctl volume list
ID                 NAME                                      ...  ENCRYPTED  ...
10852605918962284  pvc-5a885584-44ca-11e8-a17b-080027ee1df7  ...  yes        ...
```
