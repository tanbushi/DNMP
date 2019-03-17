#!/bin/bash

# 从安装模版目录里拷贝 docker 编排文件模板到挂载目录下
cp -f tpl/docker-compose.yml.tpl docker-compose.yml

# 根据 docker 编排模版自动生成 docker 编排文件
for key in ${!config[@]}
do
  echo $key
  sed -i "s/{{$key}}/${config[$key]}/g" docker-compose.yml
done
