A GCP disk template defines the Google persistent disk properties that Portworx will use as a reference. There are 2 ways you can provide this template to Portworx.

**1. Using a template specification**

The spec follows the following format:
```
"type=<GCP disk type>,size=<size of disk>"
```

* __type__: Following two types are supported
    * _pd-standard_
    * _pd-ssd_
* __size__: This is the size of the disk in GB

See [GCP disk](https://cloud.google.com/compute/docs/disks/) for more details on above parameters.

Examples:

* `"type=pd-ssd,size=200"`
* `"type=pd-standard,size=200", "type=pd-ssd,size=100"`


**2. Using existing GCP disks as templates**

You can also reference an existing GCP disk as a template. On every node where PX is brought up as a storage node, a new GCP disk(s) identical to the template will be created.

For example, if you created a template GCP disk called _px-disk-template-1_, you can pass this in to PX as a parameter as a storage device.

Ensure that these disks are created in the same zone as the GCP node group.

### Limiting storage nodes

PX allows you to create a homogenous cluster where some of the nodes are storage nodes and rest of them are storageless. You can specify the number of storage nodes in your cluster by setting the ```max_drive_set_count``` input argument.
Modify the input arguments to PX as shown in the below examples.

Examples:

* `"-s", "type=pd-ssd,size=200", "-max_drive_set_count", "3"`

For a cluster of 5 nodes, in the above example PX will have 3 storage nodes and 2 storage less nodes. PX will create a total 3 PDs of size 200 each and attach one PD to each storage node.

* `"-s", "type=pd-standard,size=200", "-s", "type=pd-ssd,size=100", "-max_drive_set_count", "3"`

For a cluster of 5 nodes, in the above example PX will have 3 storage nodes and 2 storage less nodes. PX will create a total of 6 PDs (3 PDs of size 200 and 3PDs of size 100). PX will attach a set of 2PDs (one of size 200 and one of size 100) to each of the 3 storage nodes..
