`pxctl volume snapshot create` creates a snapshot of a volume.
```
# pxctl volume snapshot create --name mysnap --label color=blue,fabric=wool myvol
Volume snap successful: 234835613696329810
```
The label values allow you to tag the snapshot. You can use them to filter the output of the `pxctl volume list` command
