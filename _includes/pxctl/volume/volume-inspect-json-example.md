Following is a sample output of the json volume inspect.

```json
# /opt/pwx/bin/pxctl -j v i 486256711004992211
[{
 "id": "486256711004992211",
 "source": {
  "parent": "",
  "seed": ""
 },
 "readonly": false,
 "locator": {
  "name": "pvc-2910e5ab-1b5e-11e8-97a3-0269077ba1bd",
  "volume_labels": {
   "namespace": "default",
   "pvc": "px-nginx-shared-pvc"
  }
 },
 "ctime": "2018-02-27T01:33:16Z",
 "spec": {
  "ephemeral": false,
  "size": "1073741824",
  "format": "ext4",
  "block_size": "65536",
  "ha_level": "2",
  "cos": "low",
  "io_profile": "sequential",
  "dedupe": false,
  "snapshot_interval": 0,
  "volume_labels": {
   "kubectl.kubernetes.io/last-applied-configuration": "{\"apiVersion\":\"v1\",\"kind\":\"PersistentVolumeClaim\",\"metadata\":{\"annotations\":{\"volume.beta.kubernetes.io/storage-class\":\"px-nginx-shared-sc\"},\"name\":\"px-nginx-shared-pvc\",\"namespace\":\"default\"},\"spec\":{\"accessModes\":[\"ReadWriteOnce\"],\"resources\":{\"requests\":{\"storage\":\"1Gi\"}}}}\n",
   "repl": "2",
   "shared": "true",
   "volume.beta.kubernetes.io/storage-class": "px-nginx-shared-sc",
   "volume.beta.kubernetes.io/storage-provisioner": "kubernetes.io/portworx-volume"
  },
  "shared": true,
  "aggregation_level": 1,
  "encrypted": false,
  "passphrase": "",
  "snapshot_schedule": "",
  "scale": 0,
  "sticky": false,
  "group_enforced": false,
  "compressed": false,
  "cascaded": false,
  "journal": false,
  "nfs": false
 },
 "usage": "33964032",
 "last_scan": "2018-02-27T01:33:16Z",
 "format": "ext4",
 "status": "up",
 "state": "detached",
 "attached_on": "",
 "attached_state": "ATTACH_STATE_INTERNAL_SWITCH",
 "device_path": "",
 "secure_device_path": "",
 "replica_sets": [
  {
   "nodes": [
    "k2n3",
    "k2n1"
   ]
  }
 ],
 "runtime_state": [
  {
   "runtime_state": {
    "FullResyncBlocks": "[{0 0} {1 0} {-1 0} {-1 0} {-1 0}]",
    "ID": "0",
    "ReadQuorum": "1",
    "ReadSet": "[0 1]",
    "ReplNodePools": "1,1",
    "ReplRemoveMids": "",
    "ReplicaSetCurr": "[0 1]",
    "ReplicaSetCurrMid": "k2n3,k2n1",
    "ReplicaSetNext": "[0 1]",
    "ReplicaSetNextMid": "k2n3,k2n1",
    "ResyncBlocks": "[{0 0} {1 0} {-1 0} {-1 0} {-1 0}]",
    "RuntimeState": "clean",
    "TimestampBlocksPerNode": "[0 0 0 0 0]",
    "TimestampBlocksTotal": "0",
    "WriteQuorum": "2",
    "WriteSet": "[0 1]"
   }
  }
 ],
 "error": ""
}]
```