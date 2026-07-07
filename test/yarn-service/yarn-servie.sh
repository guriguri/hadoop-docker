#!/bin/bash

function help() {
    echo "Usage)"
    echo "   $0 launch|destroy YARN_SERVICE_JSON"
    echo ""
    echo "   ex)"
    echo "   $0 launch date.json"
    echo "   $0 destroy date.json"
    echo "   $0 launch sleeper.json"
    echo "   $0 destroy sleeper.json"
    echo ""

    exit 1
}

if [[ $# -ne 2 ]]; then
    help
fi

cmd="${1}"
json_file="${2}"

service_name=`jq '.name' $json_file`

case "${cmd}" in
    launch)
        echo "yarn app -launch ${service_name} ${json_file}"
        yarn app -launch ${service_name} ${json_file}
        ;;
    destroy)
        echo "yarn app -destroy ${service_name}"
        yarn app -destroy ${service_name}
        ;;
    *)
        echo "Invalid command(${cmd})"
        echo ""
        help
        ;;
esac
