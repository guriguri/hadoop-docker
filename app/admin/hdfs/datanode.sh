#!/bin/bash

USER=hdfs

RETVAL=0
WHOAMI=`whoami`

CMD_PID="/bin/ps -ef |/usr/bin/grep org.apache.hadoop.hdfs.server.datanode.DataNode |/usr/bin/grep -v grep |/usr/bin/awk '{print \$2}'"

start() {
    PID=`eval $CMD_PID`
    if [ ! -z "$PID" ]; then
        echo "Already starting [$PID]"
        echo
    else
        if [ "$WHOAMI" == "$USER" ]; then
            if [ ! -d $DFS_DATANODE_DIR ]; then
                echo "not exist $DFS_NAMENODE_DIR"
                return 2
            fi

            $HADOOP_HOME/sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR start datanode
        else
            su $USER -c "if [ ! -d $DFS_DATANODE_DIR ]; then echo \"not exist $DFS_DATANODE_DIR\"; exit 2; fi"

            RETVAL=$?
            if [ $RETVAL -ne 0 ]; then
                return $RETVAL
            fi        

            su $USER -c "$HADOOP_HOME/sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR start datanode"
        fi

        RETVAL=$?
        return $RETVAL
    fi
}

stop() {
    PID=`eval $CMD_PID`
    if [ ! -z "$PID" ]; then
        if [ "$WHOAMI" == "$USER" ]; then
            $HADOOP_HOME/sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR stop datanode
        else
            su $USER -c "$HADOOP_HOME/sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR stop datanode"
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
