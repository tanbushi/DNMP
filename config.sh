#!/bin/bash

declare -A config=(
  ["project_name"]="demo"                # 项目名称
  ["mariadb_image"]="mariadb:10.3"       # mariadb 镜像名和版本
  ["php_image"]="php:7.2.3-fpm"          # php 镜像名和版本
  ["nginx_image"]="nginx:1.13"           # nginx 镜像名和版本
  
  ["test_site_name"]="test"              # 测试站点名称
  ["mysql_root_password_test"]="123456"  # 测试站点数据库root密码
  ["mysql_password_test"]="654321"       # 测试站点数据库用户密码，用户名会自动生成
  ["mysql_mapped_port_test"]=13306       # 测试站点数据库管理端口映射，便于客户端管理
  ["dns_test"]="myapitest.xxxxxx.com"     # 测试站点域名
  # 测试站点 ssl 证书文件名配置
  ["ssl_certificate_test"]="1_myapitest.xxxxxx.com_bundle.crt"
  ["ssl_certificate_key_test"]="2_myapitest.xxxxxx.com.key"
  
  ["prod_site_name"]="prod"              # 生产站点名称
  ["mysql_root_password_prod"]="123456"  # 生产站点数据库root密码
  ["mysql_password_prod"]="654321"       # 生产站点数据库用户密码，用户名会自动生成
  ["mysql_mapped_port_prod"]=23306       # 生产站点数据库管理端口映射，便于客户端管理
  ["dns_prod"]="myapi.xxxxxx.com"         # 生产站点域名
  # 生产站点 ssl 证书文件名配置
  ["ssl_certificate_prod"]="1_myapi.xxxxxx.com_bundle.crt"
  ["ssl_certificate_key_prod"]="2_myapi.xxxxxx.com.key"
)
