#!/bin/bash

bin=`which $0`
bin=`dirname ${bin}`
SCRIPT_HOME=`cd "$bin" > /dev/null; pwd`

function help() {
    echo "Usage)"
    echo "   $0 SPLIT_FILE_PREFIX TARGET_FILE"
    echo ""
    echo "   $0 app/admin/hive/llap/generated_llap/llap-19Sep2024.tar.gz.part app/admin/hive/llap/generated_llap/llap-19Sep2024.tar.gz"
    echo "   $0 app/pkgs/custom-tez-0.9.2-bin_with_hadoop_3.3.6.tar.gz.part app/pkgs/custom-tez-0.9.2-bin_with_hadoop_3.3.6.tar.gz"
    echo ""
    exit 1
}

function echo2() {
    echo "$@"
}

##### main
if [[ $# -ne 2 ]]; then
    help
    exit 1
fi

SPLIT_FILE_PREFIX="${1}"
TARGET_FILE="${2}"

if [[ -f ${TARGET_FILE} ]]; then
    echo2 "exist ${TARGET_FILE}"
    exit 2
fi

echo2 "cat ${SPLIT_FILE_PREFIX}.* > ${TARGET_FILE}"
cat ${SPLIT_FILE_PREFIX}.* > ${TARGET_FILE}
