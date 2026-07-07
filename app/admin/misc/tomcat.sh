#!/bin/bash

USER=hive

RETVAL=0
WHOAMI=`whoami`

start() {
	PID=`/bin/ps -ef |/bin/fgrep org.apache.catalina.startup.Bootstrap |/bin/grep -v grep |/bin/grep -v supervisor_wrapper.sh|/usr/bin/awk '{print }'`
	if [ ! -z "$PID" ]; then
		echo "Already starting [$PID]"
		echo
	else
		if [ "$WHOAMI" == "$USER" ]; then
			$CATALINA_HOME/bin/startup.sh
		else
			su $USER -c "exec $CATALINA_HOME/bin/startup.sh"
		fi

		RETVAL=$?
		return $RETVAL
	fi
}

stop() {
	PID=`/bin/ps -ef |/bin/fgrep org.apache.catalina.startup.Bootstrap |/bin/grep -v grep |/bin/grep -v supervisor_wrapper.sh|/usr/bin/awk '{print }'`
	if [ ! -z "$PID" ]; then
		if [ "$WHOAMI" == "$USER" ]; then
			$CATALINA_HOME/bin/shutdown.sh
		else
			su $USER -c "exec $CATALINA_HOME/bin/shutdown.sh"
		fi

		RETVAL=$?
		return $RETVAL
	else
		echo "Not running"
		echo
	fi
}

case "$1" in
	start)
		start
		;;
	stop)
		stop
		;;
	restart)
		stop
		sleep 2
		start
		;;
	*)
		echo "Usage: $prog {start|stop|restart}"
		RETVAL=3
esac

exit $RETVAL
