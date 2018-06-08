---
layout: page
title: "Run Portworx with Mesosphere DC/OS"
keywords: portworx, PX-Developer, container, Mesos, Mesosphere, storage
redirect_from:
  - /scheduler/mesosphere-dcos/install_xxx_delete_me_soon.html
  - /run-with-mesosphere.html
  - /scheduler/mesosphere-dcos/install_deprecated.html
meta-description: "Find out how to deploy Portworx and manage the Portworx cluster using DCOS."
---

* TOC
{:toc}

This DCOS service will deploy Portworx as well as all the dependencies and additional services to manage the Portworx
cluster. This includes a highly available etcd cluster and the Lighthouse service, which is the Web UI for Portworx.

Portworx can be used to provision volumes on DCOS using either the Docker Volume Driver Interface (DVDI) or, directly
through CSI.

>**Note:**<br/>Please ensure that your mesos private agents have unmounted block devices that can be used by Portworx.

### (Optional) Deploy an AWS Portworx-ready cluster
Using [this AWS CloudFormation template](/scheduler/mesosphere-dcos/px-ready-aws-cf.html), you can easily deploy a
DCOS 1.10 cluster that is "Portworx-ready".

### Pre-install (only required if moving from a Portworx Docker installation)
If you are moving from a Docker install of Portworx to an OCI install, please make sure that the Portworx service is stopped
on all the agents before updating to the OCI install. To do this run the following command on all your private agents:
```bash
sudo systemctl stop portworx
```

### Deploy Portworx
The Portworx service is available in the DCOS universe, you can find it by typing the name in the search bar.

![Portworx in DCOS Universe](/images/dcos-px-universe.png){:width="655px" height="200px"}


To modify the defaults, click on the `Review & Run` button next to the package on the DCOS UI.

On the `Edit configuration` page you can change the default configuration for Portworx deployment. Here you can choose to
enable etcd (if you do not have an external etcd service). To have a custom etcd installation please refer to
[this doc](/maintain/etcd.html). You can also enable the Lighthouse service if you want to use the WebUI.

#### Portworx Options
Specify your kvdb (consul or etcd) server if you don't want to use the etcd cluster with this service. If the etcd cluster
is enabled this config value will be ignored.

>**Note:**<br/>If you are trying to use block devices that already have a filesystem on them, either add the `-f` option
to `portworx options` to force Portworx to use these disks or wipe the filesystem using wipefs command before installing.

![Portworx Install options](/images/dcos-px-install-options.png){:width="655px" height="200px"}

>**Note:**<br/>For a full list of installtion options, please look [here](/runc/options.html#opts).

#### Secrets Options
To use DC/OS secrets for Volume Encryption and storing Cloud Credentials, refer [Portworx with DC/OS Secrets](/secrets/portworx-with-dcos-secrets.html).

#### Etcd Options
By default a 3 node etcd cluster will be created with 5GB of local persistent storage. The size of the persistent disks can
be changed during install. This can not be updated once the service has been started so please make sure you have enough
storage resources available in your DCOS cluster before starting the install.
![Portworx ETCD Install options](/images/dcos-px-etcd-options.png){:width="655px" height="200px"}

#### Lighthouse options
Lighthouse will not be installed by default. If you want to access the Lighthouse UI, you will have to enable it.

By default Lighthouse will run on a public agent in your cluster. If you do not have a public agent, you should
uncheck the `public agent` option. Once deployed, DCOS does not allow moving between public and private agents.

You can enter the `admin username` to be used for creating the Lighthouse account. This can be used to login to
Lighthouse after install in complete. The default password is `Password1` which can be changed after login.

![Portworx Lighthouse Install options](/images/dcos-px-lighthouse-options.png){:width="655px" height="200px"}

Once you have configured the service, click on `Review and Install` and then `Run Service` to start the installation
of the service.

### Install Status

Once you have started the install you can go to the `Services` page to monitor the status of the installation.

If you click on the `portworx` service you should be able to look at the status of the tasks being created. If
you have enabled etcd and Lighthouse, there will be 1 task for the framework scheduler, 3 tasks for etcd and 1
task for Lighthouse. Apart from these there will be one task on every node where Portworx runs.

![Portworx Install finished](/images/dcos-px-install-finished.png){:width="655px" height="200px"}

### Accessing Lighthouse

If Lighthouse is deployed on a private agent, it might not be accessible from outside your network depending on your
network configuration. To access Lighthouse from an external network you can deploy the
[Repoxy](https://gist.github.com/nlsun/877411115f7e3b885b5e9daa8821722f) service to redirect traffic from one of the
public agents.

To do so, run the following marathon application:
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

You can then access the Lighthouse WebUI on http://\<public_agent_ip\>:9998.
If your public agent is behind a firewall you will also need to open up two ports, 9998 and 9999.

#### Login Page
The default username/password is `admin`/`Password1`
![Lighthouse Login Page](/images/dcos-px-lighthouse-login.png){:width="355px" height="100px"}

#### Dashboard
![Lighthouse Dashboard](/images/dcos-px-lighthouse-dashboard.png){:width="655px" height="200px"}

#### Troubleshooting
Lighthouse stores it's config on host volume. If the node is lost, Lighthouse will retain only
that cluster in which it is deployed. You will have to manually add other clusters that you want
to monitor using the Lighthouse. Also, the password will be reset to `Password1`.

In case of node failures, to move the Lighthouse task to some other node, run the following command:
```bash
dcos portworx pod replace lighthouse-0
```

### Scaling Up Portworx Nodes
If you add more agents to your DCOS cluster and you want to install Portworx on those new nodes, you can increase the
`node count` to start install on the new nodes. This will relaunch the service scheduler and install Portworx on the nodes
which didn't have it previously.

![Scale up PX Nodes](/images/dcos-px-scale-up.png){:width="655px" height="200px"}

### Install DCOS Portworx CLI
To install the `dcos portworx` CLI, run the following DCOS CLI command:
```bash
dcos package install portworx --cli
```