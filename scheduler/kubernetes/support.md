---
layout: page
title: "Troubleshooting PX on Kubernetes"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk, debug, troubleshoot
sidebar: home_sidebar
meta-description: "For troubleshooting PX on Kubernetes, Portworx can help.  Read this article  for details about how to resolve your issue today."
---

* TOC
{:toc}

If you have an enterprise license, please contact us at support@portworx.com with your license key and logs.

## Obtaining Logs from PX
Please run the following command on the master node:

```
# uname -a
# docker version
# kubectl logs -l  name=portworx -n kube-system --tail=200
# /opt/pwx/bin/pxctl status
```

Email the output to support@portworx.com
