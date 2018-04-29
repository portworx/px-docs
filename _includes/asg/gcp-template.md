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
* `"type=pd-standard,size=200","type=pd-ssd,size=100"`


**2. Using existing GCP disks as templates**

You can also reference an existing GCP disk as a template. On every node where PX is brought up as a storage node, a new GCP disk(s) identical to the template will be created.

For example, if you created a template GCP disk called _px-disk-template-1_, you can pass this in to PX as a parameter as a storage device.

Ensure that these disks are created in the same zone as the GCP node group.
