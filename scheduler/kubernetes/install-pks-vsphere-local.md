---
layout: page
title: "Portworx install on PKS on vSphere using local datastores"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk

meta-description: "Find out how to install PX in a PKS Kubernetes cluster and have PX provide highly available volumes to any application deployed via Kubernetes."
---

![k8s porx Logo](/images/k8s-porx.png){:height="188px" width="188px"}

* TOC
{:toc}

## Platform preparation

* Install vSphere 6.5u1 or above.
* Install PKS 1.1 or above.
* On each ESXi host in the cluster, create a local datastore which is dedicated for Portworx storage. Use a common prefix for the names of the datastores. We will be giving this prefix during Portworx installation.
* Ensure that following options are enabled on any PKS plan that you will use with a Portworx enabled Kubernetes cluster:
    * Enable Privileged Containers
    * Disable DenyEscalatingExec


## Portworx installation

1. Deploy an ETCD cluster for Portworx.  It is recommended that this ETCD cluster be external to your PKS environment.
2. Create a secret using [this template](#pks-px-vsphere-secret). Replace values replace values corresponding to your vSphere environment.
3. Deploy the Portworx spec using [this template](#pks-px-spec). Replace values replace values corresponding to your vSphere environment.

{% include k8s-monitor-install.md %}

## Wipe Portworx installation

Below are the steps to wipe your entire Portworx installation on PKS.

1. Run cluster-scoped wipe: ```curl -fsL https://install.portworx.com/px-wipe | bash -s -- -T pks```
2. Go to each virtual machine and delete the additional vmdks Portworx created.

## References

<a name="pks-px-vsphere-secret"></a>
### Secret for vSphere credentials

Things to replace in the below spec to match your environment:

1. **VSPHERE_USER**: Use output of `echo -n <vcenter-server-user> | base64`
2. **VSPHERE_PASSWORD**: Use output of `echo -n <vcenter-server-password> | base64`

```
apiVersion: v1
kind: Secret
metadata:
  name: px-vsphere-secret
  namespace: kube-system
type: Opaque
data:
  VSPHERE_USER: YWRtaW5pc3RyYXRvckB2c3BoZXJlLmxvY2Fs
  VSPHERE_PASSWORD: cHgxLjMuMEZUVw==
```

<a name="pks-px-spec"></a>
### Portworx spec

Things to replace in the below spec to match your environment:

1. **PX etcd** endpoint in the -k argument.
2. **Cluster ID** in the -c argument. Choose a unique cluster ID.
3. **VSPHERE_VCENTER**: Hostname of the vCenter server.
4. **VSPHERE_DATASTORE_PREFIX**: Prefix of the ESXi datastores that Portworx will use for storage.

```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: px-account
  namespace: kube-system
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
   name: node-get-put-list-role
rules:
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["watch", "get", "update", "list"]
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["delete", "get", "list"]
- apiGroups: [""]
  resources: ["persistentvolumeclaims", "persistentvolumes"]
  verbs: ["get", "list"]
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: node-role-binding
subjects:
- kind: ServiceAccount
  name: px-account
  namespace: kube-system
roleRef:
  kind: ClusterRole
  name: node-get-put-list-role
  apiGroup: rbac.authorization.k8s.io
---
kind: Service
apiVersion: v1
metadata:
  name: portworx-service
  namespace: kube-system
  labels:
    name: portworx
spec:
  selector:
    name: portworx
  ports:
    - name: px-api
      protocol: TCP
      port: 9001
      targetPort: 9001
---
apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  name: portworx
  namespace: kube-system
spec:
  minReadySeconds: 0
  updateStrategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
  template:
    metadata:
      labels:
        name: portworx
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
              - key: node-role.kubernetes.io/master
                operator: DoesNotExist
      hostNetwork: true
      hostPID: true
      containers:
        - name: portworx
          image: portworx/oci-monitor:1.4.3-rc1
          imagePullPolicy: Always
          args:
            ["-c", "px-pks-demo-1", "-k", "etcd:http://PUT-YOUR-ETCD-HOST:PUT-YOUR-ETCD-PORT", "-x", "kubernetes", "-s", "type=zeroedthick"]
          env:
            - name: "PX_TEMPLATE_VERSION"
              value: "v2"
            - name: "PRE-EXEC"
              value: 'if [ ! -x /bin/systemctl ]; then apt-get update; apt-get install -y systemd; fi'
            - name: PX_IMAGE
              value: harshpx/px-enterprise:1.5-vsphere
            - name: VSPHERE_VCENTER
              value: pks-vcenter.k8s-demo.com
            - name: VSPHERE_VCENTER_PORT
              value: "443"
            - name: VSPHERE_DATASTORE_PREFIX
              value: "px-datastore"
            - name: VSPHERE_INSECURE
              value: "true"
            - name: VSPHERE_USER
              valueFrom:
                secretKeyRef:
                  name: px-vsphere-secret
                  key: VSPHERE_USER
            - name: VSPHERE_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: px-vsphere-secret
                  key: VSPHERE_PASSWORD
          livenessProbe:
            periodSeconds: 30
            initialDelaySeconds: 840 # allow image pull in slow networks
            httpGet:
              host: 127.0.0.1
              path: /status
              port: 9001
          readinessProbe:
            periodSeconds: 10
            httpGet:
              host: 127.0.0.1
              path: /health
              port: 9015
          terminationMessagePath: "/tmp/px-termination-log"
          securityContext:
            privileged: true
          volumeMounts:
            - name: dockersock
              mountPath: /var/run/docker.sock
            - name: etcpwx
              mountPath: /etc/pwx
            - name: optpwx
              mountPath: /opt/pwx
            - name: proc1nsmount
              mountPath: /host_proc/1/ns
            - name: sysdmount
              mountPath: /etc/systemd/system
      restartPolicy: Always
      serviceAccountName: px-account
      volumes:
        - name: dockersock
          hostPath:
            path: /var/vcap/sys/run/docker/docker.sock
        - name: etcpwx
          hostPath:
            path: /var/vcap/store/etc/pwx
        - name: optpwx
          hostPath:
            path: /var/vcap/store/opt/pwx
        - name: proc1nsmount
          hostPath:
            path: /proc/1/ns
        - name: sysdmount
          hostPath:
            path: /etc/systemd/system
---

apiVersion: v1
kind: ServiceAccount
metadata:
  name: portworx-pvc-controller-account
  namespace: kube-system
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
   name: portworx-pvc-controller-role
rules:
- apiGroups: [""]
  resources: ["persistentvolumes"]
  verbs: ["create","delete","get","list","update","watch"]
- apiGroups: [""]
  resources: ["persistentvolumes/status"]
  verbs: ["update"]
- apiGroups: [""]
  resources: ["persistentvolumeclaims"]
  verbs: ["get", "list", "update", "watch"]
- apiGroups: [""]
  resources: ["persistentvolumeclaims/status"]
  verbs: ["update"]
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["create", "delete", "get", "list", "watch"]
- apiGroups: ["storage.k8s.io"]
  resources: ["storageclasses"]
  verbs: ["get", "list", "watch"]
- apiGroups: [""]
  resources: ["endpoints", "services"]
  verbs: ["create", "delete", "get"]
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "list"]
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["get", "list"]
- apiGroups: [""]
  resources: ["events"]
  verbs: ["watch"]
- apiGroups: [""]
  resources: ["events"]
  verbs: ["create", "patch", "update"]
- apiGroups: [""]
  resources: ["serviceaccounts"]
  verbs: ["get"]
- apiGroups: [""]
  resources: ["configmaps"]
  verbs: ["get", "create", "update"]
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: portworx-pvc-controller-role-binding
subjects:
- kind: ServiceAccount
  name: portworx-pvc-controller-account
  namespace: kube-system
roleRef:
  kind: ClusterRole
  name: portworx-pvc-controller-role
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  annotations:
    scheduler.alpha.kubernetes.io/critical-pod: ""
  labels:
    tier: control-plane
  name: portworx-pvc-controller
  namespace: kube-system
spec:
  replicas: 3
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
    type: RollingUpdate
  template:
    metadata:
      annotations:
        scheduler.alpha.kubernetes.io/critical-pod: ""
      labels:
        name: portworx-pvc-controller
        tier: control-plane
    spec:
      containers:
      - command:
        - kube-controller-manager
        - --leader-elect=true
        - --address=0.0.0.0
        - --controllers=persistentvolume-binder
        - --use-service-account-credentials=true
        - --leader-elect-resource-lock=configmaps
        image: gcr.io/google_containers/kube-controller-manager-amd64:v1.10.4
        livenessProbe:
          failureThreshold: 8
          httpGet:
            host: 127.0.0.1
            path: /healthz
            port: 10252
            scheme: HTTP
          initialDelaySeconds: 15
          timeoutSeconds: 15
        name: portworx-pvc-controller-manager
        resources:
          requests:
            cpu: 200m
      hostNetwork: true
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                matchExpressions:
                  - key: "name"
                    operator: In
                    values:
                    - portworx-pvc-controller
              topologyKey: "kubernetes.io/hostname"
      serviceAccountName: portworx-pvc-controller-account
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: stork-config
  namespace: kube-system
data:
  policy.cfg: |-
    {
      "kind": "Policy",
      "apiVersion": "v1",
      "extenders": [
        {
          "urlPrefix": "http://stork-service.kube-system.svc:8099",
          "apiVersion": "v1beta1",
          "filterVerb": "filter",
          "prioritizeVerb": "prioritize",
          "weight": 5,
          "enableHttps": false,
          "nodeCacheCapable": false
        }
      ]
    }
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: stork-account
  namespace: kube-system
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
   name: stork-role
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list", "delete"]
  - apiGroups: [""]
    resources: ["persistentvolumes"]
    verbs: ["get", "list", "watch", "create", "delete"]
  - apiGroups: [""]
    resources: ["persistentvolumeclaims"]
    verbs: ["get", "list", "watch", "update"]
  - apiGroups: ["storage.k8s.io"]
    resources: ["storageclasses"]
    verbs: ["get", "list", "watch"]
  - apiGroups: [""]
    resources: ["events"]
    verbs: ["list", "watch", "create", "update", "patch"]
  - apiGroups: ["apiextensions.k8s.io"]
    resources: ["customresourcedefinitions"]
    verbs: ["create", "list", "watch", "delete"]
  - apiGroups: ["volumesnapshot.external-storage.k8s.io"]
    resources: ["volumesnapshots"]
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
  - apiGroups: ["volumesnapshot.external-storage.k8s.io"]
    resources: ["volumesnapshotdatas"]
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
  - apiGroups: [""]
    resources: ["configmaps"]
    verbs: ["get", "create", "update"]
  - apiGroups: [""]
    resources: ["services"]
    verbs: ["get"]
  - apiGroups: [""]
    resources: ["nodes"]
    verbs: ["get", "list", "watch"]
  - apiGroups: ["*"]
    resources: ["deployments", "deployments/extensions"]
    verbs: ["list", "get", "watch", "patch", "update", "initialize"]
  - apiGroups: ["*"]
    resources: ["statefulsets", "statefulsets/extensions"]
    verbs: ["list", "get", "watch", "patch", "update", "initialize"]
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: stork-role-binding
subjects:
- kind: ServiceAccount
  name: stork-account
  namespace: kube-system
roleRef:
  kind: ClusterRole
  name: stork-role
  apiGroup: rbac.authorization.k8s.io
---
kind: Service
apiVersion: v1
metadata:
  name: stork-service
  namespace: kube-system
spec:
  selector:
    name: stork
  ports:
    - protocol: TCP
      port: 8099
      targetPort: 8099
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  annotations:
    scheduler.alpha.kubernetes.io/critical-pod: ""
  labels:
    tier: control-plane
  name: stork
  namespace: kube-system
spec:
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
    type: RollingUpdate
  replicas: 3
  template:
    metadata:
      annotations:
        scheduler.alpha.kubernetes.io/critical-pod: ""
      labels:
        name: stork
        tier: control-plane
    spec:
      containers:
      - command:
        - /stork
        - --driver=pxd
        - --verbose
        - --leader-elect=true
        imagePullPolicy: Always
        image: openstorage/stork:1.1.3
        resources:
          requests:
            cpu: '0.1'
        name: stork
      hostPID: false
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                matchExpressions:
                  - key: "name"
                    operator: In
                    values:
                    - stork
              topologyKey: "kubernetes.io/hostname"
      serviceAccountName: stork-account
---
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: stork-snapshot-sc
provisioner: stork-snapshot
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: stork-scheduler-account
  namespace: kube-system
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: stork-scheduler-role
rules:
  - apiGroups: [""]
    resources: ["endpoints"]
    verbs: ["get", "update"]
  - apiGroups: [""]
    resources: ["configmaps"]
    verbs: ["get"]
  - apiGroups: [""]
    resources: ["events"]
    verbs: ["create", "patch", "update"]
  - apiGroups: [""]
    resources: ["endpoints"]
    verbs: ["create"]
  - apiGroups: [""]
    resourceNames: ["kube-scheduler"]
    resources: ["endpoints"]
    verbs: ["delete", "get", "patch", "update"]
  - apiGroups: [""]
    resources: ["nodes"]
    verbs: ["get", "list", "watch"]
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["delete", "get", "list", "watch"]
  - apiGroups: [""]
    resources: ["bindings", "pods/binding"]
    verbs: ["create"]
  - apiGroups: [""]
    resources: ["pods/status"]
    verbs: ["patch", "update"]
  - apiGroups: [""]
    resources: ["replicationcontrollers", "services"]
    verbs: ["get", "list", "watch"]
  - apiGroups: ["app", "extensions"]
    resources: ["replicasets"]
    verbs: ["get", "list", "watch"]
  - apiGroups: ["apps"]
    resources: ["statefulsets"]
    verbs: ["get", "list", "watch"]
  - apiGroups: ["policy"]
    resources: ["poddisruptionbudgets"]
    verbs: ["get", "list", "watch"]
  - apiGroups: [""]
    resources: ["persistentvolumeclaims", "persistentvolumes"]
    verbs: ["get", "list", "watch"]
  - apiGroups: ["storage.k8s.io"]
    resources: ["storageclasses"]
    verbs: ["get", "list", "watch"]
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: stork-scheduler-role-binding
subjects:
- kind: ServiceAccount
  name: stork-scheduler-account
  namespace: kube-system
roleRef:
  kind: ClusterRole
  name: stork-scheduler-role
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  labels:
    component: scheduler
    tier: control-plane
    name: stork-scheduler
  name: stork-scheduler
  namespace: kube-system
spec:
  replicas: 3
  template:
    metadata:
      labels:
        component: scheduler
        tier: control-plane
      name: stork-scheduler
    spec:
      containers:
      - command:
        - /usr/local/bin/kube-scheduler
        - --address=0.0.0.0
        - --leader-elect=true
        - --scheduler-name=stork
        - --policy-configmap=stork-config
        - --policy-configmap-namespace=kube-system
        - --lock-object-name=stork-scheduler
        image: gcr.io/google_containers/kube-scheduler-amd64:v1.10.4
        livenessProbe:
          httpGet:
            path: /healthz
            port: 10251
          initialDelaySeconds: 15
        name: stork-scheduler
        readinessProbe:
          httpGet:
            path: /healthz
            port: 10251
        resources:
          requests:
            cpu: '0.1'
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                matchExpressions:
                  - key: "name"
                    operator: In
                    values:
                    - stork-scheduler
              topologyKey: "kubernetes.io/hostname"
      hostPID: false
      serviceAccountName: stork-scheduler-account
```

## Limitations

If a PX storage node goes down and cluster is still in quorum, a storage less node will not automatically replace the storage node.
