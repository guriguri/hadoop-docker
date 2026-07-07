#!/bin/bash

USER=hive

RETVAL=0
WHOAMI=`whoami`

CMD_PID="/bin/ps -ef |/usr/bin/grep org.apache.hadoop.hive.metastore.HiveMetaStore |/usr/bin/grep -v grep |/usr/bin/awk '{print \$2}'"

start() {
    PID=`eval $CMD_PID`
    if [ ! -z "$PID" ]; then
        echo "Already starting [$PID]"
        echo
    else
        if [ "$WHOAMI" == "$USER" ]; then
            ${ADMIN_HOME}/hive/mysql-metastore-init.sh

            echo "nohup ${HIVE_HOME}/bin/hive --service metastore --hiveconf hive.log.dir=${HIVE_LOG_DIR} 1> /dev/null 2>&1 &"
            nohup ${HIVE_HOME}/bin/hive --service metastore --hiveconf hive.log.dir=${HIVE_LOG_DIR} 1> /dev/null 2>&1 &
        else
            su $USER -c "${ADMIN_HOME}/hive/mysql-metastore-init.sh"

            echo "su $USER -c \"nohup ${HIVE_HOME}/bin/hive --service metastore --hiveconf hive.log.dir=${HIVE_LOG_DIR} 1> /dev/null 2>&1 &\""
            su $USER -c "nohup ${HIVE_HOME}/bin/hive --service metastore --hiveconf hive.log.dir=${HIVE_LOG_DIR} 1> /dev/null 2>&1 &"
        fi

        RETVAL=$?
        return $RETVAL
    fi
}

stop() {
    PID=`eval $CMD_PID`
    if [ ! -z "$PID" ]; then
        if [ "$WHOAMI" == "$USER" ]; then
            echo "kill -9 $PID"
            kill -9 $PID
        else
            echo "su $USER -c \"kill -9 $PID\""
            su $USER -c "kill -9 $PID"
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
