**Key-value store**

Portworx uses a key-value store for it's clustering metadata. Please have a clustered key-value database (etcd or consul) installed and ready. For etcd installation instructions refer to [this doc](/maintain/etcd.html).

**Storage**

Portworx requires dedicated storage.  Please ensure at least one node in the cluster has extra storage available, in a form of unformatted partition or a disk-drive.

**Shared mounts**

Portworx 1.3 and higher automatically enables shared mounts.

If you are installing Portworx 1.2, you *must* configure Docker to allow shared mounts propagation (see [instructions](/knowledgebase/shared-mount-propagation.html)), as otherwise Portworx will fail to start.

**Firewall**

Ensure network ports 9001 through 9015 are open between the nodes that will run Portworx. Your nodes should also be able to reach the port KVDB is running on (for example etcd usually runs on port 2379).

{{ include.firewall-custom-steps }}

**NTP**

Ensure all nodes running PX are time-synchronized, and NTP service is configured and running.