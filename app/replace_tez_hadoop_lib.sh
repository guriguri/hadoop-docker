#!/bin/bash

bin=`which $0`
bin=`dirname ${bin}`
SCRIPT_HOME=`cd "$bin" > /dev/null; pwd`

function help() {
    echo "Usage)"
    echo "   $0 HADOOP_DIR HIVE_DIR TEZ_DIR HADOOP_VERSION"
    echo ""
    echo "   ex)"
    echo "   $0 $SCRIPT_HOME/hadoop $SCRIPT_HOME/hive $SCRIPT_HOME/tez 3.3.6"
    echo ""
    exit 1
}

if [[ $# -ne 4 ]]; then
    help
fi

DIR_HADOOP="${1}"
DIR_HIVE="${2}"
DIR_TEZ="${3}"
HADOOP_VERSION="${4}"

HADOOP_TEZ_LIB_JARS="${DIR_HADOOP}/share/hadoop/hdfs/hadoop-hdfs-client-${HADOOP_VERSION}.jar ${DIR_HADOOP}/share/hadoop/mapreduce/hadoop-mapreduce-client-common-${HADOOP_VERSION}.jar ${DIR_HADOOP}/share/hadoop/mapreduce/hadoop-mapreduce-client-core-${HADOOP_VERSION}.jar ${DIR_HADOOP}/share/hadoop/yarn/hadoop-yarn-server-timeline-pluginstorage-${HADOOP_VERSION}.jar ${DIR_HADOOP}/share/hadoop/common/lib/javax.servlet-api-\*.jar ${DIR_HADOOP}/share/hadoop/yarn/lib/jersey-client-\*.jar ${DIR_HADOOP}/share/hadoop/common/lib/jersey-json-\*.jar"

# tez/lib
echo "copy for tez/lib"
for f in $HADOOP_TEZ_LIB_JARS; do
    dir_name=`dirname $f`
    tmp_jar_name=`basename $f`
    # \* -> * 변환
    rm_jar_name=${tmp_jar_name/\\/}
    jar_name=`ls ${dir_name}/${rm_jar_name} | xargs basename`

    if [[ ! -f ${DIR_TEZ}/lib/${jar_name} ]]; then
        echo "rm -rf ${DIR_TEZ}/lib/${rm_jar_name/$HADOOP_VERSION/*}"
        rm -rf ${DIR_TEZ}/lib/${rm_jar_name/$HADOOP_VERSION/*}

        echo "cp -rf ${dir_name}/${jar_name} ${DIR_TEZ}/lib/"
        cp -rf ${dir_name}/${jar_name} ${DIR_TEZ}/lib/
    else
        echo "already cp -rf ${dir_name}/${jar_name} ${DIR_TEZ}/lib/"
    fi
done
echo ""

echo "remove jetty guava for tez/lib"
echo "rm -rf ${DIR_TEZ}/lib/jetty-*"
rm -rf ${DIR_TEZ}/lib/jetty-*
echo "rm -rf ${DIR_TEZ}/lib/guava-*"
rm -rf ${DIR_TEZ}/lib/guava-*
echo ""

HADOOP_TEZ_SHARE_JARS="${DIR_HADOOP}/share/hadoop/common/lib/hadoop-annotations-${HADOOP_VERSION}.jar ${DIR_HADOOP}/share/hadoop/common/lib/hadoop-auth-${HADOOP_VERSION}.jar ${DIR_HADOOP}/share/hadoop/common/hadoop-common-${HADOOP_VERSION}.jar ${DIR_HADOOP}/share/hadoop/hdfs/hadoop-hdfs-client-${HADOOP_VERSION}.jar ${DIR_HADOOP}/share/hadoop/mapreduce/hadoop-mapreduce-client-common-${HADOOP_VERSION}.jar ${DIR_HADOOP}/share/hadoop/mapreduce/hadoop-mapreduce-client-core-${HADOOP_VERSION}.jar ${DIR_HADOOP}/share/hadoop/common/hadoop-registry-${HADOOP_VERSION}.jar ${DIR_HADOOP}/share/hadoop/yarn/hadoop-yarn-api-${HADOOP_VERSION}.jar ${DIR_HADOOP}/share/hadoop/yarn/hadoop-yarn-client-${HADOOP_VERSION}.jar ${DIR_HADOOP}/share/hadoop/yarn/hadoop-yarn-common-${HADOOP_VERSION}.jar ${DIR_HADOOP}/share/hadoop/yarn/hadoop-yarn-server-applicationhistoryservice-${HADOOP_VERSION}.jar ${DIR_HADOOP}/share/hadoop/yarn/hadoop-yarn-server-common-${HADOOP_VERSION}.jar ${DIR_HADOOP}/share/hadoop/yarn/hadoop-yarn-server-timeline-pluginstorage-${HADOOP_VERSION}.jar ${DIR_HADOOP}/share/hadoop/yarn/hadoop-yarn-server-web-proxy-${HADOOP_VERSION}.jar ${DIR_HADOOP}/share/hadoop/hdfs/lib/zookeeper-*.jar ${DIR_HADOOP}/share/hadoop/common/lib/hadoop-shaded-guava-*.jar ${DIR_HADOOP}/share/hadoop/common/lib/hadoop-shaded-protobuf_3_7-*.jar ${DIR_HADOOP}/share/hadoop/common/lib/snappy-java-*.jar ${DIR_HADOOP}/share/hadoop/common/lib/javax.servlet-api-*.jar ${DIR_HADOOP}/share/hadoop/yarn/lib/jersey-client-*.jar ${DIR_HADOOP}/share/hadoop/yarn/lib/jersey-guice-*.jar ${DIR_HADOOP}/share/hadoop/common/lib/jersey-core-*.jar ${DIR_HADOOP}/share/hadoop/common/lib/jersey-json-*.jar ${DIR_HADOOP}/share/hadoop/common/lib/jersey-servlet-*.jar ${DIR_HADOOP}/share/hadoop/common/lib/woodstox-core-*.jar ${DIR_HADOOP}/share/hadoop/common/lib/stax2-api-*.jar ${DIR_HADOOP}/share/hadoop/common/lib/commons-configuration2-*.jar ${DIR_HADOOP}/share/hadoop/common/lib/commons-text-*.jar ${DIR_HADOOP}/share/hadoop/common/lib/jackson-annotations-*.jar ${DIR_HADOOP}/share/hadoop/common/lib/jackson-core-*.jar ${DIR_HADOOP}/share/hadoop/common/lib/jackson-core-asl-*.jar ${DIR_HADOOP}/share/hadoop/common/lib/jackson-databind-*.jar ${DIR_HADOOP}/share/hadoop/common/lib/jackson-mapper-asl-*.jar ${DIR_HADOOP}/share/hadoop/yarn/lib/jackson-jaxrs-base-*.jar ${DIR_HADOOP}/share/hadoop/yarn/lib/jackson-jaxrs-json-provider-*.jar ${DIR_HADOOP}/share/hadoop/yarn/lib/jackson-module-jaxb-annotations-*.jar ${DIR_HADOOP}/share/hadoop/common/lib/jsr311-api-*.jar ${DIR_HADOOP}/share/hadoop/common/lib/jetty-servlet-*.jar ${DIR_HADOOP}/share/hadoop/common/lib/jetty-server-*.jar ${DIR_HADOOP}/share/hadoop/common/lib/jetty-util-*.jar ${DIR_HADOOP}/share/hadoop/common/lib/jetty-webapp-*.jar ${DIR_HADOOP}/share/hadoop/common/lib/jetty-http-*.jar ${DIR_HADOOP}/share/hadoop/common/lib/jetty-security-*.jar ${DIR_HADOOP}/share/hadoop/common/lib/jetty-io-*.jar ${DIR_HADOOP}/share/hadoop/common/lib/jetty-xml-*.jar ${DIR_HADOOP}/share/hadoop/common/lib/re2j-*.jar"
HIVE_TEZ_SHARE_JARS="${DIR_HIVE}/lib/curator-client-*.jar ${DIR_HIVE}/lib/curator-framework-*.jar ${DIR_HIVE}/lib/curator-recipes-*.jar"

# tez/share
echo "copy for tez/share"

if [[ -d ${DIR_TEZ}/share/lib ]]; then
    echo "rm -rf ${DIR_TEZ}/share/lib"
    rm -rf ${DIR_TEZ}/share/lib
fi

echo "mkdir ${DIR_TEZ}/share/lib"
mkdir ${DIR_TEZ}/share/lib

for f in "$HADOOP_TEZ_SHARE_JARS $HIVE_TEZ_SHARE_JARS"; do
    jar_name=`basename $f`

    if [[ ! -f ${DIR_TEZ}/share/lib/${jar_name} ]]; then
        echo "cp -rf $f ${DIR_TEZ}/share/lib/"
        cp -rf $f ${DIR_TEZ}/share/lib/
    fi
done

echo ""
echo "!!! need to rebuild by rebuild_share_tez.sh for ${DIR_TEZ}/share/tez.tar.gz with hadoop ${HADOOP_VERSION} lib !!!"
echo ""
