bin=`which $0`
bin=`dirname ${bin}`
SCRIPT_HOME=`cd "$bin" > /dev/null; pwd`

CMD_BEELINE="${SCRIPT_HOME}/../../app/hive/bin/beeline"

echo "remove & load file ============="
hadoop fs -mkdir -p /user/test/tmp
hadoop fs -rm -r /user/test/tmp/passwd
hadoop fs -put passwd /user/test/tmp/
echo ""

echo "create table ==================="
$CMD_BEELINE -u jdbc:hive2://hive.hadoop-local:10000 -n test --silent=true -e "CREATE TABLE IF NOT EXISTS userinfo ( uname STRING, pswd STRING, uid INT, gid INT, fullname STRING, hdir STRING, shell STRING ) ROW FORMAT DELIMITED FIELDS TERMINATED BY ':' STORED AS TEXTFILE;"
echo ""

echo "load data ======================"
$CMD_BEELINE -u jdbc:hive2://hive.hadoop-local:10000 -n test --silent=true -e "LOAD DATA INPATH '/user/test/tmp/passwd' OVERWRITE INTO TABLE userinfo;"
echo ""

echo "select on mr ========================="
$CMD_BEELINE -u jdbc:hive2://hive.hadoop-local:10000 -n test --silent=true -e "SELECT uname, fullname, hdir FROM userinfo ORDER BY uname;" 
echo ""

echo "select on tez ========================="
$CMD_BEELINE -u "jdbc:hive2://hive.hadoop-local:10000?hive.execution.engine=tez" -n test --silent=true -e "SELECT uname, fullname, hdir FROM userinfo ORDER BY uname;" 
echo ""
