---
layout: page
title: "REST API Reference"
keywords: portworx, REST, API
sidebar: home_sidebar
---

Portworx data services can be managed and monitored through RESTful API's.
There are 2 API's that are referenced in this section:
+ [Docker Remote API](https://docs.docker.com/engine/reference/api/docker_remote_api_v1.24)
+ [LibOpenStorage OSD API](https://github.com/portworx/openstorage)

## Volume Lifecycle 

The following examples below illustrate managing the lifecycle for Portworx volumes

### Create Volumes

Volume creation is recommended through the Docker Remote API **/volumes/create** endpoint.   For Example:

```
curl --unix-socket /var/run/docker.sock \
      -H "Content-Type: application/json" \
      -XPOST http::/volumes/create -d \
          '{"Name":"px7vol","Driver":"pxd",\
            "DriverOpts": {"repl": "3", "size": "14"},\
            "Mountpoint":"","Labels":null,\
            "Scope":"global"}'
```
The above command will create a volume named "px7vol", with a size of 14GB and a H/A replication factor of 3

### List Volumes

For listing volumes in brief format with the Docker Remote API **/volumes** endpoint.

```
curl --unix-socket /var/run/docker.sock http::/volumes | python -mjson.tool
```

For listing volumes in detail format, use the OSD API **osd-volumes** endpoint.
For listing an individual volume in detail format, use the OSD API **osd-volumes/volname** endpoint.
For example:

```
curl -XGET http://localhost:9001/v1/osd-volumes/px7vol  | python -mjson.tool
[
    {
        "ctime": {
            "nanos": 890685197,
            "seconds": 1479507011
        },
        "format": 2,
        "id": "700377599852814571",
        "last_scan": {
            "nanos": 890685600,
            "seconds": 1479507011
        },
        "locator": {
            "name": "px7vol"
        },
        "replica_sets": [
            {
                "nodes": [
                    "0666fe49-e5c8-43e1-be27-3c3b0feefcbf",
                    "681a6600-f156-4eab-b55b-a8e14ff0c13d",
                    "db62a060-6e1d-4aec-99f8-518d97bbd1cd"
                ]
            }
        ],
        "runtime_state": [
            {
                "runtime_state": {
                    "FullResyncBlocks": "[{0 0} {1 0} {2 0} {-1 0} {-1 0}]",
                    "ID": "0",
                    "ReadQuorum": "1",
                    "ReadSet": "[0 1 2]",
                    "ReplicaSetCurr": "[0 1 2]",
                    "ReplicaSetNext": "[0 1 2]",
                    "ResyncBlocks": "[{0 0} {1 0} {2 0} {-1 0} {-1 0}]",
                    "RuntimeState": "clean",
                    "TimestampBlocksPerNode": "[8472 8472 0 0 0]",
                    "TimestampBlocksTotal": "8472",
                    "WriteQuorum": "2",
                    "WriteSet": "[0 1 2]"
                }
            }
        ],
        "spec": {
            "aggregation_level": 1,
            "block_size": 65536,
            "format": 2,
            "ha_level": 3,
            "size": 15032385536
        },
        "state": 4,
        "status": 2,
        "usage": 138706944
    }
]
```

>**Note:**<br/> The **id** will be needed to retrieve volume stats

### Monitor Volumes

Volume statistics can be monitored in 2 different modes:
. Live Stats
. Historical Stats

For live stats for a volume (over the past 2 seconds), use the **statslive** endpoint along with the Volume **id**, as noted above:

```
curl -XGET http://localhost:9001/statslive?volumeid=700377599852814571\&stattype=volstat
```

Historical Stats have 3 different arrays or buckets for “Hourly”, “Daily” and “Monthly”.
Once each bucket is filled, it gets aggregated (summarized) and entered into the next (aggregated) bucket tier.   
Based on this scheme, active stats for a volume can be kept for a maximum of 12 months, 31 days, 23 hours 
(aggregated at each level respectively).

For historical stats for a volume, use the **statshistory** endpoint.  For example:

```
curl -XGET http://localhost:9001/statshistory?volumeid=47726638939690023\&stattype=volstat
```

### Delete Volumes

Volume deletion can be done through the Docker Remote API.   For example:

```
curl --unix-socket /var/run/docker.sock \
      -H "Content-Type: application/json" \
      -XDELETE http::/volumes/px7vol
```
