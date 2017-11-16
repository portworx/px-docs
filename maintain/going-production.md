
---
layout: page
title: "Production Readiness Check-List"
keywords: production, ops guide, deployment, rollout
sidebar: home_sidebar
meta-description: "Production Readiness Checklist"
---

* etcd - Ensure etcd is properly configured and setup. Setup etcd as a 3-node etcd cluster outside the container orchestrator to ensure maximum stability

* Disks - If this is a on-prem installation, ensure there is enough storage available per node for PX storage pools. If it is a cloud deployment, ensure you have enough cloud disks attached. For AWS ASG, Portworx supports automatic management of EBS volumes. It is recommended to use that feature

* Volumes - Ensures volumes are thinly provisioned and make sure to monitor for capacity threshold alerts. Refer to the alerts page for more information

* Network - Use different networks for data and management better 
* snapshots - Follow DR best practices and ensure volume snapshots are scheduled for instantaneous recovery in the case of app failures

* Cloudsnaps - Follow DR best practices and setup a periodic cloudsnaps so in case of a disaster, Portworx volumes can be restored from a offsite backup

* Monitoring and Alerts - Ensure Monitoring and Alerts are setup for Portworx. Follow the link to setup Monitoring and Alerts with Prometheus

* Software Upgrades - Work with Portworx Support before planning major upgrades. Ensure all volumes have the latest snapshot and cloudsnap before performing upgrades

* Scheduler upgrades - Ensure all volumes are cloud-snapped before performing scheduler upgrades

* OS upgrades - Ensure all volumes have a snapshot before performing underlying OS upgrades. Ensure kernel-devel packages are installed after a OS migration

* 
