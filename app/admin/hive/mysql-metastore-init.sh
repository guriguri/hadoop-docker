#!/bin/bash

MYSQL_INIT_DONE_FILE="${HIVE_LOG_DIR}/mysql-init-done"

if [ -f "${MYSQL_INIT_DONE_FILE}" ]; then
	echo "already initialized."
	exit 1
fi

# init metastore
TPL_SQL="${ADMIN_HOME}/hive/mysql-metastore-init.tpl"
TMP_SQL="/tmp/mysql-metastore-init.sql"
sed "s/%MYSQL_HIVE_USERNAME%/${MYSQL_HIVE_USERNAME}/" ${TPL_SQL} | sed "s/%MYSQL_HIVE_PASSWORD%/${MYSQL_HIVE_PASSWORD}/" > ${TMP_SQL}
mysql -h${MYSQL_HOST} -uroot -p${MYSQL_ROOT_PASSWORD} < ${TMP_SQL}
if [[ "$?" != "0" ]]; then
#    rm -f ${TMP_SQL}
    echo "FAILURE, mysql -h${MYSQL_HOST} -uroot < ${TMP_SQL}"
    exit 2
else
#    rm -f ${TMP_SQL}
    echo "SUCCESS, mysql -h${MYSQL_HOST} -uroot < ${TMP_SQL}"
fi

${HIVE_HOME}/bin/schematool -dbType mysql -initSchema --verbose
if [[ "$?" != "0" ]]; then
    echo "FAILURE, ${HIVE_HOME}/bin/schematool -dbType mysql -initSchema --verbose"
    exit 3
else
    echo "SUCCESS, ${HIVE_HOME}/bin/schematool -dbType mysql -initSchema --verbose"
fi

# for hangul comment
mysql -h${MYSQL_HOST} -u${MYSQL_HIVE_USERNAME} -p${MYSQL_HIVE_PASSWORD} < ${ADMIN_HOME}/hive/mysql-metastore-alter.sql
if [[ "$?" != "0" ]]; then
    echo "FAILURE, mysql -h${MYSQL_HOST} -u${MYSQL_HIVE_USERNAME} < ${ADMIN_HOME}/hive/mysql-metastore-alter.sql"
    exit 4
else
    echo "SUCCESS, mysql -h${MYSQL_HOST} -u${MYSQL_HIVE_USERNAME} < ${ADMIN_HOME}/hive/mysql-metastore-alter.sql"
fi

touch ${MYSQL_INIT_DONE_FILE} 
