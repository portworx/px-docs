An EBS volume template defines the EBS volume properties that Portworx will use as a reference. There are 2 ways you can provide this template to Portworx.

**1. Using a template specification**

For PX 1.3 and higher, you can specify a template spec which will be used by Portworx to create new EBS volumes.

The spec follows the following format:
```
"type=<EBS volume type>,size=<size of EBS volume>,iops=<IOPS value>,enc=<true/false>,kms=<CMK>"
```

* __type__: Following two types are supported
    * _gp2_
    * _io1_ (For io1 volumes specifying the iops value is mandatory.)
* __size__: This is the size of the EBS volume in GB
* __iops__: This is the required IOs per second from the EBS volume.
* __enc__:  This needs to be set to true if EBS volumes need to be encrypted. Default: false
* __kms__:  This is the Customer Master Key to encrypt the EBS volume.

See [EBS details](https://aws.amazon.com/ebs/details/) for more details on above parameters.

Examples

* `"type=gp2,size=200"`
* `"type=gp2,size=100","type=io1,size=200,iops=1000"`
* `"type=gp2,size=100,enc=true,kms=AKXXXXXXXX123","type=io1,size=200,iops=1000,enc=true,kms=AKXXXXXXXXX123"`


**2. Using existing EBS volumes as templates**

You can also reference an existing EBS volume as a template.  Create at least one EBS volume using the AWS console or AWS CLI. This volume (or a set of volumes) will serve as a template EBS volume(s). On every node where PX is brought up as a storage node, a new EBS volume(s) identical to the template volume(s) will be created.

For example, create two volumes as:
```
vol-0743df7bf5657dad8: 1000 GiB provisioned IOPS
vol-0055e5913b79fb49d: 1000 GiB GP2
```

Ensure that these EBS volumes are created in the same region as the auto scaling group.

Record the EBS volume ID (e.g. _vol-04e2283f1925ec9ee_), this will be passed in to PX as a parameter as a storage device.

{{ include.ebs-vol-addendum }}

### Limiting storage nodes.

PX allows you to create a heterogenous cluster where some of the nodes are storage nodes and rest of them are storageless. Based on the PX version follow one of the below procedure.

#### PX Version 1.5

{% include asg/storage-less-node-1.5.md %}

Examples:

* `"-s", "type=gp2,size=200", "-max_storage_nodes_per_zone", "1"`

For a cluster of 6 nodes spanning 3 zones (us-east-1a,us-east-1b,us-east-1c), in the above example PX will have 3 storage nodes (one in each zone) and 3 storage less nodes. PX will create a total 3 EBS volumes of size 200 each and attach one EBS volume to each storage node.

* `"-s", "type=gp2,size=200", "-s", "type=io1,size=100,iops=1000", "-max_storage_nodes_per_zone", "2"`

For a cluster of 9 nodes spanning 2 zones (us-east-1a,us-east-1b), in the above example PX will have 4 storage nodes and 5 storage less nodes. PX will create a total of 8 EBS volumes (4 of size 200 and 4 of size 100). PX will attach a set of 2 EBS volumes (one of size 200 and one of size 100) to each of the 4 storage nodes..


#### PX Version 1.4 and older

{% include asg/storage-less-node-1.4.md %}

Examples:

* `"-s", "type=gp2,size=200", "-max_drive_set_count", "3"`

For a cluster of 5 nodes, in the above example PX will have 3 storage nodes and 2 storage less nodes. PX will create a total 3 EBS volumes of size 200 each and attach one EBS volume to each storage node.

* `"-s", "type=gp2,size=200", "-s", "type=io1,size=100,iops=1000", "-max_drive_set_count", "3"`

For a cluster of 5 nodes, in the above example PX will have 3 storage nodes and 2 storage less nodes. PX will create a total of 6 EBS volumes (3 of size 200 and 3 of size 100). PX will attach a set of 2 EBS volumes (one of size 200 and one of size 100) to each of the 3 storage nodes..
