#!/bin/bash

function waitForIt()
{
    local serviceport=$1
    local service=${serviceport%%:*}
    local port=${serviceport#*:}
    local retry_seconds=5
    local max_retry=100
    let i=1

    nc -z $service $port
    result=$?

    until [ $result -eq 0 ]; do
        echo "retry_count=$i, ${service}:${port} is not available yet."
        if [[ $i == $max_retry ]]; then
            echo "retry_count=$i, ${service}:${port} is not available. give up retries."
            exit 1
        fi

        let "i++"
        sleep $retry_seconds

        nc -z $service $port
        result=$?
    done
    echo "retry_count=$i, $service:${port} is available."
}

for i in ${CHECK_SERVER_PORTS[@]}
do
    waitForIt ${i}
done

exit 0
