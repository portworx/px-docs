 ```
# /opt/pwx/bin/pxctl volume create -h
NAME:
   pxctl volume create - Create a volume
USAGE:
   pxctl volume create [command options] volume-name
OPTIONS:
   --shared                                      make this a globally shared namespace volume
   --secure                                      encrypt this volume using AES-256
   --secret_key value                            secret_key to use to fetch secret_data for the PBKDF2 function
   --use_cluster_secret                          Use cluster wide secret key to fetch secret_data
   --label pairs, -l pairs                       list of comma-separated name=value pairs
   --size value, -s value                        volume size in GB (default: 1)
   --fs value                                    filesystem to be laid out: none|xfs|ext4 (default: "ext4")
   --block_size size, -b size                    block size in Kbytes (default: 32)
   --repl factor, -r factor                      replication factor [1..3] (default: 1)
   --scale value, --sc value                     auto scale to max number [1..1024] (default: 1)
   --io_priority value, --iop value              IO Priority: [high|medium|low] (default: "low")
   --journal                                     Journal data for this volume
   --io_profile value, --prof value              IO Profile: [sequential|random|db|db_remote] (default: "sequential")
   --sticky                                      sticky volumes cannot be deleted until the flag is disabled [on | off]
   --aggregation_level level, -a level           aggregation level: [1..3 or auto] (default: "1")
   --nodes value                                 comma-separated Node Ids
   --zones value                                 comma-separated Zone names
   --racks value                                 comma-separated Rack names
   --group value, -g value                       group
   --enforce_cg, --fg                            enforce group during provision
   --periodic mins,k, -p mins,k                  periodic snapshot interval in mins,k (keeps 5 by default), 0 disables all schedule snapshots
   --daily hh:mm,k, -d hh:mm,k                   daily snapshot at specified hh:mm,k (keeps 7 by default)
   --weekly weekday@hh:mm,k, -w weekday@hh:mm,k  weekly snapshot at specified weekday@hh:mm,k (keeps 5 by default)
   --monthly day@hh:mm,k, -m day@hh:mm,k         monthly snapshot at specified day@hh:mm,k (keeps 12 by default)
   --policy value, --sp value                    policy names separated by comma
   ```