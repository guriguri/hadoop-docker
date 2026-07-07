#!/bin/bash

if [ ! -d $DFS_NAMENODE_DIR ]; then
	echo "not exist $DFS_NAMENODE_DIR"
else
	echo "remove lost+found from $DFS_NAMENODE_DIR"
	rm -rf $DFS_NAMENODE_DIR/lost+found
fi

if [ "`ls -A $DFS_NAMENODE_DIR`" == "" ]; then
  echo "format $DFS_NAMENODE_DIR"
  $HADOOP_HOME/bin/hdfs --config $HADOOP_CONF_DIR namenode -format
fi
