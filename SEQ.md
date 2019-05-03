# 計測

## pstree

### インストール
```
sudo yum install -y psmisc
```

### 実行
```
pstree
```

## netdata

### インストール
```
sudo yum install -y zlib-devel libuuid-devel libmnl-devel gcc make git autoconf autogen automake pkgconfig
git clone https://github.com/firehol/netdata.git --depth=1
cd netdata
sudo ./netdata-installer.sh
```

### ポート開放・起動
```
sudo firewall-cmd --zone=public --add-port=19999/tcp --permanent
sudo firewall-cmd --reload
sudo firewall-cmd --list-all
→  ports: 19999/tcp を確認
sudo systemctl start netdata
```

### 計測
```
http://192.168.33.10:19999/ にアクセス
cd ~/torb/bench
./bin/bench -remotes=127.0.0.1 -output result.json
```

## Nginx

### h2o の停止
```
sudo systemctl stop h2o
```

### Nginx のインストール
```
sudo vi /etc/yum.repos.d/nginx.repo
cat /etc/yum.repos.d/nginx.repo
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/mainline/centos/7/$basearch/
gpgcheck=0
enabled=1
```
```
sudo yum install -y nginx
sudo systemctl start nginx
http://192.168.33.10/ にアクセス
```
```
sudo mv /etc/nginx/conf.d/default.conf /tmp/default.conf
sudo vi  /etc/nginx/nginx.conf
cat  /etc/nginx/nginx.conf

user isucon;
worker_processes  1;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;


events {
    worker_connections  1024;
}


http {

    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    keepalive_timeout  65;

    #gzip  on;

    #include /etc/nginx/conf.d/*.conf;


    server {

        listen 80;
        server_name localhost;


        location ~ ^/(img|css|js|favicon.ico) {
            root /home/isucon/torb/webapp/static;
            expires 1h;
        }

        location / {
            proxy_set_header Host $host;
            proxy_pass http://127.0.0.1:8080/;
        }
    }
}

sudo setsebool httpd_can_network_connect on -P
sudo systemctl restart nginx
```

## MariaDB

### my.cnf
```
sudo vi /etc/my.cnf
sudo cat /etc/my.cnf
[mysqld]
slow_query_log = 1
slow_query_log_file = /var/log/mariadb/slow.log
long_query_time = 0
```
###
```
sudo yum install -y https://www.percona.com/downloads/percona-toolkit/2.2.17/RPM/percona-toolkit-2.2.17-1.noarch.rpm
```
```
sudo ls /var/log/mariadb/slow.log
sudo pt-query-digest --limit 5 /var/log/mariadb/slow.log > ~/torb/webapp/go/result.txt
```