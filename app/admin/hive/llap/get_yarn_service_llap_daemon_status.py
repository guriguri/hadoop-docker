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
ES_INDEX = 'admin.yarn_service_status_daemons'
ES_ID_PREFIX = "yarn_service_status_daemon-"
TPL_DAEMON_HOST_URL = "http://%HOSTNAME%:8042"

def help():
    print("""
    Usage) get_yarn_service_llap_daemon_status.py -e ES_URL -f YARN_SERVICE_STATUS_JSON [-t]
       ex)
         for dev
         python3 get_yarn_service_llap_daemon_status.py -e http://es.hadoop-local:9200/_bulk -f yarn_service_status_llaptest-result.json

         for prd
         python3 get_yarn_service_llap_daemon_status.py -e http://172.22.224.46:9202/_bulk -f yarn_service_status_llapdaas3-result.json
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

def send_es(daemons=[], url=ES_URL, index=ES_INDEX, timeout=TIMEOUT, headers={'Content-Type': 'application/json'}):
    if not daemons:
        logger.info('daemons is an empty')
        return True
    
    body = ''

    for daemon in daemons:
       uuid4 = str(uuid.uuid4())
       body += '{"index":{"_index":"' + index + '","_type":"metrics","_id":"' + ES_ID_PREFIX + uuid4 + '"}}\n'
       body += json.dumps(daemon) + '\n'

    res = None

    try:
        cmds=['curl', '-s', '--connect-timeout', TIMEOUT, '-XPUT', url, '-H', 'Content-Type: application/json', '-d', body]
        res = subprocess.check_output(cmds, universal_newlines=True, stderr=subprocess.STDOUT)

        log_msg = log_substring(body)
        logger.info(f'url={url}, index={index}, body={log_msg}, res={res}')

        return True
    except:
        logger.error(f'url={url}, index={index}, body={body}, res={res}', exc_info=True)

        return False

def get_bean(jmx_json, name):
    beans = []

    for bean in jmx_json['beans']:
        if bean['name'].startswith(name):
            beans.append(bean)

    if beans:
        return beans[-1]
    else:
        return beans

# see: http://데이터노드:15002/js/metrics.js
#{
#    :
#    "GcTimeMillis": 132104305,
#    :
#    "MemHeapMaxM": 6127.0,
#    "MemHeapUsedM": 3099.8206,
#    :
#    "name": "Hadoop:service=LlapDaemon,name=JvmMetrics",
#    :
#    "tag.Hostname": "데이터노드",
#    :
#},
#llap.model.JvmMetrics = new function() {
#   this.name = "Hadoop:service=LlapDaemon,name=JvmMetrics";
#   this.heap_used = 0;
#   this.heap_max = 0;
#   this.heap_rate = trendlist(50);
#   this.gc_times = trendlist(50);
#   this.old_gc = 0;
#   this.push = function(jmx) {
#      var bean = jmxbean(jmx, this.name);
#      this.hostname = bean["tag.Hostname"];
#      this.heap_max = bean["MemHeapMaxM"];
#      this.heap_used = bean["MemHeapUsedM"];
#      this.heap_rate.add((this.heap_used*100.0)/this.heap_max);
#      var new_gc = (bean["GcTimeMillis"]/ 1000.0);
#      if (this.old_gc != 0) {
#         this.gc_times.add((new_gc - this.old_gc) / 1000.0);
#      }
#      this.old_gc = new_gc;
#   }
#   return this;
#}
def get_jvm_metrics(result, jmx_json):
    if result is None:
        result = {}

    bean = get_bean(jmx_json, 'Hadoop:service=LlapDaemon,name=JvmMetrics')
    if bean:
        result['hostname'] = bean['tag.Hostname']
        result['heap_max_mb'] = bean['MemHeapMaxM']
        result['heap_used_mb'] = bean['MemHeapUsedM']
        result['heap_rate'] = result['heap_used_mb'] * 100.0 / result['heap_max_mb']
        result['gc_time_sec'] = bean['GcTimeMillis'] / 1000.0

    return result

# see: http://데이터노드:15002/js/metrics.js
#{
#    :
#    "CacheCapacityTotal": 1073741824,
#    "CacheCapacityUsed": 0,
#    :
#    "CacheHitRatio": 0.0,
#    :
#    "CacheReadRequests": 0,
#    :
#    "name": "Hadoop:service=LlapDaemon,name=LlapDaemonCacheMetrics-데이터노드",
#    :
#},
#llap.model.LlapDaemonCacheMetrics = new function() {
#   this.name = "Hadoop:service=LlapDaemon,name=LlapDaemonCacheMetrics";
#   this.hit_rate = trendlist(50);
#   this.fill_rate = trendlist(50);
#   this.push = function(jmx) {
#      var bean = jmxbean(jmx, this.name);
#      if (bean) {
#        this.cache_max = bean["CacheCapacityTotal"]/(1024*1024);
#        this.cache_used = bean["CacheCapacityUsed"]/(1024*1024);
#        this.cache_reqs = bean["CacheReadRequests"];
#        this.fill_rate.add((this.cache_used*100.0)/this.cache_max);
#        this.hit_rate.add(bean["CacheHitRatio"]*100.0);
#      } else {
#        this.cache_max = -1;
#        this.cache_used = -1;
#        this.cache_reqs = -1;
#        this.fill_rate.add(0);
#        this.hit_rate.add(-1);
#      }
#   }
#   return this;
#}
def get_cache_metrics(result, jmx_json):
    if result is None:
        result = {}

    # set cache_metrics
    bean = get_bean(jmx_json, 'Hadoop:service=LlapDaemon,name=LlapDaemonCacheMetrics')
    if bean:
        result['cache_max_mb'] = bean['CacheCapacityTotal'] / (1024 * 1024)
        result['cache_used_mb'] = bean['CacheCapacityUsed'] / (1024 * 1024)
        result['cache_reqs'] = bean['CacheReadRequests']
        result['cache_rate'] = result['cache_used_mb'] * 100.0 / result['cache_max_mb']
        result['cache_hit_rate'] = bean['CacheHitRatio'] * 100.0

    return result

# see: http://데이터노드:15002/js/metrics.js
#{
#    :
#    "ExecutorsStatus": [],
#    :
#    "NumExecutors": 2,
#    :
#    "name": "Hadoop:service=LlapDaemon,name=LlapDaemonInfo"
#},
#llap.model.LlapDaemonInfo = new function() {
#   this.name = "Hadoop:service=LlapDaemon,name=LlapDaemonInfo";
#   this.active_rate = trendlist(50);
#   this.push = function(jmx) {
#      var bean = jmxbean(jmx, this.name);
#      this.executors = bean["NumExecutors"];
#      this.active = bean["ExecutorsStatus"];
#      this.active_rate.add(this.active.length);
#   }
#}
def get_executors(result, jmx_json):
    if result is None:
        result = {}

    # set executors
    bean = get_bean(jmx_json, 'Hadoop:service=LlapDaemon,name=LlapDaemonInfo')
    if bean:
        result['executors'] = bean['NumExecutors']
        result['executors_active'] = len(bean['ExecutorsStatus'])

    return result

# see: http://데이터노드:15002/js/metrics.js
#{
#    :
#    "ExecutorNumQueuedRequests": 0,
#    :
#    "ExecutorTotalPreemptionTimeLost": 15061749,
#    :
#    "ExecutorTotalRequestsHandled": 357107,
#    :
#    "name": "Hadoop:service=LlapDaemon,name=LlapDaemonExecutorMetrics-데이터노드",
#    :
#},
#llap.model.LlapDaemonExecutorMetrics = new function() {
#   this.name = "Hadoop:service=LlapDaemon,name=LlapDaemonExecutorMetrics";
#   this.queue_rate = trendlist(50);
#   this.push = function(jmx) {
#      var bean = jmxbean(jmx, this.name);
#      this.queue_rate.add(bean["ExecutorNumQueuedRequests"] || 0);
#      this.lost_time = bean["ExecutorTotalPreemptionTimeLost"] || 0;
#      this.num_tasks = bean["ExecutorTotalRequestsHandled"];
#      this.interrupted_tasks = bean["ExecutorTotalInterrupted"] || 0;
#      this.failed_tasks = bean["ExecutorTotalExecutionFailure"] || 0;
#   }
#   return this;
#}
def get_executor_metrics(result, jmx_json):
    if result is None:
        result = {}

    # set executors
    bean = get_bean(jmx_json, 'Hadoop:service=LlapDaemon,name=LlapDaemonExecutorMetrics')
    if bean:
        result['queue_rate'] = 0
        if 'ExecutorNumQueuedRequests' in bean.keys():
            result['queue_rate'] = bean['ExecutorNumQueuedRequests']

        result['total_lost_time_sec'] = 0.0
        if 'ExecutorTotalPreemptionTimeLost' in bean.keys():
            result['total_lost_time_sec'] = bean['ExecutorTotalPreemptionTimeLost'] / 1000.0

        result['total_tasks'] = 0
        if 'ExecutorTotalRequestsHandled' in bean.keys():
            result['total_tasks'] = bean['ExecutorTotalRequestsHandled']

        result['total_interrupted_tasks'] = 0
        if 'ExecutorTotalInterrupted' in bean.keys():
            result['total_interrupted_tasks'] = bean['ExecutorTotalInterrupted']

        result['total_failed_tasks'] = 0
        if 'ExecutorTotalExecutionFailure' in bean.keys():
            result['total_failed_tasks'] = bean['ExecutorTotalExecutionFailure']

    return result

def get_daemon(hostUrl):
    daemon = {}
    url = hostUrl.replace('8042', '15002') + '/jmx'
    res = None

    try:
        if IS_TEST:
            cmds=['cat', 'llap-daemon-jmx.json']
        else:
            cmds=['curl', '-s', '--connect-timeout', TIMEOUT, url, '-H', 'Content-Type: application/json']

        res = subprocess.check_output(cmds, universal_newlines=True, stderr=subprocess.STDOUT)

        # convert string to json 
        jmx_json = json.loads(res)

        # get jvm metrics
        get_jvm_metrics(daemon, jmx_json);

        # get cache metrics
        get_cache_metrics(daemon, jmx_json);

        # get executors
        get_executors(daemon, jmx_json);

        # get executor_metrics
        get_executor_metrics(daemon, jmx_json);

        if 'queue_rate' in daemon.keys() and 'executors_active' in daemon.keys():
            daemon['executing_queuing_tasks'] = daemon['queue_rate'] + daemon['executors_active']

        logger.info(f'url={url}, daemon={daemon}')

    except subprocess.CalledProcessError as e:
        logger.error(f'cmds={cmds}, e.code=%d, e.msg=%s', e.returncode, log_substring(e.output), exc_info=True)
    except:
        logger.error(f'cmds={cmds}, res={res}', exc_info=True)

    return daemon

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

    now = datetime.datetime.now() - datetime.timedelta(minutes=1)
    date_iso8601 = now.astimezone().isoformat(timespec="seconds")
    daemons = []

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
        for container in json_data['components'][0]['containers']:
            state = container['state']

            if state != 'READY':
                logger.info('SKIP, state != READY, container=%s', json.dumps(container))
                continue

            hostUrl = TPL_DAEMON_HOST_URL.replace('%HOSTNAME%', container['hostname'])

            daemon = get_daemon(hostUrl)

            if len(daemon) > 0:
                daemon['name'] = name
                daemon['date_iso8601'] = date_iso8601

                daemons.append(daemon)

            if daemons and len(daemons) % 10 == 0:
                logger.info('sleep(3) because daemons.size=%d', len(daemons))
                sleep(1)

    # send_es
    if not IS_TEST:
        send_es(daemons=daemons, url=ES_URL)

if __name__ == "__main__":
    logger.info('>>>>> START, get_yarn_service_llap_daemon_status.py')
    main()
    logger.info('<<<<< END, get_yarn_service_llap_daemon_status.py')
