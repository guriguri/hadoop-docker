#!/bin/bash

HDFS_INIT_DONE_FILE="${HIVE_LOG_DIR}/hdfs-hive-server2-init-done"

if [ -f "${HDFS_INIT_DONE_FILE}" ]; then
	echo "already initialized."
	exit 1
fi

${HADOOP_HOME}/bin/hdfs dfs -test -e /tmp
if [[ "$?" != "0" ]]; then
    ${HADOOP_HOME}/bin/hdfs dfs -mkdir /tmp
    ${HADOOP_HOME}/bin/hdfs dfs -chmod 1777 /tmp

    if [[ "$?" != "0" ]]; then
        echo "FAILURE, ${HADOOP_HOME}/bin/hdfs dfs -mkdir /tmp"
        echo "FAILURE, ${HADOOP_HOME}/bin/hdfs dfs -chmod 1777 /tmp"
        exit 2
    else
        echo "SUCCESS, ${HADOOP_HOME}/bin/hdfs dfs -mkdir /tmp"
        echo "SUCCESS, ${HADOOP_HOME}/bin/hdfs dfs -chmod 1777 /tmp"
    fi
else
    echo "exist /tmp"
fi

${HADOOP_HOME}/bin/hdfs dfs -test -e /user/hive/warehouse
if [[ "$?" != "0" ]]; then
    ${HADOOP_HOME}/bin/hdfs dfs -mkdir -p /user/hive/warehouse
    ${HADOOP_HOME}/bin/hdfs dfs -chmod g+w /user/hive/warehouse

    if [[ "$?" != "0" ]]; then
        echo "FAILURE, ${HADOOP_HOME}/bin/hdfs dfs -mkdir -p /user/hive/warehouse"
        echo "FAILURE, ${HADOOP_HOME}/bin/hdfs dfs -chmod g+w /user/hive/warehouse"
        exit 3
    else
        echo "SUCCESS, ${HADOOP_HOME}/bin/hdfs dfs -mkdir -p /user/hive/warehouse"
        echo "SUCCESS, ${HADOOP_HOME}/bin/hdfs dfs -chmod g+w /user/hive/warehouse"
    fi
else
    echo "exist /user/hive/warehouse"
fi

touch ${HDFS_INIT_DONE_FILE}
