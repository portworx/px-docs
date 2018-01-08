---
layout: page
title: "Run Zookeeper on DCOS"
keywords: portworx, container, Mesos, Mesosphere, DCOS, Zookeeper
meta-description: "For help installing and running Zookeeper on DCOS, use the guide from Portworx! Achieve more with Portworx backing your cluster."
---

* TOC
{:toc}

DC/OS provides a Zookeeper service that makes it easy to deploy and manage Zookeeper on Mesosphere DC/OS. This guide will help you to install and run the containerized
Zookeeper service backed by Portworx volumes for [persistent DCOS
storage](https://portworx.com/use-case/persistent-storage-dcos/).

The source code for these services can be found here: [Portworx DCOS-Commons Frameworks](https://github.com/portworx/dcos-commons)

>**Note:**<br/>This framework is only supported directly by Portworx.
>Please contact support@portworx.com directly for any support issues related with using this framework.

Please make sure you have installed [Portworx on DCOS](/scheduler/mesosphere-dcos/install.html) before proceeding further.

## Install
### Adding the repository for the service

For this step you will need to login to a node which has the dcos cli installed and is authenticated to your DCOS cluster.

Run the following command to add the repository to your DCOS cluster:

```
$ dcos package repo add --index=0 portworx-zookeeper-aws https://universe-converter.mesosphere.com/transform?url=https://px-dcos-dev.s3.amazonaws.com/autodelete7d/portworx-zookeeper/20180108-191631-sIi4sgvQfmd1yaDY/stub-universe-portworx-zookeeper.json
```

Once you have run the above command you should see the `portworx-zookeeper` service available in your universe

![portworx-zookeeper in DCOS Universe](/images/dcos-portworx-zookeeper-universe.png){:width=2597px" height="1287px"}

### Default Install
If you want to use the defaults, you can now run the dcos command to install the service
```
$ dcos package install --yes portworx-zookeeper
```
You can also click on the  “Install” button on the WebUI next to the service and then click “Install Package”.
The default install will create PX volumes of size 2GB with 1 replica.

### Advanced Install and Volume Options
If you want to modify the default, click on the “Install” button next to the package on the DCOS UI and then click on
“Advanced Installation”

Here you have the option to change the service name, volume name, volume size, and provide any additional options for the
Portworx volume. You can also configure other Zookeeper related parameters on this page including the number of Zookeeper
nodes.

![portworx-zookeeper install options](/images/dcos-portworx-zookeeper-install-options.png){:width="655px" height="200px"}

Click on “Review and Install” and then “Install” to start the installation of the service.

### Install Status
Once you have started the install you can go to the Services page to monitor the status of the installation.

![portworx-zookeeper on services page](/images/dcos-portworx-zookeeper-service.png){:width="655px" height="200px"}

If you click on the `portworx-zookeeper` service you should be able to look at the status of the nodes being created. There will be
one service for the scheduler and one service each for the Zookeeper nodes.

![portworx-zookeeper install started](/images/dcos-portworx-zookeeper-started-install.png){:width="655px" height="200px"}

When the Scheduler service as well as the Zookeeper nodes are in Running (green) status, you should be ready to start using the
Zookeeper cluster.

![portworx-zookeeper install finished](/images/dcos-portworx-zookeeper-finished-install.png){:width="655px" height="200px"}

If you check your Portworx cluster, you should see multiple volumes that were automatically created using the options
provided during install, one for each node of the Zookeeper cluster.

![portworx-zookeeper volumes](/images/dcos-portworx-zookeeper-volume-list.png){:width="655px" height="200px"}

If you run the “dcos service” command you should see the `portworx-zookeeper` service in ACTIVE state with 3 running tasks, one for
each Zookeeper node.

```
$ dcos service
NAME                     HOST      ACTIVE  TASKS  CPU   MEM     DISK   ID
marathon            192.168.65.90   True     2    2.0  2048.0   0.0    b69b8ce2-fe89-4688-850c-9a70438fc8f3-0000
metronome           192.168.65.90   True     0    0.0   0.0     0.0    b69b8ce2-fe89-4688-850c-9a70438fc8f3-0001
portworx               a1.dcos      True     2    0.6  2048.0  1024.0  b69b8ce2-fe89-4688-850c-9a70438fc8f3-0022
portworx-zookeeper     a1.dcos      True     3    1.5  3072.0   0.0    b69b8ce2-fe89-4688-850c-9a70438fc8f3-0028
```

## Verify Setup

From the DCOS client, install the new command for `portworx-zookeeper`
```
$ dcos package install portworx-zookeeper --cli
```

Find out all Zookeeper client endpoints
```
$ dcos portworx-zookeeper endpoints client-port
{
  "address": [
    "192.168.65.131:2182",
    "192.168.65.111:2182",
    "192.168.65.121:2182"
  ],
  "dns": [
    "zookeeper-0-node.portworx-zookeeper.autoip.dcos.thisdcos.directory:2182",
    "zookeeper-1-node.portworx-zookeeper.autoip.dcos.thisdcos.directory:2182",
    "zookeeper-2-node.portworx-zookeeper.autoip.dcos.thisdcos.directory:2182"
  ]
}
```

Using any of the above DNS names, you can now connect to the Zookeeper cluster backed by Portworx volumes.

## Scaling

You do not need to create additional PX volumes manually to scale up your cluster.
Just go to the Zookeeper service page, click on the three dots on the top right corner of the page, select “nodes”, scroll
down and increase the nodes parameter to the desired nodes.

Click on “Review and Run” and then “Run Service”. The service scheduler should restart with the updated node count and create more
Zookeeper nodes with newly created PX volumes. Please make sure you have enough resources and nodes available to scale up the number
of nodes. You also need to make sure Portworx is installed on all the agents in the DCOS cluster.

You can also increase the capacity of your Zookeeper data nodes by using the `pxctl volume update` command without taking the service offline.