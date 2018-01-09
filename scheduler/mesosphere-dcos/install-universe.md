---
layout: page
title: "Install the Portworx Universe on DCOS for air-gapped clusters"
keywords: portworx, container, Mesos, Mesosphere, storage, dcos, universe
redirect_from: "/scheduler/mesosphere-dcos/install_universe.html"
---

* TOC
{:toc}

This guide will help you install the Portworx Universe for DCOS which contains the Portworx service as well as other services
inlcuding Hadoop, Cassandra, Elastic Search and Kafka which can utilize Portworx Volumes.

This guide is based on the DCOS guide to install a local universe: https://docs.mesosphere.com/1.8/administration/installing/deploying-a-local-dcos-universe/

### Download the pre-requisites
First you will need to download 3 files and transfer them to each of you DCOS Master nodes
* [dcos-local-px-universe-http.service](https://raw.githubusercontent.com/portworx/universe/version-3.x-px/docker/local-universe/dcos-local-px-universe-http.service)
* [dcos-local-px-universe-registry.service](https://raw.githubusercontent.com/portworx/universe/version-3.x-px/docker/local-universe/dcos-local-px-universe-registry.service)
* [local-universe.tar.gz](https://px-dcos.s3.amazonaws.com/local-universe_1.10_01082017.tar.gz)

### Install the services
On each of your Master nodes run the following steps

* Load the universe container into docker
```
docker load < local-universe.tar.gz
```
This will take a few minutes.

* Copy the service files to /etc/systemd/system and start the services
```
sudo mv dcos-local-px-universe-registry.service /etc/systemd/system/
sudo mv dcos-local-px-universe-http.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable dcos-local-px-universe-http
sudo systemctl enable dcos-local-px-universe-registry
sudo systemctl start dcos-local-px-universe-http     
sudo systemctl start dcos-local-px-universe-registry
```

* Confirm that the services are up
```
sudo systemctl status dcos-local-px-universe-http
sudo systemctl status dcos-local-px-universe-registry
```

### Add the PX Universe to DCOS

Run the dcos command to add the newly deployed universe to your DCOS cluster

```
dcos package repo add local-universe http://master.mesos:8083/repo --index=0
```

### Add the docker registry as a trusted store on each agent

On each agent node you will need to download the certificate from the newly deployed Docker regitry to set is as trusted.
To do this, run the following command on each agent node, including public agents.

For CoreOS:
```
sudo mkdir -p /etc/docker/certs.d/master.mesos:5001
sudo curl -o /etc/docker/certs.d/master.mesos:5001/ca.crt http://master.mesos:8083/certs/domain.crt
sudo systemctl restart docker
sudo curl -o /etc/ssl/certs/master.registry.pem http://master.mesos:8083/certs/domain.crt
sudo update-ca-certificates
echo CURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt | sudo tee -a /opt/mesosphere/etc/mesos-slave-common
sudo systemctl restart dcos-mesos-slave.service
```

For CentOS and RHEL:
```
sudo mkdir -p /etc/docker/certs.d/master.mesos:5001
sudo curl -o /etc/docker/certs.d/master.mesos:5001/ca.crt http://master.mesos:8083/certs/domain.crt
sudo systemctl restart docker
sudo curl -o /etc/pki/ca-trust/source/anchors/master.registry.pem http://master.mesos:8083/certs/domain.crt
sudo update-ca-trust
echo CURL_CA_BUNDLE=/etc/pki/ca-trust/extracted/openssl/ca-bundle.trust.crt | sudo tee -a /opt/mesosphere/etc/mesos-slave-common
sudo systemctl restart dcos-mesos-slave.service
```

### Verify local Universe available from DCOS

To verify that the local Unviverse has been configured succsfully, log in to the DCOS UI and look at Universe->Packages to
see if the packages are available.

### Using docker images from local registry

If you want to use any images from the newly deployed registry, you will need to update the image names when starting the
services. For example, to use the Portworx docker images, you would use "master.mesos:5001/portworx/px-enterprise:tag"
