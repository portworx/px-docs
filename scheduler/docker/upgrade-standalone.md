---
layout: page
title: "Upgrade Portworx volume plugin"
keywords: portworx, architecture, storage, container, install, docker, upgrade, plugin
sidebar: home_sidebar
redirect_from:
  - /scheduler/docker/upgrade-px-plugin.html
---

* TOC
{:toc}

## Upgrade the PX Plugin
This guide describes upgrading the Portworx docker volume plugin.

The commands in this guide upgrade the plugin to version 1.2.10. You will need to run the below sequence on all Portworx nodes in the cluster.

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
>**Note:** If you get the error "plugin pxd:latest is in use" try with `--force` flag.

3. Upgrade the Portworx plugin

Use the following command to upgrade a plugin to a specific image.

```
$ docker plugin upgrade 501536d2e2ed portworx/px:<version>
```

Replace the `<version>` field with the plugin tag you want to upgrade to. Here is an example command that upgrades PX plugin to `1.2.10`

```
$ docker plugin upgrade 501536d2e2ed portworx/px:1.2.10
Upgrading plugin portworx/px:latest from portworx/px:latest to portworx/px:1.2.10
Plugin images do not match, are you sure? y
Plugin "portworx/px:1.2.10" is requesting the following privileges:
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
1.2.10: Pulling from portworx/px
1d7345f9dd3b: Download complete
Digest: sha256:65da96a98d2f3fba872ef0b90191c451b1bf6c5e1bb51e16e4012bcff6f8e51a
Status: Downloaded newer image for portworx/px:1.2.10
Upgraded plugin portworx/px:latest to portworx/px:1.2.10
```
4. Restart Docker Daemon (Optional)

With several docker versions viz. `17.06.x`, `17.09` we have seen multiple issues with docker's `plugin upgrade command`. A few of them are listed below

 a. After upgrade, when the plugin is re-enabled you see an error message like `device or resource busy` in docker daemon logs.
 b. Docker daemon crash when listing volumes [#35124](https://github.com/moby/moby/issues/35124)

We recommend restarting the docker daemon before enabling the PX plugin.

```
$ systemctl restart docker
```
5. Enable the Portworx plugin
```
$  docker plugin enable 501536d2e2ed
```
6. Check version and status
```
$ /opt/pwx/bin/pxctl -v
$ /opt/pwx/bin/pxctl status
```

### Upgrade the PX container
If you installed PX as a standalone container, you can upgrade PX using the PX CLI command on each host as follows:

```
# pxctl upgrade
```

To specify a tag, you can run:

```
# pxctl upgrade --tag 1.2.10
```
