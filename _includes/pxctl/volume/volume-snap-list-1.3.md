User created snapshots can be listed using one of the following ways
```
# pxctl volume list --all
ID          NAME                                    SIZE    HA  SHARED  ENCRYPTED   COMPRESSED  IO_PRIORITY SCALE   STATUS
234835613696329810  mysnap                                  1 GiB   1   no  no      no      LOW     1   up - detached
1125771388930868153 myvol                                   1 GiB   1   no  no      no      LOW     1   up - detached
```
(or)
```
# pxctl volume list --snapshot
ID          NAME                                    SIZE    HA  SHARED  ENCRYPTED   COMPRESSED  IO_PRIORITY SCALE   STATUS
234835613696329810  mysnap                                  1 GiB   1   no  no      no      LOW     1   up - detached
```

All scheduled snapshots can be listed using  --snapshot-schedule option.
```
# pxctl volume list --snapshot-schedule
ID          NAME                                    SIZE    HA  SHARED  ENCRYPTED   COMPRESSED  IO_PRIORITYSCALE    STATUS
423119103642927058  myvol_periodic_2018_Feb_26_21_12                    1 GiB   1   no  no      no      LOW     1up - detached
```

You can filter the results with the --parent and --label options. For instance, --parent myvol will show only snapshots whose parent is myvol, i.e., mysnap in this example
Giving labels restricts the list to snapshots that have all of the specified labels. For instance, --label fabric=wool would again show mysnap but --label fabric=cotton wo
```
# pxctl volume list --parent myvol --snapshot
ID          NAME    SIZE    HA  SHARED  ENCRYPTED   COMPRESSED  IO_PRIORITY SCALE   STATUS
234835613696329810  mysnap  1 GiB   1   no  no      no      LOW     1   up - detached

# pxctl volume list --parent myvol --snapshot --label fabric=wool
ID          NAME    SIZE    HA  SHARED  ENCRYPTED   COMPRESSED  IO_PRIORITY SCALE   STATUS
234835613696329810  mysnap  1 GiB   1   no  no      no      LOW     1   up - detached
```
