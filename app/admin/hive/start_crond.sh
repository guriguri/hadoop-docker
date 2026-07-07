# /bin/bash

LOG="/data/hive/logs/crond-hive-`date +%Y%m%d`.log"

echo ">>>>> START, $0, `date +%Y-%m-%d' '%H:%M:%S`" >> $LOG

## restart crond
echo "killall crond" >> $LOG
killall crond

echo "crond" >> $LOG
crond

## create crontab for hive
PATH=/app/hadoop/bin:/usr/bin
JAVA_HOME=/usr/lib/jvm/java-openjdk
HADOOP_CONF_DIR=/app/conf/conf.hadoop
HIVE_ADMIN_DIR=/opt/admin/hive
HIVE_LOG_DIR=/data/hive/logs
LLAP_NAME=llaptest
ES_URL=http://es.hadoop-local:9200/_bulk

CRONTAB_FILE="/var/spool/cron/hive"
echo "create crontab(${CRONTAB_FILE}) for hive" >> $LOG

echo "for llap of hive" > ${CRONTAB_FILE}

echo "*/5 * * * * PATH=${PATH} JAVA_HOME=${JAVA_HOME} HADOOP_CONF_DIR=${HADOOP_CONF_DIR} ${HIVE_ADMIN_DIR}/llap/get_yarn_service_status.sh ${LLAP_NAME} ${ES_URL} ${HIVE_LOG_DIR}/yarn_service_status_llaptest-result.json >> ${HIVE_LOG_DIR}/get_yarn_service_status-`date +\%Y\%m\%d`.log 2>&1" >> ${CRONTAB_FILE}
echo "1,6,11,16,21,26,31,36,41,46,51,56 * * * * PATH=${PATH} JAVA_HOME=${JAVA_HOME} HADOOP_CONF_DIR=${HADOOP_CONF_DIR} ${HIVE_ADMIN_DIR}/llap/get_yarn_service_llap_daemon_status.sh ${ES_URL} ${HIVE_LOG_DIR}/yarn_service_status_llaptest-result.json >> ${HIVE_LOG_DIR}/get_yarn_service_llap_daemon_status-`date +\%Y\%m\%d`.log 2>&1" >> ${CRONTAB_FILE}

chown hive ${CRONTAB_FILE}
chgrp hive ${CRONTAB_FILE}
chmod 600 ${CRONTAB_FILE}

echo ">>>>> END, $0, `date +%Y-%m-%d' '%H:%M:%S`" >> $LOG
echo "" >> $LOG
