---
layout: page
title: "Install via 'systemd'"
keywords: portworx, px-developer, px-enterprise, plugin, install, configure, container, storage, runc, oci
sidebar: home_sidebar
redirect_from:
  - /scheduler/docker/systemd.html
  - /scheduler/docker/upgrade-standalone.html
  - /scheduler/docker/upgrade-px-plugin.html
---

* TOC
{:toc}

## Install Portworx via "systemd"

>**NB:**<br/> Use this section if NOT installing via a container orchestrator

>**NB:**<br/> Please see the [installation pre-requisites](/runc/index.html#prerequisites)

Portworx can be installed simply/easily on a given server as follows:

```
curl -fsSL https://get.portworx.com | sh -s -- [px-options]
```
where the full list of `px-options` is documented here:
{% include cmdargs.md %}

The installer bootstrap also include a `"-h"` help option, that produces:
```
$ curl -fsSL https://get.portworx.com | sh -s -- -h
Usage: bootstrap-px.sh [-y] <px-options>

Options:
    -y            Assume YES on all interactive prompts
    <px-options>  Please see https://docs.portworx.com/runc/#options

Example:
    curl -fsSL https://get.portworx.com | sh -s
    curl -fsSL https://get.portworx.com | sh -s -- -k etcd://myetc.company.com:2379
    curl -fsSL https://get.portworx.com | sh -s -- -c MY_CLUSTER_ID -k etcd://myetc.company.com:2379 -s /dev/xvdb -s /dev/xvdc
```

Portworx deploys as a [systemd(1)](https://en.wikipedia.org/wiki/Systemd) service.
Logs can be viewed using `journalctl -u portworx`.
Once installed, Portworx can be started/stopped/restarted via `systemctl`.

## Install Portworx through Terraform

To install with **Terraform**, please use the [Terraform Portworx Module](https://registry.terraform.io/modules/portworx/portworx-instance/)

## Install Portworx via Ansible

To install with **Ansible**, please use the [Ansible Galaxy role](https://galaxy.ansible.com/portworx/portworx-defaults/)

