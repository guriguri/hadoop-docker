yarnfile = """
{
  "name": "%(name)s",
  "version": "1.0.0",
  "queue": "%(queue.string)s",
  "configuration": {
    "properties": {
      "yarn.service.rolling-log.include-pattern": ".*\\\\.done",
      "yarn.component.placement.policy" : "%(placement)d",
      "yarn.container.health.threshold.percent": "%(health_percent)d",
      "yarn.container.health.threshold.window.secs": "%(health_time_window)d",
      "yarn.container.health.threshold.init.delay.secs": "%(health_init_delay)d"%(service_appconfig_global_append)s
    }
  },
  "components": [
    {
      "name": "llap",
      "number_of_containers": %(instances)d,
      "launch_command": "$LLAP_DAEMON_BIN_HOME/llapDaemon.sh start &> $LLAP_DAEMON_TMP_DIR/shell.out",
      "artifact": {
        "id": "%(hdfspath)s/llap-%(version)s.tar.gz",
        "type": "TARBALL"
      },
      "resource": {
        "cpus": 1,
        "memory": "%(container.mb)d"
      },
      "configuration": {
        "env": {
          "JAVA_HOME": "%(java_home)s",
          "LLAP_DAEMON_HOME": "$PWD/lib/",
          "LLAP_DAEMON_TMP_DIR": "$PWD/tmp/",
          "LLAP_DAEMON_BIN_HOME": "$PWD/lib/bin/",
          "LLAP_DAEMON_CONF_DIR": "$PWD/lib/conf/",
          "LLAP_DAEMON_LOG_DIR": "<LOG_DIR>",
          "LLAP_DAEMON_LOGGER": "%(daemon_logger)s",
          "LLAP_DAEMON_LOG_LEVEL": "%(daemon_loglevel)s",
          "LLAP_DAEMON_HEAPSIZE": "%(heap)d",
          "LLAP_DAEMON_PID_DIR": "$PWD/lib/app/run/",
          "LLAP_DAEMON_LD_PATH": "%(hadoop_home)s/lib/native",
          "LLAP_DAEMON_OPTS": "%(daemon_args)s",

          "APP_ROOT": "<WORK_DIR>/app/install/",
          "APP_TMP_DIR": "<WORK_DIR>/tmp/"
        }
      }
    }
  ],
  "kerberos_principal" : {
    "principal_name" : "%(service_principal)s",
    "keytab" : "%(service_keytab_path)s"
  },
  "quicklinks": {
    "LLAP Daemon JMX Endpoint": "http://llap-0.${SERVICE_NAME}.${USER}.${DOMAIN}:15002/jmx"
  }
}
"""

# Placement policy feature like ANTI AFFINITY is not yet merged to trunk in YARN
runner = """
#!/bin/bash -e

DATE=`date +%%Y%%m%%d`
LOG="$HIVE_LOG_DIR/%(name)s-log-$DATE.log"

LOGDIR=`dirname $LOG`

if [[ ! -d $LOGDIR ]]; then
    echo "mkdir -p $LOGDIR"
    mkdir -p $LOGDIR
fi

echo ">>>>> START, $0, `date +%%Y-%%m-%%d' '%%H:%%M:%%S`" >> $LOG

BASEDIR=$(dirname $0)

echo "`date +%%Y-%%m-%%d' '%%H:%%M:%%S`, yarn app -stop %(name)s" >> $LOG
yarn app -stop %(name)s >> $LOG 2>&1

echo "`date +%%Y-%%m-%%d' '%%H:%%M:%%S`, yarn app -destroy %(name)s" >> $LOG
yarn app -destroy %(name)s >> $LOG 2>&1

echo "`date +%%Y-%%m-%%d' '%%H:%%M:%%S`, hdfs dfs -mkdir -p %(hdfspath)s" >> $LOG
hdfs dfs -mkdir -p %(hdfspath)s >> $LOG 2>&1

echo "`date +%%Y-%%m-%%d' '%%H:%%M:%%S`, hdfs dfs -copyFromLocal -f $BASEDIR/llap-%(version)s.tar.gz %(hdfspath)s" >> $LOG
hdfs dfs -copyFromLocal -f $BASEDIR/llap-%(version)s.tar.gz %(hdfspath)s >> $LOG 2>&1

echo "`date +%%Y-%%m-%%d' '%%H:%%M:%%S`, yarn app -launch %(name)s $BASEDIR/Yarnfile" >> $LOG
yarn app -launch %(name)s $BASEDIR/Yarnfile >> $LOG 2>&1

echo ">>>>> END, $0, `date +%%Y-%%m-%%d' '%%H:%%M:%%S`" >> $LOG
echo "" >> $LOG
"""

stopper = """
#!/bin/bash -e

DATE=`date +%%Y%%m%%d`
LOG="$HIVE_LOG_DIR/%(name)s-log-$DATE.log"

LOGDIR=`dirname $LOG`

if [[ ! -d $LOGDIR ]]; then
    echo "mkdir -p $LOGDIR"
    mkdir -p $LOGDIR
fi

echo ">>>>> START, $0, `date +%%Y-%%m-%%d' '%%H:%%M:%%S`" >> $LOG

BASEDIR=$(dirname $0)

echo "`date +%%Y-%%m-%%d' '%%H:%%M:%%S`, yarn app -stop %(name)s" >> $LOG
yarn app -stop %(name)s >> $LOG 2>&1

echo "`date +%%Y-%%m-%%d' '%%H:%%M:%%S`, yarn app -destroy %(name)s" >> $LOG
yarn app -destroy %(name)s >> $LOG 2>&1

echo ">>>>> END, $0, `date +%%Y-%%m-%%d' '%%H:%%M:%%S`" >> $LOG
echo "" >> $LOG
"""
