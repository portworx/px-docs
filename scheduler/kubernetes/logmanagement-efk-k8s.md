---
layout: page
title: "PX Log Storage and Management with Elastic Search, Kibana and, Fluentd on K8s"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, pv, persistent disk, elastic, fluentd, elastic search, kibana, cluster logging, log management
sidebar: home_sidebar
---

* TOC
{:toc}

PX Logs management on Kubernetes using Elastic search, Kibana and Fluentd. 

## PX Logs on Kubernetes
PX runs as a deamonset on the Kubernetes cluster which ensures that it runs on each node as part of the Kubernetes cluster. To allow access to the logs of a failed node, pod or a container in kubernetes we would have to adopt a complete logging solution. The need to access or view logs of failed container workloads means that we would need to enable storage and the logs should have a seperate lifecycle than that of the container that creates it. 

Elastic Search, FluentD and Kibana allow us to setup a complete logging solution for accessing logs of the PX pods scheduled on the kubernetes cluster. 

Setup Elastic Search and Kibana on your kubernetes cluster by following the the steps mentioned in the document here
[Elastic Search and Kibana on Kubernetes](https://docs.portworx.com/scheduler/kubernetes/elasticstack-kibana-k8s.html)

## Log Collection
Fluentd is a log collector which enables you to log everything in a unified manner. Fluentd uses JSON as the log collection format. 

### Install fluentd on your kubernetes cluster.
fluentd runs as a deamonset on the kubernetes cluster thus allows it to collect logs from all the PX pods placed on each node. 
If the need is to also enable the entire kubernetes cluster level logging, then please add `@include kubernetes.conf` and add a relevant `match` directive in the `ConfigMap`

Create a file named ```fluentd-spec.yaml``` and apply the configuration using `kubectl`
```
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: fluentd
  namespace: kube-system

---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  name: fluentd
  namespace: kube-system
rules:
- apiGroups:
  - ""
  resources:
  - namespaces
  - pods
  - pods/logs
  verbs:
  - get
  - list
  - watch

---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: fluentd
roleRef:
  kind: ClusterRole
  name: fluentd
  apiGroup: rbac.authorization.k8s.io
subjects:
- kind: ServiceAccount
  name: fluentd
  namespace: kube-system
- kind: ServiceAccount
  name: default
  namespace: kube-system   

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluentd
  namespace: kube-system
data:
  fluent.conf: |

    <source>
      type tail
      path /var/log/containers/portworx*.log
      pos_file /var/log/px-container.log.pos
      time_format %Y-%m-%dT%H:%M:%S.%N
      tag portworx.*
      format json
      read_from_head true
      keep_time_key true
    </source>
    <filter kubernetes.**>
      type kubernetes_metadata
    </filter>
    <match portworx.**>
       type elasticsearch
       log_level info
       include_tag_key true
       logstash_prefix px-log ## Prefix for creating an Elastic search index. 
       ## IP Address or hostname of the Elastic search client service. 
       host 10.111.118.234
       port 9200
       logstash_format true
       buffer_chunk_limit 2M
       buffer_queue_limit 32
       flush_interval 60s  # flushes events ever minute. Can be configured as needed. 
       max_retry_wait 30 
       disable_retry_limit
       num_threads 8
    </match>
---
apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  name: fluentd
  namespace: kube-system
  labels:
    k8s-app: fluentd-logging
    version: v1
    kubernetes.io/cluster-service: "true"
spec:
  template:
    metadata:
      labels:
        k8s-app: fluentd-logging
        version: v1
        kubernetes.io/cluster-service: "true"
    spec:
      serviceAccount: fluentd
      serviceAccountName: fluentd
      containers:
        - name: fluentd
          image: fluent/fluentd-kubernetes-daemonset:elasticsearch
          volumeMounts:
            - name: varlog
              mountPath: /var/log
            - name: varlibdockercontainers
              mountPath: /var/lib/docker/containers
            - name: config
              mountPath: /fluentd/etc/fluent.conf
              subPath: fluent.conf
      volumes:
        - name: varlog
          hostPath:
            path: /var/log
        - name: varlibdockercontainers
          hostPath:
            path: /var/lib/docker/containers
        - name: config
          configMap:
            name: fluentd
```

This configuration would enable cluster level logging for the Portworx Pods. 

A bit more about fluentd. 

The three important directives to be used to allow fluentd to collect logs. 
a) source
b) filter
c) match

a) A source directive in the config file allows fluentd to understand its input sources. a source directive includes a `type` parameter which defines the input source. In the above specification the input type is mentioned as `tail` which is similar to `tail -F` and it tails the logs from the `path` variable. 

b) A filter directive in fluentd allows modification of event streams. It is typically used to enrich data or, to filter out events from the input source or, to mask data for privacy considerations. 

c) A match directive is the output or the action to be taken based on the input. In the specification above there is a `match` directive specified which inserts data into the elastic search cluster in the logstash format. 

fluentd would collect logs from the `path /var/log/containers` and push them to the Elasticsearch database. 
A view of Elastic search indices for cluster level logs collected for all the pods. 

```
curl -XGET 'http://10.108.118.191:9200/_cat/indices?v&pretty'
health status index               uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   px-logs-2017.09.12  LIHcjH74Q2ScLoDf5hAQIA   5   1       1178            0      1.8mb          895kb
green  open   px-logs-2017.09.13  ks7A6lLTR8CUOROgXPiPCQ   5   1        759            0      2.1mb          1.1mb
green  open   .kibana             Fp23fd8BSkyV0iDtVuao-w   1   1         10            1     78.6kb         39.3kb
green  open   px-logs-2017.09.11  Rf5ZMV53RVOXqlwInbCUzw   5   1       7247            0      7.9mb          4.3mb
```

### Screen grabs

Login to the kibana dashboard and navigate to the `Management` submenu item. This allows you to create an index pattern which stores the collected logs. In our case the logs are stored in indexes with the name `px-logs-` followed by the date. This is configurable and can be changed in the `match` directive for the variable `logstash_prefix`

![CreateKibanaIndexpatterns](/images/kibana-px-index-pattern.png){:width="655px" height="200px"}

Upon creation of the Index, the screen would show you all the fields which are part of the index. These fields can be used for searches and filtering while viewing the logs.

![FieldsoftheIndex](/images/px-logs-fields.png){:width="655px" height="200px"}

Navigate to the `Discover` menu item. You can select the index pattern which was created earlier. It would list the available colums on the left hand side menu. In our setup, the columns with the pod name, hostname, log and the time are selected, but any columns could be selected for viewing the logs. You could also save the searches and search/view logs based on time. 

![ViewPXlogs](/images/view-px-logs.png){:width="655px" height="200px"}

