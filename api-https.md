---
layout: page
title: "encrypted api endpoint"
keywords: portworx, install, ssl, api, encryption, https 
sidebar: home_sidebar
---

## Enabling SSL on the px API server.  

Portworx storage container expects a config file in "/etc/pwx/config.json" upon startup.
to enable encryption you will need to add a new section to this config.

```
"apirootca": "/etc/pwx/rootca.pem",
"apicert": "/etc/pwx/server.crt",
"apikey": "/etc/pwx/server.key",
```

### apirootca
This is the self signed root certificate you provide. this is the signing certificates of `apicert` and `apikey`.

### apicert
This is the self signed server/client cert that you provide signed by the `apirootca`.

### apikey
This is the self signed server/client key that you provide signed by the `apirootca`.

Enabling/Disabling and updates to this feature requires a reboot of px as the server is listening with a particular set of certificates and will have to restart.
PX checks if `apirootca` is set. If that check evaluates to `true` PX will start listening for https traffic with given certs.

## PXCTL over SSL
Right now `pxctl` loads the same config as `px` and will use the `apicert` and `apikey` to communicate to `px`. It will also use the `apirootca` to validate the origin of `px`.
If `pxctl` is using SSL correctly you'll see it in the `pxctl status` output.