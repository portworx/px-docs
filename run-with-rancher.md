---
layout: page
title: "Run Portworx with Rancher"
keywords: portworx, PX-Developer, container, Rancher, storage
sidebar: home_sidebar
---
You can use PX-Developer to implement storage for Rancher. Portworx pools your servers' capacity and is deployed as a container. This section, qualified using Rancher v1.1.2, Cattle v0.165.8, describes how to use Portworx within Rancher.

## Step 1: Install Rancher

Follow the instructions for installing [Rancher](http://docs.rancher.com/rancher/latest/en/quick-start-guide/).

## Step 2: Label hosts that run Portworx

If new hosts are added through the GUI, be sure to create a label with the following key-value pair: `fabric : px`

As directed, copy from the clipboard and paste on to the new host. The form for the command follows. Use IP addresses that are appropriate for your environment.

```
sudo docker run -e CATTLE_AGENT_IP="192.168.33.12"  -e CATTLE_HOST_LABELS='fabric=px'  -d --privileged \

           -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/rancher:/var/lib/rancher           \

            rancher/agent:v1.0.2 http://192.168.33.10:8080/v1/scripts/98DD3D1ADD1F0CE368B5:1470250800000:IVpsBQEDjYGHDEULOfGjt9qgA

```

* Notice the `CATTLE_HOST_LABELS`, which indicates that this node participates in a Portworx fabric.

## Step 3: Launch jobs, specifying host affinity

When launching new jobs, be sure to include a label, indicating the job's affinity for running on a host with "fabric=px".

The `label` clause should look like the following:

```
labels:
    io.rancher.scheduler.affinity:host_label: fabric=px
```

Following is an example for starting Elasticsearch. The "docker-compose.yml" file is:

```yaml
elasticsearch:
  image: elasticsearch:latest
  command: elasticsearch -Des.network.host=0.0.0.0
  ports:
    - "9200:9200"
    - "9300:9300"
  volume_driver: pxd
  volumes:
    - elasticsearch1:/usr/share/elasticsearch/data
  labels:
      io.rancher.scheduler.affinity:host_label: fabric=px
```

* Notice the `pxd` volume driver as well as the volume itself (`elasticsearch1`).
*The referenced volume can be a volume name, a volume ID, or a snapshot ID.  

>**Note:**<br/>At this time, Rancher supports docker-compose v1 syntax, but not v2 syntax.
