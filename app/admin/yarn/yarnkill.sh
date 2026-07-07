#!/bin/bash

function help() {
    echo "Usage $0 -a APP_ID"  
    echo "  ex) $0 -a application_1719819464502_0026"
    echo ""
}

APP_OWNER=""
APP_ID=""

while getopts "a:" opt; do
    case "$opt" in
        a) APP_ID="$OPTARG"
           ;;
        *) help
           exit 1
    esac
done

if [[ "${APP_ID}" == "" ]]; then
    echo "Invalid APP_ID(${APP_ID})"
    echo ""
    help
    exit 2
fi

LOG="yarnkill-`date +%Y%m%d`.log"

echo "yarn app -kill ${APP_ID}" >> $LOG
yarn app -kill ${APP_ID} 2>&1 >> $LOG
