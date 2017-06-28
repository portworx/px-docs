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


### Install PX-Lighthouse
There are two ways to deploy PX-Lighthouse

1. Jump to [Docker Compose](#step-3-start-px-lighthouse-with-docker-compose)
2. Jump to installing the [PX-Lighthouse components manually](#component-install-step-#1:-install-kvdb)

#### Install via Docker compose

>**Important:**
<br/> To get access to Portworx PX-Lighthouse docker repository, contact at 'support@portworx.com'
<br/> Here are the release notes for the latest version of PX-Lighthouse [on-prem-lighthouse-release-notes](/release-notes/on-premise-lighthouse.html)

There is a docker compose file available to bring up on-prem lighthouse with a few easy steps. 
Please skip this section and go to Step 4 if you would like to learn about how to setup each lighthouse component individually so you can customize your configuration according to your needs. 

You can run PX-Lighthouse with [docker-compose](https://docs.docker.com/compose/install/), as follows:

Note: Use the script below to launch ‘PX-lighthouse, using your own LOCAL_IP

For **ETCD2**

```
export LOCAL_IP=1.2.3.4
git clone https://github.com/portworx/px-lighthouse.git
cd px-lighthouse/compose/etcd2
docker-compose up -d
```

For **ETCD3**

```
export LOCAL_IP=1.2.3.4
git clone https://github.com/portworx/px-lighthouse.git
cd px-lighthouse/compose/etcd3
docker-compose up -d
```

For **Consul**

```
export LOCAL_IP=1.2.3.4
git clone https://github.com/portworx/px-lighthouse.git
cd px-lighthouse/compose/consul
docker-compose up -d
``` 

At this point, Lighthouse should be functional.  If you wish to bring up the individual components without compose, follow the steps below.

#### Component Install Step #1: Install kvdb

>**Important:**
<br/> For PX-Lighthouse, output required from this step: 
<br/>Connection string in 'etcd:http://{IP_ADDRESS}:2379' or 'consul:http://{IP_Address}:2379' format

You can either

* Use your existing kvdb store (Lighthouse works with etcd2, etcd3 and consul

or

* Install as a docker container from the following 
  * [etcd2/etcd3](https://github.com/coreos/etcd/blob/2724c3946eb2f3def5ed38a127be982b62c81779/Documentation/op-guide/container.md)
  
  * [consul](https://hub.docker.com/_/consul/)
  
For **ETCD2**, start the container with the following run command:

```
IP_ADDR=10.1.2.3 
sudo docker run -d -p 4001:4001 -p 2379:2379 -p 2380:2380                     \
     --restart=always                                                         \
     --name etcd-px quay.io/coreos/etcd:v2.3.7                                \
     -name etcd0                                                              \
     -data-dir /var/lib/etcd/                                                 \
     -advertise-client-urls http://${IP_ADDR}:2379,http://${IP_ADDR}:4001     \
     -listen-client-urls http://0.0.0.0:2379                                  \
     -initial-advertise-peer-urls http://${IP_ADDR}:2380                      \
     -listen-peer-urls http://0.0.0.0:2380                                    \
     -initial-cluster-token etcd-cluster                                      \
     -initial-cluster etcd0=http://${IP_ADDR}:2380                            \
     -initial-cluster-state new
```

For **ETCD3**, start the container with the following run command:

```
IP_ADDR=10.1.2.3
sudo docker run -d -p 4001:4001 -p 2379:2379 -p 2380:2380                     \
     --restart always                                                         \
     -e "ETCDCTL_API=3" --name etcd3-px quay.io/coreos/etcd                   \
     /usr/local/bin/etcd                                                      \
     --name etcd0                                                             \
     --data-dir /var/lib/etcd/                                                \
     --advertise-client-urls http://${IP_ADDR}:2379,http://${LOCAL_IP}:4001   \
     --listen-client-urls http://0.0.0.0:2379                                 \
     --initial-advertise-peer-urls http://${IP_ADDR}:2380                     \
     --listen-peer-urls http://0.0.0.0:2380                                   \
     --initial-cluster-token etcd-cluster                                     \
     --initial-cluster etcd0=http://${IP_ADDR}:2380                           \
     --initial-cluster-state new
```

For **Consul**, start the container with the following run command:

```
sudo docker run -d -p 8300:8300 -p 8400:8400 -p 8500:8500                                       \
     --restart=always                                                                           \
     --name consul-px                                                                           \
     -e 'CONSUL_LOCAL_CONFIG={"bootstrap_expect":1,"data_dir":"/var/lib/consul","server":true}' \
     consul agent -server -bind=127.0.0.1 -client=0.0.0.0  
```

#### Component Install Step #2: Install InfluxDB

>**Important:**
<br/> For PX-Lighthouse, output required from this step: 
<br/> Connection string in 'http://{ADMIN_USER}:{ADMIN_PASSWORD}@{IP_Address}:8086' format 
<br/> ADMIN_USER: Admin username of influxdb for $PWX_INFLUXUSR
<br/> INFLUXDB_INIT_PWD: Password of admin user for $PWX_INFLUXPW 

Lighthouse requires access to InfluxDB for tracking statistics.

Either 

* [Use InfluxCloud](https://cloud.influxdata.com/)

or

* [Run InfluxDB as a docker container](https://github.com/tutumcloud/influxdb)

for configuring InfluxDB access for Lighthouse

Example docker command to run influxdb in a container:

```
sudo docker run -d -p 8083:8083 -p 8086:8086 --restart always \
     --name influxdb                                          \
     -e ADMIN_USER="admin"                                    \
     -e INFLUXDB_INIT_PWD="password"                          \
     -e PRE_CREATE_DB="px_stats" tutum/influxdb:latest
```

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
