## REF:
https://github.com/justmeandopensource/kubernetes/blob/master/kubeadm-external-etcd/2%20simple-cluster-tls.md
https://www.youtube.com/watch?v=gYNEUC9paW8


## 準備cfssl 生成工具
```
{
wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
wget https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64

chmod +x cfssl_linux-amd64 cfssljson_linux-amd64 cfssl-certinfo_linux-amd64

mv cfssl_linux-amd64 /usr/local/bin/cfssl
mv cfssljson_linux-amd64 /usr/local/bin/cfssljson
mv cfssl-certinfo_linux-amd64 /usr/local/bin/cfssl-certinfo
}
```

## 自簽CA
```
cat > ca-config.json << EOF
{
    "signing": {
        "default": {
          "expiry": "87600h"
        },
        "profiles": {
            "etcd": {
                "expiry": "87600h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "server auth",
                    "client auth"
                ]
            }
        }
    }
}
EOF
```
```
cat > ca-csr.json << EOF
{
    "CN": "etcd CA",
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names":[
        {
            "C": "CN",
            "L": "Beijing",
            "O": "Kubernetes",
            "OU": "ETCD-CA",
            "ST": "Beijing"
        }
    ]
}
EOF
```


## 生成證書
```
cfssl gencert -initca ca-csr.json | cfssljson -bare ca -
```

## 使用自簽CA簽發ETCD HTTPS證書建立證書申請文件
```
cat > etcd-csr.json << EOF
{
    "CN": "etcd",
    "hosts":[
        "localhost",
        "127.0.0.1",
        "192.168.50.71",
        "192.168.50.72",
        "192.168.50.73"
    ],
    "key":{
        "algo": "rsa",
        "size": 2048
    },
    "names":[
        {
            "C": "CN",
            "L": "Beijing",
            "O": "Kubernetes",
            "OU": "etcd",
            "ST": "Beijing"
        }
    ]
}
EOF
```
## 生成證書 etcd.etcd-key.pem
```
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=etcd etcd-csr.json | cfssljson -bare etcd
```
## Copy the certificates to a standard location
```
{
  mkdir -p /etc/etcd/pki
  mv ca.pem etcd.pem etcd-key.pem /etc/etcd/pki/ 
}
```
## 複製憑證到其他兩台
```
scp /etc/etcd/pki/{ca.pem,etcd.pem,etcd-key.pem} root@192.168.50.72:/etc/etcd/pki/
scp /etc/etcd/pki/{ca.pem,etcd.pem,etcd-key.pem} root@192.168.50.73:/etc/etcd/pki/
```
## Download etcd & etcdctl binaries from Github
```
{
  ETCD_VER=v3.5.1
  wget -q --show-progress "https://github.com/etcd-io/etcd/releases/download/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz"
  tar zxf etcd-v3.5.1-linux-amd64.tar.gz
  mv etcd-v3.5.1-linux-amd64/etcd* /usr/local/bin/
  rm -rf etcd*
}
```
## Create systemd unit file for etcd service
```
{

NODE_IP="192.168.50.73"

ETCD_NAME=$(hostname -s)

ETCD1_IP="192.168.50.71"
ETCD2_IP="192.168.50.72"
ETCD3_IP="192.168.50.73"


cat <<EOF >/etc/systemd/system/etcd.service
[Unit]
Description=etcd

[Service]
Type=notify
ExecStart=/usr/local/bin/etcd \\
  --name ${ETCD_NAME} \\
  --cert-file=/etc/etcd/pki/etcd.pem \\
  --key-file=/etc/etcd/pki/etcd-key.pem \\
  --peer-cert-file=/etc/etcd/pki/etcd.pem \\
  --peer-key-file=/etc/etcd/pki/etcd-key.pem \\
  --trusted-ca-file=/etc/etcd/pki/ca.pem \\
  --peer-trusted-ca-file=/etc/etcd/pki/ca.pem \\
  --peer-client-cert-auth \\
  --client-cert-auth \\
  --initial-advertise-peer-urls https://${NODE_IP}:2380 \\
  --listen-peer-urls https://${NODE_IP}:2380 \\
  --advertise-client-urls https://${NODE_IP}:2379 \\
  --listen-client-urls https://${NODE_IP}:2379,https://127.0.0.1:2379 \\
  --initial-cluster-token etcd-cluster-1 \\
  --initial-cluster etcd1=https://${ETCD1_IP}:2380,etcd2=https://${ETCD2_IP}:2380,etcd3=https://${ETCD3_IP}:2380 \\
  --initial-cluster-state new
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

}
```
## Enable and Start etcd service
```
{
systemctl daemon-reload
systemctl enable --now etcd
}
```

## Verify Etcd cluster status
```
ETCDCTL_API=3 etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/pki/ca.pem \
  --cert=/etc/etcd/pki/etcd.pem \
  --key=/etc/etcd/pki/etcd-key.pem \
  member list
```
  
## Better to export these as environment variables and connect to the clutser instead of a specific node
```
export ETCDCTL_API=3 
export ETCDCTL_ENDPOINTS=https://192.168.50.71:2379,https://192.168.50.72:2379,https://192.168.50.73:2379
export ETCDCTL_CACERT=/etc/etcd/pki/ca.pem
export ETCDCTL_CERT=/etc/etcd/pki/etcd.pem
export ETCDCTL_KEY=/etc/etcd/pki/etcd-key.pem
```
## And now its a lot easier
```
etcdctl member list
etcdctl endpoint status
etcdctl endpoint health
```
