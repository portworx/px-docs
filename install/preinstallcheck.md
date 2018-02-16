---
layout: page
title: "Portworx Pre-Install Check"
keywords: install, pre-flight, pre-check
sidebar: home_sidebar
---


The portworx/px-pre-flight container performs a number of checks which can be run on a node or cluster of nodes.  
It evaluates each node separately and outputs information on whether PX will possibly have a problem running on the node.

The things it checks today are:

    CPU  (>= 4)
    Memory (>= 4GB)
    Time   (> 10sec diff from time.nist.gov)
    Docker Version (> 1.10)
    Shared mount capability  (Passed in volume mount is “shared”)
    Etcd connectivity  ( -k < HTTP Etcd URL> , create/read/remove key)
    Space availability (allowed space for /var/lib & /opt)
    Attached storage  (list unmounted storage)
    PX module kernel header dependency (Check available host headers & mirrors)
    Available local sockets. (Check local sockets to see if they are in use.)

Each check is given a PASS / WARN / FAIL rating.    If there is a WARN or FAIL a NOTE may be displayed with information 
on the issue and where possible, a URL to the “docs.portworx.com” reference for more information.
A "FAIL" check indicates an issue which will cause PX to NOT run on the node.   
A check with a "WARN" result indicates that PX will run however not optimally.  A "PASS" is ideal and PX will run with no issues.  A FAIL or WARN result will result in a non-zero exit code on the container.  The exit codes 0 = "PASS", 1 = "FAIL", 2 = "WARN" and 3 = "WARN + FAIL".

The check is distributed via a container and needs to be run on each node or using the podset yaml and kubectl.   
The logging is currently captured in the container logs and also written to an output file on the node in /var/log/pxcheck.

Docker run:

   sudo docker run --rm --name px-check --net=host --privileged=true -v /usr/src:/usr/src -v /lib/modules:/lib/modules -v /var/run/docker.sock:/var/run/docker.sock -v /var/log/pxcheck:/var/log/pxcheck:shared portworx/px-pre-flight:2.0.0.0 [-k <keystore urls (comma separated)>] [-kca <Certificate Authority file>] [-m <Mgmnt Iface|IP>] [-d <Data Iface|IP>]

e.g.

   sudo docker run --rm --name px-check --net=host --privileged=true -v /usr/src:/usr/src -v /lib/modules:/lib/modules -v /var/run/docker.sock:/var/run/docker.sock -v /var/log/pxcheck:/var/log/pxcheck:shared portworx/px-pre-flight:2.0.0.0 -k http://etcdv3-01.portworx.com:2379 -d enp0s3 -m enp0s3


Below is dset yaml file which can be used with kubernetes.

e.g. Yaml:

apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  name: px-pre-install-check-dset
  namespace: kube-system
spec:
  minReadySeconds: 0
  template:
    metadata:
      labels:
        name: pre-install-check
    spec:
      hostNetwork: true
      containers:
      - name: pre-install-check
        image: portworx/px-pre-flight:2.0.0.0
        imagePullPolicy: Always
        args:
          ["-k", "http://etcdv3-01.portworx.com:2379", ]
        securityContext:
          privileged: true
        volumeMounts:
          - name: dockersock
            mountPath: /var/run/docker.sock
          - name: usrsrc
            mountPath: /usr/src
          - name: libmodules
            mountPath: /lib/modules
          - name: logpxcheck
            mountPath: /var/log/pxcheck:shared
      restartPolicy: Never
      volumes:
      - name: dockersock
        hostPath:
          path: /var/run/docker.sock
      - name: usrsrc
        hostPath:
          path: /usr/src
      - name: libmodules
        hostPath:
          path: /lib/modules
      - name: logpxcheck
        hostPath:
          path: /var/log/pxcheck
