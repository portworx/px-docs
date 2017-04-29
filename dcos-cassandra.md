---
layout: page
title: "Cassandra on DCOS with Portworx"
keywords: portworx, container, Mesos, Mesosphere, DCOS, Cassandra
---

TODO: Will generate cleaner links in S3
TODO: Will see if it’s possible to add one repo with all the services available from there
TODO: Update screenshots which shows <Service>-PX as the name of the package

This guide will help you to install the Cassandra service on your DCOS cluster backed by PX volumes for persistent storage.

Since the stateful services in DCOS universe do not have support for external volumes, you will need to add additional
repositories to your DCOS cluster to install the services mentioned here. 

The source code for these services can be found here: https://github.com/libopenstorage/dcos-commons

## Adding Service repository:

Login to a node which has dcos cli installed and is authenticated to your DCOS cluster.

Run the following command to add the repository:

```
$ dcos package repo add --index=0 cassandra-px https://disrani-cassandra.s3.amazonaws.com/autodelete7d/cassandra/20170427-193540-K1Ec66NZm1SDuIIg/stub-universe-cassandra.zip
```

Once you have run the above command you should see the Cassandra-PX service available in your universe

![Cassandra-PS in DCOS Universe](images/dcos-cassandra-unviverse.png){:width="655px" height="199px"}

## Installation
### Default Install
If you want to use the defaults, you can now run the dcos command to install the service
```
$ dcos package install --yes cassandra-px
```
You can also click on the  “Install” button on the WebUI next to the service and then click “Install Package”.

### Advanced Install
If you want to modify the default, click on the “Install” button next to the package on the DCOS UI and then click on
“Advanced Installation”

Here you have the option to change the service name, volume name, volume size,and provide any additional options that you
want to pass to the docker volume driver. You can also configure other Cassandra related parameters on this page including
the number of Cassandra nodes.

Click on “Review and Install” and then “Install” to start the installation of the service.

## Install Status
Once you have started the install you can go to the Services page to monitor the status of the installation.

{InsertScreenshot of Services page}

If you click on the Cassandra-PX service you should be able to look at the status of the nodes being created. There will be
one service for the scheduler and one service each for the Cassandra nodes. When the Scheduler service as well as the
Cassandra nodes are in Running (green) status, you should be ready to start using the Cassandra cluster.

{Insert screenshot of running Cassandra cluster}

If you check your Portworx cluster, you should see multiple volumes that were automatically created using the options provided
during install, one for each node of the Cassandra cluster.

TODO: Add dcos cli command to check status of service

## Scaling the number of nodes
You do not need to create additional volumes of perform to scale up your cluster. 
Just go to the Cassandra service page, click on the three dots on the top right corner of the page, select “nodes”, scroll
down and increase the nodes parameter to the desired nodes.

Click on “Review and Run” and then “Run Service”. The service scheduler should restart with the updated node count and
create more Cassandra nodes. Please make sure you have enough resources and nodes available to scale up the number of nodes.
You also need to make sure Portworx is installed on all the agents in the DCOS cluster.
