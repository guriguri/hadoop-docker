#!/bin/bash

function help() {
    echo "Usage $0 -u APP_OWNER -a APP_ID"  
    echo "  ex) $0 -u test -a application_1719819464502_0026"
    echo ""
}

APP_OWNER=""
APP_ID=""

while getopts "u:a:" opt; do
    case "$opt" in
        u) APP_OWNER="$OPTARG"
           ;;
        a) APP_ID="$OPTARG"
           ;;
        *) help
           exit 1
    esac
done

if [[ "${APP_OWNER}" == "" ]]; then
    echo "Invalid APP_OWNER(${APP_OWNER})"
    echo ""
    help
    exit 2
elif [[ "${APP_ID}" == "" ]]; then
    echo "Invalid APP_ID(${APP_ID})"
    echo ""
    help
    exit 3
fi

echo "yarn logs -appOwner ${APP_OWNER} -applicationId ${APP_ID} > ${APP_ID}.log"
yarn logs -appOwner ${APP_OWNER} -applicationId ${APP_ID} > ${APP_ID}.log
