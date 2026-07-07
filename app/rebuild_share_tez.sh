#!/bin/bash

bin=`which $0`
bin=`dirname ${bin}`
SCRIPT_HOME=`cd "$bin" > /dev/null; pwd`

function help() {
    echo "Usage)"
    echo "   $0 TEZ_DIR HADOOP_VERSION TEZ_VERSION"
    echo ""
    echo "   ex)"
    echo "   $0 $SCRIPT_HOME/tez 3.3.6 0.9.2"
    echo ""
    exit 1
}

if [[ $# -ne 3 ]]; then
    help
fi

DIR_TEZ_SHARE="${1}/share"
HADOOP_VERSION="${2}"
TEZ_VERSION="${3}"

tmp_dir="tmp_share_tez"
target_file="tez_with_hadoop_${HADOOP_VERSION}-${TEZ_VERSION}.tar.gz"

if [[ -d $tmp_dir ]]; then
    echo "rm -rf $tmp_dir"
    rm -rf $tmp_dir
fi

echo "mkdir $tmp_dir"
mkdir $tmp_dir

# make base from tez.tar.gz.org
echo "tar -xf ${DIR_TEZ_SHARE}/tez.tar.gz -C $tmp_dir/"
tar -xf ${DIR_TEZ_SHARE}/tez.tar.gz -C $tmp_dir/

# rm -rf old hadoop-*.jar, zookeeper-*.jar, ...
echo "rm -f $tmp_dir/lib/hadoop-*.jar"
rm -f $tmp_dir/lib/hadoop-*.jar
echo "rm -f $tmp_dir/lib/zookeeper-*.jar"
rm -f $tmp_dir/lib/zookeeper-*.jar
echo "rm -f $tmp_dir/lib/snappy-java-*.jar"
rm -f $tmp_dir/lib/snappy-java-*.jar
echo "rm -f $tmp_dir/lib/guava-*.jar"
rm -f $tmp_dir/lib/guava-*.jar
rm -f $tmp_dir/lib/jetty-*.jar
echo "rm -f $tmp_dir/lib/jersey-*.jar"
rm -f $tmp_dir/lib/jersey-*.jar
echo "rm -f $tmp_dir/lib/woodstox-core-*.jar"
rm -f $tmp_dir/lib/woodstox-core-*.jar
echo "rm -f $tmp_dir/lib/stax2-api-*.jar"
rm -f $tmp_dir/lib/stax2-api-*.jar
echo "rm -f $tmp_dir/lib/commons-configuration2-*.jar"
rm -f $tmp_dir/lib/commons-configuration2-*.jar
echo "rm -f $tmp_dir/lib/commons-configuration-*.jar"
rm -f $tmp_dir/lib/commons-configuration-*.jar
echo "rm -f $tmp_dir/lib/commons-text-*.jar"
rm -f $tmp_dir/lib/commons-text-*.jar
echo "rm -f $tmp_dir/lib/jackson-*.jar"
rm -f $tmp_dir/lib/jackson-*.jar
echo "rm -f $tmp_dir/lib/curator-*.jar"
rm -f $tmp_dir/lib/curator-*.jar
echo "rm -f $tmp_dir/lib/jsr311-api-*.jar"
rm -f $tmp_dir/lib/jsr311-api-*.jar
echo "rm -f $tmp_dir/lib/re2j-*.jar"
rm -f $tmp_dir/lib/re2j-*.jar

# cp new hadoop-*.jar zookeeper-*.jar, ...
echo "cp -f ${DIR_TEZ_SHARE}/lib/hadoop-*.jar $tmp_dir/lib/"
cp -f ${DIR_TEZ_SHARE}/lib/hadoop-*.jar $tmp_dir/lib/
echo "cp -f ${DIR_TEZ_SHARE}/lib/zookeeper-*.jar $tmp_dir/lib/"
cp -f ${DIR_TEZ_SHARE}/lib/zookeeper-*.jar $tmp_dir/lib/
echo "cp -f ${DIR_TEZ_SHARE}/lib/snappy-java-*.jar $tmp_dir/lib/"
cp -f ${DIR_TEZ_SHARE}/lib/snappy-java-*.jar $tmp_dir/lib/
echo "cp -f ${DIR_TEZ_SHARE}/lib/jersey-*.jar $tmp_dir/lib/"
cp -f ${DIR_TEZ_SHARE}/lib/jersey-*.jar $tmp_dir/lib/
echo "cp -f ${DIR_TEZ_SHARE}/lib/woodstox-core-*.jar $tmp_dir/lib/"
cp -f ${DIR_TEZ_SHARE}/lib/woodstox-core-*.jar $tmp_dir/lib/
echo "cp -f ${DIR_TEZ_SHARE}/lib/stax2-api-*.jar $tmp_dir/lib/"
cp -f ${DIR_TEZ_SHARE}/lib/stax2-api-*.jar $tmp_dir/lib/
echo "cp -f ${DIR_TEZ_SHARE}/lib/commons-configuration2-*.jar $tmp_dir/lib/"
cp -f ${DIR_TEZ_SHARE}/lib/commons-configuration2-*.jar $tmp_dir/lib/
echo "cp -f ${DIR_TEZ_SHARE}/lib/commons-text-*.jar $tmp_dir/lib/"
cp -f ${DIR_TEZ_SHARE}/lib/commons-text-*.jar $tmp_dir/lib/
echo "cp -f ${DIR_TEZ_SHARE}/lib/jackson-*.jar $tmp_dir/lib/"
cp -f ${DIR_TEZ_SHARE}/lib/jackson-*.jar $tmp_dir/lib/
echo "cp -f ${DIR_TEZ_SHARE}/lib/curator-*.jar $tmp_dir/lib/"
cp -f ${DIR_TEZ_SHARE}/lib/curator-*.jar $tmp_dir/lib/
echo "cp -f ${DIR_TEZ_SHARE}/lib/jsr311-api-*.jar $tmp_dir/lib/"
cp -f ${DIR_TEZ_SHARE}/lib/jsr311-api-*.jar $tmp_dir/lib/
echo "cp -f ${DIR_TEZ_SHARE}/lib/jetty-*.jar $tmp_dir/lib/"
cp -f ${DIR_TEZ_SHARE}/lib/jetty-*.jar $tmp_dir/lib/
echo "cp -f ${DIR_TEZ_SHARE}/lib/re2j-*.jar $tmp_dir/lib/"
cp -f ${DIR_TEZ_SHARE}/lib/re2j-*.jar $tmp_dir/lib/

echo "cd $tmp_dir"
cd $tmp_dir
echo "tar cfz ${target_file} *"
tar cfz ${target_file} *

echo "mv ${target_file} ${DIR_TEZ_SHARE}/"
mv ${target_file} ${DIR_TEZ_SHARE}/

cd ..
echo "rm -rf $tmp_dir"
rm -rf $tmp_dir

echo ""
echo "Please Upload ${DIR_TEZ_SHARE}/${target_file} to HDFS as hdfs"
echo "lima> ./attach.sh data01"
echo "[root@data01 /]# su - hdfs"
echo "[hdfs@data01 ~]$ hdfs dfs -mkdir -p hdfs:///app/tez"
echo "[hdfs@data01 ~]$ hdfs dfs -put /opt/tez/share/${target_file} hdfs:///app/tez/"
echo ""
