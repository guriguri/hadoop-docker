#!/bin/bash

USER=hdfs

RETVAL=0
WHOAMI=`whoami`

CMD_PID="/bin/ps -ef |/usr/bin/grep org.apache.hadoop.yarn.server.nodemanager.NodeManager |/usr/bin/grep -v grep |/usr/bin/awk '{print \$2}'"

start() {
    PID=`eval $CMD_PID`
    if [ ! -z "$PID" ]; then
        echo "Already starting [$PID]"
        echo
    else
        if [ "$WHOAMI" == "$USER" ]; then
            $HADOOP_HOME/sbin/yarn-daemon.sh --config $HADOOP_CONF_DIR start nodemanager
        else
            su $USER -c "$HADOOP_HOME/sbin/yarn-daemon.sh --config $HADOOP_CONF_DIR start nodemanager"
        fi

        RETVAL=$?
        return $RETVAL
    fi
}

stop() {
    PID=`eval $CMD_PID`
    if [ ! -z "$PID" ]; then
        if [ "$WHOAMI" == "$USER" ]; then
            $HADOOP_HOME/sbin/yarn-daemon.sh --config $HADOOP_CONF_DIR stop nodemanager
        else
            su $USER -c "$HADOOP_HOME/sbin/yarn-daemon.sh --config $HADOOP_CONF_DIR stop nodemanager"
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
        echo $"Usage: $prog {start|stop|restart}"
        RETVAL=3
esac

exit $RETVAL
