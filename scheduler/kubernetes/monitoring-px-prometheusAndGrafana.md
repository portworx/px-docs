---
layout: page
title: "Monitoring Portworx using Prometheus and Grafana"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, pv, persistent disk, monitoring, prometheus, alertmanager, servicemonitor, grafana
sidebar: home_sidebar
---

* TOC
{:toc}

Monitoring Portworx using Prometheus and Grafana

## About Prometheus
Prometheus is an opensource monitoring and alerting toolkit. Prometheus consists of several components some of which are listed below.
- The Prometheus server which scrapes(collects) and stores time series data based on a pull mechanism.
- A rules engine which allows generation of Alerts based on the scraped metrices.  
- An alertmanager for handling alerts.  
- Multiple integrations for graphing and dashboarding. 

In this document we would explore the monitoring of Portworx via Prometheus. The integration is natively supported by Portworx since portworx stands up metrics on a REST endpoint which can readily be scraped by Prometheus. 

The following instructions allows you to monitor Portworx via Prometheus and allow the Alertmanager to provide alerts based on configured rules.  

The Prometheus [Operator](https://coreos.com/operators/prometheus/docs/latest/user-guides/getting-started.html) creates, configures and manages a prometheus cluster. 

The prometheus operator manages 3 customer resource definitions namely
- Prometheus
The Prometheus CRD defines a Prometheus setup to be run on a Kubernetes cluster. The Operator creates a Statefulset for each definition of the Prometheus resource.

- ServiceMonitor
The Servicemonitor CRD allows the definition of how kubernetes services could be monitored based on label selectors. The Service abstraction allows Prometheus to inturn monitor underlying Pods  

- Alertmanager
The Alertmanager CRD allows the definition of an Alertmanager instance within the kubernetes cluster. The alertmanager expects a valid configuration in the form of a `secret` called `alertmanager-name`

## About Grafana
Grafana is a dashboarding and visualization tool with integrations to several timeseries datasources. It is used to create dashboards for the monitoring data with customisable visualizations. We would use Prometheus as the source of data to view Portworx monitoring metrics. 

### Prerequisites
- A running Portworx cluster. 

#### Install the Prometheus Operator
Create a file named `prometheus-operator.yaml` with the below contents and apply the spec . 

```
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: prometheus-operator
  namespace: kube-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: prometheus-operator
subjects:
- kind: ServiceAccount
  name: prometheus-operator
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  name: prometheus-operator
  namespace: kube-system
rules:
- apiGroups:
  - extensions
  resources:
  - thirdpartyresources
  verbs:
  - "*"
- apiGroups:
  - apiextensions.k8s.io
  resources:
  - customresourcedefinitions
  verbs: ["*"]
- apiGroups:
  - monitoring.coreos.com
  resources:
  - alertmanagers
  - prometheuses
  - prometheuses/finalizers
  - servicemonitors
  verbs:
  - "*"
- apiGroups:
  - apps
  resources:
  - statefulsets
  verbs: ["*"]
- apiGroups: [""]
  resources:
  - configmaps
  - secrets
  verbs: ["*"]
- apiGroups: [""]
  resources:
  - pods
  verbs: ["list", "delete"]
- apiGroups: [""]
  resources:
  - services
  - endpoints
  verbs: ["get", "create", "update"]
- apiGroups: [""]
  resources:
  - nodes
  verbs: ["list", "watch"]
- apiGroups: [""]
  resources:
  - namespaces
  verbs: ["list"]
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: prometheus-operator
  namespace: kube-system  
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  labels:
    k8s-app: prometheus-operator
  name: prometheus-operator
  namespace: kube-system
spec:
  replicas: 1
  template:
    metadata:
      labels:
        k8s-app: prometheus-operator
    spec:
      containers:
      - args:
        - --kubelet-service=kube-system/kubelet
        - --config-reloader-image=quay.io/coreos/configmap-reload:v0.0.1
        image: quay.io/coreos/prometheus-operator:v0.17.0
        name: prometheus-operator
        ports:
        - containerPort: 8080
          name: http
        resources:
          limits:
            cpu: 200m
            memory: 100Mi
          requests:
            cpu: 100m
            memory: 50Mi
      securityContext:
        runAsNonRoot: true
        runAsUser: 65534
      serviceAccountName: prometheus-operator
```

`kubectl apply -f <prometheus-operator.yaml>` 
 
#### Install the Service Monitor

Create a file named `service-monitor.yaml` with the below contents and apply the spec . 
```
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  namespace: kube-system
  name: portworx-prometheus-sm
  labels:
    name: portworx-prometheus-sm
spec:
  selector:
    matchLabels:
      name: portworx
  namespaceSelector: 
    any: true
  endpoints:
  - port: px-api
    targetPort: 9001
```

`kubectl apply -f <service-monitor.yaml>` 

#### Install the Alertmanager
Create a file named `alertmanager.yaml` with the following contents and create a secret from it. 
Make sure you add the relevant email addresses in the below config. 
```
global:
  # The smarthost and SMTP sender used for mail notifications.
  smtp_smarthost: 'smtp.gmail.com:587'
  smtp_from: '<sender-email-address>'
  smtp_auth_username: "<sender-email-address>"
  smtp_auth_password: '<sender-email-password>'
route:
  group_by: [Alertname]
  # Send all notifications to me.
  receiver: email-me
receivers:
- name: email-me
  email_configs:
  - to: <receiver-email-address>
    from: <sender-email-address>
    smarthost: smtp.gmail.com:587
    auth_username: "<sender-email-address>"
    auth_identity: "<sender-email-address>"
    auth_password: "<sender-email-password>"
## Edit the file and create a secret with it using the following command
```
`kubectl create secret generic alertmanager-portworx --from-file=alertmanager.yaml`


Create a file named `alertmanager-cluster.yaml` with the below contents and apply the spec on your cluster. 
```
apiVersion: monitoring.coreos.com/v1
kind: Alertmanager
metadata:
  name: portworx #This name is important since the Alertmanager pods wont start unless a secret named alertmanager-${ALERTMANAGER_NAME} is created. in this case if would expect alertmanager-portworx secret in the kube-system namespace 
  namespace: kube-system
  labels:
    alertmanager: portworx
spec:
  replicas: 3
```
`kubectl apply -f alertmanager-cluster.yaml`


Create a file named `alertmanager-service.yaml` with the following contents and apply the spec

```
apiVersion: v1
kind: Service
metadata:
  name: alertmanager-portworx
  namespace: kube-system
spec:
  type: NodePort
  ports:
  - name: web
    nodePort: 30903
    port: 9093
    protocol: TCP
    targetPort: web
  selector:
    alertmanager: portworx
```
`kubectl apply -f alertmanager-service.yaml`

#### Install Prometheus

Create a file named `prometheus-rules.yaml` with the following contents and apply the spec
```
kind: ConfigMap
apiVersion: v1
metadata:
  name: prometheus-portworx-rules
  namespace: kube-system
  labels:
    role: prometheus-portworx-rulefiles
    prometheus: portworx
data:
  portworx.rules.yaml: |+
    groups:
    - name: portworx.rules
      rules:
      - alert: PortworxVolumeUsageCritical
        expr: 100 * (px_volume_usage_bytes / px_volume_capacity_bytes) > 80
        for: 5m
        labels:
          issue: Portworx volume {{$labels.volumeid}} usage on {{$labels.host}} is high.
          severity: critical
        annotations:
          description: Portworx volume {{$labels.volumeid}} on {{$labels.host}} is over
            80% used for more than 10 minutes.
          summary: Portworx volume capacity is at {{$value}}% used.
      - alert: PortworxVolumeUsage
        expr: 100 * (px_volume_usage_bytes / px_volume_capacity_bytes) > 70
        for: 5m
        labels:
          issue: Portworx volume {{$labels.volumeid}} usage on {{$labels.host}} is critical.
          severity: warning
        annotations:
          description: Portworx volume {{$labels.volumeid}} on {{$labels.host}} is over
            70% used for more than 10 minutes.
          summary: Portworx volume {{$labels.volumeid}} on {{$labels.host}} is at {{$value}}%
            used.
      - alert: PortworxVolumeWillFill
        expr: (px_volume_usage_bytes / px_volume_capacity_bytes) > 0.7 and predict_linear(px_cluster_disk_available_bytes[1h],
          14 * 86400) < 0
        for: 10m
        labels:
          issue: Disk volume {{$labels.volumeid}} on {{$labels.host}} is predicted to
            fill within 2 weeks.
          severity: warning
        annotations:
          description: Disk volume {{$labels.volumeid}} on {{$labels.host}} is over 70%
            full and has been predicted to fill within 2 weeks for more than 10 minutes.
          summary: Portworx volume {{$labels.volumeid}} on {{$labels.host}} is over 70%
            full and is predicted to fill within 2 weeks.
      - alert: PortworxStorageUsageCritical
        expr: 100 * (1 - px_cluster_disk_utilized_bytes / px_cluster_disk_available_bytes) < 20
        for: 5m
        labels:
          issue: Portworx storage {{$labels.volumeid}} usage on {{$labels.host}} is high.
          severity: critical
        annotations:
          description: Portworx storage {{$labels.volumeid}} on {{$labels.host}} is over
            80% used for more than 10 minutes.
          summary: Portworx storage capacity is at {{$value}}% used.
      - alert: PortworxStorageUsage
        expr: 100 * (1 - (px_cluster_disk_utilized_bytes / px_cluster_disk_available_bytes)) < 30
        for: 5m
        labels:
          issue: Portworx storage {{$labels.volumeid}} usage on {{$labels.host}} is critical.
          severity: warning
        annotations:
          description: Portworx storage {{$labels.volumeid}} on {{$labels.host}} is over
            70% used for more than 10 minutes.
          summary: Portworx storage {{$labels.volumeid}} on {{$labels.host}} is at {{$value}}%
            used.
      - alert: PortworxStorageWillFill
        expr: (100 * (1 - (px_cluster_disk_utilized_bytes / px_cluster_disk_available_bytes))) < 30 and predict_linear(px_cluster_disk_available_bytes[1h], 14 * 86400) < 0
        for: 10m
        labels:
          issue: Portworx storage {{$labels.volumeid}} on {{$labels.host}} is predicted
            to fill within 2 weeks.
          severity: warning
        annotations:
          description: Portworx storage {{$labels.volumeid}} on {{$labels.host}} is over
            70% full and has been predicted to fill within 2 weeks for more than 10 minutes.
          summary: Portworx storage {{$labels.volumeid}} on {{$labels.host}} is over 70%
            full and is predicted to fill within 2 weeks.
      - alert: PortworxStorageNodeDown
        expr: max(px_cluster_status_nodes_storage_down) > 0
        for: 5m
        labels:
          issue: Portworx Storage Node is Offline.
          severity: critical
        annotations:
          description: Portworx Storage Node has been offline for more than 5 minutes.
          summary: Portworx Storage Node is Offline.
      - alert: PortworxQuorumUnhealthy
        expr: max(px_cluster_status_cluster_quorum) > 1
        for: 5m
        labels:
          issue: Portworx Quorum Unhealthy.
          severity: critical
        annotations:
          description: Portworx cluster Quorum Unhealthy for more than 5 minutes.
          summary: Portworx Quorum Unhealthy.
      - alert: PortworxMemberDown
        expr: (max(px_cluster_status_cluster_size) - count(px_cluster_status_cluster_size)) > 0
        for: 5m
        labels:
          issue: Portworx cluster member(s) is(are) down.
          severity: critical
        annotations:
          description: 'Portworx cluster member(s) has(have) been down for
            more than 5 minutes.'
          summary: Portworx cluster member(s) is(are) down.
```
`kubectl apply -f prometheus-rules.yaml`

Create a file named `prometheus-cluster.yaml` with the following contents and apply the spec
```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: prometheus
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  name: prometheus
  namespace: kube-system
rules:
- apiGroups: [""]
  resources:
  - nodes
  - services
  - endpoints
  - pods
  verbs: ["get", "list", "watch"]
- apiGroups: [""]
  resources:
  - configmaps
  verbs: ["get"]
- nonResourceURLs: ["/metrics"]
  verbs: ["get"]
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: prometheus
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: prometheus
subjects:
- kind: ServiceAccount
  name: prometheus
  namespace: kube-system
---
apiVersion: monitoring.coreos.com/v1
kind: Prometheus
metadata:
  name: prometheus
  namespace: kube-system  
spec:
  replicas: 2
  logLevel: debug
  serviceAccountName: prometheus
  alerting:
    alertmanagers:
    - namespace: kube-system
      name: alertmanager-portworx
      port: web
  serviceMonitorSelector:
    matchLabels:
      name: portworx-prometheus-sm
  namespaceSelector:
    matchNames:
    - kube-system
  resources:
    requests:
      memory: 400Mi
  ruleSelector:
    matchLabels:
      role: prometheus-portworx-rulefiles
      prometheus: portworx
  namespaceSelector:
    matchNames:
    - kube-system
---
apiVersion: v1
kind: Service
metadata:
  name: prometheus
  namespace: kube-system
spec:
  type: NodePort
  ports:
  - name: web
    nodePort: 30900
    port: 9090
    protocol: TCP
    targetPort: web
  selector:
    prometheus: prometheus
---
```
`kubectl apply -f prometheus-cluster.yaml`

#### Post Install verification

Navigate to the Prometheus web UI by accessing the service over the `NodePort 30900` . You should be able to navigate to the `Targets` and `Rules` section of the Prometheus dashboard which lists the Portworx cluster endpoints as well as the Alerting rules as specified earlier. 

#### Installing Grafana

Download the below files in a folder named `grafanaConfigurations`

Download the custom [Portworx dashboard](https://github.com/portworx/px-docs/blob/gh-pages/k8s-samples/grafana/dashboards/Portworx_Volume_template.json) created for Grafana to view Portworx Volume metrics. 

Download the Grafana [dashboard configuration](https://github.com/portworx/px-docs/blob/gh-pages/k8s-samples/grafana/config/dashboardConfig.yaml) file 

Create a configmap from the above files with the below command
`kubectl create configmap grafana-config --from-file=$(pwd)/grafanaConfigurations -nkube-system` 

Create a file named `grafana-deployment.yaml` with the below contents and apply the spec.

```
apiVersion: v1
kind: Service
metadata:
  name: grafana
  namespace: kube-system
  labels:
    app: grafana
spec:
  type: NodePort
  ports:
  - port: 3000
    nodePort: 30950
  selector:
    app: grafana
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: grafana
  namespace: kube-system
  labels:
    app: grafana
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: grafana
    spec:
      containers:
      - image: grafana/grafana
        name: grafana
        imagePullPolicy: IfNotPresent
        resources:
          limits:
            cpu: 100m
            memory: 100Mi
          requests:
            cpu: 100m
            memory: 100Mi
        env:
          - name: GF_AUTH_BASIC_ENABLED
            value: "true"
          - name: GF_AUTH_ANONYMOUS_ENABLED
            value: "false"
        readinessProbe:
          httpGet:
            path: /login
            port: 3000
        volumeMounts:
        - name: grafana-config
          mountPath: /etc/grafana/provisioning/dashboards/config.yaml
          subPath: config.yaml
        - name: dashboard-templates
          mountPath: /var/lib/grafana/dashboards
      volumes:
      - name: grafana-config
        configMap:
          name: grafana-config
          items:
          - key: config.yaml
            path: config.yaml
      - name: dashboard-templates
        configMap:
          name: grafana-config
```

`kubectl apply -f grafana-deployment.yaml`

Access the Grafana dashboard by navigating at the `Nodeport 30950`. You would need to create a datasource for the Portworx grafana dashboard metrics to be populated. 
Navigate to Configurations --> Datasources. 
Create a datasource named `prometheus`. Enter the Prometheus endpoint as obtained in the install verification step for Prometheus from the above section.

![grafanadatasource](/images/datasource-creation-grafana.png){:width="655px" height="200px"}

#### Post install verification

Select the Portworx volume metrics dashboard on Grafana to view the Portworx metrics. 
![grafanadashboard](/images/grafana-portworx-dashboard.png){:width="655px" height="200px"}
