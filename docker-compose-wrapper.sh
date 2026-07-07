#!/bin/bash

bin=`which $0`
bin=`dirname ${bin}`
SCRIPT_HOME=`cd "$bin" > /dev/null; pwd`

function help() {
    echo "Usage)"
    echo "   $0 [-m MODES] -c up|up-d|down"
    echo " -m: MODES"
    echo "     separator is comma(,)"
    echo "     default: mysql, es, kibana, zk01, hdfs, yarn, hive, data01, etc01"
    echo ""
    echo " -c: COMMAND"
    echo "     up: up"
    echo "     up-d: up as daemon mode"
    echo "     down: down"
    echo ""
    echo "   ex)"
    echo "   $0 -c up-d"
    echo "   $0 -c down"
    echo ""
}

declare -A DOCKER_COMPOSE_FILE_ARRAY
DOCKER_COMPOSE_FILE_ARRAY['default']="docker-compose.yml"

MODES=""
CMD=""
MODES_LIST=""
DOCKER_COMPOSE_FILES=""

while getopts "m:c:" opt; do
    case "$opt" in
        m) MODES="$OPTARG"
           ;;
        c) CMD="$OPTARG"
           ;;
        *) help
           exit 1
           ;;
    esac
done

if [[ "${MODES}" != "" ]]; then
    MODES_LIST=`echo ${MODES} | sed 's/,/\n/g' | grep -v ^#`
fi

DOCKER_COMPOSE_FILES="-f ${DOCKER_COMPOSE_FILE_ARRAY['default']}"
for f in ${MODES_LIST}; do
    if [[ "${f}" == "default" ]]; then
        continue
    fi

    DOCKER_COMPOSE_FILES="${DOCKER_COMPOSE_FILES} -f ${DOCKER_COMPOSE_FILE_ARRAY[$f]}"
done

if [[ "${DOCKER_COMPOSE_FILES}" == "" ]]; then
    echo "Invalid MODES(${MODES})"
    help
    exit 2
elif [[ "${CMD}" == "" ]]; then
    echo "Invalid CMD(${CMD})"
    help
    exit 3
fi

case "${CMD}" in
    up)
#        echo "docker-compose ${DOCKER_COMPOSE_FILES} up"
        docker-compose ${DOCKER_COMPOSE_FILES} up
        ;;
    up-d)
#        echo "docker-compose ${DOCKER_COMPOSE_FILES} up -d"
        docker-compose ${DOCKER_COMPOSE_FILES} up -d
        ;;
    down)
#        echo "docker-compose ${DOCKER_COMPOSE_FILES} down"
        docker-compose ${DOCKER_COMPOSE_FILES} down
        ;;
    *)
        help
        exit 4
        ;;
esac
