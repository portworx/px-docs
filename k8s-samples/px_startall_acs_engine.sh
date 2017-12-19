#!/bin/bash
#
# Use this script to deploy an entire stack on Kubernetes:
#     - etcd cluster
#     - px daemonset
#     - influxdb on pvc
#     - Lighthouse
#
# Assumes running instance of Kubernetes 1.6 or above
#
# Note:  Lots of timing issues that will go away once etcd-operator is in better shape
#

# Can't assume 'kubectl' is running on master, so need an IP to check liveliness of Lighthouse
MASTER_IP=`kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="ExternalIP")].address}' | awk '{print $1}'`
if [ -z "$MASTER_IP" ]
then
   MASTER_IP=`kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}' | awk '{print $1}'`
fi

# Adjust for CoreOS if needed
if kubectl describe nodes | grep 'OS Image' | grep -i CoreOS > /dev/null
then
   HEADERS=/lib/modules
else
   HEADERS=/usr/src
fi

# Configure PX interfaces.
# Default to crb0 for acs-engine
DIFACE=crb0
MIFACE=crb0

#######################################
function waitfor() {
   while true
   do
        if kubectl get $1 2>&1 | egrep 'No resources found|the server doesn.t have a resource type'
        then
            echo "Waiting for $1 ..."
            sleep 5
        else
            break
        fi
   done
}

function waitfor_lighthouse() {
   while true
   do
        if ! kubectl get pod | grep px-lighthouse | grep Running > /dev/null
        then
            echo "Waiting for px-lighthouse startup ..."
            sleep 10
        else
            if ! curl -X GET -H "Accept:application/json" -H "Authorization:Basic $AUTHKEY"  http://${MASTER_IP}:30062 > /dev/null 2>&1
            then
                echo "Waiting for px-lighthouse responsiveness ..."
                sleep 10
                continue
            else
                echo "Lighthouse is running ..."
                break
            fi
        fi
   done
}

try_etcd() {
cat <<EOF | kubectl create -f -
---
apiVersion: "etcd.coreos.com/v1beta1"
kind: "Cluster"
metadata:
  name: "etcd-cluster"
spec:
  size: 3
  version: "3.1.8"
EOF
}



cat <<EOF | kubectl create -f -
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  name: etcd-operator
rules:
- apiGroups:
  - etcd.coreos.com
  resources:
  - clusters
  verbs:
  - "*"
- apiGroups:
  - extensions
  resources:
  - thirdpartyresources
  verbs:
  - "*"
- apiGroups:
  - storage.k8s.io
  resources:
  - storageclasses
  verbs:
  - "*"
- apiGroups:
  - ""
  resources:
  - pods
  - services
  - endpoints
  - persistentvolumeclaims
  - events
  verbs:
  - "*"
- apiGroups:
  - apps
  resources:
  - deployments
  verbs:
  - "*"
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: etcd-operator
  namespace: default
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: etcd-operator
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: etcd-operator
subjects:
- kind: ServiceAccount
  name: etcd-operator
  namespace: default
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: etcd-operator
spec:
  replicas: 1
  template:
    metadata:
      labels:
        name: etcd-operator
    spec:
      serviceAccountName: etcd-operator
      containers:
      - name: etcd-operator
        image: quay.io/coreos/etcd-operator:v0.4.1
        env:
        - name: MY_POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        - name: MY_POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
EOF

# No --- you really shouldn't have to wait for 'thirdpartyresources'
waitfor thirdpartyresources

while true
do
    if ! try_etcd
    then
       echo "Waiting for etcd to start ..."
       sleep 2
    else
       break
    fi
done

# No --- you really shouldn't have to wait for 'cluster'
waitfor cluster

cat <<EOF | kubectl create -f -
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: etcd
    etcd_cluster: etcd-cluster
  name: etcd-px-client
  namespace: default
spec:
  ports:
  - name: client
    port: 2379
    protocol: TCP
    targetPort: 2379
    nodePort: 30061
  selector:
    app: etcd
    etcd_cluster: etcd-cluster
  sessionAffinity: None
  type: NodePort
status:
  loadBalancer: {}

EOF

ETCD_IP=`kubectl get svc etcd-px-client -o yaml | grep clusterIP | awk '{print $2}'`

cat <<EOF | kubectl apply -f -
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    service: px-lighthouse
  name: px-lighthouse
spec:
  replicas: 1
  strategy:
    type: Recreate
  template:
    metadata:
      creationTimestamp: null
      labels:
        io.kompose.service: px-lighthouse
    spec:
      containers:
      - command:
        - /bin/bash
        - /lighthouse/on-prem-entrypoint.sh
        - -k
        - etcd:http://${ETCD_IP}:2379
        - -d
        - http://admin:password@influx-px:8086
        env:
        - name: PWX_INFLUXDB
          value: '"http://influx-px:8086"'
        - name: PWX_INFLUXUSR
          value: '"admin"'
        - name: PWX_INFLUXPW
          value: '"password"'
        - name: PWX_HOSTNAME
        - name: PWX_PX_PRECREATE_ADMIN
          value: "true"
        - name: PWX_PX_COMPANY_NAME
          value: yourcompany
        - name: PWX_PX_ADMIN_EMAIL
          value: portworx@yourcompany.com
        image: portworx/px-lighthouse
        name: px-lighthouse
        ports:
        - containerPort: 80
        resources: {}
        volumeMounts:
        - mountPath: /var/log
          name: px-lighthouse-claim0
      restartPolicy: Always
      volumes:
      - name: px-lighthouse-claim0
        emptyDir: {}
status: {}
---
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  labels:
    service: px-lighthouse
  name: px-lighthouse
spec:
  ports:
  - name: "80"
    port: 80
    targetPort: 80
    nodePort: 30062
  selector:
    io.kompose.service: px-lighthouse
  type: NodePort
status:
  loadBalancer: {}

EOF

waitfor_lighthouse

AUTHKEY=`echo -n portworx@yourcompany.com:admin | base64`
TOKEN=`curl -X POST -H "Accept:application/json" -H "Authorization:Basic $AUTHKEY" http://${MASTER_IP}:30062/api/clusters/create/\?name\=my-cluster\&clusterid\=my-cluster | sed -e 's/"//g'`
echo LH TOKEN = $TOKEN

cat <<EOF | kubectl create -f -
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: px-account
  namespace: kube-system
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1alpha1
metadata:
   name: node-get-put-list-role
rules:
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["get", "update", "list"]
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1alpha1
metadata:
  name: node-role-binding
subjects:
- apiVersion: v1
  kind: ServiceAccount
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
spec:
  selector:
    name: portworx
  ports:
    - protocol: TCP
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
    type: OnDelete
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
          image: portworx/px-enterprise:latest
          terminationMessagePath: "/tmp/px-termination-log"
          imagePullPolicy: Always
          env:
          - name: API_SERVER
            value: "http://${MASTER_IP}:30062"
          args:
             ["",
              "-t ${TOKEN}",
              "",
              "",
              "-a -f",
              "-d ${DIFACE}",
              "-m ${MIFACE}",
              "",
              "",
              "",
              "",
              "-x", "kubernetes"]

          livenessProbe:
            initialDelaySeconds: 840 # allow image pull in slow networks
            httpGet:
              host: 127.0.0.1
              path: /status
              port: 9001
          readinessProbe:
            periodSeconds: 10
            httpGet:
              host: 127.0.0.1
              path: /status
              port: 9001
          securityContext:
            privileged: true
          volumeMounts:
            - name: dockersock
              mountPath: /var/run/docker.sock
            - name: libosd
              mountPath: /var/lib/osd:shared
            - name: dev
              mountPath: /dev
            - name: etcpwx
              mountPath: /etc/pwx/
            - name: optpwx
              mountPath: /export_bin:shared
            - name: cores
              mountPath: /var/cores
            - name: kubelet
              mountPath: /var/lib/kubelet:shared
            - name: src
              mountPath: $HEADERS
            - name: dockerplugins
              mountPath: /run/docker/plugins
      initContainers:
        - name: px-init
          image: portworx/px-init
          terminationMessagePath: "/tmp/px-init-termination-log"
          securityContext:
            privileged: true
          volumeMounts:
            - name: hostproc
              mountPath: /media/host/proc
      restartPolicy: Always
      tolerations:
      - key: node-role.kubernetes.io/master
        effect: NoSchedule
      serviceAccountName: px-account
      volumes:
        - name: libosd
          hostPath:
            path: /var/lib/osd
        - name: dev
          hostPath:
            path: /dev
        - name: etcpwx
          hostPath:
            path: /etc/pwx
        - name: optpwx
          hostPath:
            path: /opt/pwx/bin
        - name: cores
          hostPath:
            path: /var/cores
        - name: kubelet
          hostPath:
            path: /var/lib/kubelet
        - name: src
          hostPath:
            path: $HEADERS
        - name: dockerplugins
          hostPath:
            path: /run/docker/plugins
        - name: dockersock
          hostPath:
            path: /var/run/docker.sock
        - name: hostproc
          hostPath:
            path: /proc


---
apiVersion: storage.k8s.io/v1beta1
kind: StorageClass
metadata:
  name: portworx-sc
provisioner: kubernetes.io/portworx-volume
parameters:
  repl: "3"

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvcsc001
  annotations:
    volume.beta.kubernetes.io/storage-class: portworx-sc
  creationTimestamp: null
  labels:
    service: influx-px-claim0
  name: influx-px-claim0
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
status: {}

---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    service: influx-px
  name: influx-px
spec:
  replicas: 1
  strategy:
    type: Recreate
  template:
    metadata:
      creationTimestamp: null
      labels:
        service: influx-px
    spec:
      containers:
      - env:
        - name: MYSQL_ALLOW_EMPTY_PASSWORD
          value: "true"
        - name: ADMIN_USER
          value: '"admin"'
        - name: INFLUXDB_INIT_PWD
          value: '"password"'
        - name: PRE_CREATE_DB
          value: '"px_stats"'
        image: tutum/influxdb
        name: influx-px
        ports:
        - containerPort: 8083
        - containerPort: 8086
        resources: {}
        volumeMounts:
        - mountPath: /data
          name: influx-px-claim0
      restartPolicy: Always
      volumes:
      - name: influx-px-claim0
        persistentVolumeClaim:
          claimName: influx-px-claim0
status: {}

---
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  labels:
    service: influx-px
  name: influx-px
spec:
  ports:
  - name: "8083"
    port: 8083
    targetPort: 8083
  - name: "8086"
    port: 8086
    targetPort: 8086
  selector:
    service: influx-px
status:
  loadBalancer: {}

EOF

echo
echo "Portworx has been deployed and will be available shortly at:"
echo "http://${MASTER_IP}:30062"
echo
