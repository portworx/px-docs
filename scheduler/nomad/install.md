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

Portworx deploys on Nomad as a `system` job.  
Please use [this job file](https://raw.githubusercontent.com/portworx/px-docs/gh-pages/scheduler/nomad/portworx.nomad) as a reference for deploying 
Portworx on an existing Nomad system.

Portworx runs on the Nomad clients.   As a requirement, Nomad clients must be configured
with the following client options:
```
client {
  enabled = true
  options {
    "driver.raw_exec.enable" = "1"
    "docker.privileged.enabled" = "true"
  }
}
```

The following arguments to `px-runc` should be customized as per the local environment:
```
args = [ "-c", "sudo docker run --entrypoint /runc-entry-point.sh \
                      --rm -i --privileged=true \
                      -v /opt/pwx:/opt/pwx -v /etc/pwx:/etc/pwx  \
                      portworx/px-enterprise:1.2.12.1 --upgrade ;\
                /opt/pwx/bin/runc delete -f portworx; \
                /opt/pwx/bin/px-runc run -k consul:http://127.0.0.1:8500 \
                      -c pxcluster -f -a -d eth0 -m eth0" ]
```

The above command has 3 parts:

1. Install (or upgrade) the Portworx runC bootstrap 
2. Delete any existing Portworx runC containers that may be active
3. Run the Portworx runC container with cluster-specific arguments

All Portworx command line options are documented [here](/runc/options.html)

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

## Monitor Portworx cluster status

Nomad jobs can be monitored through the GUI (port 3000) or the REST API (port 4646).

For the Nomad REST API, querying the status of the job with ID `portworx` 
can be done as follows:
```
curl http://nomad_url:4646/v1/job/portworx | jq .
```

From any of the `nomad` client nodes, the CLI command:
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

## Scaling
Portworx is deployed through the Nomad `system` scheduler, which behaves similarly
to a Kubernetes `daemonset`.  The `system` scheduler is used to register jobs 
that should be run on all clients meeting a job's constraints. 
The system scheduler is also invoked when clients join the cluster 
and is useful for deploying and managing tasks that should be present on every node in the cluster.

There are no additional requirements to install Portworx on the new nodes 
in your Nomad cluster.

If using the `hashi-porx` stack on AWS, simply change the corresponding nomad client 
auto-scaling group (via GUI or API) to have the desired number of nodes/servers.
The new servers will be automatically provisioned and configured, with consul, nomad and Portworx.

## Upgrade

### Upgrade via GUI
To upgrade Portworx via the Hashi GUI, select the 'portworx' job.
Select the 'edit' icon on the upper right side.
Change the `px-enterprise` tag to the desired release.
Example:
```
    ... -v /etc/pwx:/etc/pwx  portworx/px-enterprise:1.2.14 --upgrade
```
Save the job.
Upgrade time will depend on the node configuration.
Expect the full upgrade through Nomad to take around 1 hour for AWS t2.medium clients.

### Upgrade via CLI
Update the Nomad job file to reflect the desired Portworx release tag.
Run `nomad plan` and `nomad run` accordingly.
Upgrade time will depend on the node configuration.
Expect the full upgrade through Nomad to take around 1 hour for AWS t2.medium clients.


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
          "name=mysql,size=10,repl=3/:/docker-entrypoint-initdb.d/",
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

