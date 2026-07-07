#!/bin/sh

echo ">>>>> PUT index" 
curl -X PUT \
-H 'Content-Type: application/json' \
-d '{ "name" : "Test User" }' \
http://es.hadoop-local:9200/test_index/user/1?pretty=true -v

echo ">>>>> GET index" 
curl http://es.hadoop-local:9200/test_index/user/1?pretty=true -v

echo ">>>>> DELETE index" 
curl -X DELETE \
http://es.hadoop-local:9200/test_index?pretty=true -v
