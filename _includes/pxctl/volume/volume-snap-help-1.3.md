```
# pxctl volume snap --help
NAME:
   pxctl volume snap-interval-update - Update volume configuration

USAGE:
   pxctl volume snap-interval-update [command options] volume-name-or-ID

OPTIONS:
   --periodic mins,k, -p mins,k                  periodic snapshot interval in mins,k (keeps 5 by default), 0 disables all schedule snapshots
   --daily hh:mm,k, -d hh:mm,k                   daily snapshot at specified hh:mm,k (keeps 7 by default)
   --weekly weekday@hh:mm,k, -w weekday@hh:mm,k  weekly snapshot at specified weekday@hh:mm,k (keeps 5 by default)
   --monthly day@hh:mm,k, -m day@hh:mm,k         monthly snapshot at specified day@hh:mm,k (keeps 12 by default)
   --policy value, --sp value                    policy names separated by comma
```