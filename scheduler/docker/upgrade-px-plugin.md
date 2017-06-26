---
layout: page
title: "Upgrade Portworx volume plugin"
keywords: portworx, architecture, storage, container, install, docker, upgrade, plugin
sidebar: home_sidebar
---

* TOC
{:toc}

This guide describes upgrading the Portworx docker volume plugin.

The commands in this guide upgrade the plugin to version 1.2.5. You will need to run the below sequence on all Portworx nodes in the cluster.

1. List the plugin ID
```
$ docker plugin ls
ID                  NAME                DESCRIPTION                         ENABLED
501536d2e2ed        portworx/px:latest   Portworx Data Services for Docker   true
```
2. Disable the Portworx plugin
```
$ docker plugin disable 501536d2e2ed
```
3. Upgrade the Portworx plugin
```
$ docker plugin upgrade 501536d2e2ed portworx/px:1.2.5
Upgrading plugin portworx/px:latest from portworx/px:latest to portworx/px:1.2.5
Plugin images do not match, are you sure? y
Plugin "portworx/px:1.2.5" is requesting the following privileges:
 - network: [host]
 - mount: [/dev]
 - mount: [/etc/pwx]
 - mount: [/var/lib/osd]
 - mount: [/opt/pwx/bin]
 - mount: [/var/run/docker.sock]
 - mount: [/lib/modules]
 - mount: [/usr/src]
 - mount: [/var/cores]
 - allow-all-devices: [true]
 - capabilities: [CAP_SYS_ADMIN CAP_SYS_MODULE CAP_IPC_LOCK]
Do you grant the above permissions? [y/N] y
1.2.5: Pulling from portworx/px
1d7345f9dd3b: Download complete 
Digest: sha256:65da96a98d2f3fba872ef0b90191c451b1bf6c5e1bb51e16e4012bcff6f8e51a
Status: Downloaded newer image for portworx/px:1.2.5
Upgraded plugin portworx/px:latest to portworx/px:1.2.5
```
>**Note:**<br/> If you see an error message like `device or resource busy`, you will see to restart the docker service and then re-attempt the above upgrade.

4. Enable the Portworx plugin
```
$  docker plugin enable 501536d2e2ed
```
5. Check version and status
```
$ /opt/pwx/bin/pxctl -v
pxctl version 1.2.5-7b6ab38
$ /opt/pwx/bin/pxctl status
```

