---
layout: page
title: "config.json reference"
keywords: portworx, config.json, reference
sidebar: home_sidebar
redirect_from: "/config-json.html"
---

* TOC
{:toc}

This is the schema definition for a valid PX configuration file.  This file is expected to be available at `/etc/pwx/config.json`

```
{
  "description": "Validate PWX config json",
  "type": "object",
  "properties": {
    "mode": {
      "type": "string"
    },
    "version": {
      "type": "string"
    },
    "created": {
      "type": "string"
    },
    "clusterid": {
      "type": "string"
    },
    "mgtiface": {
      "type": "string"
    },
    "dataiface": {
      "type": "string"
    },
    "kvdb": {
      "type": "array",
      "minItems": 1,
      "items": {"type": "string", "format": "uri" },
      "uniqueItems": true
    },
    "username": {
      "type": "string"
    },
    "password": {
      "type": "string"
    },
    "cafile": {
      "type": "string"
    },
    "certfile": {
      "type": "string"
    },
    "certkey": {
      "type": "string"
    },
    "trustedcafile": {
      "type": "string"
    },
    "clientcertauth": {
      "type": "string"
    },
    "acltoken": {
      "type": "string"
    },
    "loggingurl": {
      "type": "string"
    },
    "alertingurl": {
      "type": "string"
    },
    "scheduler": {
      "type": "string"
    },
    "multi-container": {
      "type": "boolean"
    },
    "nolh": {
      "type": "boolean"
    },
    "callhome": {
      "type": "boolean"
    },
    "bootstrap": {
      "type": "boolean"
    },
    "tunnelendpoint": {
      "type": "string"
    },
    "tunnelcerts": {
      "type": "array",
      "minItems": 2,
      "items": {"type": "string"},
      "uniqueItems": true
    },
    "secret": {
      "type": "object",
      "secret_type": "string",
      "cluster_secret_key": "string",
      "vault": {
        "type": "object",
        "VAULT_TOKEN": "string",
        "VAULT_ADDR": "string"
      },
      "aws": {
        "type": "object",
        "AWS_ACCESS_KEY_ID": "string",
        "AWS_SECRET_ACCESS_KEY": "string",
        "AWS_SECRET_TOKEN_KEY": "string",
        "AWS_CMK": "string",
        "AWS_REGION": "string"
      }
    },
    "storage": {
      "type": "object",
      "properties": {
        "devices_md": {
          "type": "array",
          "items": { "type": "string" },
          "uniqueItems": true
        },
        "max_count": {
          "type": "number"
        },
        "devices": {
          "type": "array",
          "items": { "type": "string" },
          "uniqueItems": true
        },
        "raidlevel": {
          "type": "string"
        },
        "raidlevelmd": {
          "type": "string"
        },
        "async_io": {
          "type": "boolean"
        },
        "num_threads": {
          "type": "number"
        }
      }
    },
    "driver": {
      "type": "string"
    },
    "debug_level": {
      "type": "string"
    },
    "domain": {
      "type": "string"
    },
    "mgmtip": {
      "type": "string"
    },
    "dataip": {
      "type": "string"
    }
  }
}
```

## Definitions

**clusterid**:   Globally unique cluster ID.  Ex: ""07ea5dc0-4e9a-11e6-b2fd-0242ac110003"".   Must be either assigned by PX-Enterprise or guaranteed to be unique

**mgtiface**:   Host ethernet interface used for Management traffic connecting to the 'loggingurl' endpoint.  Primarily used for statistics, configuration and control-path.   Ex: "enp5s0f0"

**dataiface**:  Host ethernet interface used for backend activity, such as replication and resync.  Ex: "enp5s0f1"

**loggingurl**: Endpoint used communicating to PX-Enterpise control (aka "Lighthouse").  Primary use is system statistics.   Ex:  "http://lighthouse.portworx.com/api/stats/listen"

**kvdb**:  Array of endpoints used for the key-value database.  Must be reachable and refer to 'etcd' or 'consul'.   
For 'etcd', an example would be:

```
 Ex:  
    "kvdb": [
        "etcd:http://etcd0.yourdomain.com:4001",
        "etcd:http://etcd1.yourdomain.com:4001",
        "etcd:http://etcd2.yourdomain.com:4001"
     ]
```

For 'consul', an example would be:

```
Ex:
    "kvdb": [
        "consul:http://consul.yourdomain.com:8500"
     ]
```

**storage**:   Array of devices to be used as part of the PX Storage Fabric.  Includes optional "debug_level" flag ("low", "medium", "high"[default]) in the clause.  

```           
 Ex:
           "storage": {
               "devices": [
                   "/dev/nvme0n1",
                   "/dev/sdc",
                   "/dev/sdd"
                ],
                "debug_level": "low"
             }
```
