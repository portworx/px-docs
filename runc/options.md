---
layout: page
title: "Command line options for PX"
keywords: portworx, px-developer, px-enterprise, plugin, install, configure, container, storage, runc, oci
sidebar: home_sidebar
redirect_from:
  - /install/options.html
---

* TOC
{:toc}

## Installation arguments to PX

The following arguments can be provided to PX, which will in turn pass them to the PX daemon:

>**Note:** <br>
>These options are for `runC`.  While these options are a superset of the now deprecated `docker run` method of starting PX, they can still be used with the Docker version of PX.

```
Usage: /opt/pwx/bin/px-runc <run|install> [options]
```

{% include cmdargs.md %}
