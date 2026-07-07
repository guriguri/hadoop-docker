FROM rockylinux:8

##########
# install
RUN yum update -y \
    && yum install -y \
    glibc-langpack-ko \
    procps psmisc \
    cmake make gcc gcc-c++ \
    wget telnet patch unzip git net-tools nc \
    sudo rsync mysql \
    zlib-devel snappy openssl-devel \
    java-1.8.0-openjdk-devel \
    python2 python3.11 \
    cronie

## set default python version
RUN alternatives --set python /usr/bin/python2
#RUN alternatives --set python /usr/bin/python3.11

## not exist snappy-devel of aarch64 for yum
RUN dnf --enablerepo=powertools install snappy-devel -y

## protobuf
ADD files/protoc-2.5.0-linux-x86_64.tar.gz /usr/local/bin
RUN ln -s /usr/local/bin/protoc-2.5.0-linux-x86_64 /usr/local/bin/protoc

## copy start/stop/restart script
COPY app/admin/hdfs/namenode.sh /etc/init.d/
COPY app/admin/hdfs/datanode.sh /etc/init.d/
COPY app/admin/yarn/resourcemanager.sh /etc/init.d/
COPY app/admin/yarn/historyserver.sh /etc/init.d/
COPY app/admin/yarn/timelineserver.sh /etc/init.d/
COPY app/admin/yarn/nodemanager.sh /etc/init.d/
COPY app/admin/hive/hive-metastore.sh /etc/init.d/
COPY app/admin/hive/hive-server2.sh /etc/init.d/
COPY app/admin/misc/tomcat.sh /etc/init.d/

## copy check_server_ports.sh
COPY files/check_server_ports.sh /root/

## copy rsync_*.sh
COPY files/rsync_hadoop.sh /root/
COPY files/rsync_tomcat.sh /root/

###########
# setup
## for localtime
ADD files/localtime /etc/localtime
## hadoop, yarn, hive 등 JVM 의 로그에서 UTC 로 출력되는 현상으로 추가
RUN echo "export TZ='Asia/Seoul'" >> /etc/environment

## java
ENV JAVA_HOME /usr/lib/jvm/java-openjdk

## user + group
RUN groupadd hadoop
RUN useradd -G hadoop hdfs
RUN useradd -G hadoop yarn
RUN useradd -G hadoop hive

## .bashrc
### for root
RUN echo "" >> /root/.bashrc
RUN echo "# added by docker" >> /root/.bashrc
RUN echo "## for hangul" >> /root/.bashrc
RUN echo "export LANG=ko_KR.UTF-8" >> /root/.bashrc
RUN echo "export LC_ALL=ko_KR.UTF-8" >> /root/.bashrc
RUN echo "## for java" >> /root/.bashrc
RUN echo "export JAVA_HOME=/usr/lib/jvm/java-openjdk" >> /root/.bashrc
RUN echo "## for maven" >> /root/.bashrc
RUN echo "export M2_HOME=/app/maven" >> /root/.bashrc
RUN echo "export M2=\$M2_HOME/bin" >> /root/.bashrc
RUN echo "export MAVEN_OPTS=-Xmx1024m" >> /root/.bashrc
RUN echo "## for hadoop" >> /root/.bashrc
RUN echo "export HADOOP_HOME=/app/hadoop" >> /root/.bashrc
RUN echo "export HADOOP_CONF_DIR=/app/conf/conf.hadoop" >> /root/.bashrc
RUN echo "export PATH=\$HADOOP_HOME/bin:\$M2:\$PATH" >> /root/.bashrc
### for hdfs
RUN echo "" >> /home/hdfs/.bashrc
RUN echo "# added by docker" >> /home/hdfs/.bashrc
RUN echo "## for hangul" >> /home/hdfs/.bashrc
RUN echo "export LANG=ko_KR.UTF-8" >> /home/hdfs/.bashrc
RUN echo "export LC_ALL=ko_KR.UTF-8" >> /home/hdfs/.bashrc
RUN echo "## for java" >> /home/hdfs/.bashrc
RUN echo "export JAVA_HOME=/usr/lib/jvm/java-openjdk" >> /home/hdfs/.bashrc
RUN echo "## for maven" >> /home/hdfs/.bashrc
RUN echo "export M2_HOME=/app/maven" >> /home/hdfs/.bashrc
RUN echo "export M2=\$M2_HOME/bin" >> /home/hdfs/.bashrc
RUN echo "export MAVEN_OPTS=-Xmx1024m" >> /home/hdfs/.bashrc
RUN echo "## for hadoop" >> /home/hdfs/.bashrc
RUN echo "export HADOOP_HOME=/app/hadoop" >> /home/hdfs/.bashrc
RUN echo "export HADOOP_CONF_DIR=/app/conf/conf.hadoop" >> /home/hdfs/.bashrc
RUN echo "export PATH=\$HADOOP_HOME/bin:\$M2:\$PATH" >> /home/hdfs/.bashrc
### for yarn
RUN echo "" >> /home/yarn/.bashrc
RUN echo "# added by docker" >> /home/yarn/.bashrc
RUN echo "## for hangul" >> /home/yarn/.bashrc
RUN echo "export LANG=ko_KR.UTF-8" >> /home/yarn/.bashrc
RUN echo "export LC_ALL=ko_KR.UTF-8" >> /home/yarn/.bashrc
RUN echo "## for java" >> /home/yarn/.bashrc
RUN echo "export JAVA_HOME=/usr/lib/jvm/java-openjdk" >> /home/yarn/.bashrc
RUN echo "## for maven" >> /home/yarn/.bashrc
RUN echo "export M2_HOME=/app/maven" >> /home/yarn/.bashrc
RUN echo "export M2=\$M2_HOME/bin" >> /home/yarn/.bashrc
RUN echo "export MAVEN_OPTS=-Xmx1024m" >> /home/yarn/.bashrc
RUN echo "## for hadoop" >> /home/yarn/.bashrc
RUN echo "export HADOOP_HOME=/app/hadoop" >> /home/yarn/.bashrc
RUN echo "export HADOOP_CONF_DIR=/app/conf/conf.hadoop" >> /home/yarn/.bashrc
RUN echo "export PATH=\$HADOOP_HOME/bin:\$M2:\$PATH" >> /home/yarn/.bashrc
### for hive
RUN echo "" >> /home/hive/.bashrc
RUN echo "# added by docker" >> /home/hive/.bashrc
RUN echo "## for hangul" >> /home/hive/.bashrc
RUN echo "export LANG=ko_KR.UTF-8" >> /home/hive/.bashrc
RUN echo "export LC_ALL=ko_KR.UTF-8" >> /home/hive/.bashrc
RUN echo "## for java" >> /home/hive/.bashrc
RUN echo "export JAVA_HOME=/usr/lib/jvm/java-openjdk" >> /home/hive/.bashrc
RUN echo "## for maven" >> /home/hive/.bashrc
RUN echo "export M2_HOME=/app/maven" >> /home/hive/.bashrc
RUN echo "export M2=\$M2_HOME/bin" >> /home/hive/.bashrc
RUN echo "export MAVEN_OPTS=-Xmx1024m" >> /home/hive/.bashrc
RUN echo "## for hadoop" >> /home/hive/.bashrc
RUN echo "export HADOOP_HOME=/app/hadoop" >> /home/hive/.bashrc
RUN echo "export HADOOP_CONF_DIR=/app/conf/conf.hadoop" >> /home/hive/.bashrc
RUN echo "## for hive" >> /home/hive/.bashrc
RUN echo "export HIVE_HOME=/opt/hive" >> /home/hive/.bashrc
RUN echo "export HIVE_CONF_DIR=/opt/conf/conf.hive" >> /home/hive/.bashrc
RUN echo "export HIVE_LOG_DIR=/data/hive/logs" >> /home/hive/.bashrc
RUN echo "export PATH=\$HIVE_HOME/bin:\$HADOOP_HOME/bin:\$M2:\$PATH" >> /home/hive/.bashrc

###########
# cleanup
## perform cleanup to reduce base image size
RUN yum clean packages

# Default command
CMD ["/bin/bash"]
