# Volume Sets

Orchestration software such as kubernetes, mesos, etc. allow scaling the number of instances of pods/applications. However, when these pods/applications require data volumes, there is no way to associate instances to data volumes.

`volume-sets` allows re-use of the same volume name for all container instances by performing on-demand creation of volumes as user containers get scheduled on different nodes. Each instance of a container gets a unique instance of a data volume.

In runtime, a node may fail and applications get respawned on different nodes. With `volume-sets`, applications are re-associated with volumes regardless of where they are respawned. Because the association between a container and volume is done
*after* the scheduler picks a node, the volume  chosen is a volume that has data local to the node, thus enabling compute-convergent (data colocated with the container) architectures.

## Implementation
When a `volume-set` is requested to be attached, an attempt is made to attach a volume that has data local to the node. If such a volume is not found, then one is
created using the volume spec of the scaled volume as a template.  An error is returned if a free volume in the set is not found and no more volumes can be created as per the `volume-set` `scale` limit.

## Usage
A `volume-set` can be created using the pxctl CLI, docker CLI, or inline volume spec.  This can be done via the `pxctl` cli, or docker directly as follows:

## pxctl CLI
The `--scale` parameter automatically creates a volume set:

```
# pxctl volume create elk_vol --scale 10
Volume successfully created: 232783593254518125

# pxctl volume list
ID                      NAME            SIZE         HA      SHARED  ENCRYPTED       IO_PRIORITY     SCALE   STATUS
232783593254518125      elk_vol         1 GiB        1       no      no              LOW             10      up - detached
```

## Docker CLI

```
# docker volume create --driver pxd --name elk_vol --opt scale=10
# pxctl volume list
ID                      NAME            SIZE         HA      SHARED  ENCRYPTED       IO_PRIORITY     SCALE   STATUS
232783593254518125      elk_vol         1 GiB        1       no      no              LOW             10      up - detached
```

## Inline `volume-set` creation
This is useful when creating volumes through a scheduler.

```
#docker volume create -d pxd --name scale=10,size=1G,repl=1,name=elk_vol

# pxctl volume list
ID                      NAME            SIZE         HA      SHARED  ENCRYPTED       IO_PRIORITY     SCALE   STATUS
232783593254518125      elk_vol         1 GiB        1       no      no              LOW             10      up - detached
```

### Update scale factor after volume creation

A `volume-set`'s scale factor can be modified after the volume is created:

```
# pxctl volume update scale_vol --scale 12
# pxctl volume list
ID                      NAME            SIZE         HA      SHARED  ENCRYPTED       IO_PRIORITY     SCALE   STATUS
232783593254518125      elk_vol         1 GiB        1       no      no              LOW             12      up - detached
```

Decreasing the scaled volume only restricts creation of future volumes. Decreasing scale will not delete any volumes.

## FAQ

### Can I attach more than one instance of a `volume-set` on the same node?
If multiple containers request the same volume from a `volume-set` on a node, only one instance is created. The volume will be shared between client containers.  This is done to ensure cross application shared-data integrity.

### How do I delete a scaled volume
At present all the instances of the `volume-set` need to be deleted one by one.

### How do I request for a specific instance of a scaled volume
You can always specify a an instance of a `volume-set` by name.

