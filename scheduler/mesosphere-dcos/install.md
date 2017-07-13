---
layout: page
title: "Run Portworx with Mesosphere/DCOS"
keywords: portworx, PX-Developer, container, Mesos, Mesosphere, storage
---

* TOC
{:toc}

This DCOS service will deploy Portworx as well as all the dependencies and additional services to manage the Portworx
cluster. This includes a highly available etcd cluster, influxdb to store statistics and the Lighthouse service, which is
the Web UI for Portworx.

Portworx can be used to provision volumes on DCOS using either the Docker Volume Driver Interface (DVDI) or, directly 
through CSI.

## Deploy Portworx
### Adding the repository for the service:

For this step you will need to login to a node which has the dcos cli installed and is authenticated to your DCOS cluster.

Run the following command to add the repository to your DCOS cluster:

```
$ dcos package repo add --index=0 portworx https://px-dcos.s3.amazonaws.com/v1/portworx/portworx.zip
```

Once you have run the above command you should see the Portworx service available in your universe

![Portworx in DCOS Universe](/images/dcos-px-universe.png){:width="655px" height="200px"}

### Default Install
If you want to use the defaults, you can now run the dcos command to install the service
```
$ dcos package install --yes portworx
```
You can also click on the  “Install” button on the WebUI next to the service and then click “Install Package”.

This will install all the prerequisites and start the Portworx service on 3 private agents.
The default login/password for lighthouse would be portworx@yourcompany.com/admin

### Advanced Install
If you want to modify the defaults, click on the “Install” button next to the package on the DCOS UI and then click on
“Advanced Installation”

Through the advanced install options you can change the configuration of the Portworx deployment. Here you can choose to
disable etcd (if you have an external etcd service) as well as disable the Lighthouse service in case you do not want to
use the WebUI.

### Portworx Options
Specify your kvdb (consul or etcd) server if you don't want to use the etcd cluster with this service. If the etcd cluster
is enabled this config value will be ignored.
If you have been given access to the Enterprise version of PX you can replace px-dev:latest with px-enterprise:latest.
With PX Enterprise you can increase the number of nodes in the PX Cluster to a value greater than 3.
![Portworx Install options](/images/dcos-px-install-options.png){:width="655px" height="200px"}

### Etcd Options
By default a 3 node etcd cluster will be created with 5GB of local persistent storage. The size of the persistent disks can
be changed during install. This can not be updated once the service has been started so please make sure you have enough
storage resources available in your DCOS cluster before starting the install.
![Portworx ETCD Install options](/images/dcos-px-etcd-options.png){:width="655px" height="200px"}

### Lighthouse options
By default the Lighthouse service will be installed. If this is disabled the influxdb service will also be disabled.

You can enter the admin email to be used for creating the Lighthouse account. This can be used to login to Lighthouse
after install is complete. The default password is `admin` which can be changed after login.

![Portworx Lighthouse Install options](/images/dcos-px-lighthouse-options.png){:width="655px" height="200px"}

Once you have configured the service, click on “Review and Install” and then “Install” to start the installation of the
service.

## Install Status

Once you have started the install you can go to the Services page to monitor the status of the installation.

If you click on the Portworx service you should be able to look at the status of the services being created. 

In a default install there will be one service for the framework scheduler, 5 services for etcd (one for the etcd scheduler,
3 etcd nodes and one etcd proxy), one service for influxdb and one service for lighthouse.

![Portworx Install finished](/images/dcos-px-install-finished.png){:width="655px" height="200px"}

The install for Portworx on the agent nodes will also run as a service but they will "Finish" once the installation is done.

You can check the nodes where Portworx is installed and the status of the Portworx service by clicking on the Components
link on the DCOS UI.
![Portworx in DCOS Compenents](/images/dcos-px-components.png){:width="655px" height="200px"}

## Accessing Lighthouse

Since Lighthouse is deployed on a private agent it might not be accessible from outside your network depending on your
network configuration. To access Lighthouse from an external network you can deploy the
[Repoxy](https://gist.github.com/nlsun/877411115f7e3b885b5e9daa8821722f) service to redirect traffic from one of the public 
agents.

To do so, run the following marathon application

```
{
  "id": "/repoxy",
  "cpus": 0.1,
  "acceptedResourceRoles": [
      "slave_public"
  ],
  "instances": 1,
  "mem": 128,
  "container": {
    "type": "DOCKER",
    "docker": {
      "image": "mesosphere/repoxy:2.0.0"
    },
    "volumes": [
      {
        "containerPath": "/opt/mesosphere",
        "hostPath": "/opt/mesosphere",
        "mode": "RO"
      }
    ]
  },
  "cmd": "/proxyfiles/bin/start portworx $PORT0",
  "portDefinitions": [
    {
      "port": 9998,
      "protocol": "tcp"
    },
    {
      "port": 9999,
      "protocol": "tcp"
    }
  ],
  "requirePorts": true,
  "env": {
    "PROXY_ENDPOINT_0": "Lighthouse,http,lighthouse-0-start,mesos,8085,/,/"
  }
}
```

You can then access the Lighthouse WebUI on http://\<public_agent_IP\>:9998.
If your public agent is behind a firewall you will also need to open up two ports, 9998 and 9999.

### Login Page
The default username/password is portworx@yourcompany.com/admin
![Lighthouse Login Page](/images/dcos-px-lighthouse-login.png){:width="655px" height="200px"}

### Dashboard
![Lighthouse Dashboard](/images/dcos-px-lighthouse-dashboard.png){:width="655px" height="200px"}

## Scaling Up Portworx Nodes

If you add more agents to your DCOS cluster and you want to install Portworx on those new nodes, you can increase the 
NODE_COUNT to start install on the new nodes. This will relaunch the service scheduler and install Portworx on the nodes 
which didn't have it previously.

![Scale up PX Nodes](/images/dcos-px-scale-up.png){:width="655px" height="200px"}
