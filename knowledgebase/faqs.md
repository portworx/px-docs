---
layout: page
title: "Frequently Asked Questions Portworx"
keywords: portworx, faqs
sidebar: home_sidebar
redirect_from:
  - /px-faqs.html
  - /knowledgebase/troubleshooting.html
  - /troubleshooting.html
meta-description: "Find answers to all the most frequently asked questions about Portworx.  Explore our FAQ today!"
---

* TOC
{:toc}

### Can Portworx run in the cloud?   On premise?   Both?
Portworx clusters can run in the cloud or on premise.  The volume format is the same, regardless of running in the cloud or on-prem.  When running in the cloud, Portworx aggregates and virtualizes the various underlying cloud volumes.

### Is there a Hardware/Software compatibility list?
Hardware : No. But there are minimum resource recommendation listed [here](/#minimum-requirements) 

Software:   Linux kernel 3.10 and above;     Docker 1.11 and above.

### Can Portworx work with any drive vendor?
Yes.  Portworx can recognize any drive and its type, capacity and IOPS capability and use it appropriately for the given workload.

### Should I use a H/W RAID controller, or should I present all the drives to Portworx individually?
Portworx prefers a H/W RAID controller, if available.

###  Device names are not guaranteed to be consistent. Drive lettters can change, as is the case if using Openstack.  Is there a way for Portworx to use UUID instead of device names?

PX automatically uses UUID after the drive has been specified.  You don't need to worry about drive letters changing.

### Does Portworx need to take over all the disks on a given server?
No. PX does not have to take over all the disks on a given servers. The devices that PX can be selected by giving the drive path with -s option when bringing up PX. Check your relevant scheduler install instructions to pass the drive parameter

### Can Portworx work with iSCSI or FC and make use of existing legacy storage (EMC, NetApp, Nexenta, etc.)?
Yes. Any block storage presented to a host can be used with a Portworx cluster. Portworx can virtualize any standard block device exported other vendors' storage arrays or software products like CEPH, GlusterFS etc and make them much more reliable and enable cloud-native applications to run onthem.

### Does Portworx come as a hardware appliance?
No.  Portworx software-only, deployed as a OCI container

### What are different container orchestrators support my Portworx?

Portworx supports all major container orchestrators and platforms like Kubernetes, Mesos, Swarm, Openshift, Tectonic, DC/OS, Docker UCP, Nomad and others. 

### Can storage be added to a server and used after the server has joined the cluster?
Yes.  Drives can be added easily to a server after the server has joined the cluster. Follow this [link](https://docs.portworx.com/maintain/scale-up.html) to learn more about

### What happens when a drive fails?
On a drive failure, Portworx will enter a storageless operation mode and continue to give access to replicas in the other nodes, if the volumes are configured to have replication factor more than one. PX needs to be put into maintenance mode in order to service (remove and replace) the drive. Follow this [link](https://docs.portworx.com/maintain/maintenance-mode.html) to learn more about maintenance mode operations. 

### Do servers in a cluster need to be all be configured exactly the same?
No.  Servers in a Portworx cluster can use block storage of any type, profile, capacity and performance class.
Devices of different performance classes (i.e flash or spinning drives) will be automatically detected and grouped accordingly.
Portworx also supports storageless mode, where a node participates in a cluster, but contributes no storage to the fabric.

### Are read operations parallelized?
Yes, if replication is > 1, then different blocks will be read from different servers.   We multi-source the read operations across nodes for high-performance.

### Can one server participate in multiple (different) PX clusters?
No.  Currently only one instance of PX per server is allowed.  

### Can Portworx work in a multi-cloud environment?
Yes absolutely you can create a fabric, based on servers across multiple different cloud providers.
However, we recommend that individual scale-out applications run within the context of a single cloud provider for the sake of performance and latency.    For a fabric that spans cloud providers, you can take a cloudsnap under one cloud, and then import and mount that snapshot in another cloud. Refer to [Multi-Cloud Backup operations](https://docs.portworx.com/cloud/backups.html) on how to create Cloudsnaps and import them to any cluster you want

### Can I access my data outside of Portworx volume, or is it only for containers?
With "Shared Volumes", a Portworx volume can be NFS mounted (read/write) outside of a container context.
Among the possible use cases:
* Easily sharing results of containerized workloads with non-containerized apps/reports
* Providing a "data bridge" for moving from non-containerized workloads towards containerized workloads
Please see the documentation [here](/manage/shared-volumes.html), or view our [YouTube Demo](https://www.youtube.com/watch?v=AIVABlClYAU)

### How are snapshots implemented?    Thick clones or Thin clones?
Portworx snapshots are redirect-on-write snapshots and are thin clones. 

### What's the largest cluster size that's been tested?  Supported?
Portworx PX-Enterprise supports 1000 nodes in the same cluster.  But this is only a QA/qualification limit.

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

### Does Portworx support volume encryption? 
Yes, Portworx PX-Enterprise supports data encryption-at-rest and also encryption-in-fligt as data is replicated between multiple PX nodes within a data center or across data centers or clouds. PX-Enterprise supports encrypted volumes and integration with key management software like Vault, AWS KMS, Kubernetes Secrets etc

### How can safely backup and restore my data with Portworx?
Portworx PX-Enterprise supports cloudsnaps which enable the DevOps engineers to periodically back the data volumes in incremental snaps and restore the volume anywhere they want. 

## Did we miss your question? 
If so, please let us know here: <a class="email" title="Submit feedback" href="mailto:{{site.feedback_email}}?subject={{site.feedback_subject_line}} feedback&body=I have some feedback about the {{page.title}} page"><i class="fa fa-envelope-o"></i> Feedback</a>
