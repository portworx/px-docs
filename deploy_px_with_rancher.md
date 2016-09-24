---
layout: page
title: "Deploy Portworx with Rancher"
keywords: portworx, PX, container, Rancher, storage
sidebar: home_sidebar
---
You can deploy Portworx through Rancher using the Rancher's Portworx Catalog.
The following sequence illustrates deployment in an Amazon AWS/EC2 environment.

## Step 1: Add a Host
For availability zone, use either "West N. California", or "East N. Virginia"

## Step 2: Configure Instance

* Select the name and count of your instances
* Use **m3.medium** as the instance type
* For West, use **ami-d0651bc7** for the AMI image name;  For East, use **ami-ebe6a98b** for the AMI image name.
* Specify **128GB** as the root size

(/images/rancher.png)

## Step 3 : Advanced Options

* Expand "Advanced Options".  For "Docker Install URL", select "Latest" from the dropdown

## Step 4:  Add Portworx Service

Next, select "Add From Catalog".  Select Portworx.
For "Cluster Token", provide the token supplied to you from Portworx.
Select Launch



