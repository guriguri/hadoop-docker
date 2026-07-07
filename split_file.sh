#!/bin/bash

bin=`which $0`
bin=`dirname ${bin}`
SCRIPT_HOME=`cd "$bin" > /dev/null; pwd`

function help() {
    echo "Usage)"
    echo "   $0 SPLIT_MB_SIZE FILE_TO_SPLIT"
    echo ""
    echo "   $0 45 app/admin/hive/llap/generated_llap/llap-19Sep2024.tar.gz"
    echo "   $0 45 app/pkgs/custom-tez-0.9.2-bin_with_hadoop_3.3.6.tar.gz"
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

SPLIT_MB_SIZE="${1}"
FILE_TO_SPLIT="${2}"

echo2 "split -d -b ${SPLIT_MB_SIZE}m ${FILE_TO_SPLIT} ${FILE_TO_SPLIT}.part."
split -d -b ${SPLIT_MB_SIZE}m ${FILE_TO_SPLIT} ${FILE_TO_SPLIT}.part.
