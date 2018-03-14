An EBS volume template defines a set of EBS volumes that Portworx will use as a reference. There are 2 ways you can provide this template to Portworx.

### Using existing EBS volumes as templates

Create at least one EBS volume using the AWS console or AWS CLI. This volume (or a set of volumes) will serve as a template EBS volume(s). On every node where PX is brought up as a storage node, a new EBS volume(s) identical to the template volume(s) will be created.

For example, create two volumes as:
```
vol-0743df7bf5657dad8: 1000 GiB provisioned IOPS
vol-0055e5913b79fb49d: 1000 GiB GP2
```

Ensure that these EBS volumes are created in the same region as the auto scaling group.

Record the EBS volume ID (e.g. _vol-04e2283f1925ec9ee_), this will be passed in to PX as a parameter as a storage device.

### Using a template specification

For PX 1.3 and higher, you can specify a template spec which will be used by Portworx to create new EBS volumes.

The spec follows the following format:
```
"type=<EBS volume type>,size=<size of EBS volume>,iops=<IOPS value>"
```

* __type__: Following two types are supported
    * _gp2_
    * _io1_ (For io1 volumes specifying the iops value is mandatory.)
* __size__: This is the size of the EBS volume in GB
* __iops__: This is the required IOs per second from the EBS volume.

See [EBS details](https://aws.amazon.com/ebs/details/) for more details on above parameters.

#### Examples

* `"type=gp2,size=200"`
* `"type=gp2,size=100","type=io1,size=200,iops=1000"`

{{ include.ebs-vol-addendum }}