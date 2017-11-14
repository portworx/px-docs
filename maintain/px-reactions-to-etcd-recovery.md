The following table summarizes how PX will respond to an etcd disaster and its recovery from a previous snapshot.


| PX state when snapshot was taken | PX state just before disaster | PX state after disaster recovery |
|-----------------|:---------------|:-------------------------------|
| PX running with few volumes | No PX or application activity    | PX is back online. Volumes are intact. No disruption. |
| PX running with few volumes | New volumes created | PX is back online. New Volumes are lost. |
| PX volumes were not in use by application. (Volumes are not attached) | Volumes are now in use by application (Volumes are attached) | PX is back online. The volume which was supposed to be attached is in detached state. Application is in CrashLoopBackOff state. Potentially could lead to data loss. |
| PX volumes were in use by application | Volume are now not in use by application | Volumes which are not in use by the application still stay attached. No data loss involved. |
| All PX nodes are up | No PX Activity | All the expected nodes are still Up |
| All PX nodes are up | A few nodes go down which have volume replica. Current Set changes. | Potentially could lead to data loss/corruption. Current Set is not in sync with what the storage actually has and when PX comes back up it might lead to data corruption |
| A PX node with replica is down. The node is not in current set. | The node is now online and in Current Set. | PX volume starts with older current set, but eventually gets updated current set. No data loss involved. |