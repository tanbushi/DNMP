#!/bin/bash

export ROOT_DIR="/dockers"    # 项目发布目录的上一级目录

. config.sh      # 引入配置文件脚本
. common/create_yml.sh  # 引入创建 docker-compose.yml 文件的脚本

# 卸载 docker
docker-compose down
