#!/bin/bash

# check python version
PYTHON2_PATTERN='Python 2[.]*'
python_version="`python -V 2>&1`"
if [[ ! "${python_version}" =~ $PYTHON2_PATTERN ]]; then
    echo "need to python2 !!! (current: ${python_version})"
    exit 1
fi

USERNAME=`id -un`
RUN_USERNAME="hive"
if [[ "${USERNAME}" != "${RUN_USERNAME}" ]]; then
    echo "need to execute by ${RUN_USERNAME}"
    exit 1
fi

BASE_DIR=/opt/hive/bin
export HIVE_CONF_DIR=/opt/conf/conf.hive
export HIVE_LOG_DIR=/data/hive/logs
export HIVE_AUX_JARS_PATH=""
LLAP_NAME=llaptest
LLAP_INSTANCES=1
LLAP_SIZE_MB=1g
LLAP_QUEUE=llap
export LLAP_PKG_HDFS_PATH="hdfs:///user/${USERNAME}/.yarn/package/LLAP"
OUTPUT=/data/hive/logs/llap

CMD="${BASE_DIR}/hive --service llap --name ${LLAP_NAME} --instances=${LLAP_INSTANCES} --size=${LLAP_SIZE_MB} --queue=${LLAP_QUEUE} --output=${OUTPUT}"

echo ${CMD}
#eval "nohup ${CMD} 2>&1 &"
eval ${CMD}

# add viewfs-mounttable.xml
TARBALL=llap-`LANG=C date +%d%b%Y`.tar.gz
VIEWFS_MOUNT_XML=/app/conf/conf.hadoopp/viewfs-mounttable.xml
TMP_DIR=tmp

# mkdir tmp
if [[ -d $TMP_DIR ]]; then
    echo "rm -rf $TMP_DIR"
    rm -rf $TMP_DIR
fi
echo "mkdir -p $TMP_DIR"
mkdir -p $TMP_DIR

# tar extract to tmp
echo "tar -xf $TARBALL -C $TMP_DIR"
tar -xf $TARBALL -C $TMP_DIR

# cp viewfs-mouttable.xml
echo "cp -f $VIEWFS_MOUNT_XML $TMP_DIR/conf"
cp -f $VIEWFS_MOUNT_XML $TMP_DIR/conf
echo "chmod 640 $TMP_DIR/conf/viewfs-mounttable.xml"
chmod 640 $TMP_DIR/conf/viewfs-mounttable.xml

# make tarball
echo "cd $TMP_DIR && tar cfz $TARBALL * && mv -f $TARBALL .. && cd .."
cd $TMP_DIR && tar cfz $TARBALL * && mv -f $TARBALL .. && cd ..

# rm -rf tmp
echo "rm -rf $TMP_DIR"
rm -rf $TMP_DIR
