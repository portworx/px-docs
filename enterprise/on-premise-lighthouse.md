---
layout: page
title: "Run Lighthouse On Prem"
keywords: portworx, px-developer, px-enterprise, install, configure, container, storage, lighthouse
sidebar: home_sidebar
redirect_from: "/run-lighthouse.html"
---

* TOC
{:toc}

Portworx offers a SaaS service called Lighthouse.  Lighthouse can monitor and manage your PX clusters and storage.  However you can also run your own Lighthouse.

This guide shows you how you can run [Lighthouse](https://lighthouse.portworx.com/login) locally.

Note: The example in this section uses Amazon Web Services (AWS) Elastic Compute Cloud (EC2) for servers in the cluster. In your deployment, you can use physical servers, another public cloud, or virtual machines.

### Prerequisite #1 - Launch Server

To start, create one server, following these requirements:

* Image: Must support Docker 1.10 or later, such as:
  * [Red Hat 7.2 (HVM)](https://aws.amazon.com/marketplace/pp/B019NS7T5I) or CentOS
  * [Ubuntu 16.04 (HVM)](https://aws.amazon.com/marketplace/pp/B01JBL2M0O)
  * [Ubuntu 14.04 (HVM)](https://aws.amazon.com/marketplace/pp/B00JV9TBA6)
* Instance type: c3.xlarge
* Number of instances: 1
* Storage:
  * /dev/xvda: 8 GB boot device
* Tag (optional): Add value **px-lighthouse** as the name

### Prerequisite #2 - Install and configure Docker

1. Follow the Docker [install guide](https://docs.docker.com/engine/installation/) to install and start the Docker Service.
2. Verify that your Docker version is 1.10 or later.



2. Jump to installing the [PX-Lighthouse components manually](#component-install-step-#1:-install-kvdb)


#### Component Install Step #1: Ensure Lighthouse Container can access the kvdb

>**Important:**
<br/> For PX-Lighthouse, output required from this step: 
<br/>Connection string in 'etcd:http://{IP_ADDRESS}:2379' or 'consul:http://{IP_Address}:2379' format


* Use your existing kvdb store (Lighthouse works with etcd2, etcd3 and consul)

#### Component Install Step #3: Run the PX-Lighthouse container

For **ETCD**, start the container with the following run command:

```
sudo docker run --restart=always                                        \
       --name px-lighthouse -d --net=bridge                             \
       -p 80:80                                                         \
       portworx/px-lighthouse                                           \
       -d http://${ADMIN_USER}:${ADMIN_PASSWORD}@${IP_ADDR}:8086        \
       -k etcd:http://${IP_ADDR}:2379                
```

For **Consul**, start the container with the following run command:

```
sudo docker run --restart=always --name px-lighthouse -d --net=bridge    \
       -p 80:80                                                          \
       portworx/px-lighthouse                                            \
       -d http://${ADMIN_USER}:${ADMIN_PASSWORD}@${IP_ADDR}:8086         \
       -k consul:http://${IP_ADDR}:8500                
```

Runtime command options

```
-d http://{ADMIN_USER}:{ADMIN_PASSWORD}@{IP_Address}:8086
   > Connection string of your influx db
-k {etcd/consul}:http://{IP_Address}:{Port_NO}
   > Connection string of your kbdb.
   > Note: Specify port 2379 for etcd and 8500 for consul
   > If you have multinode etcd cluster then you can specify your connection string as 
       > 'etcd:http://{IP_Address_1}:2379,etcd:http://{IP_Address_2}:2379,etcd:http://{IP_Address_3}:2379'
```

In your browser visit *http://{IP_ADDRESS}:80* to access your locally running PX-Lighthouse.

![LH-ON-PREM-FIRST-LOGIN](/images/lh-on-prem-first-login-updated_2.png "First Login"){:width="983px" height="707px"}


### Upgrading PX-Lighthouse

You can upgrade your PX-Lighthouse as shown below:

For **ETCD**, upgrade with the following commands:

```
sudo docker stop px-lighthouse
sudo docker rm px-lighthouse
sudo docker run --restart=always                                        \
       --name px-lighthouse -d --net=bridge                             \
       -p 80:80                                                         \
       portworx/px-lighthouse                                           \
       -d http://${ADMIN_USER}:${ADMIN_PASSWORD}@${IP_ADDR}:8086        \
       -k etcd:http://${IP_ADDR}:2379
```
For **Consul**, upgrade with the following commands:

```
sudo docker stop px-lighthouse
sudo docker rm px-lighthouse
sudo docker run --restart=always --name px-lighthouse -d --net=bridge    \
       -p 80:80                                                          \
       portworx/px-lighthouse                                            \
       -d http://${ADMIN_USER}:${ADMIN_PASSWORD}@${IP_ADDR}:8086         \
       -k consul:http://${IP_ADDR}:8500   
```

PX-Lighthouse repository is located [here](https://hub.docker.com/r/portworx/px-lighthouse/). Above mentioned docker commands will upgrade your PX-Lighthouse container to the latest release. There should be minimal downtime in this upgrade process. 

### Provider Specific Instructions

#### Azure

* Make sure you have set inbound security rule to 'Allow' for port 80.

![AZURE-SECURITY-RULES](/images/azure-inbound-security-rules.png "Azure Inbound Security Settings"){:width="557px" height="183px"}

* Access the web console in browser at http://{public-ip-address}:80
