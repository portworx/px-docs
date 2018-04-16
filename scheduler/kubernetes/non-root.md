---
layout: page
title: "Create shared PVC"
keywords: portworx, pre-provisioned volumes, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk, StatefulSets
sidebar: home_sidebar
meta-description: "Use PX volumes (PVCs) with Docker containers running as a non-root user."
---

This document describes how to use portworx volumes with Docker containers running as a non-root user.

### Modify the application POD spec
You can add the following section in your Pod spec to set a GID for the portworx volume mount point inside the application container.

```
  spec:
    # Allow non-root user to access PersistentVolume
    securityContext:
      fsGroup: 1000
    containers:
```
