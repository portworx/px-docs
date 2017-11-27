---
layout: page
title: "Operations Guide to deploy Portworx in Production in Kubernetes Clusters"
keywords: operations guide, run book, disaster recovery, disaster proof, site failure, node failure, power failure
sidebar: home_sidebar
meta-description: "Portworx Operations Guide for Kubernetes Deployments"
---

* TOC
{:toc}

## DAY 1 Operations

### Initial Software Setup for Production

* Deployment - Follow all instructions to deploy Portworx correctly in the scheduler of choice - 
  Refer to the install instructions [page](https://docs.portworx.com/#install-with-a-container-orchestrator)
  
  * Ensure PX container is deployed as [OCI container](https://docs.portworx.com/runc/)
  * All nodes in the cluster should have achieved quorum and `pxctl status` should display the cluster as `operational`
  * etcd - Ensure etcd is properly configured and setup. Setup etcd as a 3-node etcd cluster outside the 
    container orchestrator to ensure maximum stability. Refer to the following 
    [page](https://docs.portworx.com/maintain/etcd.html) on how to install etcd and also configure it for maximum stability.

### Configuring the Server or the Compute Infrastructure

* Check and ensure minimum 4 cores and 4GB of RAM are allocated for Portworx. 
  The minimum configuration supports light workloads and is primary used for POCs
* For database workloads similar to MySQL or Postgres, Portworx reocmmends 8 Cores and 8GB of RAM
* The base operating system of the server supports linux kernel 3.10+

```
[centos@ip-172-31-51-89 ~]$ uname -r
3.10.0-327.22.2.el7.x86_64
```

* Ensure the shared mount propagation is enabled
  Refer to this [page](https://docs.portworx.com/knowledgebase/shared-mount-propogation.html#checking-whether-shared-mounts-are-enabled) for checking and enabling shared mount propogation is enabled. 

### Configuring the Networking Infrastructure

* Make sure the following ports are open in all the servers. 9001, 9002, 9003, 9010, 9012, 9014 

* Configure separate networks for Data and Management networks to isolate the traffic

  * Data and Management networks can be configured by giving this as a 
    parameter when the PX is started by through the PX-Spec that is applied to each minion to have PX run as a daemonset
    
  * Refer to this kubernetes spec for Portworx Daeemonset on how this can be configured. [spec](px-spec.yaml)
  
  The mgmt and data interface must be given as follows:
  
   ```
   args:
     ["-k", "etcd:http://etc.fake.net:2379", "-c", "test_cluster", "-d", "eth0", "-m", "eth1", "-a", "-f",
     "-x", "kubernetes"]
   ```
  Note in the case above, data traffic will be routed through `eth0` and management traffic is routed through `eth1`
  
  * it is recommended to create a bonded ethernet port for each data and management interface for improved availability and performance.
  
### Configuring and Provisioning Underlying Storage

* Disks - If this is a on-prem installation, ensure there is enough storage available per node for PX storage pools.
  If it is a cloud deployment, ensure you have enough cloud disks attached. 
  
  * For AWS ASG, Portworx supports automatic management of EBS volumes. 
    It is recommended to use the ASG [feature](https://docs.portworx.com/cloud/aws/asg.html)

* HW RAID - If there are a large number of drives in a server and drive failure tolerance is required per server, 
  enable HW RAID (if available) and give the block device from a HW RAID volume for Portworx to manage. 

* PX can classify drive media into different performance levels and offer them as pools for volume 
  configuration and application storage. These levels are called `io_priority` and they are off the levels 
  `high`, `medium` and `low`
  
* The `io_priority` of a pool is determined automatically by PX. If the intention is to run low latency transactional workloads like databases on PX, then Portworx recommends having NVMe or other SAS/SATA SSDs in the system

* This [page](https://docs.portworx.com/manage/class-of-service.html) offers more information on different io_prioirty levels.


### Volume Management Best Practices

* Volumes - Portworx volumes are thinly provisioned by default. Make sure to monitor for capacity threshold alerts. 
  Monitor for for Volume Space Low alerts
  
  ```
  30|VolumeSpaceLow|ALARM|VOLUME|Triggered when the free space available in a volume goes below a threshold.
  ```

* For applications needing node level availability and read parallelism across nodes, it is recommended to set the 
  volumes with replication factor 2 or replication factor 3
  
  Here is how one can configure a volume with replication factor 3 for e.g.,
  
  ```
  sudo /opt/pwx/bin/pxctl volume create dbasevol --size=1 --repl=3 --iopriority=high
  ```
  
* For cloud environments like AWS, PX can auto-detect different availabilty zones and thus can provision replicas across 
  different zones. For e.g., see below for the output of `pxctl status`
  
 
 This node is in us-east-1. If PX is started in other zones, then when a volume with greater than 1 replication factor 
 is created, it will have the replicas automatically created in other nodes in other zones.

* For on-prem installs, Portworx recommends deploying the replicas for a given values across racks. This can be achieved 
  by passing the rack parameter via the environment variable. 
  This [link](https://docs.portworx.com/manage/update-px-rack.html) gives more information.
 
 
* If the volumes need to be protected against accidental deletes because of background garbage collecting scripts, 
  then the volumes need to enabled with `--sticky` flag
  
  ```
   sudo /opt/pwx/bin/pxctl volume create dbasevol --size=1 --repl=3 --iopriority=high --sticky
  ```
  
* The `--sticky` flag can be turned on and off using the `pxctl volume update` commands
 
  ```
  sudo /opt/pwx/bin/pxctl volume update dbasevol --sticky=off
  ```

* For applications that require shared access from multiple containers running in different hosts, 
  Portworx recommends running  shared volumes. Shared volumes can be configured as follows:

  ```
  pxctl volume create wordpressvol --shared --size=100 --repl=3
  ```
  
  This [page](https://docs.portworx.com/manage/volumes.html) gives more details on different volume types, 
  how to create them and update the configuration for the volumes 

### Data Protection for Containers

* Snapshots - Follow DR best practices and ensure volume snapshots are scheduled for instantaneous recovery in the 
  case of app failures. Visit the [DR best practices](dr-best-practices.html) page for more information. 
  Here is more information on how to setup [snapshots](https://docs.portworx.com/manage/snapshots.html) in PX-Enterprise.

* Cloudsnaps - Follow [DR best practices](dr-best-practices.html) and setup a periodic cloudsnaps so in case of a disaster,
  Portworx volumes can be restored from an offsite backup

### Alerts and Monitoring for Production

Portworx recommends setting up monitoring with Prometheus and AlertsManager to ensure monitoring of the data services infrastructure for your containers

While Prometheus can be deployed as a container within the container orchestrator, many of Portworx's production customers deploy Prometheus in a separate cluster that is dedicated for managing and monitoring their large scale container orchestrator infrastructure.

  * Here is how Prometheus can be setup to monitor Portworx [Prometheus] (monitoring/prometheus/index.html)
  * Configure Grafana via this [template](monitoring/grafana/index.html)
  * Here is how Alerts Manager can be configured for looking for alerts with [Alerts Manager](monitoring/alerting.html)
  * List of Portworx Alerts are documented [here](monitoring/portworx-alerts.html)

## Day 2 Operations

### Hung Node Recovery

### Volume Cleanup Steps (a.k.a Stuck Volume Recovery)

### Scaling out a cluster nodes in the Cloud and On-Prem

### Cluster Capacity Expansion

### Server Replacements and Upgrades

### Networking Upgrades and Replacements

### Software Upgrades

#### Portworx Software Upgrades - Work with Portworx Support before planning major upgrades. Ensure all volumes have the 
  latest snapshot and cloudsnap before performing upgrades

#### Container Orchestrator Upgrades - Ensure all volumes are cloud-snapped before performing scheduler upgrades

#### OS upgrades - Ensure all volumes have a snapshot before performing underlying OS upgrades. 
  Ensure kernel-devel packages are installed after a OS migration
  
#### Docker Upgrades


## Day 3 Operations

### Handling Lost or Stale Nodes on the Cloud and On-Prem

### Volume Data Recovery

### Disaster Recovery with Cloudsnaps

### Drive Replacements

