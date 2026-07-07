#!/bin/bash

docker build --rm=true -t hadoop/base .

# 옵션 설명
## --rm: true|false. 이미지 생성에 성공하면 임시 컨테이너 삭제 여부
## --no-cache: true|false. 이전 빌드에서 생성된 캐시 사용 여부
#docker build --no-cache=true --rm=true -t hadoop/base .
