## tez
### llap 구성 방법
* llap 생성용 script 수정

```
host> ./download.sh -p hive
# 실행하면 app/conf/scripts.llap 밑의 package.py, templates.py 를 app/hive/scripts/llap/yarn 으로 복사 (기존 파일 .org 로 백업)
```

* 밑에 `6. llap 생성 & 실행` 참조

### tez 버전 변경시 해야할 사항 (w/ hadoop 버전 변경)
* tez 버전 변경시 1~6
* hadoop 버전 변경시 3,4,6
* hive 버전 변경시 6

#### 1. 기존 tez-web-ui 삭제
* download.sh 에서 자동으로 tomcat 의 webapps/tez-ui 있으면 설치 안하므로 기존 것 삭제

```
host> rm -rf app/apache-tomcat/webapps/tez-ui
```

#### 2. tez 다운로드 및 설정 (symlink 및 tez-web-ui 설정 등)

```
host> ./download.sh -p tez
```

#### 3. 현재 hadoop 환경에 맞게 tez 의 hadoop lib 변경

```
# HADOOP VERSION 에 맞게 app/tez/lib, app/tez/share 변경
host> ./replace_tez_hadoop_lib.sh hadoop hive tez 3.3.6

Usage)
   ./replace_tez_hadoop_lib.sh HADOOP_DIR HIVE_DIR TEZ_DIR HADOOP_VERSION

   ex)
   ./replace_tez_hadoop_lib.sh <HOME_절대경로(예:/app/hadoop-docker)>/app/hadoop <HOME_절대경로(예:/app/hadoop-docker)>/app/hive <HOME_절대경로(예:/app/hadoop-docker)>/app/tez 3.3.6

# HADOOP VERSION 에 맞게 app/tez/share 의 tar.gz 재생성
host> ./rebuild_share_tez.sh tez 3.3.6 0.9.2

Usage)
   ./rebuild_share_tez.sh TEZ_DIR HADOOP_VERSION TEZ_VERSION

   ex)
   ./rebuild_share_tez.sh <HOME_절대경로(예:/app/hadoop-docker)>/app/tez 3.3.6 0.9.2

```

#### 4. hdfs 의 /app/tez 에 app/tez/share 에 생성한 tar.gz 업로드

```
lima> ./attach.sh data01
[root@data01 /]# su - hdfs
[hdfs@data01 ~]$ hdfs dfs -mkdir -p hdfs:///app/tez
[hdfs@data01 ~]$ hdfs dfs -put /opt/tez/share/tez_with_hadoop_3.3.6-0.9.2.tar.gz hdfs:///app/tez/
```

#### 5. conf 변경 (app/conf/conf.hive/tez-site.xml)

```
  <property>
    <name>tez.lib.uris</name>
    <value>${fs.defaultFS}/app/tez/tez_with_hadoop_3.3.6-0.9.2.tar.gz</value>
  </property>
```

#### 6. llap 생성 & 실행

```
# 생성
lima> ./attach.sh hive
[root@hive /]# su - hive
[hive@hive ~]$ cd /opt/admin/hive/llap/
[hive@hive llap]$ ./llap_generate.sh

# 실행
[hive@hive llap]$ cd /data/hive/logs/llap
[hive@hive llap]$ ./run.sh

```