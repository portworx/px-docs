#!/bin/sh
#
#       /etc/rc.d/init.d/portworx
#
#       Daemon for Portworx OCI service
#
# chkconfig:   2345 96 4
# description: Daemon for Portworx OCI service

### BEGIN INIT INFO
# Provides:             portworx
# Required-Start:       $local_fs $remote_fs
# Required-Stop:        $local_fs $remote_fs
# Should-Start:         docker
# Should-Stop:          docker
# Default-Start:        2 3 4 5
# Default-Stop:         0 1 6
# Short-Description:    start and stop portworx service
# Description:          Daemon for Portworx OCI service
### END INIT INFO

# Source function library.
[ -f /etc/rc.d/init.d/functions ] && . /etc/rc.d/init.d/functions

prog="portworx"
pidfile="/var/run/$prog.pid"
logfile="/var/log/$prog.log"
max_retries=300

[ -e /etc/sysconfig/$prog ] && . /etc/sysconfig/$prog

RETVAL=0
case "${1}" in
        start)
		printf "Starting $prog:\t"
		date +"%F %T,%3N INFO STARTUP:: Removing stale $prog runC service (if any)" >> $logfile 2>&1
		/opt/pwx/bin/runc delete -f $prog >> $logfile 2>&1
		nohup /opt/pwx/bin/px-runc run --name $prog >> $logfile 2>&1 &
		PID=$!
		RETVAL=$?
		if [ $RETVAL -eq 0 ]; then
			echo $PID > $pidfile
			success
			echo
		else
			failure
			echo
			exit 1
		fi
                ;;

        stop)
		printf "Stopping $prog:\t"
		pgpid=$(/opt/pwx/bin/runc list | awk '/^portworx/{print $2}')
		if [ "x$pgpid" != x ] && [ $pgpid -gt 0 ]; then
		    date +"%F %T,%3N INFO SHUTDOWN:: Stopping $prog runC service" >> $logfile 2>&1
		    /opt/pwx/bin/runc kill portworx >> $logfile 2>&1
		    cnt=0
		    while [ $cnt -le $max_retries ]; do
			pids=$(ps --no-headers -o pid -g $pgpid | xargs)
			if [ "x$pids" = x ]; then
			    rm -f $pidfile
			    success
			    echo
			    RETVAL=0
			    cnt=$((max_retries+1))
			    break
			elif [ $cnt -ge $max_retries ]; then
			    echo -n $"  TIMEOUT!  (killing $pids)  "
			    kill -9 $pids
			    failure
			    echo
			    RETVAL=1
			    cnt=$((max_retries+1))
			    break
			else
			    printf .
			    cnt=$((cnt+1))
			    sleep 1
			fi
		    done
		else
		    success
		    echo
		fi
                ;;

	status)
		/opt/pwx/bin/runc state $prog
		echo
		;;

        force-reload|restart)
                ${0} stop; sleep 3; ${0} start
                ;;

        *)
                echo $"Usage: ${0} {start|stop|restart|status}"
                ;;
esac

exit $RETVAL
