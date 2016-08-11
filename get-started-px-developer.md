---
layout: page
title: "Portworx Documentation"
category: get_started_px_developer
---
# Get Started with PX-Developer

## Step 1: Verify requirements

* Linux kernel 3.10 or greater
* Docker 1.10 or greater, configured with [devicemapper](https://docs.docker.com/engine/userguide/storagedriver/device-mapper-driver/#/configure-docker-with-devicemapper)
* An etcd 2.0 key/value store (Consul coming soon)
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

## Step 2: Install and run PX-Developer

See our quick start guides:

* [Docker Compose Quick Start Installation for PX-Developer](install_with_compose.html)
* [Run PX-Developer on Ubuntu](install_run_ubuntu.html), [CentOS](install_run_rhel.html), and [CoreOS](install_run_coreos.html)

Run Portworx with schedulers:

* Docker Swarm
* [Run Portworx with Kubernetes](install_with_k8s.html)
* [Run Portworx with Mesosphere](install_with_mesosphere.html)
* [Run Portworx with Rancher](run_with_rancher.html)

Run stateful containers with Docker volumes:

* [Scaling a Cassandra database with PX-Dev](examples/cassandra.html)
* [Running the Docker registry with high availability](examples/registry.html)
* [Running PostgreSQL from CrunchyData on PX volumes]()

Use our [pxctl CLI](cli_reference.html) to directly:

* View the cluster global capacity and health
* Create, inspect, and delete storage volumes
* Attach policies for IOPs prioritization, maximum volume size, and enable storage replication

Refer to [Technical FAQ and Troubleshooting](faq.html) if you run into an issue.

As you use PX-Developer, please share your feedback and ask questions. Find the team on [Google Groups](https://groups.google.com/forum/#!forum/portworx).

If your requirements extend beyond the scope of PX-Developer, please [contact Portworx](http://portworx.com/contact-us/) for information on PX-Enterprise. You can take a tour of the PX-Enterprise console [here](get-started-px-enterprise.html#step-3-take-a-tour-of-the-px-enterprise-web-console).
