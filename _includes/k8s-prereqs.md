**Key-value store**

Portworx uses a key-value store for it's clustering metadata. Please have a clustered key-value database (etcd or consul) installed and ready. For etcd installation instructions refer this [doc](/maintain/etcd.html).

**Storage**

At least one of the Portworx nodes should have extra storage available, in a form of unformatted partition or a disk-drive.

Storage devices explicitly given to Portworx will be automatically formatted by PX.

**Shared mounts**

If you are running Docker v1.12, you *must* configure Docker to allow shared mounts propagation (see [instructions](/knowledgebase/shared-mount-propogation.html)), as otherwise Kubernetes will not be able to install Portworx.

**Firewall**

Ensure ports 9001-9015 are open between the Kubernetes nodes that will run Portworx.

**NTP**

Ensure all nodes running PX are time-synchronized, and NTP service is configured and running.