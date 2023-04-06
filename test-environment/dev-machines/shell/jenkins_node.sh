#!/bin/bash

### 安裝 jenkins
apt-get update
apt-get install openjdk-8-jdk -y
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
apt-get update
apt-get install jenkins -y

### 安裝 jq && yq

sudo snap install yq  ## 用這個執行會比較好

apt install jq -y
VERSION=v4.17.2
BINARY=yq_linux_amd64
wget https://github.com/mikefarah/yq/releases/download/${VERSION}/${BINARY}.tar.gz -O - |  tar xz && sudo mv ${BINARY} /usr/bin/yq
yq

### 安裝 net 5.0 && 6.0
wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
apt-get update;   apt-get install -y apt-transport-https &&   apt-get update &&   apt-get install -y dotnet-sdk-6.0
sudo apt install dotnet-sdk-5.0 -y
dotnet --list-sdks

### 安裝 docker ###

sudo apt-get install ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg 

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io -y

cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "1g"
  },
  "storage-driver": "overlay2",
  "features": { "buildkit": true },
  "registry-mirrors": ["https://ustc-edu-cn.mirror.aliyuncs.com"]
}
EOF


## https://www.digitalocean.com/community/questions/how-to-fix-docker-got-permission-denied-while-trying-to-connect-to-the-docker-daemon-socket

sudo groupadd docker
sudo usermod -aG docker $USER
sudo usermod -aG docker jenkins
sudo chmod 777 /var/run/docker.sock

systemctl daemon-reload && systemctl restart docker

### install kubectl
apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl


### 安裝 helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh


### 安裝 aws cli

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
apt install unzip
unzip awscliv2.zip
sudo ./aws/install

apt install awscli
aws configure

AccessKeyId=$1
SecretAccessKey=$2
Region=ap-east-1


#####

echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p



### Restore
aws s3 cp s3://tgs-dev-backup/jenkins/jenkins-backup.2022-06-08.tar.gz jenkins.tar.gz
sudo tar zxvf ./jenkins.tar.gz -C /var/lib/jenkins

service jenkins restart


### Configure
mkdir /var/lib/jenkins/.nuget
mkdir /var/lib/jenkins/.nuget/NuGet
cat <<EOF | sudo tee /var/lib/jenkins/.nuget/NuGet/NuGet.Config
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <packageSources>
	<add key="nuget.org" value="https://api.nuget.org/v3/index.json" protocolVersion="3" />
	<add key="raypro" value="https://gitlab.com/api/v4/projects/20478010/packages/nuget/index.json" />
  </packageSources>
  <packageRestore>
	<add key="enabled" value="True" />
	<add key="automatic" value="True" />
  </packageRestore>
  <bindingRedirects>
	<add key="skip" value="False" />
  </bindingRedirects>
  <packageManagement>
	<add key="format" value="0" />
	<add key="disabled" value="False" />
  </packageManagement>
  <packageSourceCredentials>
	<raypro>
	  <add key="Username" value="gitlab-nuget" />
	  <add key="ClearTextPassword" value="iE1wyEx9zDqmQAZcXELT" />
	</raypro>
  </packageSourceCredentials>
</configuration>
EOF

mkdir /var/lib/jenkins/.docker
cat <<EOF | sudo tee /var/lib/jenkins/.docker/config.json
{
        "auths": {
                "cr.yggdrasill.dev": {
                        "auth": "dGdzOjNVcGY1ZjZWTUlVQ2NmdVI="
                },
                "harbor.rpgp.cc": {
                        "auth": "amVua2luczpUZ3NQQHNzdzByZA=="
                },
                "registry.gitlab.com": {
                        "auth": "bGVzdGVyLndlaUByYXlwcm9zb2Z0LmNvbToxcTJ3M2U0cg=="
                }
        }
}
EOF

systemctl daemon-reload && systemctl restart docker
