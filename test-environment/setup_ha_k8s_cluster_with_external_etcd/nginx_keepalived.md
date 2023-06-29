# install nginx & keepalived
https://github.com/justmeandopensource/kubernetes/tree/master/kubeadm-ha-keepalived-haproxy/external-keepalived-haproxy
https://hackmd.io/Uzsn4igDT3ixI5kYri8CdQ

## install nginx 
```
apt update && apt install -y nginx
```
## configure nginx.conf
```
{
cat <<EOF | sudo tee /etc/nginx/nginx.conf
user www-data;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
        worker_connections 1024;
}

stream {
    log_format main '$remote_addr $upstream_addr - [$time_local] $status $upstream_bytes_sent';
    access_log /var/log/nginx/k8s-access.log main;

    upstream k8s-apiserver {
        server 192.168.50.61:6443; #master1 apiserver ip:port
        server 192.168.50.62:6443; #master2 apiserver ip:port
        server 192.168.50.63:6443; #master3 apiserver ip:port
    }

    server {
        listen 6443;
        proxy_pass k8s-apiserver;
    }
}

http {
        log_format main '$remote_addr - $remote_user [$time_local] "$request"'
            '$status $body_bytes_sent "$http_referer"'
            '"$http_user_agent" "$http_x_forward_for"'

        sendfile on;
        tcp_nopush on;
        tcp_nodelay on;
        keepalive_timeout 65;
        types_hash_max_size 2048;

        include /etc/nginx/mime.types;
        default_type application/octet-stream;

        ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3; # Dropping SSLv3, ref: POODLE
        ssl_prefer_server_ciphers on;

        access_log /var/log/nginx/access.log;
        error_log /var/log/nginx/error.log;

        gzip on;

        include /etc/nginx/conf.d/*.conf;
        include /etc/nginx/sites-enabled/*;
}

EOF
nginx -s reload
}
```

## install keepalived
https://www.chakray.com/nginx-high-availability-through-keepalived-virtual-ip/
```
apt install -y keepalived
```
## Create keepalived config /etc/keepalived/keepalived.conf
```
{
cat <<EOF | sudo tee /etc/keepalived/keepalived.conf
global_defs {
    router_id  NGINX_MASTER
}

vrrp_script check_nginx {
    script"/etc/keepalived/check_nginx.sh"
}

vrrp_instance VI_1 {
    state MASTER
    interface ens160
    virtual_router_id 51
    priority 100
    advert_int 1
    accept
    garp_master_refresh        5
    garp_master_refresh_repeat 1
    unicast_src_ip 192.168.50.63
    unicast_peer {
        192.168.50.62
        192.168.50.61
    }
    
    virtual_ipaddress {
        192.168.50.88/24
    }
    
    track_script {
        check_nginx
    }
}
EOF
}
```
```
{
cat <<EOF | sudo tee /etc/keepalived/check_nginx.sh
#!/bin/bash
count=$(ss -antp | grep 6443 | egrep -cv "grep|$$")

if [ "$count" -eq 0 ];then
    exit 1
else
    exit 0
fi
EOF
chmod +x  /etc/keepalived/check_nginx.sh
}
```
## Enable & start keepalived service
```
systemctl enable --now keepalived
```
## 可以修改 /var/www/html/index.nginx-debian.html
確認 http://192.168.50.88 是來自哪一台機器
