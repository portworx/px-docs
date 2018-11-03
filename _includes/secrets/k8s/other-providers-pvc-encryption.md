```yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: secure-mysql-pvc
  annotations:
    px/secret-name: your-secret-key
spec:
  storageClassName: portworx-sc
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
```