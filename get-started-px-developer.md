# Get Started with PX-Developer

## Step 1: Verify requirements

* Linux kernel 3.10 or greater
* Docker 1.10 or greater, configured with [devicemapper](https://docs.docker.com/engine/userguide/storagedriver/device-mapper-driver/#/configure-docker-with-devicemapper)
* An etcd 2.0 key/value store (Consul coming soon)
* Minimum resources per server:
  * 4 CPU cores
  * 4 GB RAM
*Recommended resources per server:
  * 12 CPU cores
  * 16 GB RAM
  * 128 GB Storage
  * 10Gb

## Step 2: Install and run PX-Developer

See our quick start guides on:



* [Launching PX-Dev with Docker Compose](README.md)
* [Running PX-Dev with Kubernetes](install_with_k8s.md)
* [Running PX-Dev on Ubuntu](install_run_ubuntu), [CentOS](install_run_rhel), and [CoreOS](install_run_coreos)

Run stateful containers with Docker volumes:

* [Scaling a Cassandra database with PX-Dev](cassandra.md)
* [Running the Docker registry with high availability](./blob/master/px-dev/examples/registry.md)
* [Running PostgreSQL from CrunchyData on PX volumes]()

Use our [pxctl CLI](./cli_reference.md) to directly:

* View the cluster global capacity and health
* Create, inspect, and delete storage volumes
* Attach policies for IOPs prioritization, maximum volume size, and enable storage replication

Refer to the [Technical FAQ and Troubleshooting guide](../blob/master/px-dev/faq.md) if you run into an issue.

As you use PX-Dev, please share your feedback and ask questions. Find the team on [Google Groups](https://groups.google.com/forum/#!forum/portworx).

If your requirements extend beyond the scope of PX-Developer, then please [contact Portworx](http://portworx.com/contact-us/) for information on PX-Enterprise.
