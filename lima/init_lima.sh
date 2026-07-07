#!/bin/bash

bin=`which $0`
bin=`dirname ${bin}`
SCRIPT_HOME=`cd "$bin" > /dev/null; pwd`

if [[ ! -d /tmp/lima/logs ]]; then
    echo "mkdir -p /tmp/lima/logs"
    mkdir -p /tmp/lima/logs
    chmod 777 /tmp/lima/logs
else
    echo "exist /tmp/lima/logs"
    chmod 777 /tmp/lima/logs
fi

if [[ ! -d /tmp/lima/yarn ]]; then
    echo "mkdir -p /tmp/lima/yarn"
    mkdir -p /tmp/lima/yarn
    chmod 777 /tmp/lima/yarn
else
    echo "exist /tmp/lima/yarn"
    chmod 777 /tmp/lima/yarn
fi

if [[ ! -d /tmp/lima/app ]]; then
    parent_dir=`dirname ${SCRIPT_HOME}`
    echo "ln -s ${parent_dir}/app /tmp/lima/app"
    ln -s ${parent_dir}/app /tmp/lima/app
else
    echo "exist /tmp/lima/app"
fi
