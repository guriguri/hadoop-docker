#!/bin/bash

bin=`which $0`
bin=`dirname ${bin}`
SCRIPT_HOME=`cd "$bin" > /dev/null; pwd`

function help() {
    echo "usage) $0 ES_URL YARN_SERVICE_STATUS_JSON"
    echo "   ex)"
    echo "     for dev"
    echo "     $0 http://es.hadoop-local:9200/_bulk yarn_service_status_llaptest-result.json"
    echo ""
    echo "     for prd"
    echo "     $0 http://172.22.224.46:9202/_bulk yarn_service_status_llapdaas3-result.json"
    echo ""
    exit -1
}

function print_log() {
    contents="$@"
    echo "[`date +"%Y-%m-%d %H:%M:%S"`][$$] ${contents}"
}

if [ $# -ne 2 ]; then
    help
fi

ES_URL="$1"
INPUT_FILE="$2"

CMD_PYTHON=`which python3`
if [ "${CMD_PYTHON}" == "" ]; then
    CMD_PYTHON="/app/python3/bin/python3"
fi

function main()
{
    print_log "$CMD_PYTHON $SCRIPT_HOME/get_yarn_service_llap_daemon_status.py -e ${ES_URL} -f ${INPUT_FILE}"
    $CMD_PYTHON $SCRIPT_HOME/get_yarn_service_llap_daemon_status.py -e ${ES_URL} -f ${INPUT_FILE}
}

# Main ----------
main
