---
layout: page
title: "Updating Portworx Rack and Zone Info"
keywords: portworx, pxctl, command-line tool, cli, reference
sidebar: home_sidebar
redirect_from: "/px-rack.html"
meta-description: "Learn how to inform your Portworx nodes where they are placed in order to influence replication decisions and performance."
---

Portworx nodes can be made aware of the rack on which they are a placed as well as the zone in which they are present. Portworx can use this information to influence the volume replica placement decisions. The way PX reacts to zone and rack information is different and is explained below.

#### Rack

If PX nodes are provided with the information about their racks then they can use this information to honor the rack placement strategy provided during volume creation. If PX nodes are aware of their racks, and a volume is instructed to be created on specific racks, PX will make a best effort to place the replicas on those racks. The placement is user driven and has to be provided during volume creation.

#### Zone
  If PX nodes are provided with the information about their zones then they can influence the `default` replica placement. In case of replicated volumes PX will always try to keep the replicas of a volume in different zones. This placement is not `striclty` user driven and if zones are provided PX will automatically default to placing replicas in different zones for a volume


## Providing rack info to PX

To update the rack information in Kubernetes using node labels refer [Update Rack Info in Kubernetes](https://docs.portworx.com/scheduler/kubernetes/update-px-rack.html)

### Updating rack information through environment variables

Portworx can be made aware of its rack information through ``PWX_RACK`` environment variable. This environment variable can be provided through
the ```/etc/pwx/px_env``` file. A sample file looks like this

```
# PX Environment File
# Add variables in the following format to automatically export them into PX container
# PWX_EXAMPLE_VAR=foobar
PWX_RACK=rack3
```

Add the ```PWX_RACK=<rack-id>``` entry to the end of this file and bounce the PX container. On every PX restart, all the variables defined in ``/etc/pwx/px_env`` will be exported as environment variables in the PX container. Please make sure the label is a string not starting with a special character or a number.

>**Note:** This method requires a reboot of the PX container.

## Providing zone info to PX

### Updating zone information through environment variables

Portworx can be made aware of its zone information through ``PWX_ZONE`` environment variable. This environment variable can be provided through
the ```/etc/pwx/px_env``` file. A sample file looks like this

```
# PX Environment File
# Add variables in the following format to automatically export them into PX container
# PWX_EXAMPLE_VAR=foobar
PWX_ZONE=zone1
```

Add the ```PWX_ZONE=<zone-id>``` entry to the end of this file and bounce the PX container. On every PX restart, all the variables defined in ``/etc/pwx/px_env`` will be exported as environment variables in the PX container. Please make sure the label is a string not starting with a special character or a number.

>**Note:** This method requires a reboot of the PX container.
