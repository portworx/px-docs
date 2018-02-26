---
layout: page
title: "Control Portworx systemd service on Kubernetes"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk
sidebar: home_sidebar

meta-description: "Find out how to manually control the Portworx systemd service in your Kubernetes cluster"
---

* TOC
{:toc}

This guide shows how you can perform systemctl operations using _kubectl_ to control the Portworx systemd service. Portworx already manages the lifecycle of the systemd service and hence these operations should not be required in a properly functioning cluster.

>**Warning:** These operations should be performed only for debugging/troubleshooting purposes.

### Service control

>**NOTE:** You should not stop the Portworx systemd service while applications are still using it. Doing so can cause docker and applications to hang on the system. Migrate all application pods using `kubectl drain` from the node before stopping the Portworx systemd service.


#### stop / start / restart the PX-OCI service

* note: this is the equivalent of running `systemctl stop portworx`, `systemctl start portworx` ... on the node

```bash
kubectl label nodes minion2 px/service=start
kubectl label nodes minion5 px/service=stop
kubectl label nodes --all px/service=restart
```

#### enable / disable the PX-OCI service
  
* note: this is the equivalent of running `systemctl enable portworx`, `systemctl disable portworx` on the node

```bash
kubectl label nodes minion2 minion5 px/service=enable
```
