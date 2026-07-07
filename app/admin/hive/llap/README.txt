1. llap_generate.sh 
- /tmp/lima/logs/llap 에 하기 파일을 생성함
.
├── Yarnfile
├── llap-19Sep2024.tar.gz
├── run.sh
└── stop.sh
- /opt 밑은 docker 에서 read only 로 마운트 되므로 파일을 생성할 수 없어서...

2. 나중에 변경된 파일들을 docker-compose 에 적용하기 위해서는 ${HOME}/app/admin/hive/llap/generated_llap 로 옮겨야 함!!
