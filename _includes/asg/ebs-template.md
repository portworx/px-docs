An EBS volume templates defines a set of EBS volumes that Portworx will use as a reference. Create at least one EBS volume using the AWS console or AWS CLI. This volume (or a set of volumes) will serve as a template EBS volume(s). On every node where PX is brought up as a storage node, a new EBS volume(s) identical to the template volume(s) will be created.

For example, create two volumes as:
```
vol-0743df7bf5657dad8: 1000 GiB provisioned IOPS
vol-0055e5913b79fb49d: 1000 GiB GP2
```

Ensure that these EBS volumes are created in the same region as the auto scaling group.

Record the EBS volume ID (e.g. _vol-04e2283f1925ec9ee_), this will be passed in to PX as a parameter as a storage device.

**For PX version > 1.3**

A set of EBS volume templates can be specified in the following comma-separated format

```
"type=<EBS volume type>,size=<size of EBS volume>,iops=<IOPS value>","type=<EBS volume type>,size=<size of EBS volume>,iops=<IOPS value>"

For ex:

"type=gp2,size=100","type=io1,size=200,iops=1000"

```

Following two types are supported
- gp2
- io1

>**Note:**For io1 volumes specifying the iops value is mandatory.
