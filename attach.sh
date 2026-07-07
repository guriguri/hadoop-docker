#!/bin/bash

function docker_attach() {
    docker_name=$1
    docker exec -it ${docker_name} /bin/bash
}

function docker_run_base() {
    is_running_base=`docker ps -f name=base | grep -v NAMES | wc -l`
    if [[ "${is_running_base}" == "0" ]]; then
        is_stop_base=`docker ps -a -f name=base | grep -v NAMES | wc -l`
        if [[ "${is_stop_base}" == "1" ]]; then
            echo "docker restart base"
            docker start base
        else
            echo "docker start base"
            docker run -it -v /tmp/lima/app:/app -h base --name base -dit hadoop/base
        fi
    fi
}

case "$1" in
    base)
        docker_run_base
        docker_attach $1
        ;;
    nn)
        docker_attach $1
        ;;
    yarn)
        docker_attach $1
        ;;
    hive)
        docker_attach $1
        ;;
    data01)
        docker_attach $1
        ;;
    etc01)
        docker_attach $1
        ;;
    zk01)
        docker_attach $1
        ;;
    mysql)
        docker_attach $1
        ;;
    es)
        docker_attach $1
        ;;
    kibana)
        docker_attach $1
        ;;
    *)
        echo "Usage: $0 base|nn|yarn|hive|data01|etc01|zk01|mysql|es|kibana"
esac
