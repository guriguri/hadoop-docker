# -*- coding: utf-8 -*-

import sys
import argparse
import json
import subprocess
import logging
import uuid
import datetime
from time import sleep

IS_TEST = None

TIMEOUT = '10'
YARN_SERVICE_STATUS_JSON = None
ES_URL = None
ES_INDEX = 'admin.yarn_service_status'
ES_ID_PREFIX = "yarn_service_status-"

def help():
    print("""
    Usage) get_yarn_service_status.py -e ES_URL -f YARN_SERVICE_STATUS_JSON [-t]
       ex)
         for dev
         python3 get_yarn_service_status.py -e http://es.hadoop-local:9200/_bulk -f yarn_service_status_llaptest-result.json

         for prd
         python3 get_yarn_service_status.py -e http://172.22.224.46:9202/_bulk -f yarn_service_status_llapdaas3-result.json
    """)


def set_params():
    global ES_URL, YARN_SERVICE_STATUS_JSON, IS_TEST

    # set param info
    parser = argparse.ArgumentParser()
    parser.add_argument("-e", "--es_url", help="es url", default=None)
    parser.add_argument("-f", "--file", help="json of yarn service status", default=None)
    parser.add_argument("-t", "--test", help="test flag", default=False, action="store_true")
    pargs = parser.parse_args()

    ES_URL = pargs.es_url
    YARN_SERVICE_STATUS_JSON = pargs.file
    IS_TEST = pargs.test	

    if ES_URL is None or YARN_SERVICE_STATUS_JSON is None:
        help()
        exit(1)


def getLogger(level=logging.INFO, format=None):
    if format is None:
        format = '%(asctime)s [%(process)d:%(threadName)s][%(module)s:%(lineno)d] %(levelname)s %(funcName)s() %(message)s'

    formatter = logging.Formatter(format)

    rootLogger = logging.getLogger()

    consoleHandler = logging.StreamHandler()
    consoleHandler.setFormatter(formatter)

    rootLogger.addHandler(consoleHandler)
    rootLogger.setLevel(level)

    return rootLogger


logger = getLogger()

def read_file(file_path):
    json_data = None

    try:
        with open(file_path, "r", encoding='utf-8') as json_file:
            json_data = json.load(json_file)
        logger.debug('json_data, %s', json.dumps(json_data, indent=4))
    except Exception as e:
        logger.error(f'file={file_path}, e=%s', log_substring(str(e)), exc_info=True)
        json_data = {'status': None}

    return json_data

def log_substring(msg, str_len=1000):
    if len(msg) > str_len:
        return msg[:str_len]
    return msg

def send_es(llap_name, desired, live, url, index=ES_INDEX, timeout=TIMEOUT, headers={'Content-Type': 'application/json'}):
    now = datetime.datetime.now()
    date_iso8601 = now.astimezone().isoformat(timespec="seconds")

    data = {}
    data['name'] = llap_name
    data['desired'] = desired
    data['live'] = live
    data['date_iso8601'] = date_iso8601

    uuid4 = str(uuid.uuid4())
    body = '{"index":{"_index":"' + index + '","_type":"metrics","_id":"' + ES_ID_PREFIX + uuid4 + '"}}\n'
    body += json.dumps(data) + '\n'

    res = None

    try:
        cmds=['curl', '-s', '--connect-timeout', timeout, '-XPUT', url, '-H', 'Content-Type: application/json', '-d', body]
        res = subprocess.check_output(cmds, universal_newlines=True, stderr=subprocess.STDOUT)

        log_msg = log_substring(body)
        logger.info(f'url={url}, index={index}, body={log_msg}, res={res}')

        return True
    except:
        logger.error(f'url={url}, index={index}, body={body}, res={res}', exc_info=True)

        return False

def main():
    set_params()

    logger.info(f'ES_URL={ES_URL}, YARN_SERVICE_STATUS_JSON={YARN_SERVICE_STATUS_JSON}, IS_TEST={IS_TEST}')

    json_data = read_file(YARN_SERVICE_STATUS_JSON)

# example yarn service status structure
# {
#   "name": "llaptest",
#   "id": "application_1725616236869_0021",
#   "lifetime": -1,
#   "components": [
#   {
#     :
#     "containers": [
#        {
#          "id": "container_1725616236869_0021_01_000002",
#          "ip": "192.168.48.9",
#          "hostname": "data01",
#          "state": "READY", # "RUNNING_BUT_UNREADY" daemon 이 강제 종료돼서 재실행중일 때
#          "launch_time": 1726044769947,
#          "bare_host": "data01",
#          "component_instance_name": "llap-0"
#        }
#      ],
#     :
#   },
#   "state": "STABLE", # "STARTED" daemon 이 강제 종료돼서 재실행중일 때
# }

    now = datetime.datetime.now()
    date_iso8601 = now.astimezone().isoformat(timespec="seconds")

    try:
        name = json_data['name']
        container_size = -1
        if json_data['components'] and len(json_data['components']) > 0:
            container_size = json_data['components'][0]['number_of_containers']
            logger.info(f'json_data[components][0][number_of_containers]={container_size}')
        else:
            logger.info(f'json_data[components] or len(json_data[components]) == 0')
    except:
        logger.error('json_data, %s', json.dumps(json_data, indent=4), exc_info=True)
        return

    if container_size > 0:
        count = {}
        for container in json_data['components'][0]['containers']:
            state = container['state']

            if state not in count:
                count[state] = 0

            count[state] += 1
        logger.info(f'name={name}, count={count}')
        if 'READY' in count:
            ready_count = count['READY']
        else:
            ready_count = 0


    # send_es
    if not IS_TEST:
        send_es(llap_name=name, desired=container_size, live=ready_count, url=ES_URL)

if __name__ == "__main__":
    logger.info('>>>>> START, get_yarn_service_status.py')
    main()
    logger.info('<<<<< END, get_yarn_service_status.py')
