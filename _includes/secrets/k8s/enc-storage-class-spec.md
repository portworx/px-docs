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

To create a **shared encrypted volume** set the `shared` parameter to `true` as well.
