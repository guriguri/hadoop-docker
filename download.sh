#!/bin/bash

bin=`which $0`
bin=`dirname ${bin}`
SCRIPT_HOME=`cd "$bin" > /dev/null; pwd`

function help() {
    echo "Usage)"
    echo "   $0 -p all|hadoop|hive|tez [-f]"
    echo ""
    echo "  -p: package"
    echo "  -f: force download"
    echo "      default is not force download"
    echo ""
    echo "   $0 -p all"
    echo "   $0 -p all -f"
    echo "   $0 -p hadoop"
    echo "   $0 -p hadoop -f"
    echo ""
    exit 1
}

function echo2() {
    echo "$@"
}

function set_env() {
    ARCH_TYPE=$(uname -m)
    echo2 "arch=${ARCH_TYPE}"

    DIR_APP="${SCRIPT_HOME}/app"
    DIR_PKGS="${DIR_APP}/pkgs"

    if [ ! -d ${DIR_APP} ]; then
        echo2 "mkdir -p ${DIR_APP}"
        mkdir -p ${DIR_APP}
    fi

    if [ ! -d ${DIR_PKGS} ]; then
        echo2 "mkdir -p ${DIR_PKGS}"
        mkdir -p ${DIR_PKGS}
    fi
}

function backup_and_copy_file() {
    check_file="${1}"
    org_file="${2}"
    src_file="${3}"
    dst_path="${4}"

    if [[ ! -f $check_file ]]; then
        if [[ -f ${org_file} ]]; then
            echo2 "backup ${org_file} to ${org_file}.org"
            mv ${org_file} ${org_file}.org
        fi

        echo2 "cp ${src_file} ${dst_path}"
        cp ${src_file} ${dst_path}
    else
        echo2 "already cp ${src_file} ${dst_path}"
    fi
}

PATTERN_FILE="^file://*"

function get_pkg() {
    pkg_url="${1}"
    pkg_name=`basename ${pkg_url}`
    if [[ "${pkg_url}" == "" ]]; then
        echo2 "pkg_url is empty"
        return
    fi

    pkg_check_path="${2}"
    if [[ "${pkg_check_path}" == "" ]]; then
        echo2 "pkg_check_path is empty"
        return
    fi

    pkg_link="${3}"
    if [[ "${pkg_link}" == "" ]]; then
        echo2 "pkg_link is empty"
        return
    fi

    if [[ "${IS_FORCE_DOWNLOAD}" == "true" ]]; then
        if [[ -d ${DIR_APP}/${pkg_check_path} ]]; then
            echo2 "rm -rf ${DIR_APP}/${pkg_check_path}"
            rm -rf ${DIR_APP}/${pkg_check_path}
        fi

        if [[ -f ${DIR_PKGS}/${pkg_name} ]]; then
            if [[ ! "${pkg_url}" =~ $PATTERN_FILE ]]; then
                echo2 "rm -rf ${DIR_PKGS}/${pkg_name}"
                rm -rf ${DIR_PKGS}/${pkg_name}
            else
                echo2 "SKIP, rm -rf ${DIR_PKGS}/${pkg_name} because ${pkg_link}"
            fi
        fi

        if [[ -f ${DIR_APP}/${pkg_link} ]]; then
            echo2 "rm -rf ${DIR_APP}/${pkg_link}"
            rm -rf ${DIR_APP}/${pkg_link}
        fi
    fi

    if [[ ! -f ${DIR_PKGS}/${pkg_name} ]]; then
        if [[ ! "${pkg_url}" =~ $PATTERN_FILE ]]; then
            echo2 "curl -fSL \"${pkg_url}\" -o ${DIR_PKGS}/${pkg_name}"
            curl -fSL "${pkg_url}" -o ${DIR_PKGS}/${pkg_name}
        fi
    else
        if [[ ! "${pkg_url}" =~ $PATTERN_FILE ]]; then
            echo2 "already exist ${DIR_PKGS}/${pkg_name}"
        fi
    fi

    if [[ ! -d ${DIR_APP}/${pkg_check_path} ]]; then
        if [[ (${pkg_name} == *.tar.gz) || (${pkg_name} == *.tgz) ]]; then
            echo2 "tar -xf ${DIR_PKGS}/${pkg_name} -C ${DIR_APP}/"
            tar -xf ${DIR_PKGS}/${pkg_name} -C ${DIR_APP}/

            if [[ $? -ne 0 ]]; then
                echo2 "not exist ${DIR_PKGS}/${pkg_name}"
                exit 2
            fi
        elif [[ ${pkg_name} != *.war ]]; then
            echo2 "SKIP, tar extract for ${pkg_name}"
        fi
    else
        echo2 "already exist ${DIR_APP}/${pkg_check_path}"
    fi

    if [[ "${pkg_link}" == "none" ]]; then
        echo2 "SKIP, create symlink for ${pkg_name} because pkg_link is ${pkg_link}"
    elif [[ ! -L ${DIR_APP}/${pkg_link} ]]; then
        echo2 "ln -s ${DIR_APP}/${pkg_check_path} ${DIR_APP}/${pkg_link}"
        cd ${DIR_APP}
        ln -s ${pkg_check_path} ${pkg_link}
    else
        current_real_path="`realpath ${DIR_APP}/${pkg_link}`"
        if [[ "${current_real_path}" != "${DIR_APP}/${pkg_check_path}" ]]; then
            echo2 "rm ${DIR_APP}/${pkg_link} for re-symlink (${current_real_path} -> ${DIR_APP}/${pkg_check_path})"
            rm ${DIR_APP}/${pkg_link}

            echo2 "ln -s ${DIR_APP}/${pkg_check_path} ${DIR_APP}/${pkg_link}"
            cd ${DIR_APP}
            ln -s ${pkg_check_path} ${pkg_link}
        else
            echo2 "already exist ${DIR_APP}/${pkg_link}"
        fi
    fi
}

function set_maven() {
    # already download ${DIR_PKGS}/apache-maven-3.6.3-bin.tar.gz
    # need to maven 3.6+ for hadoop 3.x 
    OLD_IS_FORCE_DOWNLOAD="${IS_FORCE_DOWNLOAD}"
    IS_FORCE_DOWNLOAD="false"

    # archive 로 옮겨짐
    #get_pkg "https://dlcdn.apache.org/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz" "apache-maven-3.6.3" "maven"
    get_pkg "https://archive.apache.org/dist/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz" "apache-maven-3.6.3" "maven"

    IS_FORCE_DOWNLOAD="${OLD_IS_FORCE_DOWNLOAD}"
}

function set_hadoop() {
    if [[ "${ARCH_TYPE}" == "x86_64" ]]; then
        get_pkg "https://dlcdn.apache.org/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz" "hadoop-3.3.6" "hadoop"
    else
        get_pkg "https://dlcdn.apache.org/hadoop/common/hadoop-3.3.6/hadoop-3.3.6-aarch64.tar.gz" "hadoop-3.3.6" "hadoop"
    fi
}

function set_hive() {
    # archive 로 옮겨짐
    #get_pkg "https://dlcdn.apache.org/hive/hive-3.1.3/apache-hive-3.1.3-bin.tar.gz" "apache-hive-3.1.3-bin" "hive"
    get_pkg "https://archive.apache.org/dist/hive/hive-3.1.3/apache-hive-3.1.3-bin.tar.gz" "apache-hive-3.1.3-bin" "hive"

    # mysql-connector
    if [[ ! -f ${DIR_APP}/hive/lib/mysql-connector-j-8.0.33.jar ]]; then
        get_pkg "https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-j-8.0.33.tar.gz" "mysql-connector-j-8.0.33" "mysql-connector"
        echo2 "cp ${DIR_APP}/mysql-connector/mysql-connector-j-8.0.33.jar ${DIR_APP}/hive/lib"
        cp ${DIR_APP}/mysql-connector/mysql-connector-j-8.0.33.jar ${DIR_APP}/hive/lib
    else
        echo2 "already cp ${DIR_APP}/mysql-connector/mysql-connector-j-8.0.33.jar ${DIR_APP}/hive/lib"
    fi

    # llap
    files=`ls ${DIR_APP}/conf/scripts.llap`
    for f in $files; do
        # backup_and_copy_file CHECK_FILE ORG_FILE SRC_FILE DST_PATH
        backup_and_copy_file "${DIR_APP}/hive/scripts/llap/yarn/$f.org" "${DIR_APP}/hive/scripts/llap/yarn/$f" "${DIR_APP}/conf/scripts.llap/$f" "${DIR_APP}/hive/scripts/llap/yarn/"
    done 

    # llap daemon 에서 zookeeper 에 자신의 상태를 등록할 때 hive 3.1.3 의 기본버전(3.4.6) 으로 zookeeper 3.7.0 에 접근 안됨
    echo2 "HEAD copy zookeeper for llap"
    # backup_and_copy_file CHECK_FILE ORG_FILE SRC_FILE DST_PATH
    hadoop_zookeeper_jar=`ls ${DIR_APP}/hadoop/share/hadoop/hdfs/lib/zookeeper-*.jar | grep -v jute | xargs basename`
    backup_and_copy_file "${DIR_APP}/hive/lib/${hadoop_zookeeper_jar}" "${DIR_APP}/hive/lib/zookeeper-3.4.6.jar" "${DIR_APP}/hadoop/share/hadoop/hdfs/lib/${hadoop_zookeeper_jar}" "${DIR_APP}/hive/lib/"
    echo2 "TAIL copy zookeeper for llap"

    # tez
    set_tez

    # https://issues.apache.org/jira/browse/HIVE-22915
    echo2 "HEAD for HIVE-22915"
    # backup_and_copy_file CHECK_FILE ORG_FILE SRC_FILE DST_PATH
    hadoop_guava_jar=`ls ${DIR_APP}/hadoop/share/hadoop/hdfs/lib/guava-*.jar | xargs basename`
    backup_and_copy_file "${DIR_APP}/hive/lib/${hadoop_guava_jar}" "${DIR_APP}/hive/lib/guava-19.0.jar" "${DIR_APP}/hadoop/share/hadoop/hdfs/lib/${hadoop_guava_jar}" "${DIR_APP}/hive/lib/"
    echo2 "TAIL for HIVE-22915"
}

function set_tez() {
    # merge llap-19Sep2024.tar.gz
    ${SCRIPT_HOME}/merge_file.sh ${DIR_APP}/admin/hive/llap/generated_llap/llap-19Sep2024.tar.gz.part ${DIR_APP}/admin/hive/llap/generated_llap/llap-19Sep2024.tar.gz

    # merge custom-tez-0.9.2-bin_with_hadoop_3.3.6.tar.gz
    ${SCRIPT_HOME}/merge_file.sh ${DIR_PKGS}/custom-tez-0.9.2-bin_with_hadoop_3.3.6.tar.gz.part ${DIR_PKGS}/custom-tez-0.9.2-bin_with_hadoop_3.3.6.tar.gz

    # hive 와 tez 호환성
    # hive 3.x - tez 0.9.2, 0.10.0, 0.10.1
    # hive 4.x - tez 0.10.2+
    # 그런데, tez 0.10.1 은 hadoop 3.1.x 와 호환성이 있어서 hadoop 부분 변경필요!!
    #get_pkg "https://dlcdn.apache.org/tez/0.9.2/apache-tez-0.9.2-bin.tar.gz" "apache-tez-0.9.2-bin" "tez"
    get_pkg "file://${DIR_PKGS}/custom-tez-0.9.2-bin_with_hadoop_3.3.6.tar.gz" "custom-tez-0.9.2-bin_with_hadoop_3.3.6" "tez"

    ##########
    # tomcat 
    # archive 로 옮겨짐
    #get_pkg "https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.91/bin/apache-tomcat-9.0.91.tar.gz" "apache-tomcat-9.0.91" "apache-tomcat"
    get_pkg "https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.91/bin/apache-tomcat-9.0.91.tar.gz" "apache-tomcat-9.0.91" "apache-tomcat"

    if [[ ! -d ${DIR_APP}/apache-tomcat/webapps.org ]]; then
        echo2 "cp -rf ${DIR_APP}/apache-tomcat/webapps ${DIR_APP}/apache-tomcat/webapps.org"
        cp -rf ${DIR_APP}/apache-tomcat/webapps ${DIR_APP}/apache-tomcat/webapps.org
    else
        echo2 "already exist ${DIR_APP}/apache-tomcat/webapps.org"
    fi

    rm_dirs="docs examples host-manager manager"
    for d in $rm_dirs; do
        if [[ -d ${DIR_APP}/apache-tomcat/webapps/$d ]]; then
            echo2 "rm -rf ${DIR_APP}/apache-tomcat/webapps/$d"
            rm -rf ${DIR_APP}/apache-tomcat/webapps/$d
        fi
    done

    ## for security of tomcat
    if [[ ! -d ${DIR_APP}/apache-tomcat/webapps/ROOT/backup ]]; then
        echo2 "mkdir ${DIR_APP}/apache-tomcat/webapps/ROOT/backup"
        mkdir ${DIR_APP}/apache-tomcat/webapps/ROOT/backup

        echo2 "mv ${DIR_APP}/apache-tomcat/webapps/ROOT/*.* ${DIR_APP}/apache-tomcat/webapps/ROOT/backup"
        mv ${DIR_APP}/apache-tomcat/webapps/ROOT/*.* ${DIR_APP}/apache-tomcat/webapps/ROOT/backup
        mv ${DIR_APP}/apache-tomcat/webapps/ROOT/WEB-INF ${DIR_APP}/apache-tomcat/webapps/ROOT/backup

        echo2 "cp -rf ${DIR_APP}/apache-tomcat/webapps/ROOT/backup/favicon.ico ${DIR_APP}/apache-tomcat/webapps/ROOT/"
        cp -rf ${DIR_APP}/apache-tomcat/webapps/ROOT/backup/favicon.ico ${DIR_APP}/apache-tomcat/webapps/ROOT/

        echo2 "cp -rf ${DIR_APP}/conf/conf.tomcat/index.jsp ${DIR_APP}/apache-tomcat/webapps/ROOT/"
        cp -rf ${DIR_APP}/conf/conf.tomcat/index.jsp ${DIR_APP}/apache-tomcat/webapps/ROOT/
    fi

    ## custom setting 
    files="logging.properties server.xml"
    for f in $files; do
        if [[ ! -f ${DIR_APP}/apache-tomcat/conf/$f.org ]]; then
            echo2 "cp -rf ${DIR_APP}/apache-tomcat/conf/$f ${DIR_APP}/apache-tomcat/conf/$f.org"
            cp -rf ${DIR_APP}/apache-tomcat/conf/$f ${DIR_APP}/apache-tomcat/conf/$f.org

            echo2 "cp -rf ${DIR_APP}/conf/conf.tomcat/$f ${DIR_APP}/apache-tomcat/conf/$f"
            cp -rf ${DIR_APP}/conf/conf.tomcat/$f ${DIR_APP}/apache-tomcat/conf/$f
        fi
    done


    ##########
    # tez-web-ui 
    get_pkg "https://repo1.maven.org/maven2/org/apache/tez/tez-ui/0.9.2/tez-ui-0.9.2.war" "tez-ui-0.9.2.war" "none"
    if [[ ! -d ${DIR_APP}/apache-tomcat/webapps/tez-ui ]]; then
        # create directory of tez-ui
        echo2 "mkdir -p ${DIR_APP}/apache-tomcat/webapps/tez-ui"
        mkdir -p ${DIR_APP}/apache-tomcat/webapps/tez-ui

        # extract war
        echo2 "tar -xf ${DIR_PKGS}/tez-ui-0.9.2.war -C ${DIR_APP}/apache-tomcat/webapps/tez-ui"
        tar -xf ${DIR_PKGS}/tez-ui-0.9.2.war -C ${DIR_APP}/apache-tomcat/webapps/tez-ui
    else
        echo2 "already exist ${DIR_APP}/apache-tomcat/webapps/tez-ui"
    fi

    ## custom setting 
    ### configs.env for tez 0.9.1-0.9.2
    ### configs.js for tez 0.10.1+
    files="configs.env configs.js"
    for f in $files; do
        if [[ -f ${DIR_APP}/apache-tomcat/webapps/tez-ui/config/$f && ! -f ${DIR_APP}/apache-tomcat/webapps/tez-ui/config/$f.org ]]; then
            echo2 "cp -rf ${DIR_APP}/apache-tomcat/webapps/tez-ui/config/$f ${DIR_APP}/apache-tomcat/webapps/tez-ui/config/$f.org"
            cp -rf ${DIR_APP}/apache-tomcat/webapps/tez-ui/config/$f ${DIR_APP}/apache-tomcat/webapps/tez-ui/config/$f.org

            echo2 "cp -rf ${DIR_APP}/conf/conf.tez-ui/$f ${DIR_APP}/apache-tomcat/webapps/tez-ui/config/$f"
            cp -rf ${DIR_APP}/conf/conf.tez-ui/$f ${DIR_APP}/apache-tomcat/webapps/tez-ui/config/$f
        fi
    done


    echo ""
    echo "Please Upload ${DIR_APP}/tez/share/tez.tar.gz to HDFS as hdfs"
    echo "lima> ./attach.sh data01"
    echo "[root@data01 /]# su - hdfs"
    echo "[hdfs@data01 ~]$ hdfs dfs -mkdir -p hdfs:///app/tez"
    echo "[hdfs@data01 ~]$ hdfs dfs -put /opt/tez/share/tez_with_hadoop_3.3.6-0.9.2.tar.gz hdfs:///app/tez/"
    echo ""
}

##### main 
PKG=""
IS_FORCE_DOWNLOAD="false"

while getopts "p:f" opt; do
    case $opt in
        p) PKG="$OPTARG"
           ;;
        f) IS_FORCE_DOWNLOAD="true"
           ;;
        *) help
           ;;
    esac
done

if [[ "${PKG}" == "" ]]; then
    help
fi

set_env

case "$PKG" in
    all)
        set_maven
        set_hadoop
        set_hive
        ;;
    maven)
        set_maven
        ;;
    hadoop)
        set_hadoop
        ;;
    hive)
        set_hive
        ;;
    tez)
        set_tez
        ;;
esac
