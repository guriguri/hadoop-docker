#!/bin/bash

USER=hdfs

RETVAL=0
WHOAMI=`whoami`

CMD_PID="/bin/ps -ef |/usr/bin/grep org.apache.hadoop.mapreduce.v2.hs.JobHistoryServer |/usr/bin/grep -v grep |/usr/bin/awk '{print \$2}'"

start() {
    PID=`eval $CMD_PID`
    if [ ! -z "$PID" ]; then
        echo "Already starting [$PID]"
        echo
    else
        if [ "$WHOAMI" == "$USER" ]; then
            $HADOOP_HOME/sbin/mr-jobhistory-daemon.sh --config $HADOOP_CONF_DIR start historyserver
        else
            su $USER -c "$HADOOP_HOME/sbin/mr-jobhistory-daemon.sh --config $HADOOP_CONF_DIR start historyserver"
        fi

        RETVAL=$?
        return $RETVAL
    fi
}

stop() {
    PID=`eval $CMD_PID`
    if [ ! -z "$PID" ]; then
        if [ "$WHOAMI" == "$USER" ]; then
            $HADOOP_HOME/sbin/mr-jobhistory-daemon.sh --config $HADOOP_CONF_DIR stop historyserver
        else
            su $USER -c "$HADOOP_HOME/sbin/mr-jobhistory-daemon.sh --config $HADOOP_CONF_DIR stop historyserver"
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
