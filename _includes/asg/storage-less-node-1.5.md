You can specify the number of storage nodes in your cluster by setting the ```max_storage_nodes_per_zone``` input argument.
This instructs PX to limit the number of storage nodes in one zone to the value specified in ```max_storage_nodes_per_zone``` argument. The total number of storage nodes in your cluster will be
```
Total Storage Nodes = (Num of Zones) * max_storage_nodes_per_zone.
```
While planning capacity for your auto scaling cluster make sure the minimum size of your cluster is equal to the total number of storage nodes in PX. This ensures that when you scale up your cluster, only storage less nodes will be added. While when you scale down the cluster, it will scale to the minimum size which ensures that all PX storage nodes are online and available.

>**Note:**<br/> You can always ignore the **max_storage_nodes_per_zone** argument. When you scale up the cluster, the new nodes will also be storage nodes but while scaling down you will loose storage nodes causing PX to loose quorum.
