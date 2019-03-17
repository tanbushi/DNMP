#!/bin/bash

export ROOT_DIR="/dockers"    # 项目发布目录的上一级目录

. config.sh      # 引入配置文件脚本
. common/create_yml.sh  # 引入创建 docker-compose.yml 文件的脚本

project_name=${config["project_name"]}      # 项目名称
test_site_name=${config["test_site_name"]}  # 测试站点名称
prod_site_name=${config["prod_site_name"]}  # 生产站点名称

# 在主机上创建相关挂载目录，会在安装时挂载到 docker 上
mkdir -p $ROOT_DIR/$project_name/$test_site_name/www       # 测试站点页面目录
mkdir -p $ROOT_DIR/$project_name/$prod_site_name/www       # 生产站点页面目录
mkdir -p $ROOT_DIR/$project_name/nginx/conf.d              # nginx 配置目录
mkdir -p $ROOT_DIR/$project_name/nginx/ssl                 # ssl 证书文件目录

# 从安装模版目录里拷贝相关模板到挂载目录下
cp -f tpl/index_1.html.tpl  $ROOT_DIR/$project_name/$test_site_name/www/index.html
cp -f tpl/index_2.html.tpl  $ROOT_DIR/$project_name/$prod_site_name/www/index.html
cp -f tpl/index_1.php.tpl   $ROOT_DIR/$project_name/$test_site_name/www/index.php
cp -f tpl/index_2.php.tpl   $ROOT_DIR/$project_name/$prod_site_name/www/index.php
cp -f tpl/testdb_1.php.tpl  $ROOT_DIR/$project_name/$test_site_name/www/testdb.php
cp -f tpl/testdb_2.php.tpl  $ROOT_DIR/$project_name/$prod_site_name/www/testdb.php
cp -f tpl/default.conf.tpl  $ROOT_DIR/$project_name/nginx/conf.d/default.conf

# 根据模版自动生成相应文件
for key in ${!config[@]}
do
  sed -i "s/{{$key}}/${config[$key]}/g" $ROOT_DIR/$project_name/$test_site_name/www/index.html
  sed -i "s/{{$key}}/${config[$key]}/g" $ROOT_DIR/$project_name/$prod_site_name/www/index.html
  sed -i "s/{{$key}}/${config[$key]}/g" $ROOT_DIR/$project_name/$test_site_name/www/index.php
  sed -i "s/{{$key}}/${config[$key]}/g" $ROOT_DIR/$project_name/$prod_site_name/www/index.php
  sed -i "s/{{$key}}/${config[$key]}/g" $ROOT_DIR/$project_name/$test_site_name/www/testdb.php
  sed -i "s/{{$key}}/${config[$key]}/g" $ROOT_DIR/$project_name/$prod_site_name/www/testdb.php
  sed -i "s/{{$key}}/${config[$key]}/g" $ROOT_DIR/$project_name/nginx/conf.d/default.conf
done

# 将安装源 ssl 目录里的证书文件分发到对应的挂载目录下
cp -f ssl/*.* $ROOT_DIR/$project_name/nginx/ssl/.
cp -f ssl/*.* $ROOT_DIR/$project_name/nginx/ssl/.

#安装 docker
docker-compose up -d

#向测试站点的 php 容器里安装 PDO 扩展
echo "往 $project_name_$test_site_name 的php容器里安装 PDO扩展..."
docker cp common/install_pdo_in_container.sh ${project_name}_${test_site_name}_php:/var/$project_name/$test_site_name/. # 将 pdo 安装脚本文件由属主机拷入 php 容器里的/var/homework_test 目录下
docker exec -i ${project_name}_${test_site_name}_php bash /var/$project_name/$test_site_name/install_pdo_in_container.sh # 在 php 容器里运行 pdo 脚本，安装 mysq 的 pdo 驱动
docker restart ${project_name}_${test_site_name}_php # 重启 php 容器里的 php 服务
echo "往php容器里安装 PDO扩展结束！"

#向生产站点的 php 容器里安装 PDO 扩展
echo "往 $project_name_$prod_site_name 的php容器里安装 PDO扩展..."
docker cp common/install_pdo_in_container.sh ${project_name}_${prod_site_name}_php:/var/$project_name/$prod_site_name/. # 将 pdo 安装脚本文件由属主机拷入 php 容器里的/var/homework_test 目录下
docker exec -i ${project_name}_${prod_site_name}_php bash /var/$project_name/$prod_site_name/install_pdo_in_container.sh # 在 php 容器里运行 pdo 脚本，安装 mysq 的 pdo 驱动
docker restart ${project_name}_${prod_site_name}_php # 重启 php 容器里的 php 服务
echo "往php容器里安装 PDO扩展结束！"
