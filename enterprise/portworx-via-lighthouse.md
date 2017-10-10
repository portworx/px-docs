---
layout: page
title: "Manage PX-Enterprise via Lighthouse"
keywords: portworx, px-enterprise, cluster, container, storage
sidebar: home_sidebar
redirect_from:
  - /launch-via-lighthouse.html
  - /create-px-enterprise-cluster.html
meta-description: "Lighthouse is a management and GUI to create PX clusters and launch PX nodes to join your clusters. Learn how to manage PX clusters via the Lighthouse today."
---

* TOC
{:toc}

Lighthouse is a management and GUI service that allows you to create PX clusters and launch PX nodes to join your clusters.  You can then manage your PX clusters via the Lighthouse web interface.

This section walks through installing and configuring a PX-Enterprise cluster via Lighthouse. In this example, you run the PX-Enterprise Docker container on server nodes. Running the container enables PX-Enterprise to aggregate storage capacity and monitor hardware for degradation and failure. Server nodes are joined into a cluster for the sake of high availability. You can use direct attached disks, storage arrays, or cloud volumes for the underlying storage.

## Step 1: Provision a cluster in the PX-Enterprise console

Log in to the PX-Enterprise Lighthouse console. If a cluster has not already been created for your account, click the **Manage Clusters** menu and then click **Manage Clusters**.

![Manage Clusters menu](/images/clusters-manage-clusters-menu-updated-2.png "Manage Clusters menu"){:width="312px" height="228px"}

On the **Clusters** page, click the **+** icon to create a new storage cluster.

![Add a cluster](/images/clusters-add-updated.png "Add a cluster"){:width="1115px" height="510px"}

Then, type a unique Name for your PX-Enterprise cluster and click **Create**.

![Name a new cluster](/images/clusters-new-updated.png "Name a new cluster"){:width="848px" height="406px"}

(Don't use the "Existing Cluster" option, unless directed by Portworx Support.)

The new cluster appears in the Clusters list.

![List of clusters](/images/clusters-list-updated-2.png "List of clusters"){:width="1590px" height="503px"}

## Step 2: Run discovery and bootstrap on a server node

You will now add your first server node to the storage cluster. On the **Clusters** page, click **Get Startup Script** for the cluster you just created.

![Startup script example](/images/clusters-list-updated-2.png "Startup script example"){:width="1590px" height="503px"}

A window containing a `curl` command opens. The following `curl` example includes an authentication token and downloads the PX-Enterprise Docker container.

![Startup script to add a cluster](/images/startup-script-window-updated.png "Startup script to add a cluster"){:width="794px" height="812px"}

Log in to each node that will install PX-Enterprise and join the cluster. Open a terminal window and run as `root` or `sudo su` to give privileges. On your system, copy the `curl` string provided by the pop-up window and paste it into a terminal session and press Enter, as shown below.

![Startup script status messages](/images/startup-script-result-updated.png "Startup script status messages"){:width="854px" height="492px"}

## Step 3: Configure the Hardware Profile

The bootstrap startup script discovers the server/node configuration. It lets you specify which storage and network elements you want to participate in PX-Enterprise.

First menu is ***Storage Selection Menu*** You can either pick individual storage devices or can choose to add all devices.

![Hardware configuration](/images/storage-selection-menu.png "Hardware configuration"){:width="724px" height="405px"}

Second menu is ***Data Network Interface Selection Menu*** This will let you assign one of your network interfaces as data interface for your this node.
The *data interface* is used between server nodes, primarily for data transfer as part of data availability (that is, multi-node data replication).

![Hardware configuration](/images/data-network-interface-selection-menu.png "Hardware configuration"){:width="728px" height="410px"}

Last menu is ***Management Network Interface Selection Menu*** This will let you assign one of your network interfaces as management interface for your this PX node.
The *management interface* is used for communication between the hosted PX-Enterprise product and the individual server nodes, for control-path as well as statistics and metrics.

Note: You can choose to use the same interface both for data interface and management interface.PX-Enterprise requires at least one NIC and only needs a maximum of two NICs.

![Hardware configuration](/images/management-network-interface-selection-menu.png "Hardware configuration"){:width="725px" height="409px"}

To instruct the PX-Enterprise container on the server node to complete the installation, click **Commit Selections** on the Management Network Interface Selection Menu. Upon installation, PX-Enterprise aggregates the specified storage and uses the network interfaces selected.

From the server node that ran the `curl` command, you should see the following status:

![Status messages after activation](/images/status-messages-after-activate.png "Status messages after activation"){:width="1379px" height="736px"}

Bootstrap script also saves your selection as a unique *Hardware Profile*. You can reference this on any other node where you want to run PX-Enterprise with the same storage and network elements.

![Hardware configuration](/images/hardware-profile-example.png "Hardware configuration"){:width="1379px" height="118px"}

## Step 4: Expand the cluster

You can add new servers nodes to the existing cluster by running the bootstrap script for a cluster. Server nodes can have different Server Profiles, where some servers might contribute little or no storage to the cluster.

>**Important:**<br/>For server node connections, use a low-latency network, as opposed to spanning a WAN. For more details, see [Step 1: Verify requirements](/getting-started/px-developer.html#step-1-verify-requirements).

At this point you will have a PX-Enterprise cluster that you will be able to monitor from PX-Enterprise console.

![New cluster in Lighthouse](/images/new-cluster-in-lighthouse.png "New cluster in Lighthouse"){:width="1394px" height="595px"}
