# add custom env
# set HIVE_AUX_JARS_PATH
## HEAD of sentry
#if [ "${HIVE_AUX_JARS_PATH}" == "" ]; then
#	export HIVE_AUX_JARS_PATH="/etc/hive/conf/sentry/lib"
#else
#	export HIVE_AUX_JARS_PATH="/etc/hive/conf/sentry/lib,$HIVE_AUX_JARS_PATH"
#fi
## TAIL of sentry

## HEAD of tez
export TEZ_HOME="/opt/tez"
TEZ_JARS=""
for f in ${TEZ_HOME}/*.jar ${TEZ_HOME}/lib/*.jar; do
    # slf4j-reload4j 가 hive 의 log4j-slf4j 보다 먼저 binding 되면 hadoop 로그 설정으로 처리되서 제외
    # reload4j(log4j 1.x 가 더이상 관리가 안되서 새로 pkg 된 것)가 hive 의 log4j2 보다 먼저 binding 되면 log4j2 가 아니라 log4j 1.x 로 처리되면서 STARTUP_MSG 로그 등이 출력 안되서 제외
    if [[ ( $f == */slf4j* ) || ( $f == */reload4j* ) ]]; then
        continue
    fi

    # extract hadoop-libs
    if [[ ( $f == */lib/hadoop-* ) || ( $f == */lib/commons-* ) || ( $f == */lib/guava* ) || ( $f == */lib/javax* ) || ( $f == */lib/jersey-* ) || ( $f == */lib/jettison* ) || ( $f == */lib/jsr305-* ) || ( $f == */lib/metrics-core* ) || ( $f == */lib/netty-* ) || ( $f == */lib/protobuf-* ) ]]; then
        continue
    fi

    if [[ "${TEZ_JARS}" == "" ]]; then
        TEZ_JARS=$f
    else
        TEZ_JARS=${TEZ_JARS}:$f
    fi
done

if [ "x${HADOOP_CLASSPATH}" == "x" ]; then
    export HADOOP_CLASSPATH="${TEZ_JARS}"
else
    export HADOOP_CLASSPATH="${HADOOP_CLASSPATH}:${TEZ_JARS}"
fi
## TAIL of tez

## HEAD of remote jvm
if [[ "$SERVICE" =~ ^(hiveserver2)$ ]]; then
    if [[ ! ${HADOOP_CLIENT_OPTS} == *jdwp* ]]; then
        export HADOOP_CLIENT_OPTS="${HADOOP_CLIENT_OPTS} -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005"
    fi
fi
## TAIL of remote jvm
