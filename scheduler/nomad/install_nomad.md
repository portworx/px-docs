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

**__[Experimental]__**
Nomad is a scheduler and job orchestrator from HashiCorp for managing a 
cluster of machines and running applications on them. 
Nomad abstracts away machines and the location 
of applications, and instead enables users to declare what they want to run 
and Nomad handles where they should run and how to run them.
Portworx can run within Nomad and provide persistent volumes to other 
applications running on Nomad. This section describes how to deploy and consume 
Portworx within a Nomad cluster. 

Current use of Portworx with Nomad is **__experimental__**, not fully supported,
and provided as-is.

# Install

Portworx deploys on Nomad as a "system" job.  
Please use [this job file](/scheduler/portworx.nomad) as a reference for deploying 
Portworx on an existing Nomad system.

The following arguments should be customized as per the local environment:
```
args = [ "-c", "curl http://get.portworx.com | sh ; /opt/pwx/bin/px-runc run -k consul:http://127.0.0.1:8500 -c pxcluster -f -a -d eth0 -m eth0" ]
``

Nomad has a very natural alignment with `consul`.
Therefore having Portworx use `consul` as the clustered `kvdb` when 
deployed through Nomad makes common sense.  
When doing so, `consul` can be referenced locally on all nodes,
as with `127.0.0.1:8500`

In the above example `consul:http://127.0.0.1:8500` refers to the required `kvdb`, 
(which can be either `etcd` or `consul`).   All Portworx command line options 
are documented [here](/runc/options.html)

## Hashi-porx

As a community resource, please refer to the [hashi-porx](https://github.com/portworx/terraporx/tree/master/aws/hashi-porx) repository for a full-stack deployment of consul, nomad, vault, the Hashi UI, and Portworx all deployed through Terraform on AWS.

When using the `hashi-porx` stack, the status for the Nomad and Consul clusters
can be accessed via the `nomad_url` output variable, which refers to port 3000 
of the external load balancer.

# Monitor Portworx cluster status

Nomad jobs can be monitored through the GUI (port 3000) or the REST API (port 4646).

For the Nomad REST API, querying the status of the job with ID `portworx` 
can be done as follows:
```
curl http://nomad_url:4646/v1/job/portworx | jq .
```

From any of the `nomad` client nodes, the command:
```
nomad job status portworx
```
will retrieve the Nomad `Allocation IDs` for the job `portworx`.

Each Allocation refers to a running instance of Portworx.

The logs for an instance of Portworx can be viewed by referencing the `Allocation ID`:
```
nomad logs AllocID
```
where `AllocID` refers to a valid Allocation ID.

# Scaling
Portworx is deployed through the Nomad `system` scheduler, which behaves similarly
to a Kubernetes `daemonset`.  The `system` scheduler is used to register jobs 
that should be run on all clients meeting a job's constraints. 
The system scheduler is also invoked when clients join the cluster 
and is useful for deploying and managing tasks that should be present on every node in the cluster.

There are no additional requirements to install Portworx on the new nodes 
in your Nomad cluster.

# Upgrade

# Using and Accessing Portworx

# Uninstall

# Delete PX Cluster configuration
