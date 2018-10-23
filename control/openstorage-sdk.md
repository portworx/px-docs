---
layout: page
title: "OpenStorage SDK for Portworx Enterprise"
keywords: portworx, REST, SDK, OpenStorage SDK, API
sidebar: home_sidebar
redirect_from: "/openstorage-sdk.html"
meta-description: "Portworx data services can be managed and monitored through the OpenStorage SDK"
---

* TOC
{:toc}


Portworx data services can be managed and monitored through the [OpenStorage SDK](https://libopenstorage.github.io). 


### OpenStorage SDK Ports

When you connect your OpenStorage SDK client to Portworx you can use either the
default gRPC port 9020 or the default REST Gateway port of 9021. If the port
range has been configured to another location during installation, you will
find the OpenStorage SDK ports by grepping for SDK in the Portworx container logs.

### OpenStorage versions

The following table shows the OpenStorage SDK version released in each version of Portworx:

| Portworx Version | OpenStorage SDK Version | OpenStorage SDK Clients |
| ---------------- | ----------------------- | ----------------------- |
| v1.6.0 | [v0.9.0](https://libopenstorage.github.io/w/v0.9.0) | [v0.9.0](https://github.com/libopenstorage/openstorage-sdk-clients/releases/tag/v0.9.0)

You may need to match the version of the OpenStorage SDK Client version.
