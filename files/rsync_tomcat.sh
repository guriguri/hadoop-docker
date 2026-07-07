#!/bin/bash

# 한 docker 에서 먼저 mount 한 디렉토리의 파일들을 다른 docker 에서 command 단계에서 접근을 못하므로 내부 디렉토리로 rsync 하고 읽어야 함!! 
DIRS="apache-tomcat"

DIR_SRC_PREFIX="/opt"
DIR_DST_PREFIX="/app"

for d in $DIRS; do
    if [[ ! -d ${DIR_DST_PREFIX}/$d ]]; then
        echo "mkdir -p ${DIR_DST_PREFIX}/$d"
        mkdir -p ${DIR_DST_PREFIX}/$d
    fi

    echo "START rsync -az ${DIR_SRC_PREFIX}/$d/ ${DIR_DST_PREFIX}/$d/"
    rsync -az ${DIR_SRC_PREFIX}/$d/ ${DIR_DST_PREFIX}/$d/
    echo "END rsync -az ${DIR_SRC_PREFIX}/$d/ ${DIR_DST_PREFIX}/$d/"

    echo "START change permission directory(o+rwx), file(o+rx)"
    find ${DIR_DST_PREFIX}/$d -type d -exec chmod o+rwx {} \;
    find ${DIR_DST_PREFIX}/$d -type f -exec chmod o+r {} \;
    find ${DIR_DST_PREFIX}/$d -type f -name '*.sh' -exec chmod o+x {} \;
    echo "END change permission directory(o+rwx), file(o+rx)"
done
