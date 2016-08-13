---
layout: page
---
# Get Started with PX-Enterprise

Portworx PX-Enterprise is full-featured container storage for DevOps, IT ops, and the enterprise.

## Step 1: Verify requirements

* Linux kernel 3.10 or greater
* Docker 1.10 or greater, configured with [devicemapper](https://docs.docker.com/engine/userguide/storagedriver/device-mapper-driver/#/configure-docker-with-devicemapper)
* Minimum resources per server:
  * 4 CPU cores
  * 4 GB RAM
* Recommended resources per server:
  * 12 CPU cores
  * 16 GB RAM
  * 128 GB Storage
  * 10Gb
* Maximum nodes per cluster:
    * 20 server nodes

## Step 2: Get PX-Enterprise

For information about PX-Enterprise and to request a demo, please provide your contact information [here](http://na-sj15.marketo.com/lp/126-NHQ-240/request_a_demo.html).

After you purchase PX-Enterprise, you'll receive an email with the PX-Enterprise web console URL.

## Step 3: Take a tour of the PX-Enterprise web console

The PX-Enterprise web console provides storage management for all of your PX-Enterprise deployments, including on-premises clusters and in public clouds. The console monitors health and capacity and lets you provide container-granular storage. You can use any scheduler to orchestrate containers.

The Overview page provides a summary view of the health of a cluster. In the example below, the cluster called DBaaS-cluster-1 is selected in the upper right. **There are twenty server nodes offering XXX TB of capacity through YYY drives.** The Alerts identify key status changes for that cluster, sorted by severity or recency.

![Overview page in Portworx console](images/overview.png "Overview page in Portworx console")

Use the top row of the cluster Overview page to navigate to server Nodes, manage Storage, view running Containers, or chart the Performance and storage capacity for the cluster.

The Storage page presents a complete view for a cluster’s storage, as shown below. From this page, you can create new volumes (under Actions) and manage existing volumes, including snapshotting a volume.

![Storage page in Portworx console](images/storage-with-volume-groups.png "Storage page in Portworx console")

You can also create volumes programmatically using a scheduler or by the container itself, as well as from the command-line. You can manage a volume created by any of those methods from the Storage page. For information about supported schedulers, see "Run PX-Enterprise with schedulers" in the next step.

For more on creating and managing volumes, see [Create and Manage Storage Volumes](create-manage-storage-volumes.html).

## Step 4: Start configuring

[Create a PX-Enterprise Cluster](create-px-enterprise-cluster.html)  <br/>
[Create and Manage Storage Volumes](create-manage-storage-volumes.html)  <br/>
[Manage Nodes and Capacity](ZZZ.html)  <br/>
[Manage Users](manage-users-groups.html)

Run PX-Enterprise with schedulers:

* Docker Swarm
* [Run Portworx with Kubernetes](install_with_k8s.html)
* [Run Portworx with Mesosphere](install_with_mesosphere.html)
* [Run Portworx with Rancher](run_with_rancher.html)


You can also use our [pxctl CLI](https://github.com/portworx/px-dev/blob/master/cli_reference.html) to:

* View the cluster global capacity and health
* Create, inspect, and delete storage volumes
* Attach policies for IOPs prioritization, maximum volume size, and enable storage replication
