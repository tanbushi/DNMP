# DNMP
Docker Nginx Mariadb Php


#1、生产环境&测试环境的规划和部署
##1.1、说明
![系统部署示意图](https://upload-images.jianshu.io/upload_images/11433144-88dbca6291a04589.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

**1）项目**
此处以一个演示项目的形式来进行环境的规划和部署。此项目名称默认定义为：“demo”，且主要功能为前端应用提供 API 接口服务，项目下面包含两个站点：一个测试站点和一个生产站点；主要特点如下：
- 项目支持 http 和 https 访问
- 默认按最简配置傻瓜式安装、卸载，安装、卸载简单
- 可根据需要添加配置参数，扩展灵活
- 脚本化执行，在 shell 里运行脚本即可实现自动化的安装和卸载

**2）站点：**
站点一般由 nginx + php + mariadb 组成， nginx 提供路由访问服务， php 程序提供业务处理能力， mariadb 提供 mysql 数据库服务。此项目有两个站点：测试站点和生产站点，生产站点作为正式发布的版本，测试站点提供开发过程中的功能测试。测试站点的默认名称为：“test”，域名为： myapitest.xxxxxx.com ；生产站点的默认名称为：“prod”，域名为： myapi.xxxxxx.com ；由于本示例中生产环境和测试环境架设在同一台服务器上，所以采用一个 nginx 为两个站点提供访问服务。
**3）服务**
此项目中使用到的： nginx 、 php 、 mariadb 等，就是服务，包括一个 nginx 、两个 php 、两个 mariadb ；
**4） ssl 证书**
此演示项目是在腾讯云服务器上安装，里面用到的 ssl 证书是从腾讯云申请的，具体申请流程请看腾讯云的相关说明文档，包含两个文件，具体文件名格式为： 1_myapitest.xxxxxx.com_bundle.crt 和 2_myapitest.xxxxxx.com.key ，其中 myapitest.xxxxxx.com 为申请时使用的域名，此处为非真实的域名，请读者使用自己的域名。如果是其他云，也可以从对应的云服务器里找到相关证书申请的讯息，当然还可以从第三方直接申请免费证书，具体就请在网上搜索吧。
##1.2、演示项目安装完成后的结果
为了使大家对安装后的环境有个宏观的了解，也便于讲解，所以从结果倒着看，先看看安装完成后的情况，了解一下即可，文章最后会给出相关安装的脚本及配置文件。此处约定的参数为：

- 项目名称：project_name -->> demo
- 测试站点名称：test_site_name -->> test
- 生产站点名称：prod_site_name -->> prod

###1.2.1、安装完成后的主机挂载目录的结构
![主机挂载目录结构](https://upload-images.jianshu.io/upload_images/11433144-f52baf030751145b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
在使用脚本进行安装时，脚本会先建立相关目录以及对应的文件。
###1.2.2、安装用到的关键配置文件
**1）docker-compose.yml**
```
version: "3.5"

services:
    demo_test_mariadb:
        container_name: demo_test_mariadb
        image: mariadb:10.3
        restart: always
        privileged: true
        ports:
            - 13306:3306
        volumes:
            - $ROOT_DIR/demo/test/data/mariadb:/var/lib/mysql
        environment:
            MYSQL_ROOT_PASSWORD: 123456
            MYSQL_DATABASE: demo_test_db
            MYSQL_USER: demo_test_user
            MYSQL_PASSWORD: 654321
        command: [
            '--character-set-server=utf8mb4',
            '--collation-server=utf8mb4_unicode_ci'
        ]
        networks:
            - demo_test_network

    demo_test_php:
        container_name: demo_test_php
        image: php:7.2.3-fpm
        privileged: true
        restart: always
        networks:
            - demo_test_network
        volumes:
            - $ROOT_DIR/demo/test/www:/var/demo/test/www
        environment:
            - TZ=Asia/Shanghai
        links:
            - demo_test_mariadb




    demo_prod_mariadb:
        container_name: demo_prod_mariadb
        image: mariadb:10.3
        restart: always
        privileged: true
        ports:
            - 23306:3306
        volumes:
            - $ROOT_DIR/demo/prod/data/mariadb:/var/lib/mysql
        environment:
            MYSQL_ROOT_PASSWORD: 123456
            MYSQL_DATABASE: demo_prod_db
            MYSQL_USER: demo_prod_user
            MYSQL_PASSWORD: 654321
        command: [
            '--character-set-server=utf8mb4',
            '--collation-server=utf8mb4_unicode_ci'
        ]
        networks:
            - demo_prod_network

    demo_prod_php:
        container_name: demo_prod_php
        image: php:7.2.3-fpm
        privileged: true
        restart: always
        networks:
            - demo_prod_network
        volumes:
            - $ROOT_DIR/demo/prod/www:/var/demo/prod/www
        environment:
            - TZ=Asia/Shanghai
        links:
            - demo_prod_mariadb




    demo_nginx:
        container_name: demo_nginx
        image: nginx:1.13
        privileged: true
        restart: always
        networks:
            - demo_test_network
            - demo_prod_network
        ports:
            - 80:80
            - 443:443
        volumes:
            - $ROOT_DIR/demo/test/www:/var/demo/test/www
            - $ROOT_DIR/demo/prod/www:/var/demo/prod/www
            - $ROOT_DIR/demo/nginx/conf.d:/etc/nginx/conf.d
            - $ROOT_DIR/demo/nginx/ssl:/etc/nginx/ssl
        environment:
            - TZ=Asia/Shanghai
        links:
            - demo_test_php
            - demo_prod_php




networks:
    demo_test_network:
        name: demo_test_network
    demo_prod_network:
        name: demo_prod_network

```
docker-compose.yml 文件说明：
- 版本
```
version: "3.5"
```
版本选的是3.5，主要是考虑用来支持网卡命名特性，见docker-compose.yml 文件的末尾部分，networks的定义：
```
networks:
    demo_test_network:
        name: demo_test_network
    demo_prod_network:
        name: demo_prod_network
```
- docker服务、相关参数、网卡命名规范
以服务mariadb的命名为例：demo_test_mariadb，将项目名称为demo、站点名称为test、服务为mariadb的三个名字用下划线“_”连接起来，就可以保证主机上服务命名的唯一性，主机上的多个服务不会有重复命名的情况出现，demo_test_mariadb 可以这样理解：demo项目的test测试站点的mariadb服务；
同理还有类似的命名有：demo_prod_php（php服务）、demo_test_db（mariadb数据库）、demo_prod_network（demo项目中生产站点的网卡）
由于demo项目里的nginx服务同时为生产环境和测试环境提供服务，所以其命名为：demo_nginx（demo项目的nginx服务）
- docker目录规范
/dockers/demo/test/www --- 表示 demo项目中测试站点的网页目录
/dockers/demo/prod/data --- 表示 demo项目中生产站点的数据目录
/dockers/demo/nginx/ssl --- 表示 demo项目中 nginx 服务的 ssl 证书目录
- 环境变量 ROOT_DIR
环境变量 ROOT_DIR 为此脚本作用范围内的环境变量，用来指定项目目录的上一级目录，该环境变量在 install.sh 里定义。
**2）/dockers/demo/nginx/conf.d/default.conf**
```
server {
    listen       80;
    listen       443 ssl;
    server_name  myapitest.xxxxxx.com;

    #ssl on;
    ssl_certificate       /etc/nginx/ssl/1_myapitest.xxxxxx.com_bundle.crt;
    ssl_certificate_key   /etc/nginx/ssl/2_myapitest.xxxxxx.com.key;

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2; #按照这个协议配置
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:HIGH:!aNULL:!MD5:!RC4:!DHE;#按照这个套件配置
    ssl_prefer_server_ciphers on;

    location / {
        root   /var/demo/test/www;
        index  index.html index.htm index.php;
    }
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
    location ~ \.php$ {
        fastcgi_pass   demo_test_php:9000;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME /var/demo/test/www$fastcgi_script_name;
        include        fastcgi_params;
    }
}

server {
    listen       80;
    listen       443 ssl;
    server_name  myapi.xxxxxx.com;
	
    #ssl on;
    ssl_certificate       /etc/nginx/ssl/1_myapi.xxxxxx.com_bundle.crt;
    ssl_certificate_key   /etc/nginx/ssl/2_myapi.xxxxxx.com.key;

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2; #按照这个协议配置
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:HIGH:!aNULL:!MD5:!RC4:!DHE;#按照这个套件配置
    ssl_prefer_server_ciphers on;

    location / {
        root   /var/demo/prod/www;
        index  index.html index.htm index.php;
    }
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
    location ~ \.php$ {
        fastcgi_pass   demo_prod_php:9000;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME /var/demo/prod/www$fastcgi_script_name;
        include        fastcgi_params;
    }
}

```
安装demo项目的基本流程为：
- 第一步：将相关文件拷贝到主机挂载目录（包括docker-compose.yml 和 default.conf）
- 第二步：配置好 docker-compose.yml
- 第三步：配置好 default.conf
- 第四步：运行 docker-compose up -d 安装
- 第五步：安装PDO驱动等
#2、脚本化安装
##2.1、安装文件目录结构
![项目目录结构](https://upload-images.jianshu.io/upload_images/11433144-25476935be3533b0.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
从上图可以看出，安装文件的目录结构还是很简单的，其中模版目录下除了default.conf.tpl、docker-compose.yml.tpl比较重要和相对复杂以外，其他模版文件都很简单，可有可无，不关键，只是为了配合测试。
##2.2、自定义变量说明
此项目为了简化文件生成，在模版文件中使用了自定义变量，自定义变量的书写形式为：{{自定义变量_xxxx}}，可以在脚本中根据变量的配置值，对模版文件的自定义变量区域进行动态替换。例如：我们在config.sh文件中定义了变量“project_name”，“test_site_name”
```
 ["project_name"]="demo"                # 项目名称
 ["test_site_name"]="test"              # 测试站点名称
```
同时，我们在docker-compose.yml.tpl中使用了自定义变量域{{project_name}}、{{test_site_name}}
```
version: "3.5"

services:
    {{project_name}}_{{test_site_name}}_mariadb:

```
运行脚本后，生成的配置文件的自定义变量域会被替换，比如上面的模版对应的配置文件会变成：
```
version: "3.5"

services:
    demo_test_mariadb:

```
需要说明的是：在本配置中，自定义变量实现了“即加即用”，且用户可以根据需要定义，在congfig.sh文件里定义一个变量，在模版文件里加上对应的自定义变量域，不用修改其他代码，就能自动进行替换。
##2.3、关键文件说明
###2.3.1、config.sh
```
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

```
配置文件里定义了一个map来存储相关配置参数，用户可以根据需要进行修改、增加、删除配置。
###2.3.2、tpl/docker-compose.yml.tpl
```
version: "3.5"

services:
    {{project_name}}_{{test_site_name}}_mariadb:
        container_name: {{project_name}}_{{test_site_name}}_mariadb
        image: {{mariadb_image}}
        restart: always
        privileged: true
        ports:
            - {{mysql_mapped_port_test}}:3306
        volumes:
            - $ROOT_DIR/{{project_name}}/{{test_site_name}}/data/mariadb:/var/lib/mysql
        environment:
            MYSQL_ROOT_PASSWORD: {{mysql_root_password_test}}
            MYSQL_DATABASE: {{project_name}}_{{test_site_name}}_db
            MYSQL_USER: {{project_name}}_{{test_site_name}}_user
            MYSQL_PASSWORD: {{mysql_password_test}}
        command: [
            '--character-set-server=utf8mb4',
            '--collation-server=utf8mb4_unicode_ci'
        ]
        networks:
            - {{project_name}}_{{test_site_name}}_network

    {{project_name}}_{{test_site_name}}_php:
        container_name: {{project_name}}_{{test_site_name}}_php
        image: {{php_image}}
        privileged: true
        restart: always
        networks:
            - {{project_name}}_{{test_site_name}}_network
        volumes:
            - $ROOT_DIR/{{project_name}}/{{test_site_name}}/www:/var/{{project_name}}/{{test_site_name}}/www
        environment:
            - TZ=Asia/Shanghai
        links:
            - {{project_name}}_{{test_site_name}}_mariadb




    {{project_name}}_{{prod_site_name}}_mariadb:
        container_name: {{project_name}}_{{prod_site_name}}_mariadb
        image: {{mariadb_image}}
        restart: always
        privileged: true
        ports:
            - {{mysql_mapped_port_prod}}:3306
        volumes:
            - $ROOT_DIR/{{project_name}}/{{prod_site_name}}/data/mariadb:/var/lib/mysql
        environment:
            MYSQL_ROOT_PASSWORD: {{mysql_root_password_prod}}
            MYSQL_DATABASE: {{project_name}}_{{prod_site_name}}_db
            MYSQL_USER: {{project_name}}_{{prod_site_name}}_user
            MYSQL_PASSWORD: {{mysql_password_prod}}
        command: [
            '--character-set-server=utf8mb4',
            '--collation-server=utf8mb4_unicode_ci'
        ]
        networks:
            - {{project_name}}_{{prod_site_name}}_network

    {{project_name}}_{{prod_site_name}}_php:
        container_name: {{project_name}}_{{prod_site_name}}_php
        image: {{php_image}}
        privileged: true
        restart: always
        networks:
            - {{project_name}}_{{prod_site_name}}_network
        volumes:
            - $ROOT_DIR/{{project_name}}/{{prod_site_name}}/www:/var/{{project_name}}/{{prod_site_name}}/www
        environment:
            - TZ=Asia/Shanghai
        links:
            - {{project_name}}_{{prod_site_name}}_mariadb




    {{project_name}}_nginx:
        container_name: {{project_name}}_nginx
        image: {{nginx_image}}
        privileged: true
        restart: always
        networks:
            - {{project_name}}_{{test_site_name}}_network
            - {{project_name}}_{{prod_site_name}}_network
        ports:
            - 80:80
            - 443:443
        volumes:
            - $ROOT_DIR/{{project_name}}/{{test_site_name}}/www:/var/{{project_name}}/{{test_site_name}}/www
            - $ROOT_DIR/{{project_name}}/{{prod_site_name}}/www:/var/{{project_name}}/{{prod_site_name}}/www
            - $ROOT_DIR/{{project_name}}/nginx/conf.d:/etc/nginx/conf.d
            - $ROOT_DIR/{{project_name}}/nginx/ssl:/etc/nginx/ssl
        environment:
            - TZ=Asia/Shanghai
        links:
            - {{project_name}}_{{test_site_name}}_php
            - {{project_name}}_{{prod_site_name}}_php




networks:
    {{project_name}}_{{test_site_name}}_network:
        name: {{project_name}}_{{test_site_name}}_network
    {{project_name}}_{{prod_site_name}}_network:
        name: {{project_name}}_{{prod_site_name}}_network

```
###2.3.3、tpl/default.conf.tpl
```
server {
    listen       80;
    listen       443 ssl;
    server_name  {{dns_test}};

    #ssl on;
    ssl_certificate       /etc/nginx/ssl/{{ssl_certificate_test}};
    ssl_certificate_key   /etc/nginx/ssl/{{ssl_certificate_key_test}};

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2; #按照这个协议配置
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:HIGH:!aNULL:!MD5:!RC4:!DHE;#按照这个套件配置
    ssl_prefer_server_ciphers on;

    location / {
        root   /var/{{project_name}}/{{test_site_name}}/www;
        index  index.html index.htm index.php;
    }
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
    location ~ \.php$ {
        fastcgi_pass   {{project_name}}_{{test_site_name}}_php:9000;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME /var/{{project_name}}/{{test_site_name}}/www$fastcgi_script_name;
        include        fastcgi_params;
    }
}

server {
    listen       80;
    listen       443 ssl;
    server_name  {{dns_prod}};
	
    #ssl on;
    ssl_certificate       /etc/nginx/ssl/{{ssl_certificate_prod}};
    ssl_certificate_key   /etc/nginx/ssl/{{ssl_certificate_key_prod}};

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2; #按照这个协议配置
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:HIGH:!aNULL:!MD5:!RC4:!DHE;#按照这个套件配置
    ssl_prefer_server_ciphers on;

    location / {
        root   /var/{{project_name}}/{{prod_site_name}}/www;
        index  index.html index.htm index.php;
    }
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
    location ~ \.php$ {
        fastcgi_pass   {{project_name}}_{{prod_site_name}}_php:9000;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME /var/{{project_name}}/{{prod_site_name}}/www$fastcgi_script_name;
        include        fastcgi_params;
    }
}

```
###2.3.4、install.sh
```
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

```
###2.3.5、uninstall.sh
```
#!/bin/bash

export ROOT_DIR="/dockers"    # 项目发布目录的上一级目录

. config.sh      # 引入配置文件脚本
. common/create_yml.sh  # 引入创建 docker-compose.yml 文件的脚本

# 卸载 docker
docker-compose down

```
###2.3.6、common/create_yml.sh
```
#!/bin/bash

# 从安装模版目录里拷贝 docker 编排文件模板到挂载目录下
cp -f tpl/docker-compose.yml.tpl docker-compose.yml

# 根据 docker 编排模版自动生成 docker 编排文件
for key in ${!config[@]}
do
  echo $key
  sed -i "s/{{$key}}/${config[$key]}/g" docker-compose.yml
done

```
###2.3.7、common/install_pdo_in_container.sh
```
#!/bin/bash

# 以下操作是进入 php 的 docker 容器里执行的
cd /usr/local/bin
./docker-php-ext-install pdo_mysql
./docker-php-ext-install mysql
exit

```
###2.3.8、其他几个测试网页模板文件
**1）tpl/index_1.html.tpl**
```
{{dns_test}}/index.html
```
**2）tpl/index_1.php.tpl**
```
<?php
  echo "{{dns_test}}/index.php";
?>
```
**3）tpl/testdb_1.php.tpl**
```
<?php
$PDO = new PDO('mysql:host={{project_name}}_{{test_site_name}}_mariadb;dbname=mysql', 'root', '{{mysql_root_password_test}}');
var_dump($PDO);
$stmt=$PDO->prepare('select count(*) as userCount from user');
$stmt->execute();
echo '<br>';
echo 'rowCount='.$stmt->rowCount().'<br>';
while ($row=$stmt->fetch(PDO::FETCH_ASSOC)) {
      echo 'userCount='.$row['userCount'].'<br>';
}
?>
```
**4）tpl/index_2.html.tpl**
```
{{dns_prod}}/index.html
```
**5）tpl/index_2.php.tpl**
```
<?php
  echo "{{dns_prod}}/index.php";
?>
```
**6）tpl/testdb_2.php.tpl**
```
<?php
$PDO = new PDO('mysql:host={{project_name}}_{{prod_site_name}}_mariadb;dbname=mysql', 'root', '{{mysql_root_password_prod}}');
var_dump($PDO);
$stmt=$PDO->prepare('select count(*) as userCount from user');
$stmt->execute();
echo '<br>';
echo 'rowCount='.$stmt->rowCount().'<br>';
while ($row=$stmt->fetch(PDO::FETCH_ASSOC)) {
      echo 'userCount='.$row['userCount'].'<br>';
}
?>
```
##2.4、运行安装脚本
为了便于说明，我按照我的安装目录结构来进行安装，您可以根据自己的喜好来选择。安装目录为：/dockers/demo_install，该目录下包含的文件如下图：
![安装目录下的文件结构](https://upload-images.jianshu.io/upload_images/11433144-dba3037b4c7de1df.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
在 shell 里运行命令，检查 dockers 安装情况
```
[root@VM_16_17_centos demo_install]# docker ps
```
发现我的电脑里目前没有 docker 容器在运行
![docker列表](https://upload-images.jianshu.io/upload_images/11433144-a8427a24e411b696.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
运行 install.sh
```
[root@VM_16_17_centos demo_install]# ./install.sh
```
如果不出意外，会自动完成安装！安装结果如下图：
![安装完成后 docker 列表](https://upload-images.jianshu.io/upload_images/11433144-91da3e52b67c3401.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
##2.5、浏览器访问测试

利用浏览器访问网址：
- http://myapitest.xxxxxx.com/index.html
- http://myapitest.xxxxxx.com/index.php
- http://myapitest.xxxxxx.com/testdb.php
- http://myapi.xxxxxx.com/index.html
- http://myapi.xxxxxx.com/index.php
- http://myapi.xxxxxx.com/testdb.php
- https://myapitest.xxxxxx.com/index.html
- https://myapitest.xxxxxx.com/index.php
- https://myapitest.xxxxxx.com/testdb.php
- https://myapi.xxxxxx.com/index.html
- https://myapi.xxxxxx.com/index.php
- https://myapi.xxxxxx.com/testdb.php
经测试都能成功访问，选其中有代表性的访问实例截图如下：
![浏览器访问站点实例](https://upload-images.jianshu.io/upload_images/11433144-b66bea3cb0f520e6.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

同理可以测试卸载：
```
[root@VM_16_17_centos demo_install]# ./uninstall.sh
```

以上脚本安装、卸载测试成功。请参考！

至此，已经完全实现了Docker在一台服务器上搭建支持80、443端口访问的测试、生产双站点系统。下面的工作就是利用git给两个网站进行代码开发和部署工作了！

本实例代码以上传到 github ，敬请下载试用、参考。地址为：
https://github.com/tanbushi/DNMP

***
上一篇：[Docker搭建LNMP环境实战（九）：安装mariadb](https://www.jianshu.com/p/12cdf9a9c454)
下一篇：完结
所属文集：[Docker搭建LNMP环境实战](https://www.jianshu.com/nb/33625279)
***
