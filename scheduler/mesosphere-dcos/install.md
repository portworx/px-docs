---
layout: page
title: "Run Portworx with Mesosphere/DCOS"
keywords: portworx, PX-Developer, container, Mesos, Mesosphere, Marathon, storage
sidebar: home_sidebar
youtubeId : 02yMYE-CEdw
redirect_from: "/run-with-mesosphere.html"
---
Portworx communicated with DCOS through either the Docker Volume Driver Interface (DVDI) or, directly through CSI.

# Install Portworx

## Install DCOS CLI or Apache Mesos
For Mesosphere, follow the instructions for installing [Mesosphere DCOS](https://dcos.io/install) and the [DCOS CLI](https://docs.mesosphere.com/1.7/usage/cli/install).
Use the DCOS CLI command `dcos node` to identify which nodes in the Mesos cluster are the Agent nodes.

If not using Mesosphere, then follow the instructions appropriate for your OS distribution and environment to install both Apache Mesos and Marathon. 

### Add constraints oni slave nodes (optional)
If the size of your Mesos cluster is larger than the maximum number of nodes supported for a Portworx release,
then you will need to use Mesos "constraints", in order to restrict/constrain jobs that use Portworx volumes to only run
on Mesos-slave nodes where Portworx is running.   (Please check the Portworx release notes for maximum Portworx cluster size).
Otherwise, Portworx recommends simply deploying Portworx on all nodes in a Mesos cluster, thereby avoiding the need to use "constraints".

The following steps are required only for configuring and using "constraints".

For each Mesosphere Agent node or Mesos-slave that is participating in the PX cluster, specify Mesos attributes that allow for affinity of tasks to nodes that are part of the Portworx cluster.

If using Mesosphere/DCOS:

```
# echo MESOS_ATTRIBUTES=pxfabric:pxclust1 >> /var/lib/dcos/mesos-slave-common
# rm -f /var/lib/mesos/slave/meta/slaves/latest
# systemctl restart dcos-mesos-slave.service
# systemctl status dcos-mesos-slave.service -l
```

If using Apache Mesos:

```
# mkdir -p /etc/default/mesos-slave/attributes
# echo pxclust1 > /etc/default/mesos-slave/attributes/pxfabric
# rm -f /var/lib/mesos/slave/meta/slaves/latest
# systemctl restart mesos-slave
# systemctl status mesos-slave -l
```

## Deploy Portworx
You can deploy Portworx using the Mesosphere universe or through Marathon.  Follow one of the two options below.

### To Deploy Portworx through Universe:
Portworx is now available through the Mesosphere Universe catalog of services.
![Portworx on Universe](/images/universe.png){:width="2047px" height="884px"}

Deploying Portworx through Mesosphere Universe provides great ease of deployment.
Please follow the published [Mesosphere/DCOS Examples for deploying Portworx through Universe](https://github.com/dcos/examples/tree/master/portworx) 

### To Deploy Portworx through Marathon:

><br/>**NEW!**

For simple deployment with DCOS, please follow [these instructions](/run-px-etcd-marathon.html) for creating
Portworx and etcd together as a converged application group.


This section assumes that Portworx will be installed on a set of homogeneously configured machines (which is not a general requirement for Portworx).

The pre-requisites for installing Portworx through Marathon include:

1. Determine the list of physical devices (disks and interfaces) for the agent/slave nodes
2. If running PX-Enterprise in '**air-gapped**' mode, then follow instructions for [running a on-prem lighthouse](/enterprise/lighthouse-with-secure-etcd.html) and note the IPaddress and Port of the etcd server. 
3. If running PX-Enterprise, obtain your Lighthouse token.

The following is a sample JSON file that can be used to launch Portworx through Marathon.
The example below assumes the hosts are running CoreOS with an implicit (localhost) etcd.
For all other OS's, please refer to the `etcd` or `consul` instance, and change all references of `/lib/modules` to `/usr/src`.

>**Important:**<br/> If you are not deploying Portworx on all nodes in the cluster, then you should include a *"pxfabric"* constraint.

```json
{
    "id": "pxcluster1",
    "cpus": 2,
    "mem": 2048.0,
    "instances": 3,
    "constraints": [
        ["hostname", "UNIQUE"]
    ],
    "container": {
        "type": "DOCKER",
        "volumes": [],
        "docker": {
            "image": "portworx/px-enterprise",
            "network": "HOST",
            "portmappings": [{
                "containerPort": 0,
                "hostPort": 0,
                "protocol": "tcp"
            }],
            "privileged": true,
            "parameters": [{
                "key": "volume",
                "value": "/run/docker/plugins:/run/docker/plugins"
            }, {
                "key": "volume",
                "value": "/var/lib/osd:/var/lib/osd:shared"
            }, {
                "key": "volume",
                "value": "/dev:/dev"
            }, {
                "key": "volume",
                "value": "/etc/pwx:/etc/pwx"
            }, {
                "key": "volume",
                "value": "/opt/pwx/bin:/export_bin:shared"
            }, {
                "key": "volume",
                "value": "/var/run/docker.sock:/var/run/docker.sock"
            }, {
                "key": "volume",
                "value": "/var/cores:/var/cores"
            }, {
                "key": "volume",
                "value": "/lib/modules:/lib/modules"
            } ],
            "forcePullImage": false
        }
    },
    "portDefinitions": [],
    "ipAddress": {},
    "args": [
        "--name pxcluster.mesos",
        "-k etcd:http://localhost:2379",
        "-c mesos-demo1",
        "-s /dev/sdb",
        "-m bond0",
        "-d bond0"
    ],
    "healthChecks": [
    {
        "protocol": "HTTP",
        "port": 9001,
        "path": "/status",
        "gracePeriodSeconds": 300,
        "intervalSeconds": 60,
        "timeoutSeconds": 20,
        "maxConsecutiveFailures": 3
    }]
}
```
[Download example](/px-marathon.json?raw=true)


This example illustrates running PX-Enterprise in an "air-gapped" environment, as noted by the "**-c mesos-demo1**" cluster argument and the "**-k etcd**" argument for the key-value database.

If running PX-Enterprise with Lighthouse (SaaS or on-prem), then both the "**-c**" and "**-k**" options would be replaced with a single "**-t**" option indiciating the Lighthouse token-ID.

Each physical device must be listed with its own "**-s**" argument.

In this example a single network interface ("bond0") is used for both management and data traffic.

For all command line options, please see [px-enterprise-usage](/px-usage.html)

## Try it our with an example 
Try the PX deployment out with a simple example.

### Reference PX volumes through the Marathon configuration file

Portworx passes the `pxd` docker volume driver and any associated volumes to Marathon as Docker parameters. The following example is for `mysql`.

```json
{
    "id": "mysql",
    "cpus": 0.5,
    "mem": 256,
    "instances": 1,
    "container": {
        "type": "DOCKER",
        "docker": {
            "image": "mysql:5.6.27",
            "parameters": [
                    {
                       "key": "volume-driver",
                       "value": "pxd"
                    },
                    {
                       "key": "volume",
                       "value": "mysql_vol:/var/lib/mysql"
                    }],
            "network": "BRIDGE",
              "portMappings": [
                {
                  "containerPort": 3306,
                  "hostPort": 32000,
                  "protocol": "tcp"
                }
                ]
        }
    },
    "constraints": [
            [
              "pxfabric",
              "LIKE",
              "pxclust1"
            ]],
    "env": {
        "MYSQL_ROOT_PASSWORD": "password"
    },
      "minimumHealthCapacity" :0,
      "maximumOverCapacity" : 0.0
}
```

[Download example](/px-marathon-mysql.json?raw=true)

* Notice the Docker `parameters` clause as the way to reference the `pxd` volume driver as well as the volume itself.
* The referenced volume can be a volume name, a volume ID, or a snapshot ID.   If the volume name does not previously exist, it gets created in-band with default settings.
* The `constraints` clause, restricts this task to running only on Agent nodes that are part of a given Portworx cluster.

>**Important:**<br/> If you are deploying Portworx on all nodes in the cluster, then you should omit the *"pxfabric"* constraint.

### Launch the application through Marathon

To launch the application through the DC/OS CLI:

```
# dcos marathon app add mysql.json
```

To launch the application through Marathon directly:

```
# curl -X POST http://1.2.3.4:8080/v2/apps -d @mysql.json -H "Content-type: application/json"
```
