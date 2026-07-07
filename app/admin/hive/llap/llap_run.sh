#!/bin/bash
set -x

PATH=/app/hadoop/bin:$PATH

DATE=`date +%Y%m%d`
LOG="$HIVE_LOG_DIR/${LLAP_NAME}-log-$DATE.log"

LOGDIR=`dirname $LOG`

if [[ ! -d $LOGDIR ]]; then
    echo "mkdir -p $LOGDIR"
    mkdir -p $LOGDIR
fi

echo ">>>>> START, $0, `date +%Y-%m-%d' '%H:%M:%S`" >> $LOG

# Wait for DFS to come out of safe mode
until hdfs dfsadmin -safemode wait
do
    echo "Waiting for HDFS safemode to turn off"
    # force safemode leave
    hdfs dfsadmin -safemode leave
done

/opt/admin/hive/llap/generated_llap/run.sh

echo ">>>>> END, $0, `date +%Y-%m-%d' '%H:%M:%S`" >> $LOG
echo "" >> $LOG
