---
layout: page
title: "Run Portworx with Mesosphere"
keywords: portworx, PX-Developer, container, Mesosphere, Marathon, storage
sidebar: home_sidebar
youtubeId : 02yMYE-CEdw
---
You can use Portworx to implement storage for Mesosphere and Marathon. Portworx pools your servers' capacity and is deployed as a container. This section, qualified using DC/OS 1.7, describes how to launch Docker containers through Marathon.

The Marathon application configuration files map options through the Docker command line to reference the Portworx volume driver and associated volume.

## Watch the video
Here is a short video that shows how to configure and run Portworx with Mesosphere:
{% include youtubePlayer.html id=page.youtubeId %}


## Step 1: Install Mesosphere DC/OS CLI

Follow the instructions for installing [Mesosphere DC/OS](https://dcos.io/install) and the [DC/OS CLI](https://docs.mesosphere.com/1.7/usage/cli/install).

Use the DC/OS CLI command `dcos node` to identify which nodes in the Mesos cluster are the Agent nodes.

## Step 2: Run the PX-Developer container on Mesos Agent nodes

Depending on which base OS is used for the Mesos Agent nodes, launch the PX-Developer container according to the examples in [Application Solutions](application-solutions.html).

Complete the installation process to create a Portworx cluster using Mesos Agent nodes.

## Step 3: Add Mesos constraints

For each Mesos Agent node that is participating in the PX cluster, specify `MESOS_ATTRIBUTES` that allow for affinity of tasks to nodes that are part of the Portworx cluster.

1. Add `MESOS_ATTRIBUTES=fabric:px` to the file /var/lib/dcos/mesos-slave-common.
2. Restart the slave service:

  ```
  rm -f /var/lib/mesos/slave/meta/slaves/latest
  systemctl restart dcos-mesos-slave.service
  ```
3. Verify that the slave service started properly:

   ```
  systemctl status dcos-mesos-slave.service
   ```

## Step 4: Reference PX volumes through the Marathon configuration file

Portworx passes the `pxd` docker volume driver and any associated volumes to Marathon as Docker parameters. The following example is for `mysql`.

```
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
              "fabric",
              "CLUSTER",
              "px"
            ]],
    "env": {
        "MYSQL_ROOT_PASSWORD": "password"
    },
      "minimumHealthCapacity" :0,
      "maximumOverCapacity" : 0.0
}
```

* Notice the Docker `parameters` clause as the way to reference the `pxd` volume driver as well as the volume itself.
* The referenced volume can be a volume name, a volume ID, or a snapshot ID.   If the volume name does not previously exist, it gets created in-band with default settings.
* The `constraints` clause, restricts this task to running only on Agent nodes that are part of the Portworx cluster.

## Step 5: Launch the application through Marathon

Launch the application as you normally would through the DC/OS CLI. For example:

```
dcos marathon app add mysql.json
```
