Portworx pools the storage devices on your server and creates a global capacity for containers.

>**Important:**<br/>Back up any data on storage devices that will be pooled. Storage devices will be reformatted!

To view the storage devices on your server, use the `lsblk` command.

For example:
```
# lsblk
    NAME                      MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
    xvda                      202:0    0     8G  0 disk
    └─xvda1                   202:1    0     8G  0 part /
    xvdb                      202:16   0    64G  0 disk
    xvdc                      202:32   0    64G  0 disk
```
Note that devices without the partition are shown under the **TYPE** column as **part**. This example has two non-root storage devices (/dev/xvdb, /dev/xvdc) that are candidates for storage devices.

Identify the storage devices you will be allocating to PX.  PX can run in a heterogeneous environment, so you can mix and match drives of different types.  Different servers in the cluster can also have different drive configurations.