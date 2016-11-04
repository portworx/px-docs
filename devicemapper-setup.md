---
layout: page
title: "Pre-requisites : Devicemapper setup"
keywords: portworx, px-developer, devicemapper
sidebar: home_sidebar
---
Portworx recommends using devicemapper for the thinpool, rather than loopback devices.

[This script](devicemapper-setup.html) can be used to help with the basic thinpool and devicemapper setup.

Please note the following caveats:

 * This script must be run as 'root'
 * This script requires one command line argument for the device to be used
 * This is intended to run at docker installation time (and will stop docker if it's already running)
