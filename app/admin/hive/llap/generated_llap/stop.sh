
#!/bin/bash -e

DATE=`date +%Y%m%d`
LOG="$HIVE_LOG_DIR/llaptest-log-$DATE.log"

LOGDIR=`dirname $LOG`

if [[ ! -d $LOGDIR ]]; then
    echo "mkdir -p $LOGDIR"
    mkdir -p $LOGDIR
fi

echo ">>>>> START, $0, `date +%Y-%m-%d' '%H:%M:%S`" >> $LOG

BASEDIR=$(dirname $0)

echo "`date +%Y-%m-%d' '%H:%M:%S`, yarn app -stop llaptest" >> $LOG
yarn app -stop llaptest >> $LOG 2>&1

echo "`date +%Y-%m-%d' '%H:%M:%S`, yarn app -destroy llaptest" >> $LOG
yarn app -destroy llaptest >> $LOG 2>&1

echo ">>>>> END, $0, `date +%Y-%m-%d' '%H:%M:%S`" >> $LOG
echo "" >> $LOG
