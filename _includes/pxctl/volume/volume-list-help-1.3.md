Snapshots are listed using pxctl volume list command.
```
NAME:
   pxctl volume list - List volumes in the cluster

USAGE:
   pxctl volume list [command options]

OPTIONS:
   --all, -a                 show all volumes, including snapshots
   --node-id value           show all volumes whose replica is present on the given node
   --name value              volume name used during creation if any
   --label pairs, -l pairs   list of comma-separated name=value pairs
   --snapshot, -s            show all snapshots (read-only volumes)
   --snapshot-schedule, --ss show all schedule created snapshots
   --parent value, -p value  show all snapshots created for given volume
```
