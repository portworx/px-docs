---
layout: page
title: "cloud-config reference"
keywords: portworx, cloud-config, yaml, config.json, reference
sidebar: home_sidebar
---

This is the schema definition for a valid yaml file. For AWS, this file is passed in through user-data. 

```
portworx:
  config:
    clusterid: "unique_cluster_id"
    mgtiface: "enp5s0f0"
    dataiface: "enp5s0f1"
    kvdb:
    - etcd:http://etcd0.yourdomain.com:4001
    - etcd:http://etcd1.yourdomain.com:4001
    loggingurl: ""
    alertingurl: ""
    storage:
      devices:
      - vol-0743df7bf5657dad8
      - vol-0055e5913b79fb49d
```

# Definitions

**clusterid**:   Globally unique cluster ID.  Ex: ""07ea5dc0-4e9a-11e6-b2fd-0242ac110003"".   Must be either assigned by PX-Enterprise or guaranteed to be unique

**mgtiface**:   Host ethernet interface used for Management traffic connecting to the 'loggingurl' endpoint.  Primarily used for statistics, configuration and control-path.   Ex: "enp5s0f0"

**dataiface**:  Host ethernet interface used for backend activity, such as replication and resync.  Ex: "enp5s0f1"

**loggingurl**: Endpoint used communicating to PX-Enterpise control (aka "Lighthouse").  Primary use is system statistics.   Ex:  "http://lighthouse.portworx.com/api/stats/listen"

**kvdb**:  Array of endpoints used for the key-value database.  Must be reachable and refer to 'etcd' or 'consul'.   

```
 Ex:  
    kvdb: 
    - etcd:http://etcd0.yourdomain.com:4001
    - etcd:http://etcd1.yourdomain.com:4001
```

For 'consul', an example would be:

```
Ex:
    kvdb:
        consul:http://consul.yourdomain.com:8500
```

**storage**:   Array of devices to be used as part of the PX Storage Fabric. This can be either volume-ids for cloud providers or path to attached devices. 

```
Ex:
    storage:
      devices:
      - vol-0743df7bf5657dad8
      - vol-0055e5913b79fb49d
```

Or for attached devices:

```
Ex:
    storage:
      devices:
      - /dev/xvdg
      - /dev/xvdh
```

