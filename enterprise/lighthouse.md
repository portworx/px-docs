---
layout: page
title: "Run Lighthouse"
keywords: portworx, px-developer, px-enterprise, install, configure, container, storage, lighthouse
sidebar: home_sidebar
redirect_from: 
  - /run-lighthouse.html
  - /enterprise/on-premise-lighthouse.html
  - /enterprise/lighthouse-with-secure-etcd.html
meta-description: "Lighthouse monitors and manages your PX cluster and storage and can be run on-prem. Find out how today."
---

* TOC
{:toc}

Lighthouse can monitor and manage your PX clusters and storage. This guide shows you how you can run [Lighthouse](http://lighthouse-new.portworx.com/login) locally.

Note: The example in this section uses Amazon Web Services (AWS) Elastic Compute Cloud (EC2). In your deployment, you can use physical servers, another public cloud, or virtual machines.

## Minimum Requirements
Lighthouse runs as a Docker container and has the same minumum requirements as the Portworx storage solution. Please consult [this guide](https://docs.portworx.com/#minimum-requirements) for the minumum requirements.

Lighthouse connects to two other services: 
1) Key Value Database (KVDB) store: it stores all the cluster data and lighthouse management data. This must be the same KVDB store that your Portworx nodes are/will be configured to use
2) Influxdb: it stores all the performance data that lighthouse uses to graph

Setup KVDB store by following instructions on [Etcd](https://docs.portworx.com/maintain/etcd.html).

Setup Influxdb by following instructions on [InfluxDB](https://hub.docker.com/r/library/influxdb/).

## Install Lighthouse: Run the PX-Lighthouse container

Start the container with the following run command:

```
sudo docker run --restart=always                                        \
       --name px-lighthouse -d --net=bridge                             \
       -p 80:80                                                         \
       portworx/px-lighthouse                                           \
       -d http://${ADMIN_USER}:${ADMIN_PASSWORD}@${IP_ADDR}:8086        \
       -k etcd:http://{KVDB_IP_ADDR_1}:2379,etcd:http://{KVDB_IP_ADDR_2}:2379,etcd:http://{KVDB_IP_ADDR_3}:2379               
```

Runtime command options

```
-d http://{ADMIN_USER}:{ADMIN_PASSWORD}@{IP_Address}:8086
   > Connection string of your influx db
-k etcd:http://{KVDB_IP_ADDR_1}:2379,etcd:http://{KVDB_IP_ADDR_2}:2379,etcd:http://{KVDB_IP_ADDR_3}:2379
   > Connection string of your kbdb.
```

The following environment variables are available for px-lighthouse:

```
PWX_KVDB                    KVDB URL:PORT without username:password
PWX_KVDB_AUTH               'true' or 'false', to enable or disable auth 
PWX_KVDB_CA_PATH            Absolute path to host ca cert(e.g. /etc/ssl/ca.crt)
PWX_KVDB_USER_CERT_KEY_PATH Absolute path to host's certificate file (e.g. /etc/ssl/key.cert)
PWX_KVDB_USER_CERT_PATH     Absolute path to host's private key (e.g. /etc/ssl/key.key)
PWX_KVDB_USER_PWD           Username and password for etcd2 as username:password
PWX_INFLUXDB                Influx URL:PORT without username:password
PWX_INFLUXUSR               Influx username
PWX_INFLUXPW                Influx password
PWX_PX_PRECREATE_ADMIN      'true' or 'false', by default false, will create a user 'admin' with password 'admin'
PWX_PX_COMPANY_NAME         Company name, by default Portworx
PWX_PX_ADMIN_EMAIL          Email address that would be used to login

Note: 
1) If you are specifying PWX_KVDB_USER_PWD, then PWX_KVDB_AUTH needs to be set as true
2) PWX_PX_COMPANY_NAME are used in set PWX_PX_ADMIN_EMAIL, and can only be used when PWX_PX_PRECREATE_ADMIN is set to true
```

In your browser visit *http://{IP_ADDRESS}:80* to access your locally running PX-Lighthouse. 
Here as a part of sign-up, you can create a root user and setup email server, that will be used to send emails for password reset, new user signup, Portworx alerts. 

![LH-ON-PREM-FIRST-LOGIN](/images/lh-on-prem-first-login-updated_2.png "First Login"){:width="983px" height="707px"}

## Create Portworx Cluster

Follow the instructions on [Manage PX-Enterprise via Lighthouse](https://docs.portworx.com/enterprise/portworx-via-lighthouse.html).

## Add users to Lighthouse

You have already setup a root user while signing up. Here, we are going to create additional users. Click on the gear icon on top right. From the dropdown, choose 'Manage Users'. Here click on 'New', and fill out user name and email address.

![LH-ADD-USER](/images/LH-add-a-new-user.png "Add User"){:width="983px" height="707px"}

By default lighthouse will create a cluster for this user names &lt;user-name&gt;-cluster and also add this user to a group called &lt;user-name&gt;-group. This user will only have admin access on the cluster that got created for him. These permission can be modified under Manage Users -> Groups -> Edit. Permissions are per comapnay and per cluster based.

![LH-USER-GROUPS](/images/LH-group-details.png "User Groups"){:width="983px" height="707px"}

### Upgrading PX-Lighthouse

You can upgrade your PX-Lighthouse as shown below:

```
sudo docker stop px-lighthouse
sudo docker rm px-lighthouse
sudo docker run --restart=always                                        \
       --name px-lighthouse -d --net=bridge                             \
       -p 80:80                                                         \
       portworx/px-lighthouse                                           \
       -d http://${ADMIN_USER}:${ADMIN_PASSWORD}@${IP_ADDR}:8086        \
       -k etcd:http://{KVDB_IP_ADDR_1}:2379,etcd:http://{KVDB_IP_ADDR_2}:2379,etcd:http://{KVDB_IP_ADDR_3}:2379
```

PX-Lighthouse repository is located [here](https://hub.docker.com/r/portworx/px-lighthouse/). Above mentioned docker commands will upgrade your PX-Lighthouse container to the latest release. There should be minimal downtime in this upgrade process. 

### Provider Specific Instructions

#### Azure

* Make sure you have set inbound security rule to 'Allow' for port 80.

![AZURE-SECURITY-RULES](/images/azure-inbound-security-rules.png "Azure Inbound Security Settings"){:width="557px" height="183px"}

* Access the web console in browser at http://{public-ip-address}:80
