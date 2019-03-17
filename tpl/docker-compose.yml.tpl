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
