---
layout: page
title: "Install Portworx Now"
keywords: portworx, px-developer, px-enterprise, plugin, install, configure, container, storage, runc, oci
sidebar: home_sidebar
redirect_from:
  - /scheduler/docker/systemd.html
  - /scheduler/docker/upgrade-standalone.html
  - /scheduler/docker/upgrade-px-plugin.html
---

* TOC
{:toc}

## Install Portworx with a Container Orchestrator
You can also deploy Portworx via your container orchestrator.  Chose the appropriate installation instructions for your scheduler.

* [Install on Kubernetes](/scheduler/kubernetes)
* [Install on Mesosphere DCOS](/scheduler/mesosphere-dcos/install.html)
* [Install on Docker](/scheduler/docker/install-standalone.html)
* [Install on GKE](/cloud/gcp/gke.html)
* [Install on AWS ECS](/cloud/aws/ecs.html)
* [Install on Nomad](/scheduler/nomad/install.html)
* [Install on Rancher](/scheduler/rancher/install.html)

## Install Portworx Directly Now

### Prerequisites

* *SYSTEMD*: The installation below assumes the [systemd](https://en.wikipedia.org/wiki/Systemd) package is installed on your system (i.e. _systemctl_ command works).
    - Note, if you are running Ubuntu 16.04, CentoOS 7 or CoreOS v94 (or newer) the "systemd" is already installed and no actions will be required.
* *SCHEDULERS*: If you are installing PX into **Kubernetes** or **Mesosphere DC/OS** cluster, we recommend to install the scheduler-specific Portworx package, which provides tighter integration, and better overall user experience.
* *FIREWALL*: Ensure ports 9001-9015 are open between the cluster nodes that will run Portworx.
* *NTP*: Ensure all nodes running PX are time-synchronized, and NTP service is configured and running.
* *KVDB*: Please have a clustered key-value database (etcd or consul) installed and ready. For etcd installation instructions refer this [doc](/maintain/etcd.html).
* *STORAGE*: At least one of the PX-nodes should have extra storage available, in a form of unformatted partition or a disk-drive.<br/> Also please note that storage devices explicitly given to Portworx (ie. `px-runc ... -s /dev/sdb -s /dev/sdc3`) will be automatically formatted by PX.

### Install Portworx Now

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
Logs can be viewed using `journalctl`.
Once installed, Portworx can be started/stopped/restarted via `systemctl`.

## Install Portworx through Terraform

To install with **Terraform**, please use the [Terraform Portworx Module](https://registry.terraform.io/modules/portworx/portworx-instance/)

## Install Portworx via Ansible

To install with **Ansible**, please use the [Terraporx Ansible Playbook](https://github.com/portworx/terraporx/tree/master/automation/ansible/portworx)

