---
layout: page
title: "Run Portworx with Rancher"
keywords: portworx, PX-Developer, container, Rancher, storage
sidebar: home_sidebar
youtubeId: yGjDxDLyS78
redirect_from:
  - /run-with-rancher.html
  - /scheduler/rancher.html
  - /deploy_px_with_rancher.html
---

* TOC
{:toc}

You can use PX-Developer to implement storage for Rancher. Portworx pools your servers' capacity and is deployed as a container. This section, qualified using Rancher v1.5.5, Cattle v0.178.3, describes how to use Portworx within Rancher.

{%
    include youtubePlayer.html
    id = "yGjDxDLyS78"
    title = "Running Portworx with Rancher"
    description = "Here is a short video that shows how to configure and run Portworx with Rancher"
%}


## Step 1: Install Rancher

Follow the instructions for installing [Rancher](http://docs.rancher.com/rancher/latest/en/quick-start-guide/).

## Step 2: Create/Configure PX-Ready Rancher Hosts

>**Note** : Portworx requires that Rancher hosts have at least one non-root disk or partition to contribute.

For trial/demo purposes, Portworx has created "PX-ready" AMI images in AWS:
* If deploying on AWS in US-East-2, then use this AMI : ami-c64a6da3
* If deploying on AWS in US-West-2, then use this AMI : ami-767fe016

If not deploying in AWS, the customers must ensure that each host has at least one non-root disk or partition.

For the the AWS security group (SG), make sure the standard Rancher ports are open as per 
[Rancher requirements](https://docs.rancher.com/rancher/v1.2/en/hosts/amazon/).
In addition, the following inbound TCP ports should be opened in the SG:  2379, 2380, 9001 - 9005, 
or for simplicity you could open up all TCP ports for the given SG.    

In general, Portworx will require ports 2379, 2380, 9001-9005 to be open for inbound traffic.

When configuring the Rancher hosts using the provided AMI:
* The number of instances should be min(3)
* The type of instance should be min(t2.medium)   
* The root size should be min(128)    
* The 'ssh' user should be "ubuntu"

## Step 3: Launch an 'etcd' stack

Launch an instance of the 'etcd' stack.
Set "Enable Backups" and "Debug" to False.
Look through the logs to note the published client URL, and make note of that. 
The client URL will have the following form:
```
etcdserver: published {Name:10-42-207-178 ClientURLs:[http://10.42.207.178:2379]} ...
```

## Step 4: Launch Portworx

From the Library Catalog, select the Portworx volume plugin driver.  Configure with the following parameters:
* Volume Driver Name: pxd
* Cluster ID: user-defined/arbitrary
* Key-Value Database: of the form:  "etcd://10.42.207.178:2379", where the URL come from the above etcdserver
* Use Disks: -s /dev/xvdb, for the referenced AMI images; otherwise see storage options from [here](/install/docker.html#run-px)
* Headers Directory : /usr/src, for the referenced AMI images; /lib/modules if using with CoreOS


## Step 5: Launch jobs with docker-compose / rancher-compose

Here are some sample compose scripts that bring up wordpress stacks, referencing Portworx volumes:

**docker-compose.yml:**
```

version: '2'
volumes:
  anchsand-db:
    driver_opts:
      repl: '3'
      size: '5'
    driver: pxd
  anchsand-data:
    driver_opts:
      repl: '3'
      size: '5'
    driver: pxd
services:
  wordpress:
    image: wordpress
    volumes:
    - anchsand-data:/var/www/html
    links:
    - db:mysql
    labels:
      io.rancher.container.pull_image: always
  lb:
    image: wordpress
    ports:
    - 8026:8026/tcp
    labels:
      io.rancher.container.agent.role: environmentAdmin
      io.rancher.container.create_agent: 'true'
      io.rancher.scheduler.global: 'true'
  db:
    image: mariadb
    environment:
      MYSQL_ROOT_PASSWORD: example
    volumes:
    - anchsand-db:/var/lib/mysql
```

**rancher-compose.yml**
```
version: '2'
services:
  wordpress:
    scale: 2
    start_on_create: true
    health_check:
      healthy_threshold: 2
      response_timeout: 2000
      port: 80
      unhealthy_threshold: 3
      initializing_timeout: 60000
      interval: 2000
      strategy: recreate
      reinitializing_timeout: 60000
  lb:
    start_on_create: true
    lb_config:
      certs: []
      config: |-
        timeout client 2400000
        timeout server 2400000
      port_rules:
      - priority: 1
        protocol: http
        service: wordpress
        source_port: 8026
        target_port: 80
    health_check:
      healthy_threshold: 2
      response_timeout: 2000
      port: 42
      unhealthy_threshold: 3
      initializing_timeout: 60000
      interval: 2000
      strategy: recreate
      reinitializing_timeout: 60000
  db:
    scale: 1
    start_on_create: true
    health_check:
      healthy_threshold: 2
      response_timeout: 2000
      port: 3306
 ```
 
      
## `WARNING:`

Please stop running below mentioned containers in the rancher env, Unless you are sure about those functionalities. Because it caused more trouble in the environment and portworx volumes. 

1. Janitor - Unless you are sure about match [patterns]9https://github.com/rancher/community-catalog/tree/master/templates/janitor) for Janitor container, Please don't run this in Rancher env. Because by default it will delete any unused image, and any orphaned volume. It will also remove any stopped containers that are taking up space; note that this may not be what you want if you are using stopped containers to hold volumes. If you are using 'run-once' sidekick containers that mount a volume, then these containers may be removed by Janitor.

2. cAdvisor (container advisor) is an open-source project. It is implemented as a daemon process that collects, aggregates, processes, and exports information about running containers. also, it provides users with resource usage information about running containers. This process holds the portworx volumes and causes the trouble. 