---
layout: page
title: "PX Log Storage and Management with S3 using Fluentd"
keywords: portworx, container, Kubernetes, storage, Docker, S3, k8s, pv, persistent disk, fluentd, cluster logging, log management
sidebar: home_sidebar
---

* TOC
{:toc}

PX Logs management on Kubernetes using Fluentd. 

## PX Logs on Kubernetes
PX runs as a daemonset on the Kubernetes cluster which ensures that it runs on each node as part of the Kubernetes cluster. To allow access to the logs of a failed node, pod or a container in kubernetes we would have to adopt a complete logging solution. The need to access or view logs of failed container workloads means that we would need to enable storage and the logs should have a separate lifecycle than that of the container that creates it. 

## Log Collection
Fluentd is a log collector which enables you to log everything in a unified manner. Fluentd uses JSON as the log collection format. 


### Install fluentd on your kubernetes cluster.
The following instructions allows you to ship your Portworx logs to an S3 bucket managed by Portworx. 

Write to support@portworx.com or reach out to us on Slack [![](/images/slack.png){:height="24px" width="24px" alt="Slack" .slack-icon}](http://slack.portworx.com)

requesting for an S3 bucket to enable remote storage of the PX cluster logs.
Portworx would provide you with a specification file which needs to be applied on kubernetes. 

Apply the spec file provided by portworx with the following command. 
For eg: If the filename provided by Portworx is `fluentd-k8s-secrets.yaml` 

`kubectl apply -f <fluentd-k8s-secrets.yaml>` 

Create a file named ```fluentd-spec.yaml``` with the following contents and apply the configuration using `kubectl apply -f fluentd-spec.yaml`
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
     @type systemd
     path /var/log/journal
     filters [{ "_SYSTEMD_UNIT": "docker.service" }]
     pos_file /tmp/docker-service.pos
     tag journal.dockerd
     read_from_head true
     strip_underscores true
   </source>

    <source>
      @type systemd
      path /var/log/journal
      filters [{ "_SYSTEMD_UNIT": "kubelet.service" }]
      pos_file /tmp/k8s-kubelet.pos
      tag journal.kubelet
      read_from_head true
      strip_underscores true
    </source>

    <source>
      @type systemd
      path /var/log/journal
      filters [{ "_SYSTEMD_UNIT": "portworx.service" }]
      pos_file /tmp/portworxservice.pos
      tag journal.portworx
      read_from_head true
      strip_underscores true
    </source>

    <source>
      type tail
      path /var/log/containers/portworx*.log
      pos_file /tmp/px-container.log.pos
      time_format %Y-%m-%dT%H:%M:%S.%N
      tag portworx.*
      format json
      read_from_head true
      keep_time_key true
    </source>

    <filter portworx.**>
      @type rename_key
      rename_rule3 kubernetes.host hostname
    </filter>

    <filter journal.kubelet.**>
      @type rename_key
      rename_rule1 MESSAGE log
      rename_rule2 HOSTNAME hostname
    </filter>

    <filter journal.dockerd.**>
      @type rename_key
      rename_rule1 MESSAGE log
      rename_rule2 HOSTNAME hostname
    </filter>

    <filter journal.portworx.**>
      @type rename_key
      rename_rule1 MESSAGE log
      rename_rule2 HOSTNAME hostname
    </filter>

    <filter **>
      type kubernetes_metadata
    </filter>
    
    <match journal.portworx.**>
       @type s3
       aws_key_id #AWS_KEY_ID#
       aws_sec_key #AWS_SECRET_KEY_ID#
       s3_bucket #S3_BUCKET#
       s3_region #S3_REGION#
       path logs/
       buffer_path /var/log/journal-portworx/s3
       s3_object_key_format #indexUUID#_%{path}%{time_slice}_%{index}.%{file_extension}          
       time_slice_format %Y%m%d%H
       time_slice_wait 3m
       utc
       buffer_chunk_limit 256m
    </match>

    <match journal.dockerd.**>
       @type s3
       aws_key_id #AWS_KEY_ID#
       aws_sec_key #AWS_SECRET_KEY_ID#
       s3_bucket #S3_BUCKET#
       s3_region #S3_REGION#
       path logs/
       buffer_path /var/log/journal-dockerd/s3
       s3_object_key_format #indexUUID#_%{path}%{time_slice}_%{index}.%{file_extension}          
       time_slice_format %Y%m%d%H
       time_slice_wait 3m
       utc
       buffer_chunk_limit 256m
    </match>

    <match journal.kubelet.**>
       @type s3
       aws_key_id #AWS_KEY_ID#
       aws_sec_key #AWS_SECRET_KEY_ID#
       s3_bucket #S3_BUCKET#
       s3_region #S3_REGION#
       path logs/
       buffer_path /var/log/journal-kubelet/s3
       s3_object_key_format #indexUUID#_%{path}%{time_slice}_%{index}.%{file_extension}          
       time_slice_format %Y%m%d%H
       time_slice_wait 3m
       utc
       buffer_chunk_limit 256m
    </match>

    <match portworx.**>
       @type s3
       aws_key_id #AWS_KEY_ID#
       aws_sec_key #AWS_SECRET_KEY_ID#
       s3_bucket #S3_BUCKET#
       s3_region #S3_REGION#
       path logs/
       buffer_path /var/log/px-container/s3
       s3_object_key_format #indexUUID#_%{path}%{time_slice}_%{index}.%{file_extension}          
       time_slice_format %Y%m%d%H
       time_slice_wait 1m
       utc
       buffer_chunk_limit 256m
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
      initContainers:
      - name: fluentd-init
        image: hrishi/fluentd-initutils-s3:v1
        imagePullPolicy: Always
        securityContext:
          privileged: true
        command: ['/bin/sh']
        args: ['-c','/usr/bin/init-fluentd.sh portworx-service']
        env:
        - name: "AWS_KEY_ID"
          valueFrom:
            secretKeyRef:
              name: fluentd-px-secrets
              key: AWS_KEY_ID
        - name: "AWS_SECRET_KEY_ID"
          valueFrom:
            secretKeyRef:
              name: fluentd-px-secrets
              key: AWS_SECRET_KEY_ID
        - name: "S3_BUCKET"
          valueFrom:
            secretKeyRef:
              name: fluentd-px-secrets
              key: S3_BUCKET
        - name: "S3_REGION"
          valueFrom:
            secretKeyRef:
              name: fluentd-px-secrets
              key: S3_REGION
        volumeMounts:
        - name: config
          mountPath: /tmp
      containers:
        - name: fluentd
          image: hrishi/fluentd:v1
          securityContext:
            privileged: true
          volumeMounts:
            - name: varlog
              mountPath: /var/log
            - name: runlog
              mountPath: /run/log
            - name: varlibdockercontainers
              mountPath: /var/lib/docker/containers
            - name: posloc
              mountPath: /tmp
            - name: config
              mountPath: /fluentd/etc/fluent.conf
              subPath: fluent.conf
      volumes:
        - name: varlog
          hostPath:
            path: /var/log
        - name: runlog
          hostPath:
            path: /run/log
        - name: varlibdockercontainers
          hostPath:
            path: /var/lib/docker/containers
        - name: config
          configMap:
            name: fluentd
        - name: posloc
          hostPath:
            path: /mnt

```
This configuration would enable cluster level logging for the Portworx Pods and publish those logs to an S3 bucket. The logs would be retained for 61 days in the S3 bucket. 