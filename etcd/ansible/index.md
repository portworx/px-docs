---
layout: page
title: "Install 'etcd3' cluster on BareMetal or VMs"
sidebar: home_sidebar
---

The `ansible` script in this directory can be used to deploy a 
fully functioning 3 node 'etcd3' cluster to existing servers or VMs with host persistent storage.

The inventory file `inv.yml` should be structured as follows:

```
[nodes]
server1 IP=192.168.205.10
server2 IP=192.168.205.11
server3 IP=192.168.205.12
```

Ensure that the `nodes` group is used and that the `IP` attribute is defined

This installation method assumes you have root `ssh` keys installed on all the servers in the inventory file.

## Install

The current/default version of 'etcd3' installed is `"3.2.7"`.
For other version of `etcd3` to be installed, update the `etcd_version` variable 
in the `etcd3.yml` file.

To install 'etcd3' on all servers, run the following command:

```
ansible-playbook -i inv.yml etcd3.yml
```
