echo "hadoop fs -ls /tmp/test ================="
hadoop fs -ls /tmp/test
echo ""

echo "remove input, output directory =========="
hadoop fs -rm -r /tmp/test/input
hadoop fs -rm -r /tmp/test/output
echo ""

echo "put input ==============================="
hadoop fs -mkdir /tmp/test
hadoop fs -put input /tmp/test/
hadoop fs -ls /tmp/test
echo ""

echo "run wordcount ==========================="
hadoop jar WordCount-1.0-SNAPSHOT.jar com.mycompany.wordcount.WordCount /tmp/test/input /tmp/test/output
echo ""

echo "check result  ==========================="
hadoop fs -cat /tmp/test/output/part-r-00000
echo ""
