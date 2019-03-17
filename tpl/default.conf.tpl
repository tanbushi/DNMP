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


