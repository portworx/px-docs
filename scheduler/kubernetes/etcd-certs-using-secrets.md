---
layout: page
title: "Etcd certificates using Kubernetes Secrets"
keywords: portworx, container, kubernetes, storage, k8s, etcd, secrets, certificates
meta-description: "This guide is a step-by-step tutorial on how to use Kubernetes secrets to give etcd certificates to Portworx."
---

This page will guide you on how to give your etcd certificates to Portworx using Kubernetes Secrets. This is the recommended way of providing etcd certificates, as the certificates will be automatically available to the new nodes joining the cluster.

#### Create Kubernetes secret
Copy all your etcd certificates and key in a directory `etcd-secrets/` to create a Kubernetes secret from it.
```
# ls -1 etcd-secrets/
etcd-ca.crt
etcd.crt
etcd.key
```

Use `kubectl` to create the secret named `px-etcd-certs` from the above files:
```
# kubectl -n kube-system create secret generic px-etcd-certs --from-file=etcd-secrets/
```

Notice that the secret has 3 keys `etcd-ca.crt`, `etcd.crt` and `etcd.key`, corresponding to file names in the `etcd-secrets` folder. We will use these keys in the Portworx spec file to reference the certificates.
```
# kubectl -n kube-system describe secret px-etcd-certs
Name:         px-etcd-certs
Namespace:    kube-system
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data
====
etcd-ca.crt:      1679 bytes
etcd.crt:  1680 bytes
etcd.key:  414  bytes
```

#### Edit Portworx spec
Once the secret is created we need to edit the Portworx spec file to consume the certificates from the secret.

To mount the certificates under `/etc/pwx/etcdcerts` inside the portworx container, add the following under the _volumeMounts_ in Portworx DaemonSet.
```
  volumeMounts:
  - mountPath: /etc/pwx/etcdcerts
    name: etcdcerts
```

Now, we use the keys from the secret that we created and mount it under paths that portworx will use to talk to the etcd server. In the `items` below, the `key` is the key from the `px-etcd-certs` secret and the `path` is the relative path from `/etc/pwx/etcdcerts` where Kubernetes will mount the certificates. Put the following under the _volumes_ section of Portworx DaemonSet.
```
  volumes:
  - name: etcdcerts
    secret:
      secretName: px-etcd-certs
      items:
      - key: etcd-ca.crt
        path: etcd-ca.crt
      - key: etcd.crt
        path: etcd.crt
      - key: etcd.key
        path: etcd.key
```

Now that the certificates are mounted at `/etc/pwx/etcdcerts` and the sub-paths that we specified in the _volumes_ section, change the portworx container args to use the correct certificate paths.
```
  containers:
  - name: portworx
    args:
      ["-c", "test-cluster", "-a", "-f",
      "-ca", "/etc/pwx/etcdcerts/etcd-etcd-ca.crt",
      "-cert", "/etc/pwx/etcdcerts/etcd.crt",
      "-key", "/etc/pwx/etcdcerts/etcd.key",
      "-x", "kubernetes"]
```
