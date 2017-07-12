---
layout: page
title: "Install the Portworx Universe on DCOS for air-gapped clsuters"
keywords: portworx, PX-Developer, container, Mesos, Mesosphere, storage, dcos, universe
---

* TOC
{:toc}

This guide will help you install the Portworx Universe for DCOS which contains the Portworx service as well as other services
inlcuding Hadoop, Cassandra, Elastic Search and Kafka which can utilize Portworx Volumes.

This guide is based on the DCOS guide to install a local universe: https://docs.mesosphere.com/1.8/administration/installing/deploying-a-local-dcos-universe/

## Download the pre-requisites
First you will need to download 3 files and transfer them to each of you DCOS Master nodes
* [dcos-local-px-universe-http.service](https://raw.githubusercontent.com/portworx/universe/version-3.x-px/docker/local-universe/dcos-local-px-universe-http.service)
* [dcos-local-px-universe-registry.service](https://raw.githubusercontent.com/portworx/universe/version-3.x-px/docker/local-universe/dcos-local-px-universe-registry.service)
* [local-universe.tar.gz](https://px-dcos.s3.amazonaws.com/local-universe.tar.gz)

## Install the services
On each of your Master nodes run the following steps

* Load the universe container into docker
```
$ docker load < local-universe.tar.gz
```

This will take a few minutes.

* Copy the service files to /etc/systemd/system and start the services
```
$ sudo mv dcos-local-px-universe-registry.service /etc/systemd/system/
$ sudo mv dcos-local-px-universe-http.service /etc/systemd/system/
$ systemctl enable dcos-local-px-universe-http
$ systemctl enable dcos-local-px-universe-registry
$ sudo systemctl start dcos-local-px-universe-http     
$ sudo systemctl start dcos-local-px-universe-registry
```

* Confirm that the services are up
```
$ sudo systemctl status dcos-local-px-universe-http
$ sudo systemctl status dcos-local-px-universe-registry
```

## Add the PX Universe to DCOS

Run the dcos command to add the newly deployed universe to your DCOS cluster

```
$ dcos package repo add local-universe http://master.mesos:8082/repo
```

## Add the docker registry as a trusted store on each agent

On each agent node you will need to download the certificate from the newly deployed Docker regitry to set is as trusted.
To do this, run the following command on each agent node, including public agents.

```
$ sudo mkdir -p /etc/docker/certs.d/master.mesos:5000
$ sudo curl -o /etc/docker/certs.d/master.mesos:5000/ca.crt http://master.mesos:8082/certs/domain.crt
$ sudo systemctl restart docker
```

## Verify local Universe available from DCOS

To verify that the local Unviverse has been configured succsfully, log in to the DCOS UI and look at Universe->Packages to
see if the packages are available.
