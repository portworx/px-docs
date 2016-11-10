---
layout: page
title: "Run Lighthouse"
keywords: portworx, px-developer, px-enterprise, install, configure, container, storage, lighthouse
sidebar: home_sidebar
---

The example in this section uses Amazon Web Services (AWS) Elastic Compute Cloud (EC2) for servers in the cluster. In your deployment, you can use physical servers, another public cloud, or virtual machines.

### Prerequisite

To start, create one server, following these requirements:

* Image: Must support Docker 1.10 or later, such as:
  * [Red Hat 7.2 (HVM)](https://aws.amazon.com/marketplace/pp/B019NS7T5I) or CentOS
  * [Ubuntu 14.04 (HVM)](https://aws.amazon.com/marketplace/pp/B00JV9TBA6/ref=mkt_wir_Ubuntu14)
* Instance type: c3.xlarge
* Number of instances: 1
* Storage:
  * /dev/xvda: 8 GB boot device
* Tag (optional): Add value **px-lighthouse** as the name

### Step 1: Launch the PX-Lighthouse Container

## To run the Lighthouse container

For **CentOS** or **Ubuntu**, start the Portworx container with the following run command:

```
# sudo docker run --restart=always --name px-lighthouse -d --net=bridge \
                 -p 80:80                                               \
                 -e  PWX_INFLUXDB="http://influx-px:8086"               \
                 -e PWX_INFLUXUSR="admin"                               \
                 -e PWX_INFLUXPW="password"                             \
                 -e PWX_HOSTNAME="${LOCAL_IP}"                          \
                 portworx/px-lighthouse                                 \
               etcd:http://${LOCAL_IP}:2379
```
