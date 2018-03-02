 ```
# /opt/pwx/bin/pxctl volume create --help
NAME:
   pxctl volume create - Create a volume

USAGE:
   pxctl volume create [command options] [arguments...]

OPTIONS:
   --shared                             make this a globally shared namespace volume
   --secure                             encrypt this volume using AES-256
   --secret_key value                   secret_key to use to fetch secret_data for the PBKDF2 function
   --use_cluster_secret                 Use cluster wide secret key to fetch secret_data
   --label pairs, -l pairs              list of comma-separated name=value pairs
   --size value, -s value               volume size in GB (default: 1)
   --fs value                           filesystem to be laid out: none|xfs|ext4 (default: "ext4")
   --block_size size, -b size           block size in Kbytes (default: 32)
   --repl factor, -r factor             replication factor [1..3] (default: 1)
   --scale value, --sc value            auto scale to max number [1..1024] (default: 1)
   --io_priority value, --iop value     IO Priority: [high|medium|low] (default: "low")
   --sticky                             sticky volumes cannot be deleted until the flag is disabled [on | off]
   --snap_interval min, --si min        snapshot interval in minutes, 0 disables snaps (default: 0)
   --daily hh:mm, --sd hh:mm            daily snapshot at specified hh:mm 
   --weekly value, --sw value           weekly snapshot at specified weekday@hh:mm 
   --monthly value, --sm value          monthly snapshot at specified day@hh:mm   
   --aggregation_level level, -a level  aggregation level: [1..3 or auto] (default: "1")
   --nodes value                        comma-separated Node Ids
   --zones value                        comma-separated Zone names
   --racks value                        comma-separated Rack names
   --group value, -g value              group
   --enforce_cg, --fg                   enforce group during provision
   ```