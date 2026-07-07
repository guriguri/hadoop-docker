#!/bin/bash

bin=`which $0`
bin=`dirname ${bin}`
SCRIPT_HOME=`cd "$bin" > /dev/null; pwd`

function help() {
    echo "usage) $0 LLAP_NAME ES_URL RESULT_JSON"
    echo "   ex)"
    echo "     for dev"
    echo "     $0 llaptest http://es.hadoop-local:9200/_bulk yarn_service_status_llaptest-result.json"
    echo ""
    exit -1
}

function print_log() {
    contents="$@"
    echo "[`date +"%Y-%m-%d %H:%M:%S"`][$$] ${contents}"
}

if [ $# -ne 3 ]; then
    help
fi
    
LLAP_NAME="$1"
ES_URL="$2"
RESULT_JSON="$3"

CMD_PYTHON=`which python3`
if [ "${CMD_PYTHON}" == "" ]; then
    CMD_PYTHON="/app/python3/bin/python3"
fi

DATE=`date +"%Y%m%d"`

function main() {
    cmd="yarn app -status ${LLAP_NAME} > ${RESULT_JSON}"
    eval "${cmd}"
    print_log "${cmd}"

    print_log "$CMD_PYTHON $SCRIPT_HOME/get_yarn_service_status.py -e ${ES_URL} -f ${RESULT_JSON}"
    $CMD_PYTHON $SCRIPT_HOME/get_yarn_service_status.py -e ${ES_URL} -f ${RESULT_JSON}
}

# Main ----------
main
