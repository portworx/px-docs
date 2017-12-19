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

>**Note:**<br/>You must have an enterprise license to be able to download and install the `portworx/px-lighthouse` image.  Please contact support@portworx.com for access to this image and the install instructions.

## Connect Lighthouse to your Portworx Cluster
Lighthouse runs as a Docker container and has the same minumum requirements as the Portworx storage solution. Please consult [this guide](https://docs.portworx.com/#minimum-requirements) for the minumum requirements.

Lighthouse connects to an existing PX cluster by talking to the same KVDB that your PX cluster uses.  In order to get Lighthouse to manage your PX cluster, you must provide the following connection strings:

* Key Value Database (KVDB) store: This must be the same KVDB store that your Portworx nodes use.
* Influxdb: Light house stores the performance data of your PX cluster in this time series DB.

Setup Influxdb by following instructions on [InfluxDB](https://hub.docker.com/r/library/influxdb/).

## Connect to Lighthouse
Once you have Lighthouse installed, visit *http://{IP_ADDRESS}:80* in your browser to access your locally running PX-Lighthouse. 
Here as a part of sign-up, you can create a root user and setup email server, that will be used to send emails for password reset, new user signup, Portworx alerts. 

![LH-ON-PREM-FIRST-LOGIN](/images/lh-on-prem-first-login-updated_2.png "First Login"){:width="983px" height="707px"}

## Create Portworx Cluster

Follow the instructions on [Manage PX-Enterprise via Lighthouse](https://docs.portworx.com/enterprise/portworx-via-lighthouse.html).

## Add users to Lighthouse

You have already setup a root user while signing up. Here, we are going to create additional users. Click on the gear icon on top right. From the dropdown, choose 'Manage Users'. Here click on 'New', and fill out user name and email address.

![LH-ADD-USER](/images/LH-add-a-new-user.png "Add User"){:width="983px" height="707px"}

By default lighthouse will create a cluster for this user names &lt;user-name&gt;-cluster and also add this user to a group called &lt;user-name&gt;-group. This user will only have admin access on the cluster that got created for him. These permission can be modified under Manage Users -> Groups -> Edit. Permissions are per comapnay and per cluster based.

![LH-USER-GROUPS](/images/LH-group-details.png "User Groups"){:width="983px" height="707px"}

PX-Lighthouse repository is located [here](https://hub.docker.com/r/portworx/px-lighthouse/). Above mentioned docker commands will upgrade your PX-Lighthouse container to the latest release. There should be minimal downtime in this upgrade process. 

### Provider Specific Instructions

#### Azure

* Make sure you have set inbound security rule to 'Allow' for port 80.

![AZURE-SECURITY-RULES](/images/azure-inbound-security-rules.png "Azure Inbound Security Settings"){:width="557px" height="183px"}
