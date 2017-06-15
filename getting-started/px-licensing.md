---
layout: page
sidebar: home_sidebar
title: "Portworx Licensing"
keywords: portworx, px-enterprise, px-developer, requirements
redirect_from: "/get-started-licensing.html"
---

* TOC
{:toc}

## Introduction

Starting with v1.2.8 release, the Portworx products support the following license types:

|      License type      |  Description
|:-----------------------|:-------------------------------------------------------------------------------------------------------------------------------
| PX-Developer           | Embedded into [px-developer](/getting-started/px-developer.html), free license that supports limited functionality.
| Trial                  | Automatically installed w/ [px-enterprise](/getting-started/px-enterprise.html), enables full functionality for 30 days.
| PX-Enterprise VM Basic | Commercial license, suitable for medium-sized VM/cloud based installs (see [Features](https://portworx.com/products/features/))
| PX-Enterprise VM Plus  | Enterprise license, suitable for large VM/cloud -based installs (see [Features](https://portworx.com/products/features/))
| PX-Enterprise Metal    | Enterprise license, suitable for large installs on any hardware (see [Features](https://portworx.com/products/features/))


Depending on the type of the container you are installing, a different license will be automatically activated:

* [px-developer](/getting-started/px-developer.html) container activates free "PX-Developer" license, and
* [px-enterprise](/getting-started/px-enterprise.html) automatically
activates the "Trial" license (limited to 30 days), which can be upgraded to one of the "PX-Enterprise" licenses at any time.


## How to check which license is installed?

A brief license summary is provided w/ `pxctl status` command:

```
[root@vm1 ~]# pxctl status
Status: PX is operational
License: Trial license (expires in 30 days)
 [...]
```

More details about each individual licensed feature is displayed via `pxctl license list` command, ie.:

```
[root@vm1 ~]# pxctl license list
DESCRIPTION                  ENABLEMENT  ADDITIONAL INFO
Number of nodes maximum         1000
Number of volumes maximum       1024 [...]
Virtual machine hosts            yes
Product SKU                     Trial    expires in 29 days, 20:40
```

## Licensed features

In the table below, we can see the overview of features that are controlled via licensing as of PX v1.2.8.

|       Description            |  Type  | Details
|:-----------------------------|:------:|:------------------------------------------------------------------------------------
| Number of nodes maximum      | number | Defines the maximum number of nodes in a cluster
| Number of volumes maximum    | number | Defines max number of volues on a single node
| Volume capacity [TB] maximum | number | Defines max size of a single volume
| Storage aggregation          | yes/no | Defines if volumes may be aggregated across multiple nodes
| Shared volumes               | yes/no | Defines if volumes may be shared w/ other nodes
| Volume sets                  | yes/no | Defines if volumes may be scaled
| BYOK data encryption         | yes/no | Defines if volumes may be encrypted
| Snapshot to object store     | yes/no | Defines if volumes may be snapshotted to Amazon S3, MS Azure and Google storage
| Virtual machine hosts        | yes/no | PX Containers may be deployed on VMs (including Amazon EC2, OpenStack Nova, etc...)
| Bare-metal hosts             | yes/no | PX Containers may be deployed on commodity hardware


## Types of licenses

### PX-Developer license

The "PX-Developer" license is a default license for [px-developer](/getting-started/px-developer.html) containers.
The "PX-Developer" license is permanent and free, and provides a limited set of functionality, with unrestricted use.
It supports the following features:

```
[root@vm1 ~]# pxctl license list
DESCRIPTION                  ENABLEMENT    ADDITIONAL INFO
Number of nodes maximum             3
Number of volumes maximum         256
Volume capacity [TB] maximum        1
Storage aggregation                no      feature upgrade needed
Shared volumes                    yes
Volume sets                       yes
BYOK data encryption               no      feature upgrade needed
Resize volumes on demand           no      feature upgrade needed
Snapshot to object store           no      feature upgrade needed
Bare-metal hosts                  yes
Virtual machine hosts             yes
Product SKU                  PX-Developer  permanent
```

**UPGRADE NOTES**:

The "PX-Developer" license can be upgraded to the "Trial" license by running the following command:

```bash
pxctl license trial
```
Alternatively, the PX-Dev can also be upgraded into "PX-Enterprise" license by contacting
[Portworx support](https://docs.portworx.com/knowledgebase/support.html), and activating via the "activation code" or the
license file, like so:

```bash
pxctl license activate c0ffe-fefe-activation-123    || \
pxctl license add customer_license.bin
```

### Trial license

The "Trial" license activates automatically when the [px-enterprise](/getting-started/px-enterprise.html) container is installed.
The trial license provides the full product functionality for 30 days.

```
DESCRIPTION                  ENABLEMENT  ADDITIONAL INFO
Number of nodes maximum         1000
Number of volumes maximum       1024
Volume capacity [TB] maximum      40
Storage aggregation              yes
Shared volumes                   yes
Volume sets                      yes
BYOK data encryption             yes
Resize volumes on demand         yes
Snapshot to object store         yes
Bare-metal hosts                 yes
Virtual machine hosts            yes
Product SKU                     Trial    expires in 6 days, 20:40
```


**EXPIRATION**:

When the trial period expires, no new data may be written to the PX-volumes: one will no longer be able to create new volumes or volume
snapshots.  Additionally, the existing volumes will no longer be accessible as "Read/Write", but will switch to "Read-Only" mode.
The normal "Read/Write" functionality may be enabled at any time, by purchasing and installing the "PX-Enterprise" license.

**UPGRADE NOTES**:

* The "Trial" license can be activated from the "PX-Developer" containers, by running the `pxctl license trial` command.
* The "Trial" license itself cannot be upgraded or extended with another "Trial", or downgraded back to the "PX-Developer" license
* However, it can be upgraded into a "PX-Enterprise" license by contacting
[Portworx support](https://docs.portworx.com/knowledgebase/support.html), and activating via the "activation code" or the
license file, like so:

```bash
pxctl license activate c0ffe-fefe-activation-123    || \
pxctl license add customer_license.bin
```

### PX-Enterprise license

The "PX-Enterprise" license is our most flexible license, which comes with a number of options.
Please refer to [Features page](https://portworx.com/products/features/) to
determine which type of "PX-Enterprise" license will work best for your needs.

**LICENSE SHARING**:

Once installed, the PX-Enterprise license is "locked" to a single PX-Cluster via the unique UUID identifier of the cluster.
Such license (or, license-file) will not work on other clusters.


**INSTALLATION**:

The easiest way to install the "PX-Enterprise" license, is via the
[Portworx support](https://docs.portworx.com/knowledgebase/support.html) -provided "Activation ID", ie:

```
pxctl license activate c0ffe-fefe-activation-123
```

Note that the "license activation" process will require active Internet connection from the PX-node to the license-server,
as the activation process of automatically sends the unique cluster UUID to the license-server, retrieves and installs
the generated license on the cluster.  Upon activating the license on one PX-node, all remaining PX-nodes will automatically update to the new license.



**INSTALL ON AIR-GAPPED ENVIRONMENTS**: Customers that do not have an active Internet connection on their PX-cloud, will need to
be guided by the 
[Portworx support](https://docs.portworx.com/knowledgebase/support.html), and will follow a slightly different process.

Customers will be asked to provide the *Cluster UUID* (available via `pxctl cluster list` command):

```
[root@vm1 ~]# pxctl cluster list
Cluster ID: MY_FAVORITE_PX_CLUSTER
Cluster UUID: f987ad4b-987c-4e7e-a8bd-788c89cc40f1
Status: OK [...]
```

... and will be supplied the "license file".  This "license file" will need to be uploaded to one of the PX-nodes,
and activated via the following command:

```
pxctl license add customer_license.bin
```

Finally, please note that the license installation is a non-obtrusive process, which will not interfere with the data stored
on the PX volumes, nor will it interrupt the active IO operations.


For information on purchase, upgrades and support, see
[https://docs.portworx.com/knowledgebase/support.html](https://docs.portworx.com/knowledgebase/support.html) page.