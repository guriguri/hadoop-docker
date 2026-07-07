#!/bin/bash

bin=`which $0`
bin=`dirname ${bin}`
SCRIPT_HOME=`cd "$bin" > /dev/null; pwd`

function help() {
    echo "Usage)"
    echo "   $0 CMD"
    echo ""
    echo "   CMD:"
    echo "      start|list|stop|help|..."
    echo "      Other commands is an bypass to limactl"
    echo ""
}

cmd="$1"

case "${cmd}" in
    start)
        echo "pre-process ${SCRIPT_HOME}/lima/init_lima.sh"
        ${SCRIPT_HOME}/lima/init_lima.sh
        echo ""
        ;;
    help)
        help
        ;;
    *)
        ;;
esac

if [[ "${cmd}" == "" ]]; then
    help
    exit 1
fi

limactl $@
