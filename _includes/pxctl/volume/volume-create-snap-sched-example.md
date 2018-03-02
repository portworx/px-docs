```
# /opt/pwx/bin/pxctl volume create *--daily 23:50,30 --periodic 60,24 --weekly sunday@10:10* vx1
Volume successfully created: 836228556646454877
root@70-0-39-240:/home/ub# /opt/pwx/bin/pxctl v i vx1
Volume    :  836228556646454877
    Name                 :  vx1
    Size                 :  1.0 GiB
    Format               :  ext4
    HA                   :  1
    IO Priority          :  LOW
    Creation time        :  Feb 19 17:38:27 UTC 2018
    Snapshot             :  *periodic 1h0m0s,keep last 24, daily @23:50,keep last 30, weekly Sunday@10:10,keep last 5*
    Shared               :  no
    Status               :  up
    State                :  detached
    Reads                :  0
    Reads MS             :  0
    Bytes Read           :  0
    Writes               :  0
    Writes MS            :  0
    Bytes Written        :  0
    IOs in progress      :  0
    Bytes used           :  32 MiB
    Replica sets on nodes:
        Set  0
          Node          :  70.0.39.241 (Pool 0)
    Replication Status     :  Detached (edited)
```