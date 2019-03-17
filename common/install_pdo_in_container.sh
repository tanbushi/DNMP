#!/bin/bash

# 以下操作是进入 php 的 docker 容器里执行的
cd /usr/local/bin
./docker-php-ext-install pdo_mysql
./docker-php-ext-install mysql
exit
