---
layout: page
title: "Deploy Portworx stack on Docker Swarm or UCP"
keywords: portworx, architecture, storage, container, cluster, install, docker, compose
sidebar: home_sidebar
---

* TOC
{:toc}

Deploy Portworx stack on Docker Swarm or UCP

## Install

If you are using [Docker UCP](https://docs.docker.com/datacenter/ucp/2.1/guides/) or [Docker in Swarm mode](https://docs.docker.com/engine/swarm/), you can deploy Portworx as a stack.
```
$ curl -o pxservice.yaml "http://portworx.us-west-2.elasticbeanstalk.com/swarm?cluster=mycluster&kvdb=etcd://etc.company.net:4001"
$ docker stack deploy -c pxservice.yaml portworx
```
>**Note:**<br/>A Docker Engine of version 1.13.0 or later is required  using docker stack deploy

Above command first fetches the service specification from a web service and then gives it to `docker stack deploy` command. Make sure you change the custom parameters (_cluster_ and _kvdb_) to match your environment.
Portwork will get deployed as a global service on each of the nodes in the Swarm cluster. You can check status of portworx stack using
```
$ docker stack ps portworx
```

Below are all parameters that can be given in the query string of the curl command.

| Key         	| Description                                                                                                                                                                              	| Example                                           	|
|-------------	|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	|---------------------------------------------------	|
| cluster     	| (Required) Specifies the cluster ID that this PX instance is to join.,You can create any unique name for a cluster ID.                                                                   	| cluster=test_cluster                              	|
| kvdb        	| (Required) Points to your key value database, such as an etcd cluster or a consul cluster.                                                                                               	| kvdb=etcd://etcd.fake.net:4001                    	|
| drives      	| (Optional) Specify comma-separated list of drives.                                                                                                                                       	| drives=/dev/sdb,/dev/sdc                          	|
| diface      	| (Optional) Specifies the data interface. This is useful if your instances have non-standard network interfaces.                                                                          	| diface=eth1                                       	|
| miface      	| (Optional) Specifies the management interface. This is useful if your instances have non-standard network interfaces.                                                                    	| miface=eth1                                       	|
| zeroStorage 	| (Optional) Instructs PX to run in zero storage mode.,In this mode, PX can still provide virtual storage to your containers, but the data will come over the network from other PX nodes. 	| zeroStorage=true                                  	|
| force       	| (Optional) Instructs PX to use any available, unused and unmounted drives or partitions.,PX will never use a drive or partition that is mounted.                                         	| force=true                                        	|
| etcdPasswd  	| (Optional) Username and password for ETCD authentication in the form user:password                                                                                                       	| etcdPasswd=username:password                      	|
| etcdCa      	| (Optional) Location of CA file for ETCD authentication.                                                                                                                                  	| etcdCa=/path/to/server.ca                         	|
| etcdCert    	| (Optional) Location of certificate for ETCD authentication.                                                                                                                              	| etcdCert=/path/to/server.crt                      	|
| etcdKey     	| (Optional) Location of certificate key for ETCD authentication.                                                                                                                          	| etcdKey=/path/to/server.key                       	|
| acltoken    	| (Optional) ACL token value used for Consul authentication.                                                                                                                               	| acltoken=398073a8-5091-4d9c-871a-bbbeb030d1f6     	|
| token       	| (Optional) Portworx lighthouse token for cluster.                                                                                                                                        	| token=a980f3a8-5091-4d9c-871a-cbbeb030d1e6        	|
| env         	| (Optional) Comma-separated list of environment variables that will be exported to portworx.                                                                                              	| env=API_SERVER=http://lighthouse-new.portworx.com 	|

#### Examples
```
# To specify drives
$ curl -o pxservice.yaml "http://portworx.us-west-2.elasticbeanstalk.com/swarm?cluster=mycluster&kvdb=etcd://etcd.fake.net:4001&drives=/dev/sdb,/dev/sdc"
$ docker stack deploy -c pxservice.yaml portworx

# To specify data and management interfaces
$ curl -o pxservice.yaml "http://portworx.us-west-2.elasticbeanstalk.com/swarm?cluster=mycluster&kvdb=etcd://etcd.fake.net:4001&diface=enp0s8&miface=enp0s8"
$ docker stack deploy -c pxservice.yaml portworx

# To run in zero storage mode
$ curl -o pxservice.yaml "http://portworx.us-west-2.elasticbeanstalk.com/swarm?cluster=mycluster&kvdb=etcd://etcd.fake.net:4001&zeroStorage=true"
$ docker stack deploy -c pxservice.yaml portworx
```

## Upgrade
To upgrade Portworx, use the same `docker stack deploy` command used to install it. This will repull the image used for Portworx (portworx/px-enterprise:latest) and perform a rolling upgrade.

You can check the upgrade status with following command.
```
$ docker stack ps portworx
```

## Uninstall
Following command uninstalls Portworx from the cluster.

```
$ docker stack rm portworx
```
>**Note:**<br/>During uninstall, the configuration files (/etc/pwx/config.json and /etc/pwx/.private.json) are not deleted. If you delete /etc/pwx/.private.json, Portworx will lose access to data volumes.