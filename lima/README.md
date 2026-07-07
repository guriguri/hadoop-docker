## lima 사용법

### Requirement
* lima

### 설치
```
host> brew install lima
```

### 기본 명령어
#### instance 시작 (instance 없을 시 생성 포함)
```
# default instance 시작 (cpu: 4, mem: 4GB)
host> limactl start

# default 에 cpu, memory 변경해서 instance 시작
host> limactl start --set='.cpus = 6 | .memory = "10GiB"'

# 변경된 YAML 로 instance 시작
host> limactl start INSTANCE명.yaml

# instance 시작시 /tmp/lima 를 자동 생성해주기 위해서 wrapper script 사용
host> ./limawrapper.sh
Usage)
   ./limawrapper.sh CMD

   CMD:
      start
      Other commands is an bypass to limactl
```

#### instance 중지
```
# instance 중지 (INSTANCE명 없을 시 default)
host> limactl stop [INSTANCE명]
```

#### instance 조회
```
host> limactl ls
NAME       STATUS     SSH                VMTYPE    ARCH      CPUS    MEMORY    DISK      DIR
default    Running    127.0.0.1:60022    qemu      aarch64    6       10GiB     100GiB    ~/.lima/default
test       Running    127.0.0.1:55052    qemu      aarch64    6       10GiB     100GiB    ~/.lima/hojoon
```

#### instance 삭제
```
# instance 삭제 (INSTANCE명 없을 시 default)
host> limactl delete [INSTANCE명]
```

#### instance 접속
```
# default 일 경우
host> lima

# INSTANCE명 있을 경우
host> limactl shell INSTANCE명
```

### 환경설정
#### PKG 설치
```
# docker-compose 사용을 위해서 docker-compose 설치
# ifconfig, netstat 등 사용을 위해서 net-tools 설치
lima> sudo apt install docker-compose net-tools
```

#### host <-> lima <-> container 간 공유 설정
* host <-> lima 간 공유는 INSTANCE명.yaml 의 mount 부분

```
:
mounts:
- location: "~"
- location: "/tmp/lima"
  writable: true
:
```
* lima <-> container 간 공유는 docker-compose.yml 의 volumes 부분

```
:
  hive:
:
  volumes:
    - /tmp/lima/logs:/data/hive/logs
    - ./app:/opt
:
```
* lima/init_lima.sh 로 /tmp/lima/logs, /tmp/lima/yarn, /tmp/lima/app 을 생성해서 host <-> lima <-> container 와 공유

```
host> lima/init_lima.sh
host> ls -al /tmp/lima
total 0
drwxr-xr-x   5 1002635  wheel  160  5 28 19:04 .
drwxrwxrwt  15 root     wheel  480  5 28 17:20 ..
lrwxr-xr-x   1 1002635  wheel   57  5 28 19:04 app -> <HOME_절대경로(예:/app/hadoop-docker)>/app
drwxrwxrwx   2 1002635  wheel   64  5 28 18:54 logs
drwxrwxrwx   2 1002635  wheel   64  5 28 18:54 yarn
```
* lima <-> container 파일 복사

```
# lima 의 경우 ~/, /tmp 같은 곳을 지정해야 복사할 수 있음
lima> docker cp 32162f4ebeb0:/dir_inside_container/image1.jpg /tmp/lima/image1.jpg
lima> docker cp /tmp/lima/image1.jpg  32162f4ebeb0:/dir_inside_container/image1.jpg
```
