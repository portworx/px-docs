---
layout: page
title: "How it Works"
keywords: portworx, px-enterprise, px-developer, containers, storage, architecture
sidebar: home_sidebar
meta-description: "Learn how a Portworx cluster is architected in order to provide persistence for stateful Docker containers."
---

* TOC
{:toc}
Portworx storage runs in a cluster of server nodes.

Each server has the Portworx container and the Docker daemon.
Servers join a cluster and share configuration through PX-Enterprise or the key/value store, such as etcd.
The Portworx container pools the capacity of the storage media residing on the server.

![Portworx cluster architecture](/images/cluster-architecture.png "Portworx cluster architecture"){:width="442px" height="492px"}

Storage volumes are thinly provisioned, using capacity only as an application consumes it. Volumes are replicated across the nodes within the cluster, per a volume’s configuration, to ensure high availability.

Using MySQL as an example, a Portworx storage cluster has the following characteristics:

* MySQL is unchanged and continues to write its data to /var/lib/mysql.
* This data gets stored in the container’s volume, managed by Portworx.
* Portworx synchronously and automatically replicates writes to the volume across the cluster.

![Portworx cluster architecture with MySQL](/images/cluster-architecture-example-mysql.png "Portworx cluster architecture with MySQL"){:width="839px" height="276px"}

Each volume specifies its request of resources (such as its max capacity and IOPS) and its individual requirements (such as ext4 as the file system and block size).

Using IOPS as an example, a team can choose to set the MySQL container to have a higher IOPS than an offline batch processing container. Thus, a container scheduler can move containers, without losing storage and while protecting the user experience.
