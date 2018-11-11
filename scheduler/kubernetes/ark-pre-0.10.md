---
layout: page
title: "Using Ark (pre v0.10) with Portworx"
keywords: portworx, container, Kubernetes, storage, k8s, pv, persistent disk, snapshot
sidebar: home_sidebar
---

* TOC
{:toc}

Heptio Ark is a utility for managing disaster recovery, specifically for your
Kubernetes cluster resources and persistent volumes. To take snapshots of
Portworx volumes through Ark you need to install and configure the Portworx
plugin.

## Install Ark Plugin
Run the following command to install the Portworx plugin for Ark:
```
$ ark plugin add portworx/ark-plugin:0.3
```

This should add an init container to your Ark deployment to install the
plugin.

## Configure Ark to use Portworx snapshots

Once the plugin is installed you need to configure Ark to use Portworx as the
Persistent Volume Provider when taking snapshots. To edit the config run the
following command:

```
$ kubectl edit config -n heptio-ark
```

And set up `portworx` as the `persistentVolumeProvider` by adding the following
snippet to the config spec:
```
persistentVolumeProvider:
  name: portworx
```

### Using local snapshots (default)
By default, local snapshots will be created for PVCs backed by Portworx. You can explicitly configure this by specifying
`local` as the `type` in the `config` section:
```
persistentVolumeProvider:
  name: portworx
  config:
    type: local
```

### Using cloud snapshots (Supported from PX-Enterprise 1.4 onwards)
To use cloud snapshots to backup your PVCs, you need to specify `cloud` as the `type` in the `config` section. If you have
more than one credential configured with Portworx you also need to specify the UUID of the credential using `credId`:
```
persistentVolumeProvider:
  name: portworx
  config:
    type: cloud
    # Optional, required only if Portworx is configured with more than one credential
    credId: <UUID>
```

## Managing snapshots
Once the plugin has been installed and configured, everytime you take backups
using Ark and include PVCs, it will also take Portworx snapshots of your volumes.

### Creating backups
For example, to backup all your apps in the default namespace and also snapshot
your volumes, you would run the following command:
```
$ ark backup create default-ns-backup --include-namespaces=default --snapshot-volumes
Backup request "default-ns-backup" submitted successfully.
Run `ark backup describe default-ns-backup` for more details.
```

Once the specs and volumes have been backed up you should see the backup marked
as `Completed` in ark.

```
$ ark get backup
NAME                STATUS      CREATED                         EXPIRES   SELECTOR
default-ns-backup   Completed   2018-05-29 20:10:45 +0000 UTC   29d       <none>
```

### Restoring from backups
When restoring from backups, a clone volume will be created from the snapshot and
bound to the restored PVC. To restore from the backup created above you can run
the following command:
```
$ ark restore create --from-backup default-ns-backup
Restore request "default-ns-backup-20180529201245" submitted successfully.
Run `ark restore describe default-ns-backup-20180529201245` for more details.
```
