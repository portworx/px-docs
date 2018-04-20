---
layout: page
title: "Deploy Portworx on Nomad"
keywords: portworx, container, Nomad, storage
sidebar: home_sidebar

meta-description: "Install and consume Portworx from within a Nomad cluster." 
---

![nomad logo](/images/Nomad.png){:height="188px" width="188px"}

* TOC
{:toc}

**[Experimental]**
Nomad is a scheduler and job orchestrator from HashiCorp for managing a 
cluster of machines and running applications on them. 
Nomad abstracts away machines and the location 
of applications, and instead enables users to declare what they want to run 
and Nomad handles where they should run and how to run them.
Portworx can run within Nomad and provide persistent volumes to other 
applications running on Nomad. This section describes how to deploy and consume 
Portworx within a Nomad cluster. 

Current use of Portworx with Nomad is **experimental**.

## Install

Portworx can install easily through either Terraform or Ansible.
* To install with **Terraform**, please use the [Terraform Portworx Module](https://registry.terraform.io/modules/portworx/portworx-instance/)
* To install with **Ansible**, please use the [Terraporx Ansible Playbook](https://github.com/portworx/terraporx/tree/master/automation/ansible/portworx)

Please refer to the [Portworx installation arguments](/runc/options.html) for more detail. 

Nomad has a very natural alignment with `consul`.
Therefore having Portworx use `consul` as the clustered `kvdb` when 
deployed through Nomad makes common sense.  
When doing so, `consul` can be referenced locally on all nodes,
as with `127.0.0.1:8500`

### Hashi-porx

As a community resource, please refer to the [hashi-porx](https://github.com/portworx/terraporx/tree/master/hashi-porx/aws) repository for a full-stack deployment of consul, nomad, vault, the Hashi UI, and Portworx all deployed through Terraform on AWS.

When using the `hashi-porx` stack, the status for the Nomad and Consul clusters
can be accessed through the GUI via the `nomad_url` output variable, which refers to port 3000 
of the external load balancer.


## Scaling

A Portworx cluster is uniquely defined by its `kvdb` and `clusterID` parameters.
As long as these are consistent, a cluster can easily scale up in Terraform, 
by using the same `kvdb` and `clusterID`, and then increasing the instance `count`.
Similarly for Ansible, as long as the same `kvdb` and `clusterID` are used,
any new nodes can automatically join an existing cluster.  (NB: For Ansible,
be sure to exclude existing nodes from the inventory before running the playbook
on the new nodes)

## Upgrade

Currently for Nomad, Portworx needs to be upgraded through the CLI on a node-by-node basis.
Please see the [upgrade instructions](/maintain/upgrade.html)

## Using and Accessing Portworx
Portworx volumes can be easily accessed through the Nomad `docker` driver 
by referencing the `pxd` volume driver.
```
   ...
   task "mysql-server" {
      driver = "docker"
      config {
        image = "mysql/mysql-server:8.0"
        port_map {
          db = 3306
        }
        volumes = [
          "name=mysql,size=10,repl=3/:/var/lib/mysql",
        ]
        volume_driver = "pxd"
    }
    ...
```

A complete example for launching MySQL can be found [here](https://github.com/portworx/terraporx/blob/master/hashi-porx/aws/nomad/examples/mysql.nomad)

## Storage On Demand
Portworx provides an important feature that enables applications to have storage provisioned on demand, 
rather than requiring storage to be pre-provisioned.

The feature, also refered to as `inline volume creation` is documented [here](/manage/volumes.html#inline-volume-spec)

Using this feature can be seen in the above example in the `volumes` clause.
Note than all relevent Portworx volume metadata can be specified through this mechanism.

