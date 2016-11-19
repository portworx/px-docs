---
layout: page
title: "REST API Reference"
keywords: portworx, REST, API
sidebar: home_sidebar
---

Portworx data services can be managed and monitored through RESTful API's.
There are 2 API's that are referenced in this section:

* [Docker Remote API](https://docs.docker.com/engine/reference/api/docker_remote_api_v1.24)
* [LibOpenStorage OSD API](https://github.com/portworx/openstorage)

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

* Live Stats
* Historical Stats

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

Volume alerts can be queried through the **/alerts** endpoint.  For example:

```
curl -XGET http://localhost:9001/v1/osd-volumes/alerts
```


### Delete Volumes

Volume deletion can be done through the Docker Remote API.   For example:

```
curl --unix-socket /var/run/docker.sock \
      -H "Content-Type: application/json" \
      -XDELETE http::/volumes/px7vol
```

## Cluster Monitoring

### Cluster Status

To query overall cluster and node meta, use the **/cluster/enumerate** enpoint.   For example:

```
curl -XGET http://localhost:9001/v1/cluster/enumerate | python -mjson.tool
{
    "Id": "9256cd75-add2-11e6-ae2d-0242ac110003",
    "NodeId": "db62a060-6e1d-4aec-99f8-518d97bbd1cd",
    "Nodes": [
        {
            "Avgload": 0,
            "Cpu": 0,
            "DataIp": "10.0.12.224",
            "Disks": null,
            "GenNumber": 1479511413349655793,
            "Hostname": "mesos4",
            "Id": "db62a060-6e1d-4aec-99f8-518d97bbd1cd",
            "Luns": {},
            "MemFree": 3023777792,
            "MemTotal": 3975540736,
            "MemUsed": 951762944,
            "MgmtIp": "10.0.12.224",
            "NodeData": {
                "STORAGE-INFO": {
                    "LastError": "",
                    "Random4KIops": 0,
                    "ReadThroughput": 0,
                    "ResourceMdUUID": "23e8d89d-699d-4230-951f-f0b7c407137d",
                    "ResourceUUID": "23e8d89d-699d-4230-951f-f0b7c407137d",
                    "Resources": {
                        "1": {
                            "last_scan": {
                                "nanos": 111935554,
                                "seconds": 1479514695
                            },
                            "online": true,
                            "path": "/dev/sdb",
                            "rotation_speed": "Unknown",
                            "size": 68719476736,
                            "used": 4337916968
                        }
                    },
                    "ResourcesCount": 1,
                    "ResourcesLastScan": "Resources Scan OK",
                    "ResourcesMd": {},
                    "ResourcesMdCount": 0,
                    "ResourcesMdLastScan": "",
                    "Status": "Up",
                    "TotalSize": 68719476736,
                    "WriteThroughput": 0
                },
                "STORAGE-RUNTIME": {
                    "TotalAllocated": 2147483648
                },
                "storage_stats": {
                    "Cpu": 100,
                    "DiskAvail": 64469835776,
                    "DiskTotal": 68719476736,
                    "DiskUtil": 2109464576,
                    "Memory": 21,
                    "PendingIo": 0
                }
            },
            "NodeLabels": {
                "Arch": "x86_64",
                "City": "Kennesaw",
                "Country": "United States",
                "Docker Version": "1.12.3",
                "IP": "208.185.17.115",
                "ISP": "Zayo Bandwidth",
                "Kernel Version": "3.10.0-327.36.2.el7.x86_64",
                "LAT": "3.40331E+01",
                "LNG": "-8.46011E+01",
                "Node Count Limit": "35",
                "OS": "CentOS Linux 7 (Core)",
                "PX Version": "1.0.9-d1ade46",
                "Region": "GA",
                "Timezone": "America/New_York",
                "Zip": "30144"
            },
            "StartTime": "2016-11-18T23:23:33.349659166Z",
            "Status": 2,
            "Timestamp": "2016-11-19T00:19:38.209272869Z"
        },
        {
            "Avgload": 0,
            "Cpu": 0,
            "DataIp": "10.0.13.42",
            "Disks": null,
            "GenNumber": 1479503189525952161,
            "Hostname": "mesos3",
            "Id": "681a6600-f156-4eab-b55b-a8e14ff0c13d",
            "Luns": {},
            "MemFree": 3254935552,
            "MemTotal": 3975540736,
            "MemUsed": 720605184,
            "MgmtIp": "10.0.13.42",
            "NodeData": {
                "STORAGE-INFO": {
                    "LastError": "",
                    "Random4KIops": 0,
                    "ReadThroughput": 0,
                    "ResourceMdUUID": "5a395415-9658-4599-acbd-be3c8f75710c",
                    "ResourceUUID": "5a395415-9658-4599-acbd-be3c8f75710c",
                    "Resources": {
                        "1": {
                            "last_scan": {
                                "nanos": 638057825,
                                "seconds": 1479514714
                            },
                            "online": true,
                            "path": "/dev/sdb",
                            "rotation_speed": "Unknown",
                            "size": 68719476736,
                            "used": 5411658792
                        }
                    },
                    "ResourcesCount": 1,
                    "ResourcesLastScan": "Resources Scan OK",
                    "ResourcesMd": {},
                    "ResourcesMdCount": 0,
                    "ResourcesMdLastScan": "",
                    "Status": "Up",
                    "TotalSize": 68719476736,
                    "WriteThroughput": 0
                },
                "STORAGE-RUNTIME": {
                    "TotalAllocated": 2362232012
                },
                "storage_stats": {
                    "Cpu": 100,
                    "DiskAvail": 64246095872,
                    "DiskTotal": 68719476736,
                    "DiskUtil": 2334711808,
                    "Memory": 21,
                    "PendingIo": 0
                }
            },
            "NodeLabels": {
                "Arch": "x86_64",
                "City": "Kennesaw",
                "Country": "United States",
                "Docker Version": "1.12.3",
                "IP": "208.185.17.115",
                "ISP": "Zayo Bandwidth",
                "Kernel Version": "3.10.0-327.36.2.el7.x86_64",
                "LAT": "3.40331E+01",
                "LNG": "-8.46011E+01",
                "Node Count Limit": "35",
                "OS": "CentOS Linux 7 (Core)",
                "PX Version": "1.0.8-9a5c0ea",
                "Region": "GA",
                "Timezone": "America/New_York",
                "Zip": "30144"
            },
            "StartTime": "2016-11-18T21:06:29.525956328Z",
            "Status": 2,
            "Timestamp": "2016-11-19T00:19:34.520081887Z"
        },
        {
            "Avgload": 0,
            "Cpu": 100,
            "DataIp": "10.0.13.85",
            "Disks": null,
            "GenNumber": 1479503173752120061,
            "Hostname": "mesos2",
            "Id": "0666fe49-e5c8-43e1-be27-3c3b0feefcbf",
            "Luns": {},
            "MemFree": 3133652992,
            "MemTotal": 3975540736,
            "MemUsed": 841887744,
            "MgmtIp": "10.0.13.85",
            "NodeData": {
                "STORAGE-INFO": {
                    "LastError": "",
                    "Random4KIops": 0,
                    "ReadThroughput": 0,
                    "ResourceMdUUID": "b53c8b54-d98e-48e3-9155-620ff51ad2c3",
                    "ResourceUUID": "b53c8b54-d98e-48e3-9155-620ff51ad2c3",
                    "Resources": {
                        "1": {
                            "last_scan": {
                                "nanos": 510241127,
                                "seconds": 1479511375
                            },
                            "online": true,
                            "path": "/dev/sdb",
                            "rotation_speed": "Unknown",
                            "size": 68719476736,
                            "used": 4337916968
                        }
                    },
                    "ResourcesCount": 1,
                    "ResourcesLastScan": "Resources Scan OK",
                    "ResourcesMd": {},
                    "ResourcesMdCount": 0,
                    "ResourcesMdLastScan": "",
                    "Status": "Up",
                    "TotalSize": 68719476736,
                    "WriteThroughput": 0
                },
                "STORAGE-RUNTIME": {
                    "TotalAllocated": 1039138816
                },
                "storage_stats": {
                    "Cpu": 0.25252525252525254,
                    "DiskAvail": 65466560512,
                    "DiskTotal": 68719476736,
                    "DiskUtil": 1094979584,
                    "Memory": 10,
                    "PendingIo": 24641536
                }
            },
            "NodeLabels": {
                "Arch": "x86_64",
                "City": "Kennesaw",
                "Country": "United States",
                "Docker Version": "1.12.3",
                "IP": "208.185.17.115",
                "ISP": "Zayo Bandwidth",
                "Kernel Version": "3.10.0-327.36.2.el7.x86_64",
                "LAT": "3.40331E+01",
                "LNG": "-8.46011E+01",
                "Node Count Limit": "35",
                "OS": "CentOS Linux 7 (Core)",
                "PX Version": "1.0.9-d1ade46",
                "Region": "GA",
                "Timezone": "America/New_York",
                "Zip": "30144"
            },
            "StartTime": "2016-11-18T21:06:13.752123905Z",
            "Status": 3,
            "Timestamp": "2016-11-18T23:23:45.496762379Z"
        }
    ],
    "Status": 2
}
```
