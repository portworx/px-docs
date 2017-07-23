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
Product SKU                     Trial    expires in 30 days
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
| Virtual machine hosts        | yes/no | Software may be deployed on VMs (including Amazon EC2, OpenStack Nova, etc...)
| Bare-metal hosts             | yes/no | Software may be deployed on commodity hardware


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

When the trial period expires, one will no longer be able to create new volumes or volume snapshots.
The normal functionality may be restored at any time, by purchasing and installing the "PX-Enterprise" license.

**UPGRADE NOTES**:

* The "Trial" license can be upgraded into a "PX-Enterprise" license by contacting
support@portworx.com, and activating via the "activation code" or via the
license file (see [PX-Enterprise](#px-enterprise-license) below for details)
* The "Trial" license itself cannot be upgraded or extended with another "Trial", or downgraded into "PX-Developer" license.


### PX-Enterprise license

The "PX-Enterprise" license is our most flexible license, which comes with a number of options.
Please refer to [Features page](https://portworx.com/products/features/) to
determine which type of "PX-Enterprise" license will work best for your needs.

**LICENSE SHARING**:

Once installed, the PX-Enterprise license is "locked" to a single PX-Cluster via the unique UUID identifier of the cluster.
Such license (or, license-file) will not work on other clusters.


**INSTALLATION**:

The easiest way to install the "PX-Enterprise" license, is via the
 "Activation ID" (reach out to us at support@portworx.com for purchasing licenses), ie:

```
pxctl license activate c0ffe-fefe-activation-123
```

Note that the "license activation" process will require active Internet connection from the PX-nodes to the license-server,
as the activation process automatically registers the cluster UUID, generates and installs the license on the cluster.
Upon activating the license on one PX-node, all remaining PX-nodes will automatically update to the new license.



**INSTALL ON AIR-GAPPED ENVIRONMENTS**: Customers that do not have an active Internet connection on their PX-cloud, will need to be guided by the Portworx support (can be reached at support@portworx.com) , and will follow a slightly different process.

Customers will be asked to provide the `Cluster UUID` information (available via `pxctl cluster list` command):

```
[root@vm1 ~]# pxctl cluster list
Cluster ID: MY_FAVORITE_PX_CLUSTER
Cluster UUID: f987ad4b-987c-4e7e-a8bd-788c89cc40f1
Status: OK [...]
```

Upon supplying the "Cluster UUID", the customers will get their "license file".
The "license file" will need to be uploaded to one of the PX-nodes, and activated via the following command:

```
pxctl license add license_file.bin
```

Finally, please note that the license installation is a non-obtrusive process, which will not interfere with the data stored
on the PX volumes, nor will it interrupt the active IO operations.


For information on purchase, upgrades and support, please reach out to us at support@portworx.com
