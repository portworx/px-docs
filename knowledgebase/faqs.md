---
layout: page
title: "FAQs"
keywords: portworx, faqs
sidebar: home_sidebar
redirect_from: "/px-faqs.html"
meta-description: "Find answers to all the most frequently asked questions about Portworx.  Explore our FAQ today!"
---
* TOC
{:toc}

### Can Portworx run in the cloud?   On premise?   Both?
Portworx clusters can run in the cloud or on premise.  The volume format is the same, regardless of running in the cloud or on-prem.  When running in the cloud, Portworx aggregates and virtualizes the various underlying cloud volumes.

### Is there a Hardware/Software compatibility list?
Hardware : No. But there are minimum resource recommendation listed [here](/getting-started/px-enterprise.html#step-1-verify-requirements) 

Software:   Linux kernel 3.10 and above;     Docker 1.11 and above.

### Can Portworx work with any drive vendor?
Yes.  Portworx can recognize any drive and its type, capacity and IOPS capability and use it appropriately for the given workload.

### Do I need to create a RAID group or do I present all the drives to Portworx individually?
There is no nead to pre-prepare a RAID group.  Portworx will appropriately place raid drives into different tiers based on their profile.

### Does Portworx need to take over all the disks on a given server?
No.  You can explicitly allow/disallow drives that participate in a Portworx cluster. In PX-Enterprise, this notion of device delegation/participation is exposed through the "Server Profile".
A "Server Profile" determines which nodes will be allowed to automatically join a cluster, based on their H/W profile.
Similarly, the "Server Profile" determines which devices should not be allowed to participate in the Portworx Fabric.

### Can Portworx work with iSCSI or FC and make use of existing legacy storage (EMC, NetApp, Nexenta, etc.)?
Yes. Any block storage presented to a host can be used within a Portworx cluster.

### Does Portworx come as a hardware appliance?
No.  We are software-only, deployed as a container

### Can storage be added to a server and used after the server has joined the cluster?
Yes.  With 'pxctl service add /dev/xyz' additional storage gets dynamically incorporated into the the global capacity pool.

### What happens when a drive fails?
Portworx will enter maintenance mode.  In this mode, you can replace up to one failed drive.  If there are multiple drive failures, a node can be decommissioned from the cluster.  Once the node is decommissioned, the drives can be replaced and recommissioned into the cluster.

### Do servers in a cluster need to be all be configured exactly the same?
No.  Servers in a Portworx cluster can use block storage of any type, profile, capacity and performance class.
Devices of different performance classes (i.e flash or spinning drives) will be automatically detected and grouped accordingly.
Portworx also supports "head-only" mode, where a node participates in a cluster, but contributes no storage to the fabric.

### Are read operations parallelized?
Yes, if replication is > 1, then different blocks will be read from different servers.   We multi-source the read operations across nodes for high-performance.

### Can one server participate in multiple (different) PX clusters?
No.  Currently only one instance of PX per server is allowed.  

### Can Portworx work in a multi-cloud environment?
Yes absolutely you can create a fabric, based on servers across multiple different cloud providers.
However, we recommend that individual scale-out applications run within the context of a single cloud provider for the sake of performance and latency.    For a fabric that spans cloud providers, you can take a volume snapshot under one cloud, and then mount that snapshot in another cloud.

### Can I access my data outside of Portworx volume, or is it only for containers?
With "Shared Volumes", a Portworx volume can be NFS mounted (read/write) outside of a container context.
Among the possible use cases:
* Easily sharing results of containerized workloads with non-containerized apps/reports
* Providing a "data bridge" for moving from non-containerized workloads towards containerized workloads
Please see the documentation [here](/manage/shared-volumes.html), or view our [YouTube Demo](https://www.youtube.com/watch?v=AIVABlClYAU)

### How are snapshots implemented?    Thick clones or Thin copy-on-write?
Thin copy-on-write

### What's the largest cluster size that's been tested?  Supported?
We support 20 nodes for the 1.0 release of PX-Enterprise.  But this is only a QA/qualification limit.

### How quickly is node failure detected?
On the order of milliseconds. 

### Do you support Block?  File?  Object?
We provide "Container Volumes".   We support Block and File, out of the box (though block is never exposed directly).
We do not support Object native.   But minio provides an S3 Object interface that we've tested with (and works).

### Any way to segregate frontend/backend/management traffic?
Yes.  Management traffic (for configuration) and statistics traffic will travel over "mgtiface" .
Traffic associated with replication and resynchronization will travel over "dataiface".
Please see the [config-json file definition](/control/config-json.html).  
Regardless, all data requests between the container and the PX volume driver will be handled locally on that host.

## Did we miss your question? 
If so, please let us know here: <a class="email" title="Submit feedback" href="mailto:{{site.feedback_email}}?subject={{site.feedback_subject_line}} feedback&body=I have some feedback about the {{page.title}} page"><i class="fa fa-envelope-o"></i> Feedback</a>
